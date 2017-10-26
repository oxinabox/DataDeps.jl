module DataDeps

export query_datadep, datadep_str,

abstract type DataDep end

"""
    ManualDataDep(name, message)

"""
struct ManualDataDep <: AbstractDataDep
    name::String
    message::String
end

struct DataDep{R, F, P, H} <: AbstractDataDep
    name::String
    remotepath::R
    hash::H
    fetch_method::F
    post_fetch_method::P
    extra_message::String
end

const registry = Dict{String, AbstractDataDep}()

RegisterDataDep(name::String, remotepath, hash;
        fetch_method=download
        post_fetch_method=identity
        extra_message="")
    if haskey(registry, name)
        warn("Over-writing registration of the datadep: $name")
    end
    registery[name] = DataDep(name,remotepath,hash,fetch_method,post_fetch_method, extra_message)
end

RegisterDataDep(name::String, message::String)
    if haskey(registry, name)
        warn("Over-writing registration of the datadep: $name")
    end
    registery[name] = ManualDataDep(name, message)
end

"""
    is_valid_name(name)

This checks if a datadep name is valid.
This basically means it must be a valid folder name on windows.

"""
function is_valid_name(name)
    namechars = collect(name)
    !any( namechars .∈ "\\/:*?<>|") && !any(Base.UTF8prox.iscntrl.(namechars))
end

macro dataset_str(name)
    :(DataDeps.resolve(DataDeps.registry[$(esc(name))]))
end

"""
    resolve(datadep)

Returns a path to the folder containing the datadep.
Even if that means downloading the dependancy and putting it in there.

This is basically the function the lives behind the string macro `datadep"DepName`.
"""
function resolve(datadep::DataDep)::String
    error("Not Implemented")
end

function resolve(datadep::ManualDataDep)::String
    lp = try_determine_load_path(datadep.name)
    if isnull(lp)
        error("Not Implemented resolving manual datadeps")
    else
        lp[]
    end
end

include("locations.jl")

"""
    Base.download(
        datadep::DataDep,
        localpath=determine_save_path(datadep.name);
        remotepath=datadep.remotepath,
        skiphash=false,
        always_accept_terms=false)

A method to download a datadep.
Normally, you do not have to download a data dependancy manually.
If you simply cause the string macro `datadep"DepName"`,
to be exectuted it will be downloaded if not already present.

Invoking this `download` method manually is normally for purposes of debugging.
As such it include a number of parameters that most people will not want to use.

 - `localpath`: this is the local path to save to. It defaults to an automatically chosen path
 - `remotepath`: the remote path to fetch the data from, use this e.g. if you can't access the normal path where the data should be, but have an alternative.
 - `skiphash`: setting this to true causes the hash to not be checked. Use this if the data has changed since the hash was set in the registery, or for some reason you want to download different data.
 - `always_accept_terms`: use this to bypass the I agree to terms screen. Useful if you are scripting the whole process.

 If you need more control than this, then your best bet is to construct a new DataDep object, based on the original,
 and then invoke download on that.
"""
function Base.download(
    datadep::DataDep,
    localpath=determine_save_path(datadep.name);
    remotepath=datadep.remotepath,
    always_accept_terms=false,
    skiphash=false)
    error("Not Implemented")
end


end # module
