# This file is a part of DataDeps.jl. License is MIT.

const registry = Dict{String, AbstractDataDep}()

function register(datadep::AbstractDataDep)
    name = datadep.name
    if haskey(registry, name)
        @warn("Over-writing registration of the datadep", name)
    end
    if !is_valid_name(name)
        throw(ArgumentError(name, " is not a valid name for a datadep. Valid names must be legal foldernames on Windows."))
    end

    registry[name] = datadep
end


"""
    is_valid_name(name)

This checks if a datadep name is valid.
This basically means it must be a valid folder name on windows.

"""
function is_valid_name(name)
    namechars = collect(name)
    !any( namechars .∈ "\\/:*?<>|") && !any(iscntrl.(namechars))
end
