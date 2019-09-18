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
            "5" # seconds
        end
    end
    parse(Float32, envvar)
end

"""
    fetch_default(remote_path, local_path)

The default fetch method.
It tries to be a little bit smart to work with things other than just HTTP.
See also [`fetch_base`](@ref) and [`fetch_http`](@ref).
"""
function fetch_default(remotepath, localdir)
    if remotepath isa AbstractString && occursin(r"^https?://", remotepath)
        # It is HTTP, use good HTTP method, that gets filename by HTTP rules
        return fetch_http(remotepath, localdir)
    else
        # More generic fallback, hopefully `Base.basename`
        return fetch_base(remotepath, localdir)
    end
end


"""
  fetch_base(remote_path, local_dir)

Download from `remote_path` to `local_dir`, via `Base` mechanisms.
The download is performed using `Base.download`
and `Base.basename(remote_path)` is used to determine the filename.
This is very limitted in the case of HTTP as the filename is not always encoded in the URL.
But it does work for simple paths like `"http://myserver/files/data.csv"`.
In general for those cases prefer `http_download`.

The more important feature is that this works for anything that has overloaded
`Base.basename` and `Base.download`, e.g. [`AWSS3.S3Path`](https://github.com/JuliaCloud/AWSS3.jl).
While this doesn't work for all transport mechanisms (so some datadeps will still a custom `fetch_method`),
it works for many.
"""
function fetch_base(remote_path, local_dir)
    localpath = joinpath(local_dir, basename(remote_path))
    return Base.download(remote_path, localpath)
    return string(localpath)
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
    return HTTP.download(remotepath, localdir; update_period=update_period)
end
