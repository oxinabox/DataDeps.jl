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

Download from `remote_path` to `local_dir`, via stdlib Downloads.
The download is performed using `Downloads.download`
and `Base.basename(remote_path)` is used to determine the filename.
This is very limited in the case of HTTP as the filename is not always encoded in the URL.
But it does work for simple paths like `"http://myserver/files/data.csv"`.
In general for those cases prefer `http_download`.

The more important feature is that this works for anything that has overloaded
`Base.basename` and `Downloads.download`, e.g. [`AWSS3.S3Path`](https://github.com/JuliaCloud/AWSS3.jl).
While this doesn't work for all transport mechanisms (so some datadeps will still a custom `fetch_method`),
it works for many.
"""
function fetch_base(remote_path, local_dir)
    localpath = joinpath(local_dir, basename(remote_path))
    Downloads.download(remote_path, localpath)
    return string(localpath)
end

struct BadEncoding <: Exception end


"""
    fetch_http(remotepath, localdir; update_period=5)

Pass in a HTTP[/S] URL  and a directory to save it to,
and it downloads that file, returning the local path.
This is using the HTTP protocol's method of defining filenames in headers,
if that information is present.
Returns the localpath that it was downloaded to.


`update_period` controls how often to print the download progress to the log.
It is expressed in seconds. It is printed at `@info` level in the log.
By default it is once per second, though this depends on configuration

"""
function fetch_http(remotepath, localdir; update_period=progress_update_period())
    @assert(isdir(localdir))

    local downloaded_bytes = 0
    local total_bytes = 0
    local last_update_time = time()

    # copy from Downloads 1.7

    function hex_digit(str::AbstractString, i::Int)::Tuple{UInt8,Int}
        if i ≤ ncodeunits(str)
            d, i = iterate(str, i)
            '0' ≤ d ≤ '9' && return d - '0', i
            'a' ≤ d ≤ 'f' && return d - 'a' + 10, i
            'A' ≤ d ≤ 'F' && return d - 'A' + 10, i
        end
        throw(BadEncoding())
    end

    function url_unescape(str::Union{String, SubString{String}})
        try return sprint(sizehint = ncodeunits(str)) do io
                i = 1
                while i ≤ ncodeunits(str)
                    c, i = iterate(str, i)
                    if c == '%'
                        hi, i = hex_digit(str, i)
                        lo, i = hex_digit(str, i)
                        x = hi*0x10 + lo
                        write(io, x)
                    else
                        print(io, c)
                    end
                end
            end
        catch err
            err isa BadEncoding && return
            rethrow()
        end
    end

    # copy from Downloads 1.7
    function url_filename(url::AbstractString)
        m = match(r"^[a-z][a-z+._-]*://[^#?]*/([^/#?]+)(?:[#?]|$)"i, url)
        m === nothing && return
        url_unescape(m[1])
    end

    filename = url_filename(remotepath)

    # Progress callback with throttling based on update_period
    progress_callback = function(total, now)
        total_bytes = total
        downloaded_bytes = now

        current_time = time()
        if !isinf(update_period) && (current_time - last_update_time) >= update_period
            if filename === nothing
                # Don't have filename yet
                if total > 0
                    progress_pct = round(100 * now / total; digits=1)
                    @info "Downloading: $(now) / $(total) bytes ($(progress_pct)%)"
                else
                    @info "Downloading: $(now) bytes"
                end
            else
                if total > 0
                    progress_pct = round(100 * now / total; digits=1)
                    @info "Downloading $filename: $(now) / $(total) bytes ($(progress_pct)%)"
                else
                    @info "Downloading $filename: $(now) bytes"
                end
            end
            last_update_time = current_time
        end
    end

    function peek_filename(url::AbstractString)
        try
            # 1. Send a HEAD request
            response = Downloads.request(url, method="HEAD")
            
            filename = ""
            
            # 2. Extract and inspect the headers Vector
            for (key, val) in response.headers
                if lowercase(key) == "content-disposition"
                    matched = match(r"filename=\s*\"?([^\";]+)\"?", val)
                    if matched !== nothing
                        filename = String(matched.captures[1])
                        break
                    end
                end
            end
            
            # 3. Fallback strategy
            if isempty(filename)
                # Try url_filename which handles percent-encoding
                filename_decoded = url_filename(url)
                if filename_decoded !== nothing
                    filename = filename_decoded
                else
                    # Last resort: Take only the base URL part BEFORE the '?' query parameters
                    url_without_params = split(url, '?')[1]

                    # Extract the final element after the last slash
                    filename = String(split(url_without_params, '/')[end])

                    if isempty(filename)
                        filename = "unknown_file"
                    end
                end
            end
            
            return filename
            
        catch e
            @warn "HEAD request failed or was rejected by server. Error: $e"
            return ""
        end
    end
    
    # Download to temporary location first
    # Downloads.download without output path uses Content-Disposition or URL basename
    tempfile = Downloads.download(remotepath; progress = progress_callback)

    # Determine the final filename
    # If Downloads couldn't determine a good filename (tempfile starts with jl_),
    # try to get it from Content-Disposition header via peek_filename
    tempfile_basename = basename(tempfile)
    if startswith(tempfile_basename, "jl_")
        # Downloads used a generated temp name - try to get better filename
        peeked = peek_filename(remotepath)
        if !isempty(peeked) && !startswith(peeked, "jl_")
            # peek_filename found a reasonable name, use it
            filename = peeked
        end
    end

    # Fallback: if filename is still nothing, use tempfile basename
    if filename === nothing
        filename = tempfile_basename
    end

    # Move to the target directory
    localpath = joinpath(localdir, filename)
    mv(tempfile, localpath; force=true)

    # Final progress log
    if !isinf(update_period)
        if total_bytes > 0
            @info "Downloaded $filename: $(downloaded_bytes) / $(total_bytes) bytes (complete)"
        else
            @info "Downloaded $filename: $(downloaded_bytes) bytes (complete)"
        end
    end

    return string(localpath)
end
