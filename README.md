# pluralwebsite

A static Hugo website for [getplural.net](https://getplural.net), hosted on GitHub Pages.
The site uses local templates and CSS; no external theme is required.

## Local development

Install [Hugo](https://gohugo.io/installation/) **0.167.0**, matching the
version in `.github/workflows/hugo.yml`, then run from the repository root:

```sh
hugo server --buildDrafts
```

Open the local URL printed by Hugo. Edit `content/_index.md` for the homepage,
`layouts/` for templates, and `static/css/main.css` for styling.
To add a page:

```sh
hugo new content about.md
```

New pages are drafts by default. Set `draft = false` in their front matter to
publish them and add a navigation link where appropriate.

## Theme and identity

The consumer homepage lives in `layouts/home.html`. Support and privacy copy
lives in `content/`. The theme uses ink, recording coral and muted mint, with
locally hosted Space Grotesk (SIL Open Font License included in `static/fonts/`).
Animation and the FAQ are native HTML and CSS only. Reduced-motion preferences
disable animation and smooth scrolling. The icon-only appearance menu defaults to System
and follows the device's light/dark setting live. Its popup uses CSS hover and
focus-within, including keyboard and touch access, and closes when hover and
focus leave. A small local script remembers
explicit Light or Dark choices in local storage; automatic theming still works
without JavaScript; CSS also supports temporary theme choices when scripts are
disabled. No external fonts or analytics are required. Product images
are captures of the real Plural UI with simulated mics.

`static/images/plural.svg` is the master logo. Three rounded recording tracks
form an abstract P, with a coral third voice. SVG is used for the website mark
and favicon; PNG and ICO exports support app icons and older browsers.

To refresh the image exports on Windows, with the app repository checked out:

```powershell
./tools/export-assets.ps1 -AppRoot ../Sabinetek
./tools/export-assets.ps1 -AppRoot ../Sabinetek -SyncApp
```

The second command also updates the app's marketing SVG/PNG, Android icon and
desktop ICO. Store exports read `Marketing/brand/plural.svg` when regenerating
icons. Keep both committed SVG copies together when changing the mark.

## Production build

```sh
hugo --gc --minify --panicOnWarning
```

Run the appearance-switch regression tests with Node.js (no dependencies):

```sh
node --test tools/theme.test.mjs
```

The generated site is written to `public/`, which is excluded from Git.
To host elsewhere, update `baseURL` in `hugo.toml` or pass `--baseURL` to Hugo.

## GitHub Pages deployment

In the repository's **Settings → Pages**, set **Source** to **GitHub Actions**.
The workflow builds pull requests without deploying and deploys pushes to
`main`. It can also be run manually from the **Actions** tab. If your default
branch has a different name, update the workflow's push branch filter.

Deployment uses the base URL supplied by GitHub Pages so asset links work
under the repository subpath or a configured custom domain.

The intended production domain is `getplural.net`, declared in `hugo.toml` and
`static/CNAME`. Configure that custom domain in GitHub Pages settings and point
its DNS records to GitHub Pages; committing these files does not change DNS.