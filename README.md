[![CI Status](https://github.com/idanarye/nvim-impairative/workflows/CI/badge.svg)](https://github.com/idanarye/nvim-impairative/actions)

INTRODUCTION
============

SETUP
=====

Install Impairative with your plugin manager of choice, and add this to your `init.lua`:

```lua
require'impairative'.setup {
}
```

ALTERNATIVES
============

DIFFERENCE FROM UNIMPAIRED
==========================

* unimpaired's normal mode version of `[e` and `]e` work on the current line. In Impairative, they are operators.
* unimpaired's URL encoding encode spaces a `%20`. Impairative encodes them as `+`.
* Impairative's C string decoder (`]y` / `]C`) knows how to decode 32bit Unicode codepoints (the ones that start with `\U`)
* Impairative does not implement unimpaired's paste-related keymaps, because in Neovim the `'paste'` option is obsolete.


CONTRIBUTION GUIDELINES
=======================

* If your contribution can be reasonably tested with automation tests, add tests.
* Documentation comments must be compatible with both [Sumneko Language Server](https://github.com/sumneko/lua-language-server/wiki/Annotations) and [lemmy-help](https://github.com/numToStr/lemmy-help/blob/master/emmylua.md). If you do something that changes the documentation, please run `make docs` to update the vimdoc.
* Impairative uses Google's [Release Please](https://github.com/googleapis/release-please), so write your commits according to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format.
