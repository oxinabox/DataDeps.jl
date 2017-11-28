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

"""
    resolve(datadep)

Returns a path to the folder containing the datadep.
Even if that means downloading the dependancy and putting it in there.

This is basically the function the lives behind the string macro `datadep"DepName`.
"""
function resolve(datadep::AbstractDataDep, calling_filepath)::String
    lp = try_determine_load_path(datadep.name, calling_filepath)
    if isnull(lp)
        handle_missing(datadep, calling_filepath)
    else
        get(lp)
    end
end

include("util.jl")
include("registration.jl")

include("locations.jl")
include("verification.jl")

include("resolution_automatic.jl")
include("resolution_manual.jl")

include("helpers.jl")

end # module
