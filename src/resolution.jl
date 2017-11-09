"""
    resolve(datadep)

Returns a path to the folder containing the datadep.
Even if that means downloading the dependancy and putting it in there.

This is basically the function the lives behind the string macro `datadep"DepName`.
"""
function resolve(datadep::AbstractDataDep, calling_filepath)::String
    lp = try_determine_load_path(datadep.name, calling_filepath)
    if isnull(lp)
        save_dir = determine_save_path(datadep.name, calling_filepath)
        download(datadep, save_dir)
        save_dir
    else
        get(lp)
    end
end



"""
    Base.download(
        datadep::DataDep,
        localpath;
        remotepath=datadep.remotepath,
        skiphash=false,
        always_accept_terms=false)

A method to download a datadep.
Normally, you do not have to download a data dependancy manually.
If you simply cause the string macro `datadep"DepName"`,
to be exectuted it will be downloaded if not already present.

Invoking this `download` method manually is normally for purposes of debugging.
As such it include a number of parameters that most people will not want to use.

 - `localpath`: this is the local path to save to.
 - `remotepath`: the remote path to fetch the data from, use this e.g. if you can't access the normal path where the data should be, but have an alternative.
 - `skiphash`: setting this to true causes the hash to not be checked. Use this if the data has changed since the hash was set in the registery, or for some reason you want to download different data.
 - `always_accept_terms`: use this to bypass the I agree to terms screen. Useful if you are scripting the whole process.
     - `for automation perposes you can set the enviroment variable`

 If you need more control than this, then your best bet is to construct a new DataDep object, based on the original,
 and then invoke download on that.
"""
function Base.download(
    datadep::DataDep,
    localdir,
    remotepath=datadep.remotepath,
    always_accept_terms=env_bool("DATADEPS_ALWAY_ACCEPT"),
    skiphash=false)

    !env_bool("DATADEPS_DISABLE_DOWNLOAD") || error("DATADEPS_DISABLE_DOWNLOAD enviroment variable set. Can not trigger download.")
    always_accept_terms || accept_terms(datadep, localdir, remotepath)

    local fetched_path
    while true
        fetched_path = run_fetch(datadep.fetch_method, remotepath, localdir)
        if skiphash || checksum_pass(datadep.hash, fetched_path)
            break
        end
    end

    run_post_fetch(datadep.post_fetch_method, fetched_path)
end

"""
    run_fetch(fetch_method, remotepath, localdir)

executes the fetch_method on the given remote_path,
into the local directory and local paths.
Performs in (async) parallel if multiple paths are given
"""
function run_fetch(fetch_method, remotepath, localdir)
    mkpath(localdir)
    localpath = joinpath(localdir, basename(remotepath))
    #use the local folder and the remote filename
    fetch_method(remotepath, localpath)
    localpath
end

function run_fetch(fetch_method, remotepaths::Vector, localdir)
    asyncmap(rp->run_fetch(fetch_method, rp, localdir),  remotepaths)
end

function run_fetch(fetch_methods::Vector, remotepaths::Vector, localdir)
    asyncmap((meth, rp)->run_fetch(meth, rp, localdir),  fetch_method, remotepaths)
end


"""
    run_post_fetch(post_fetch_method, fetched_path)

executes the post_fetch_method on the given fetched path,
Performs in (async) parallel if multiple paths are given
"""
function run_post_fetch(post_fetch_method, fetched_path)
    cd(dirname(fetched_path)) do
        # Run things in the directory fetched from
        # useful if running `Cmds`
        post_fetch_method(fetched_path)
    end
end

function run_post_fetch(post_fetch_method, fetched_paths::Vector)
    asyncmap(fp->run_post_fetch(post_fetch_method, fp),  fetched_paths)
end

function run_post_fetch(post_fetch_methods::Vector, fetched_paths::Vector)
    asyncmap((meth, fp)->run_post_fetch(post_fetch_method, fp),  fetched_paths, post_fetch_method)
end



"""
    checksum_pass(hash, fetched_path)

Ensures the checksum passes, and handles the dialog with use user when it fails.
"""
function checksum_pass(hash, fetched_path)
    if !run_checksum(hash, fetched_path)
        warn("Hash failed on $(fetched_path)")
        reply = input_choice("Do you wish to Abort, Retry download or Ignore", 'a','r','i')
        if reply=='a'
            error("Hash Failed")
        elseif reply=='r'
            return false
        end
    end
    true
end

function accept_terms(dd::DataDep, localpath, remotepath)
    info(dd.extra_message)
    info("\n")
    if !input_bool("Do you want to download the dataset from $remotepath to \"$localpath\"?")
        error("User declined to download $(dd.name). Can not proceed without the data.")
    end
    true
end
