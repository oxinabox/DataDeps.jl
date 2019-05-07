# This file is a part of DataDeps.jl. License is MIT.
## Core path determining stuff

const standard_loadpath = joinpath.([
    Base.DEPOT_PATH; homedir(); # Common all systems

    @static if Sys.iswindows()
        vcat(get.(Ref(ENV),
           ["APPDATA", "LOCALAPPDATA",
            "ProgramData", "ALLUSERSPROFILE", # Probably the same, on all systems where both exist
            "PUBLIC", "USERPROFILE"], # Home Dirs ("USERPROFILE" is probably the same as homedir()
           [String[]])...)
    else
        ["/scratch", "/staging", # HPC common folders
         "/usr/share", "/usr/local/share"] # Unix Filestructure
    end], "datadeps")

# ensure at least something in the loadpath exists when instaleld
mkpath(first(standard_loadpath))


########################################################################################################################
## Package reletive path determining

"""
    try_determine_package_datadeps_dir(filepath)

Takes a path to a file.
If that path is in a package's folder,
Then this returns a path to the deps/data dir for that package (as a Nullable).
Which may or may not exist.
If not in a package returns null
"""
function try_determine_package_datadeps_dir(filepath)::Union{String, Nothing}
    olddir=filepath
    curdir = dirname(filepath)
    while(olddir!=curdir) # At root `dirname` returns it's input
        olddir = curdir
        curdir = dirname(curdir)
        datadeps_dir = joinpath(curdir, "deps","data")
        if isdir(datadeps_dir)
            return datadeps_dir
        end
    end
    return nothing
end



############################################

"""
    preferred_paths(calling_filepath; use_package_dir=true)

returns the datadeps load_path
plus if calling_filepath is provided and `use_package_dir=true`
and is currently inside a package directory then it also includes the path to the dataseps in that folder.
"""
function preferred_paths(rel=nothing; use_package_dir=true)
    cands = String[]
    if use_package_dir
        @assert rel != nothing
        pkg_deps_root = try_determine_package_datadeps_dir(rel)
        pkg_deps_root != nothing && push!(cands, pkg_deps_root)
    end

    append!(cands, env_list("DATADEPS_LOAD_PATH", []))
    if !env_bool("DATADEPS_NO_STANDARD_LOAD_PATH", false)
        append!(cands, standard_loadpath)
    end
    cands
end

####################################################################################################################
## Permission checking stuff
@enum AccessMode F_OK=0b0000 X_OK=0b0001 W_OK=0b0010 XW_OK=0b0011 R_OK=0b0100 XR_OK=0b0101 WX_OK=0b0110 XWR_OK=0b0111

"""
    uv_access(path, mode)

Check access to a path.
Returns 2 results, first an error code (0 for all good), and second an error message.
https://stackoverflow.com/a/47126837/179081
"""
function uv_access(path, mode::AccessMode)
    local ret
    req = Libc.malloc(Base._sizeof_uv_fs)
    try
        ret = ccall(:uv_fs_access, Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}, Cstring, Cint, Ptr{Cvoid}),
                Base.eventloop(), req, path, mode, C_NULL)
        ccall(:uv_fs_req_cleanup, Cvoid, (Ptr{Cvoid},), req)
    finally
        Libc.free(req)
    end
    return ret, ret==0 ? "OK" : Base.struverror(ret)
end

can_read_file(path) = uv_access(path, R_OK)[1] == 0

##########################################################################################################################
## Actually determining path being used (/going to be used) by a given datadep


"""
    determine_save_path(name)

Determines the location to save a datadep with the given name to.
"""
function determine_save_path(name, rel=nothing)::String
    cands = preferred_paths(rel; use_package_dir=false) #TODO Consider removing `rel` argument, it is not used
    path_ind = findfirst(cands) do path
        0 == first(uv_access(path, W_OK))
    end
    if path_ind === nothing
            @error """
            No writable path exists to save the data. Make sure there exists as writable path in your DataDeps Load Path.
            See http://white.ucc.asn.au/DataDeps.jl/stable/z10-for-end-users.html#The-Load-Path-1
            The current load path contains:
            """ cands
        throw(NoValidPathError("No writable path exists to save the data."))
    end
    return joinpath(cands[path_ind], name)
end

"""
    try_determine_load_path(name)

Trys to find a local path to the datadep with the given name.
If it fails then it returns nothing.
"""
function try_determine_load_path(name::String, rel)
    paths = list_local_paths(name, rel)
    paths = paths[first.(uv_access.(paths, Ref(R_OK))) .== 0] # 0 means passes
    length(paths)==0 ? nothing :  first(paths)
end

"""
    list_local_paths( name|datadep, [calling_filepath|module|nothing])

Lists all the local paths to a given datadep.
This may be an empty list
"""
function list_local_paths(name::String, rel)
    cands = preferred_paths(rel)
    joinpath.(cands, name)
end

list_local_paths(dd::AbstractDataDep, rel) = list_local_paths(dd.name, rel)
