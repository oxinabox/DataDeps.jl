# This file is a part of DataDeps.jl. License is MIT.

## Core path determining stuff


const default_loadpath = joinpath.([
    Pkg.Dir._pkgroot(); homedir(); # Common all systems

    @static if is_windows()
        vcat(get.(ENV,
           ["APPDATA", "LOCALAPPDATA",
            "ProgramData", "ALLUSERSPROFILE", # Probably the same, on all systems where both exist
            "PUBLIC", "USERPROFILE"], # Home Dirs ("USERPROFILE" is probably the same as homedir()
           [String[]])...)
    else
        ["/scratch", "/staging", # HPC common folders
         "/usr/share", "/usr/local/share"] # Unix Filestructure
    end], "datadeps")





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
function try_determine_package_datadeps_dir(filepath)::Nullable{String}
    # TODO: Consider rewriting this to just go up the directory tree
    # checking for `deps/data`
    package_roots = [LOAD_PATH; Pkg.dir()]
    for root in package_roots
        if startswith(filepath, root) && filepath!=root # if running from REPL from a root this can happen
            inner_path = filepath[length(root) + 1:end]
            first_pp, pkgname = splitpath(inner_path)
            @assert(first_pp ∈ ["/", "\\"], "expected \"/\", got \"$(first_pp)\"")
            datadeps_dir = joinpath(root, pkgname,"deps","data")
            return Nullable(datadeps_dir)
        end
    end
    return Nullable{String}()
end

"""
    try_determine_package_datadeps_dir(::Void)

Fallback for if being run in some enviroment (eg the REPL),
where @__FILE__ is nothing.
Falls back to using the current directory.
So that if you are prototyping in the REPL (etc) for a package,
and you are in the packages directory, then
"""
function try_determine_package_datadeps_dir(::Void)
    try_determine_package_datadeps_dir(pwd())
end



"""
    try_determine_package_datadeps_dir(module::Module)

Takes a module, attempts to located the file for that module,
and thus the deps/data dir for the package that declares it.
Then this returns a path to the deps/data dir for that package (as a Nullable).
Which may or may not exist.
If not in a package returns null
"""
function try_determine_package_datadeps_dir(mm::Module)::Nullable{String}
    module_file  = first(function_loc(mm.eval, (Any,))) # Hack
    try_determine_package_datadeps_dir(module_file)
end


############################################

"""
    preferred_paths([calling_filepath|module|nothing]; use_package_dir=true)

returns the datadeps load_path
plus if calling_filepath is provided and `use_package_dir=true`
and is currently inside a package directory then it also includes the path to the dataseps in that folder.
"""
function preferred_paths(rel=nothing; use_package_dir=true)
    cands = String[]
    if use_package_dir
        pkg_deps_root = try_determine_package_datadeps_dir(rel)
        !isnull(pkg_deps_root) && push!(cands, get(pkg_deps_root))
    end
    append!(cands, env_list("DATADEPS_LOAD_PATH", default_loadpath))
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
                (Ptr{Void}, Ptr{Void}, Cstring, Cint, Ptr{Void}),
                Base.eventloop(), req, path, mode, C_NULL)
        ccall(:uv_fs_req_cleanup, Void, (Ptr{Void},), req)
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
    if path_ind==0
        error("No possible save path")
    end
    return joinpath(cands[path_ind], name)
end

"""
    try_determine_load_path(name)

Trys to find a local path to the datadep with the given name.
If it fails then it returns nothing.
"""
function try_determine_load_path(name::String, rel=nothing)::Nullable{String}
    paths = list_local_paths(name, rel)
    paths = paths[first.(uv_access.(paths, R_OK)) .== 0] #0 means passes
    length(paths)==0 ? Nullable{String}() : Nullable(first(paths))
end

"""
    list_local_paths( name|datadep, [calling_filepath|module|nothing])

Lists all the local paths to a given datadep.
This may be an empty list
"""
function list_local_paths(name::String, rel=nothing)
    cands = preferred_paths(rel)
    joinpath.(cands, name)
end

list_local_paths(dd::AbstractDataDep, rel=nothing) = list_local_paths(dd.name, rel)
