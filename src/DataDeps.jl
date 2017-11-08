module DataDeps

using Reexport
@reexport using SHA

export RegisterDataDep, @datadep_str

abstract type AbstractDataDep end

"""
    ManualDataDep(name, message)

"""
struct ManualDataDep <: AbstractDataDep
    name::String
    message::String
end

struct DataDep{H, R, F, P} <: AbstractDataDep
    name::String
    remotepath::R
    hash::H
    fetch_method::F
    post_fetch_method::P
    extra_message::String
end

macro datadep_str(name)
    :(resolve(registry[$(esc(name))], @__FILE__))
end

include("util.jl")
include("registration.jl")

include("locations.jl")
include("verification.jl")

include("resolution.jl")


end # module
