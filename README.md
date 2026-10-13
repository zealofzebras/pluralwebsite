# pluralwebsite

A static Hugo website hosted at https://zealofzebras.github.io/pluralwebsite/.
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
publish them; published pages are linked from the homepage.

## Production build

```sh
hugo --gc --minify --panicOnWarning
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