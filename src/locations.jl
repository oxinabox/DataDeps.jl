"""
    determine_save_path(name)

Determines the default location to save a datadep with the given name to.
"""
function determine_save_path(name)
    cands = preferred_paths(calling_filepath)

end

"""
    try_determine_load_path(name)

Trys to find a local path to the datadep with the given name.
If it fails then it returns nothing.
"""
function try_determine_load_path(name, calling_filepath="")::Nullable{String}
    cands = [pwd(); preferred_paths(calling_filepath)]
    Nullable{String}()
end

function preferred_paths(calling_filepath="")
    cands = [pwd()]
    pkg_deps_root = try_determine_package_datadeps_dir(calling_filepath)
    !isnull(pkg_deps_root) && push!(cands, get(pkg_deps_root))
    append!(cands, env_list("DATADEPS_LOAD_PATH"))
    cands
end

"""
    try_determine_package_datadeps_dir(filepath)

Takes a path to a file.
If that path is in a package's folder,
Then this returns a path to the deps/data dir for that package (as a Nullable).
Which may or may not exist.
If not in a package returns null
"""
function try_determine_package_datadeps_dir(filepath)::Nullable{String}
    package_roots = [LOAD_PATH; Pkg.dir()]
    for root in package_roots
        if startswith(filepath, root)
            inner_path = filepath[1:length(root)]
            pkgname = first(splitpath(inner_path))
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
