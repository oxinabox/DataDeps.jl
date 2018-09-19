using Documenter
using DataDeps

using Documenter


makedocs(
    format = :html,
    sitename = "DataDeps.jl",
    modules = [DataDeps]
)

deploydocs(
    repo = "github.com/oxinabox/DataDeps.jl.git",
    julia  = "0.7",
    latest = "master",
    target = "build",
    deps = nothing,  # we use the `format = :html`, without `mkdocs`
    make = nothing,  # we use the `format = :html`, without `mkdocs`
)

