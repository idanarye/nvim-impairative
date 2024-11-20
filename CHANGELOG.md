# Changelog

## [0.6.0](https://github.com/idanarye/nvim-impairative/compare/v0.5.0...v0.6.0) (2024-11-20)


### Features

* show message when toggling ([04f7c04](https://github.com/idanarye/nvim-impairative/commit/04f7c043ab5f06c2f46e5e9d501b1ac70e5bd4af))


### Bug Fixes

* check args is nil or not ([95bb100](https://github.com/idanarye/nvim-impairative/commit/95bb100c74e61b3b25344b6261ca2b4dffc188e2))

## [0.5.0](https://github.com/idanarye/nvim-impairative/compare/v0.4.0...v0.5.0) (2024-10-05)


### Features

* **better-n:** remap `N` relative to the direction ([2b3c4df](https://github.com/idanarye/nvim-impairative/commit/2b3c4df86f4a4f36e1656c0a1c1cf722b46ec74a))
* type annotations and validation for better-n ([0e55a82](https://github.com/idanarye/nvim-impairative/commit/0e55a82c049e45a22c387418db60ebdcf22d8323))

## [0.4.0](https://github.com/idanarye/nvim-impairative/compare/v0.3.1...v0.4.0) (2024-09-22)


### Features

* integrate better-n ([1d99a9b](https://github.com/idanarye/nvim-impairative/commit/1d99a9be7dae7ecf1f0a14cacb70e01c6fc9961a))

## [0.3.1](https://github.com/idanarye/nvim-impairative/compare/v0.3.0...v0.3.1) (2024-08-08)


### Bug Fixes

* using command_pair with a count looks up non-existing commands ([749bf54](https://github.com/idanarye/nvim-impairative/commit/749bf54ae5f8e987a2f773bd5b4b27cb251a1eca))

## [0.3.0](https://github.com/idanarye/nvim-impairative/compare/v0.2.0...v0.3.0) (2024-08-05)


### Features

* Improve `command_pair` error reporting ([44b3710](https://github.com/idanarye/nvim-impairative/commit/44b3710513b0b3f106ca639b47031182dff6d629))

## [0.2.0](https://github.com/idanarye/nvim-impairative/compare/v0.1.0...v0.2.0) (2024-06-04)


### Features

* Add `ImpairativeToggling:manual` (Close [#2](https://github.com/idanarye/nvim-impairative/issues/2)) ([07ec54b](https://github.com/idanarye/nvim-impairative/commit/07ec54bc37895114ed463bb4004d7f960b0360a4))
* Add validation for the argument objects passed to the helpers ([cff284f](https://github.com/idanarye/nvim-impairative/commit/cff284f8223b98000dc1e20939385910596a1404))
* Add vimdocs ([314c704](https://github.com/idanarye/nvim-impairative/commit/314c7045faf7c804ef7564d7c5b5c04d8b29b1e5))
* Allow using `setup` to generate the keymaps ([cacd341](https://github.com/idanarye/nvim-impairative/commit/cacd341857d67ddab0bf8199bfd1e81cf8bd5952))

## 0.1.0 (2024-06-01)


### Features

* `require'impairative'.toggling` for creating enable/disable/toggle trios of keymaps ([5519022](https://github.com/idanarye/nvim-impairative/commit/551902281320e47b40aab43f0772bc2659d9b102))
* `require'impairative'.operations` for creating backward/forward pairs of keymaps ([5dc04c9](https://github.com/idanarye/nvim-impairative/commit/5dc04c92a2a63923efa036a83a9b9b290dcce11f))
* `require'impairative'.operations` also supports text manipulation (with visual mode and with operators) ([c6717e3](https://github.com/idanarye/nvim-impairative/commit/c6717e3c48a79b8d18291503c430f3404a2f4523))
* Add `require'impairative.replicate-unimpaired'()` for creating the same mappings unimpaired creates ([195dcf2](https://github.com/idanarye/nvim-impairative/commit/195dcf26ed63b65b28793abd1bbc0d717f94ce3d))


### Miscellaneous Chores

* Initialize repository for Neovim plugin development ([dd9fe13](https://github.com/idanarye/nvim-impairative/commit/dd9fe13c8dbf2990f769acfaa2e8f3a31ab7580a))
