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
    default_progress_callback(total, now, filename_hint=nothing)

Default progress logger used by [`fetch`](@ref) when no custom callback is
provided and `update_period` is finite.
"""
function default_progress_callback(total, now, filename_hint=nothing)
    name_str = filename_hint !== nothing ? " $filename_hint:" : ":"
    if total > 0
        pct_str = " ($(round(100 * now / total; digits=1))%)"
        @info "Downloading$name_str $(now) / $(total) bytes$pct_str"
    else
        @info "Downloading$name_str $(now) bytes"
    end
end

"""
    fetch(remote_path, local_dir;
          progress_callback=nothing,
          update_period=progress_update_period())

Unified fetch implementation. Downloads `remote_path` to `local_dir`.

The download is performed in two steps:
1. Download to temporary location (via `Downloads.download`)
2. Move to `local_dir` using the basename of the downloaded file

For HTTP URLs, this properly handles Content-Disposition headers and percent-encoded
filenames. For custom types, implement `Downloads.download(::YourType)` to return
a path where `basename()` gives the correct filename.

# Arguments
- `remote_path`: URL string or custom path object supporting `Downloads.download`
- `local_dir`: Target directory for the downloaded file
- `progress_callback`: Optional callback `(total_bytes, downloaded_bytes, filename_hint) -> nothing`
    called on each throttled update. If omitted and `update_period` is finite,
    [`default_progress_callback`](@ref) is used.
- `update_period`: Seconds between progress updates. `Inf` disables progress
    callback invocation and progress logging.

# Custom Types
To support custom download sources, implement:
```julia
function Downloads.download(p::YourType; progress=nothing)
    # Download the file
    tempfile = download_your_way(p; progress=progress)
    # Ensure basename(tempfile) is the desired filename!
    # Either download to a temp dir with the right name, or rename the temp file
    return tempfile
end
```

# Examples
```julia
# Simple HTTP download with progress
fetch("https://example.com/data.csv", "/tmp")

# With custom progress callback
fetch(url, "/tmp";
    update_period=1,
    progress_callback = (total, now, name) -> println("\$name \$now/\$total"))

# Without progress logging
fetch(url, "/tmp"; update_period=Inf)
```
"""
function fetch(remote_path, local_dir;
               progress_callback=nothing,
               update_period=progress_update_period())
    @assert isdir(local_dir)

    # Setup progress tracking if needed
    progress = nothing
    if progress_callback !== nothing || !isinf(update_period)
        downloaded_bytes = 0
        total_bytes = 0
        last_update_time = time()

        # Hint for logging (best effort, may be nothing)
        filename_hint = remote_path isa AbstractString ? url_filename(remote_path) : nothing

        progress_callback === nothing && (progress_callback = default_progress_callback)
        
        progress = function(total, now)
            downloaded_bytes = now
            total_bytes = total
            current_time = time()
            
            # Throttled logging
            if !isinf(update_period) && (current_time - last_update_time) >= update_period
                progress_callback(total_bytes, downloaded_bytes, filename_hint)
                last_update_time = current_time
            end
        end
    end

    # Download to temporary location
    # Downloads.jl (or custom type) is responsible for choosing temp path
    # Only pass progress kwarg if we actually have a progress callback
    tempfile = if progress === nothing
        Downloads.download(remote_path)
    else
        Downloads.download(remote_path; progress)
    end

    # Extract filename from the downloaded path
    filename = basename(tempfile)

    # Fallback for Downloads 1.6 or other cases with bad temp names
    # resolve_filename is already defined (with compat shim)
    if startswith(filename, "jl_") && remote_path isa AbstractString
        filename = resolve_filename(remote_path, tempfile)
    end

    # Move to target directory
    localpath = joinpath(local_dir, filename)
    mv(tempfile, localpath; force=true)

    # Final progress log
    if !isinf(update_period)
        if total_bytes > 0
            @info "Downloaded $filename: $(downloaded_bytes) / $(total_bytes) bytes (complete)"
        else
            @info "Downloaded $filename: $(downloaded_bytes) bytes"
        end
    end

    return string(localpath)
end


# Compatibility shim for Downloads < v1.7 (Julia 1.10 LTS)
@static if !isdefined(Downloads, :url_filename)
    include("fetch_compat.jl")
else
    using Downloads: url_filename

    """
        resolve_filename(url, tempfile_path)

    Resolve the best filename for a download.
    In Downloads v1.7+, Downloads.download already handles Content-Disposition properly
    """
    function resolve_filename(url::AbstractString, tempfile_path::AbstractString)
        return basename(tempfile_path)
    end
end


