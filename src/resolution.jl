# This file is a part of DataDeps.jl. License is MIT.

"""
    `datadep"Name"` or `datadep"Name/file"`

Use this just like you would a file path, except that you can refer by name to the datadep.
The name alone will resolve to the corresponding folder.
Even if that means it has to be downloaded first.
Adding a path within it functions as expected.
"""
macro datadep_str(namepath)
    :(resolve($(esc(namepath)), @__FILE__))
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
            return realpath(filepath) # resolve any symlinks for maximum compatibility with external applications
        else # Something has gone wrong
            @warn("DataDep $(datadep.name) found at \"$(dirpath)\". But could not read file at \"$(filepath)\".")
            println("Something has gone wrong. What would you like to do?")
            input_choice(
                ('A', "Abort -- this will error out",
                    ()->abort("Aborted resolving data dependency, program could not continue.")
                ),
                ('R', "Retry -- do this after fixing the problem outside of this script",
                    ()->nothing  # nothing to do
                ),
                ('X', "Remove directory and retry  -- will retrigger download if there isn't another copy elsewhere",
                    ()->rm(dirpath, force=true, recursive=true)
                )
            )
        end
    end
end


function resolve(datadep_name::AbstractString, inner_filepath, calling_filepath)::String
    resolve(registry[datadep_name], inner_filepath, calling_filepath)
end

"""
    resolve("name/path", @__FILE__)

Is the function that lives directly behind the `datadep"name/path"` macro.
If you are working the the names of the datadeps programatically,
and don't want to download them by mistake;
it can be easier to work with this function.

Note though that you must include `@__FILE__` as the second argument,
as DataDeps.jl uses this to allow reading the package specific `deps/data` directory.
Advanced usage could specify a different file or `nothing`, but at that point you are on your own.
"""
function resolve(namepath::AbstractString, calling_filepath)
    parts = splitpath(namepath)
    name = first(parts)
    inner_path = length(parts) > 1 ? joinpath(Iterators.drop(parts, 1)...) : ""
    resolve(name, inner_path, calling_filepath)
end


"The core of the resolve function without any user friendly file stuff, returns the directory"
function _resolve(datadep::AbstractDataDep, calling_filepath)::String
    lp = try_determine_load_path(datadep.name, calling_filepath)
    if lp != nothing
        lp
    else
        handle_missing(datadep, calling_filepath)
    end
end
