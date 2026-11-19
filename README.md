# Turriff PC Repair — website

A one-page Jekyll site in the same style as the A5 flyer (navy, cyan, Lato).
No theme gem, no plugins — just Jekyll 4.

## Run it locally

```bash
cd jekyll-website
jekyll serve --livereload
```

Then open <http://localhost:4000>.

`jekyll build` writes the site to `_site/` without starting a server.

Bundler is optional. Use it if you want a pinned gem set:

```bash
bundle install
bundle exec jekyll serve --livereload
```

(If `bundle exec` complains it cannot find gems, your Bundler lock has drifted
from what is installed — delete `Gemfile.lock` and rerun `jekyll serve`, or
`bundle install` again.)

## Build the static files

```bash
bundle exec jekyll build
```

The finished HTML lands in `_site/` — upload that folder to any static host
(Netlify, Cloudflare Pages, GitHub Pages, or plain shared hosting).

## Where to edit things

| What | File |
|---|---|
| Phone number, address, price, area, opening times, page title/description | `_config.yml` |
| Trustpilot business unit, API key, review count | `_config.yml` |
| The three repair cards | `_data/services.yml` |
| Hero wording, section headings, contact block | `index.html` |
| Reviews section markup | `_includes/reviews.html` |
| Trustpilot API fetch (build step) | `_plugins/trustpilot_reviews.rb` |
| Colours, spacing, type sizes | `assets/css/main.css` (variables at the top) |
| Header (brand lockup, nav, call button) | `_includes/header.html` |
| Footer | `_includes/footer.html` |
| 404 page | `404.html` |

The phone number lives in **one** place: `phone_display` (what people read)
and `phone_link` (the `tel:` target) in `_config.yml`. Every button, the
header, the contact block, the footer and the structured data pull from those
values, and every contact link is a `tel:` link.

The address is the `street`, `locality` and `postcode` values under `address`
in the same file; the contact section lists them on separate lines beside the
opening times and they feed the schema's `PostalAddress`.

## Trustpilot reviews

The reviews section sits directly after the price band (`#reviews`) and is
driven by the `trustpilot` block in `_config.yml`:

```yaml
trustpilot:
  enabled: true
  business_unit_id: ""   # Trustpilot business unit ID
  api_key: ""            # Trustpilot API key
  profile_url: ""        # public profile link
  review_url: ""         # link to the "write a review" form
  per_page: 6
  cache_minutes: 360
```

The "Leave a review on Trustpilot" button uses `review_url`. Leave it blank and
it is derived from `profile_url` by swapping `/review/` for `/evaluate/`, which
is Trustpilot's write-a-review address for your domain. The button only appears
once one of those URLs is set.

Fill in `business_unit_id` and `api_key` when the account is ready — no other
changes needed. Until then the section shows a short "coming shortly" note
rather than an empty box; set `enabled: false` to hide it completely.

Reviews are fetched **at build time** by `_plugins/trustpilot_reviews.rb` and
rendered from the response, so the API key never reaches the browser. The
fetched copy is cached in `.jekyll-cache/` for `cache_minutes`, and if a fetch
fails the build continues with the cached copy (or the placeholder). On CI,
set `TRUSTPILOT_API_KEY` and leave `api_key` blank so the secret stays out of
the repo — the environment variable takes priority.

Note: GitHub Pages does not run custom plugins. Build locally or on a CI
service (Netlify, Cloudflare Pages, Actions) so the fetch can run. If you need
GitHub Pages, commit the generated data as `_data/trustpilot.yml` instead.

## Design notes

- Palette matches the flyer: navy `#0B1628`, cyan `#00AEEF`, deep cyan
  `#0084BA`, plus the pale `#F2F7FB` card tint.
- Type is Lato (Google Fonts) at 400 / 700 / 900 — the same family used in the
  printed flyer.
- The cyan tick badges and the monitor mark are CSS/inline SVG, so there are
  no icon image files to manage.
- The navy sections (both heroes and the contact band) share a darkened
  motherboard backdrop behind layered navy gradients. The site serves
  optimised copies in `assets/img/` (`mobo-bg-1600.jpg`,
  `mobo-bg-2400.jpg`); the 4K original `assets/4k-mobo-wp.jpg` is kept in
  the repo but excluded from the build. The header and footer stay flat navy.
- Layout is mobile-first and fluid; nav links hide below 760 px, where the
  header keeps the tappable call button and the hero keeps its call button.

## Deploying

Set `url` in `_config.yml` before going live — it is used for the canonical
link, the Open Graph tags and the structured data. Otherwise they point at
`http://localhost:4000`.

```yaml
url: "https://turriffpcrepair.co.uk"    # your real domain, no trailing slash
baseurl: ""                             # or "/repairs" for a project page
```

All internal links use `relative_url`, so a `baseurl` is picked up automatically.
