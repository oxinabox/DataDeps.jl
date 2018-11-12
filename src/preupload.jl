# This file is a part of DataDeps.jl. License is MIT.


"""
    preupload_check(datadep, local_filepath[s])::Bool)

Peforms preupload checks on the local files without having to download them.
This is tool for creating or updating DataDeps,
allowing the author to check the files before they are uploaded (or if downloaded directly).
This checking includes checking the checksum, and the making sure the `post_fetch_method` runs without errors.
It basically performs datadep resolution, but bypasses the step of downloading the files.
The results of performing the `post_fetch_method` are not kept.
As normal if the DataDep being checked does not have a checksum, or if the checksum does not match,
then a warning message will be displayed.
Similarly, if the `post_fetch_method` throws an exception, a warning will be displayed.

Returns: true or false, depending on if the checks were all good, or not.

Arguements:

 - `datadep`: Either an instance of a DataDep type, or the name of a registered DataDep as a AbstractString
 - `local_filepath`: a filepath or (recursive) list of filepaths.
    This is what would be returned by fetch in normal datadep use.
"""
function preupload_check(dd::DataDep, local_filepath)
    checksum_passes = run_checksum(dd.hash, local_filepath)
    postfetch_passes = postfetch_check(dd.post_fetch_method, local_filepath)


    return checksum_passes && postfetch_passes
end


function preupload_check(datadep_name::AbstractString, fetched_files)
    return preupload_check(registry[datadep_name], fetched_files)
end


"""
    postfetch_check(post_fetch_method, local_path)

Executes the post_fetch_method on the given local path,
in a temportary directory.
Returns true if there are no exceptions.
Performs in (async) parallel if multiple paths are given
"""
function postfetch_check(post_fetch_method, local_path)
    return mktempdir() do working_dir
        working_path = cp(local_path, joinpath(working_dir, basename(local_path)))
        try
            run_post_fetch(post_fetch_method, working_path)
            return true
        catch err
            @warn "Post-fetch method threw an exception" local_path exception=err
            return false
        end
    end
end

function postfetch_check(post_fetch_method, fetched_paths::AbstractVector)
    asyncmap(fp->postfetch_check(post_fetch_method, fp),  fetched_paths)
end

function postfetch_check(post_fetch_methods::AbstractVector, fetched_paths::AbstractVector)
    asyncmap(postfetch_check,  post_fetch_methods, fetched_paths)
end
