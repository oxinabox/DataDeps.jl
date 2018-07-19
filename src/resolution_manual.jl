# This file is a part of DataDeps.jl. License is MIT.

function handle_missing(datadep::ManualDataDep, calling_filepath)::String
    localpaths = list_local_paths(datadep, calling_filepath)
    @assert(length(localpaths) > 0)
    @info("This program requested access to the data dependency $(datadep.name)")
    @info("It could not be found on your system. It requires manual installation.")
    @info("Please install it to one of the directories in the DataDeps load path: " *
          join(localpaths,", \n", ",\nor "))
    @info("by following the instructions:")
    @info(datadep.message)
    while true
        reply = input_choice("Once installed please enter 'y' reattempt loading, or 'a' to abort", 'y','a')
        if reply=='a'
            abort("User has aborted attempt to load datadep. Can not proceed without loading.")
        end
        lp = try_determine_load_path(datadep.name, calling_filepath)
        if lp == nothing
            @info("Still failed to find $(datadep.name). User should reattempt to install it.")
        else
            return lp
        end
    end
end
