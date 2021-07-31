# storage driver for DataSets.jl

function DataDep_storage_driver(user_func, storage_config, dataset)
    conf = dataset.conf
    dp = DataDep(
        conf["name"],
        "",
        storage_config["remote_path"],
        get(storage_config, "sha256", "")
    )
    localdir = expanduser(storage_config["localdir"])
    if !isdir(localdir)
        try
            DataDeps.download(dp, localdir; i_accept_the_terms_of_use=true)
        catch
            @error "failed to download dataset"
            rm(localdir; recursive=true)
        end
    end
    user_func(BlobTree(DataSets.FileSystemRoot(localdir), path"."))
end
