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
| Email, price, area, page title/description | `_config.yml` |
| The three repair cards | `_data/services.yml` |
| Hero wording, section headings, contact block | `index.html` |
| Colours, spacing, type sizes | `assets/css/main.css` (variables at the top) |
| Header (brand lockup, nav, email button) | `_includes/header.html` |
| Footer | `_includes/footer.html` |
| 404 page | `404.html` |

The email address lives in **one** place: `email` in `_config.yml`. Every
button, the header, the contact block, the footer and the structured data pull
from that value, and every contact link is a `mailto:` link.

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
  header keeps the tappable email button and the hero keeps its email button.

## Deploying

Set `url` in `_config.yml` before going live — it is used for the canonical
link, the Open Graph tags and the structured data. Otherwise they point at
`http://localhost:4000`.

```yaml
url: "https://turriffpcrepair.co.uk"    # your real domain, no trailing slash
baseurl: ""                             # or "/repairs" for a project page
```

All internal links use `relative_url`, so a `baseurl` is picked up automatically.
