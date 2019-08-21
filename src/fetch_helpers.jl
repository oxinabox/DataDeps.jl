# This file is a part of DataDeps.jl. License is MIT.


"""
    progress_update_period()
   
Returns the period between updated being logged on the progress.
This is used by the default `fetch_method` and is generally a good idea
to use it in any custom fetch method, if possible
"""
function progress_update_period()
    envvar = get(ENV, "DATADEPS_PROGRESS_UPDATE_PERIOD") do
        if haskey(ENV, "DATADEPS_ALWAYS_ACCEPT")
            # Running in a script, probably want minimal updates
            "Inf"
        else # default
            if haskey(ENV, "DATADEP_PROGRESS_UPDATE_PERIOD")
                @warn "\"DATADEP_PROGRESS_UPDATE_PERIOD\" is deprecated, use \"DATADEPS_PROGRESS_UPDATE_PERIOD\" instead."
                get(ENV, "DATADEP_PROGRESS_UPDATE_PERIOD", "5")
            else
                "5" # seconds
            end
        end
    end
    parse(Float32, envvar) 
end




"""
    fetch_http(remotepath, localdir; update_period=5)

Pass in a HTTP[/S] URL  and a directory to save it to,
and it downloads that file, returing the local path.
This is using the HTTP protocol's method of defining filenames in headers,
if that information is present.
Returns the localpath that it was donwloaded to.


`update_period` controls how often to print the download progress to the log.
It is expressed in seconds. It is printed at `@info` level in the log.
By default it is once per second, though this depends on configuration

"""
function fetch_http(remotepath, localdir; update_period=progress_update_period())
    @assert(isdir(localdir))
    HTTP.download(remotepath, localdir; update_period=update_period)
end



