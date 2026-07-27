# DataDeps

[![CI](https://github.com/oxinabox/DataDeps.jl/workflows/CI/badge.svg)](https://github.com/oxinabox/DataDeps.jl/actions?query=workflow%3ACI)
[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://oxinabox.github.io/DataDeps.jl/stable)
[![Dev Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://oxinabox.github.io/DataDeps.jl/dev)

Please see the detailed documentation linked above.

## Breaking Changes (1.0)
DataDeps 1.0 includes breaking changes in the download/fetch API.
Downloading has been refactored to always use `Downloads.download()`. This removes the dependency on HTTP.jl, which is comparatively large and has had recent breaking changes.


- `fetch_base` and `fetch_http` were removed.
- `fetch_default` was removed.
- The default `fetch_method` is now `fetch`.

### Migration Guide

If your code used one of the removed fetch wrappers:

- Replace `fetch_default(remote, dir)` with `fetch(remote, dir)`.
- Replace `fetch_base(remote, dir)` with `fetch(remote, dir; update_period=Inf)`.
- Replace `fetch_http(remote, dir; update_period=...)` with `fetch(remote, dir; update_period=...)`.

If you provide a custom `fetch_method` in `DataDep(...)`:

- Keep the `(remote_path, local_dir) -> local_path` contract.
- Breaking change: for custom `remote_path` types, overload `Downloads.download(::YourType)` instead of overloading `Base.download(::YourType)`.
- Your `Downloads.download(::YourType)` method must return a local file path (or move to one) whose basename is the final filename DataDeps should use.

### Progress Callback Semantics

The built-in `fetch` method now supports a configurable progress callback API.

- `progress_callback` takes three arguments:
  `(total_bytes, downloaded_bytes, filename_hint)`.
- Progress callback invocation is throttled by `update_period`.
- `update_period=Inf` disables progress callbacks and progress logging.
- If `progress_callback` is not provided and `update_period` is finite,
  a default logging callback is used.

### Existing Environment Variable

- `DATADEPS_PROGRESS_UPDATE_PERIOD` still controls the progress update interval used by the default fetch behavior.


## Software using DataDeps.jl
It might help to look at how DataDeps.jl is being used to understand how it may be used in your project.
Some of these add some additional abstraction or niceness for users on top of the DataDeps.jl core functionality.

 - [WordNet.jl](https://github.com/JuliaText/WordNet.jl)
 - [MLDatasets.jl](https://github.com/JuliaML/MLDatasets.jl/)
 - [CorpusLoaders.jl](https://github.com/JuliaText/CorpusLoaders.jl)
 - [Embeddings.jl](https://github.com/JuliaText/Embeddings.jl)
 - [MORWiki.jl](https://github.com/mpimd-csc/MORWiki.jl)

(Feel free to submit a PR adding a link to your package, or research script here.)

## Links:

  - [ANN: thread on Discourse](https://discourse.julialang.org/t/ann-datadeps-jl-bindeps-for-data/8457)
  - [MLOSS](http://mloss.org/software/view/705/)
  - [Release Blog Post](http://white.ucc.asn.au/2018/01/18/DataDeps.jl-Repeatabled-Data-Setup-for-Repeatable-Science.html)
  - [DataDepsGenerators.jl](https://github.com/oxinabox/DataDepsGenerators.jl)
  - JuliaCon 2018 [Slides](https://figshare.com/articles/JuliaCon2018_DataDeps_jl_pdf/6949145), and [Video](https://youtu.be/kSlQpzccRaI)
 
 #### Paper

[White, L., Togneri, R., Liu, W., & Bennamoun, M. (2019). DataDeps. jl: Repeatable Data Setup for Reproducible Data Science. Journal of Open Research Software, 7(1).](http://doi.org/10.5334/jors.244)
