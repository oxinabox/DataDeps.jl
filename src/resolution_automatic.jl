# This file is a part of DataDeps.jl. License is MIT.

"""
    handle_missing(datadep::DataDep, calling_filepath)::String

This function is called when the datadep is missing.
"""
function handle_missing(datadep::DataDep, calling_filepath)::String
    save_dir = determine_save_path(datadep.name, calling_filepath)
    download(datadep, save_dir)
    save_dir
end


"""
    ensure_download_permitted()

This function will throw an error if download functionality has been disabled.
Otherwise will do nothing.
"""
function ensure_download_permitted()
    if env_bool("DATADEPS_DISABLE_DOWNLOAD")
        throw(DisabledError("DATADEPS_DISABLE_DOWNLOAD enviroment variable set."))
    end
    if env_bool("CI") && !haskey(ENV, "DATADEPS_ALWAYS_ACCEPT")
        throw(DisabledError("DataDeps download disabled, as we appear to be in a CI environment, " *
                            "and the environment variable `DATADEPS_ALWAYS_ACCEPT` is not set.\n" *
                            "If this is indeed running in a headless CI environment, then " *
                            "set the `DATADEPS_ALWAYS_ACCEPT` environment variable to `true` to bypass " *
                            "the accept download prompt (if you do wish to always accept.)\n" *
                            "If not, then either unset the `CI` environment variable from true, or " *
                            "set `DATADEPS_ALWAYS_ACCEPT` to `false` for the normal prompt behaviour."))
    end
end

"""
    Base.download(
        datadep::DataDep,
        localdir;
        remotepath=datadep.remotepath,
        skip_checksum=false,
        i_accept_the_terms_of_use=nothing)

A method to download a datadep.
Normally, you do not have to download a data dependancy manually.
If you simply cause the string macro `datadep"DepName"`,
to be exectuted it will be downloaded if not already present.

Invoking this `download` method manually is normally for purposes of debugging,
As such it include a number of parameters that most people will not want to use.

 - `localdir`: this is the local directory to save to.
 - `remotepath`: the remote path to fetch the data from, use this e.g. if you can't access the normal path where the data should be, but have an alternative.
 - `skip_checksum`: setting this to true causes the checksum to not be checked. Use this if the data has changed since the checksum was set in the registry, or for some reason you want to download different data.
 - `i_accept_the_terms_of_use`: use this to bypass the I agree to terms screen. Useful if you are scripting the whole process, or using annother system to get confirmation of acceptance.
     - For automation perposes you can set the enviroment variable `DATADEPS_ALWAYS_ACCEPT`
     - If not set, and if `DATADEPS_ALWAYS_ACCEPT` is not set, then the user will be prompted.
     - Strictly speaking these are not always terms of use, it just refers to the message and permission to download.

 If you need more control than this, then your best bet is to construct a new DataDep object, based on the original,
 and then invoke download on that.
"""
function Base.download(
    datadep::DataDep,
    localdir;
    remotepath=datadep.remotepath,
    i_accept_the_terms_of_use = nothing,
    skip_checksum=false)

    ensure_download_permitted()

    accept_terms(datadep, localdir, remotepath, i_accept_the_terms_of_use)

    mkpath(localdir)
    try
        local fetched_path
        while true # this is a Do-While loop
            fetched_path = run_fetch(datadep.fetch_method, remotepath, localdir)
            if skip_checksum || checksum_pass(datadep.hash, fetched_path)
                break
            end
        end

        run_post_fetch(datadep.post_fetch_method, fetched_path)
    catch err
        env_bool("DATADEPS_DISABLE_ERROR_CLEANUP") || rm(localdir, force=true, recursive=true)
        rethrow(err)
    end
end

"""
    run_fetch(fetch_method, remotepath, localdir)

executes the fetch_method on the given remote_path,
into the local directory and local paths.
Performs in (async) parallel if multiple paths are given
"""
function run_fetch(fetch_method, remotepath, localdir)
    localpath = fetch_method(remotepath, localdir)
    localpath
end

function run_fetch(fetch_method, remotepaths::AbstractVector, localdir)
    asyncmap(rp->run_fetch(fetch_method, rp, localdir),  remotepaths)
end

function run_fetch(fetch_methods::AbstractVector, remotepaths::AbstractVector, localdir)
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

function run_post_fetch(post_fetch_method, fetched_paths::AbstractVector)
    asyncmap(fp->run_post_fetch(post_fetch_method, fp),  fetched_paths)
end

function run_post_fetch(post_fetch_methods::AbstractVector, fetched_paths::AbstractVector)
    asyncmap(run_post_fetch,  post_fetch_methods, fetched_paths)
end



"""
    checksum_pass(hash, fetched_path)

Ensures the checksum passes, and handles the dialog with use user when it fails.
"""
function checksum_pass(hash, fetched_path)
    if !run_checksum(hash, fetched_path)
        reply = input_choice("Do you wish to Abort, Retry download or Ignore", 'a','r','i')
        if reply=='a'
            abort("Hash Failed, user elected not to retry")
        elseif reply=='r'
            return false
        end
    end
    true
end

##############################
# Term acceptance checking

"""
    accept_terms(datadep, localpath, remotepath, i_accept_the_terms_of_use)

Ensurses the user accepts the terms of use; otherwise errors out.
"""
function accept_terms(datadep::DataDep, localpath, remotepath, ::Nothing)
   if haskey(ENV, "DATADEPS_ALWAY_ACCEPT")
       @warn("Environment variable \$DATADEPS_ALWAY_ACCEPT is deprecated. " *
            "Please use \$DATADEPS_ALWAYS_ACCEPT instead.")
   end
    if !(env_bool("DATADEPS_ALWAYS_ACCEPT") || env_bool("DATADEPS_ALWAY_ACCEPT"))
        response = check_if_accept_terms(datadep, localpath, remotepath)
        accept_terms(datadep, localpath, remotepath, response)
    else
        true
    end
end
function accept_terms(datadep::DataDep, localpath, remotepath, i_accept_the_terms_of_use::Bool)
    if !i_accept_the_terms_of_use
        abort("User declined to download $(datadep.name). Can not proceed without the data.")
    end
    true
end

function check_if_accept_terms(datadep::DataDep, localpath, remotepath)
    println("This program has requested access to the data dependency $(datadep.name).")
    println("which is not currently installed. It can be installed automatically, and you will not see this message again.")
    println("\n",datadep.extra_message,"\n\n")
    input_bool("Do you want to download the dataset from $remotepath to \"$localpath\"?")
end
