using Documenter
using DataDeps

using Documenter


makedocs(
    format=Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "DataDeps.jl",
    modules = [DataDeps],
    repo="https://github.com/oxinabox/DataDeps.jl/blob/{commit}{path}#L{line}",
    authors="Lyndon White",
)

deploydocs(
    repo = "github.com/oxinabox/DataDeps.jl.git",
)

