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

    always_accept_terms || accept_terms(datadep, localdir, remotepath)

    #use the local folder and the remote filename
    localpath = joinpath(localdir, basename(remotepath))

    @label retry
    mkpath(localdir)

    fetched_path = datadep.fetch_method(remotepath, localpath)

    if !skiphash
        if !run_checksum(datadep.hash, fetched_path)
            warn("Hash failed")
            reply = input_choice("Do you wish to Abort, Retry download or Ignore", 'a','r','i')
            if reply=='a'
                error("Hash Failed")
            elseif reply=='r'
                @goto retry
            end
        end
    end

    datadep.post_fetch_method(fetched_path)
end


function accept_terms(dd::DataDep, localpath, remotepath)
    info(dd.extra_message)
    info("\n")
    if !input_bool("Do you want to download the dataset from $remotepath to \"$localpath\"?")
        error("User declined to download $(dd.name). Can not proceed without the data.")
    end
    true
end
