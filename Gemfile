source "https://rubygems.org"

gem "jekyll", "~> 4.3"

# Windows and JRuby do not ship zoneinfo, so include the tzinfo-data gem
platforms :windows, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# File-watching on Windows
gem "wdm", "~> 0.1.1", platforms: [:mingw, :x64_mingw, :mswin]
