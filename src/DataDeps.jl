module DataDeps

using HTTP
using Reexport
@reexport using SHA

export RegisterDataDep, @datadep_str, unpack

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

macro datadep_str(path)
    quote
        parts = splitpath($(esc(path)))
        name = first(parts)
        inner_path = length(parts) > 1 ? joinpath(Iterators.drop(parts, 1)...) : ""
        resolve(registry[name], inner_path, @__FILE__)
    end
end

"""
    resolve(datadep, inner_filepath, calling_filepath)

Returns a path to the folder containing the datadep.
Even if that means downloading the dependancy and putting it in there.

     - `inner_filepath` is the path to the file within the data dir
     - `calling_filepath` is a path to the file where this is being invoked from

This is basically the function the lives behind the string macro `datadep"DepName/inner_filepath"`.
"""
function resolve(datadep::AbstractDataDep, inner_filepath, calling_filepath)::String
    while true
        dirpath = _resolve(datadep, calling_filepath)
        filepath = joinpath(dirpath, inner_filepath)

        if can_read_file(filepath)
            return filepath
        else # Something has gone wrong
            warn("DataDep $(datadep.name) found at \"$(dirpath)\". But could not read file at \"$(filepath)\".")
            warn("Something has gone wrong. What would you like to do?")
            input_choice(
                ('A', "Abort -- this will error out",
                    ()->error("Aborted resolving data dependency, program could not continue.")),
                ('R', "Retry -- do this after fixing the problem outside of this script",
                    ()->nothing), # nothing to do
                ('X', "Remove directory and retry  -- will retrigger download if there isn't another copy elsewhere",
                    ()->rm(dirpath, force=true, recursive=true);
                )
            )
        end
    end
end

"The core of the resolve function without any user friendly stuff, returns the directory"
function _resolve(datadep::AbstractDataDep, calling_filepath)::String
    lp = try_determine_load_path(datadep.name, calling_filepath)
    dirpath = if !isnull(lp)
        get(lp)
    else
        handle_missing(datadep, calling_filepath)
    end
end


include("util.jl")
include("registration.jl")

include("filename_solving.jl")
include("locations.jl")
include("verification.jl")


include("resolution_automatic.jl")
include("resolution_manual.jl")

include("helpers.jl")

function __init__()
    #ensure at least something in the loadpath exists.
    path = first(default_loadpath)
    isdir(path) || mkpath(first(default_loadpath))
end

end # module
