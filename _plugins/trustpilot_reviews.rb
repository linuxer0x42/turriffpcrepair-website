# frozen_string_literal: true

# Build-time loader for Trustpilot reviews.
#
# Fetches the business unit score and latest reviews from the Trustpilot
# Business API and exposes them as site.data["trustpilot"], which
# _includes/reviews.html renders. Running at build time keeps the API key out
# of the generated HTML - never call the API from the browser on a static site.
#
# Credentials: trustpilot.business_unit_id and trustpilot.api_key in
# _config.yml. On CI, set TRUSTPILOT_API_KEY instead so the secret never has to
# be committed; the environment variable wins when both are present.
#
# Responses are cached in .jekyll-cache for trustpilot.cache_minutes, and a
# failed fetch falls back to the cached copy when one exists.

require "json"
require "net/http"
require "uri"
require "time"
require "fileutils"

module TrustpilotReviews
  API_HOST = "api.trustpilot.com"

  class Generator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      conf = site.config["trustpilot"]
      return unless conf.is_a?(Hash) && conf["enabled"]

      unit = conf["business_unit_id"].to_s.strip
      key  = ENV["TRUSTPILOT_API_KEY"].to_s.strip
      key  = conf["api_key"].to_s.strip if key.empty?

      if unit.empty? || key.empty?
        Jekyll.logger.warn "Trustpilot:", "reviews are enabled but the " \
          "business unit ID and API key are not set - rendering the placeholder"
        return
      end

      data = cached(site, unit, conf) { fetch(unit, key, conf) }
      return unless data

      site.data["trustpilot"] = data
      Jekyll.logger.info "Trustpilot:", "loaded #{Array(data['reviews']).size} " \
        "reviews (score #{data['rating']})"
    rescue StandardError => e
      # Never let a network problem break the build.
      Jekyll.logger.warn "Trustpilot:", "could not load reviews " \
        "(#{e.class}: #{e.message}) - rendering the placeholder"
    end

    private

    def fetch(unit, key, conf)
      per_page = (conf["per_page"] || 6).to_i
      per_page = 1 if per_page < 1
      per_page = 20 if per_page > 20

      business = get("/v1/business-units/#{unit}", key)
      listing  = get("/v1/business-units/#{unit}/reviews", key,
                     "perPage" => per_page, "orderBy" => "recency")

      count = business["numberOfReviews"]
      count = count["total"] if count.is_a?(Hash)

      {
        "fetched_at"  => Time.now.utc.iso8601,
        "rating"      => business.dig("score", "trustScore"),
        "count"       => count,
        "profile_url" => conf["profile_url"].to_s,
        "reviews"     => Array(listing["reviews"]).map { |r| normalise(r) }
      }
    end

    def normalise(review)
      {
        "id"     => review["id"],
        "rating" => review["stars"],
        "title"  => review["title"],
        "text"   => review["text"],
        "author" => review.dig("consumer", "displayName"),
        "date"   => format_date(review["createdAt"])
      }
    end

    def format_date(value)
      Time.parse(value.to_s).strftime("%-d %B %Y")
    rescue ArgumentError, TypeError
      nil
    end

    def get(path, key, params = {})
      query = URI.encode_www_form(params.merge("apikey" => key))
      uri = URI::HTTPS.build(host: API_HOST, path: path, query: query)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      response = http.request(Net::HTTP::Get.new(uri))
      raise "HTTP #{response.code} from #{path}" unless response.code == "200"

      JSON.parse(response.body)
    end

    def cached(site, unit, conf)
      minutes = (conf["cache_minutes"] || 360).to_i
      path = File.join(site.cache_dir, "trustpilot-#{unit}.json")

      if fresh?(path, minutes)
        begin
          return JSON.parse(File.read(path))
        rescue StandardError => e
          Jekyll.logger.warn "Trustpilot:", "ignoring unreadable cache (#{e.message})"
        end
      end

      begin
        data = yield
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(data))
        data
      rescue StandardError
        raise unless File.file?(path)

        Jekyll.logger.warn "Trustpilot:", "fetch failed; using the cached copy"
        JSON.parse(File.read(path))
      end
    end

    def fresh?(path, minutes)
      File.file?(path) && (Time.now - File.mtime(path)) < minutes * 60
    end
  end
end
