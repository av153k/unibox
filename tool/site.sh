#!/usr/bin/env bash
#
# Builds the static site: the web rendering from the Jaspr export, the same pages
# from the Flutter build, and one landing page that shows them side by side.
#
# Usage:
#   tool/site.sh                          # for http://localhost:8000/
#   tool/site.sh --base=/unibox/          # the path GitHub Pages serves from
#   tool/site.sh --url=https://…/unibox/  # adds a sitemap for that address
#   tool/site.sh --serve                  # builds, then serves build/site
#
# Everything lands in build/site, which is the directory a static host publishes.
set -euo pipefail

cd "$(dirname "$0")/.."

base='/'
url=''
serve=0

for argument in "$@"; do
  case "$argument" in
    --base=*) base="${argument#--base=}" ;;
    --url=*) url="${argument#--url=}" ;;
    --serve) serve=1 ;;
    -h | --help)
      sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown option: $argument" >&2
      exit 2
      ;;
  esac
done

# A base href has to start and end with a slash, the rule Flutter states too.
[[ "$base" == /* ]] || base="/$base"
[[ "$base" == */ ]] || base="$base/"

site='build/site'

step() {
  printf '\n==> %s\n' "$1"
}

fail() {
  printf '\n==> FAILED: %s\n' "$1" >&2
  exit 1
}

step 'Resolving the workspace'
flutter pub get || fail 'flutter pub get'

step 'Rendering the web pages'
(cd example/unibox_example_jaspr && dart run bin/build.dart) || fail 'the Jaspr export'

step 'Building the Flutter web app'
# The service worker is off on purpose: a demo that caches its own old build is
# worse than one that downloads again.
(cd example/unibox_example_flutter && flutter build web \
  --base-href "${base}flutter/" \
  --pwa-strategy=none) || fail 'flutter build web'

step 'Assembling the site'
rm -rf "$site"
mkdir -p "$site/showcase/signup" "$site/flutter"

# One document per destination: the export names the listings `index.html` and the
# dialog `signup.html`, and the site serves them at the paths the navigation uses.
cp example/unibox_example_jaspr/build/index.html "$site/showcase/index.html"
cp example/unibox_example_jaspr/build/signup.html "$site/showcase/signup/index.html"
cp -R example/unibox_example_flutter/build/web/. "$site/flutter/"

# A static host has no rewrite rule, so a Flutter route is a real file. The build's
# absolute base href is what lets the copied document resolve its assets from a
# deeper path.
for route in showcase showcase/signup; do
  mkdir -p "$site/flutter/$route"
  cp "$site/flutter/index.html" "$site/flutter/$route/index.html"
done

step 'Writing the landing page'
cat >"$site/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Unibox — the same tree, drawn twice</title>
<meta name="description" content="One Unibox node tree rendered by Jaspr as HTML and CSS and by Flutter, side by side.">
<style>
  :root { color-scheme: light; }
  body { margin: 0; font: 16px/1.5 system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif; color: #111827; background: #f3f4f6; }
  header { padding: 24px; }
  h1 { margin: 0 0 4px; font-size: 24px; }
  p { margin: 0; color: #6b7280; }
  nav { margin-top: 12px; display: flex; gap: 16px; flex-wrap: wrap; }
  a { color: #2d6cf3; }
  .frames { display: grid; grid-template-columns: 1fr 1fr; gap: 1px; background: #d1d5db; height: calc(100vh - 132px); min-height: 420px; }
  iframe { border: 0; width: 100%; height: 100%; background: #ffffff; }
  @media (max-width: 760px) { .frames { grid-template-columns: 1fr; height: auto; } iframe { height: 70vh; } }
</style>
</head>
<body>
<header>
  <h1>Unibox</h1>
  <p>One node tree. Two renderers. Left: Jaspr, as HTML and CSS. Right: Flutter. Resize the window and both answer the same breakpoint.</p>
  <nav>
    <a href="showcase/">Web — listings</a>
    <a href="showcase/signup/">Web — sign-up dialog</a>
    <a href="flutter/showcase/">Flutter — listings</a>
    <a href="flutter/showcase/signup/">Flutter — sign-up dialog</a>
  </nav>
</header>
<main class="frames">
  <iframe src="showcase/" title="The example, rendered by Jaspr"></iframe>
  <iframe src="flutter/showcase/" title="Same tree, rendered by Flutter" loading="lazy"></iframe>
</main>
</body>
</html>
HTML

step 'Writing robots, sitemap and .nojekyll'
cat >"$site/robots.txt" <<'ROBOTS'
# The Flutter build is a canvas with no text of its own for a crawler to read; the
# web rendering carries the markup, so it is the one that gets indexed.
User-agent: *
Allow: /
Disallow: /flutter/
ROBOTS

if [[ -n "$url" ]]; then
  [[ "$url" == */ ]] || url="$url/"
  cat >"$site/sitemap.xml" <<SITEMAP
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>${url}</loc></url>
  <url><loc>${url}showcase/</loc></url>
  <url><loc>${url}showcase/signup/</loc></url>
</urlset>
SITEMAP
  printf 'Sitemap: %ssitemap.xml\n' "$url" >>"$site/robots.txt"
fi

# GitHub Pages runs Jekyll over a published directory unless this file is there,
# and Jekyll drops paths it thinks are special.
: >"$site/.nojekyll"

printf '\n==> Built %s (base %s)\n' "$site" "$base"

if [ "$serve" -eq 1 ]; then
  printf '==> Serving http://localhost:8000/ (Ctrl-C to stop)\n'
  exec python3 -m http.server --directory "$site" 8000
fi
