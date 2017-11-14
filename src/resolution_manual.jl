
function handle_missing(datadep::ManualDataDep, calling_filepath)::String
    localpaths = list_local_paths(datadep, calling_filepath)

    info("Failed to find $(datadep.name)")
    info("$(datadep.name) requires manual installation.")
    info("Please install it to one of the directories in the DataDeps load path: " *
          join(localpath,", ", "or"))
    info("by following the instructions:")
    info(datadep.message)
    info()
    while true
        reply = input_choice("Once installed please enter 'y' reattempt loading, or 'a' to abort", 'y','a')
        if reply=='a'
            error("User has aborted attempt to load datadep. Can not proceed without loading.")
        end
        lp = try_determine_load_path(datadep, calling_filepath)
        if isnull(lp)
            info("Still failed to find $(datadep.name). User should reattempt to install it.")
        else
            return get(lp)
        end
    end
end
