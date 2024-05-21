[![CI Status](https://github.com/idanarye/nvim-impairative/workflows/CI/badge.svg)](https://github.com/idanarye/nvim-impairative/actions)

INTRODUCTION
============

FEATURES (IMPLEMENTED/PLANNED)
==============================

* [x] Determining the last time the configuration was changed.
* [x] Exposing that information for other plugins (e.g. custom splash screens) to use.
* [x] Displaying a billboard (using a floating window) with that information.

SETUP
=====

Install Impairative with your plugin manager of choice, and add this to your `init.lua`:

```lua
require'impairative'.setup {
}
```

ALTERNATIVES
============

CONTRIBUTION GUIDELINES
=======================

* If your contribution can be reasonably tested with automation tests, add tests.
* Documentation comments must be compatible with both [Sumneko Language Server](https://github.com/sumneko/lua-language-server/wiki/Annotations) and [lemmy-help](https://github.com/numToStr/lemmy-help/blob/master/emmylua.md). If you do something that changes the documentation, please run `make docs` to update the vimdoc.
* Impairative uses Google's [Release Please](https://github.com/googleapis/release-please), so write your commits according to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format.
