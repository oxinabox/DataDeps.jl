# This file is a part of DataDeps.jl. License is MIT.

# Compatibility shim for Downloads v1.6 (Julia 1.10 LTS)

struct BadEncoding <: Exception end

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

"""
    try_content_disposition(url)

Try to get filename from Content-Disposition header via HEAD request.
Returns `nothing` if unsuccessful.
Note: Only needed for Downloads < v1.7; newer versions handle this automatically.
"""
function try_content_disposition(url::AbstractString)
    try
        response = Downloads.request(url, method="HEAD")
        for (key, val) in response.headers
            if lowercase(key) == "content-disposition"
                m = match(r"filename=\s*\"?([^\";]+)\"?", val)
                m !== nothing && return String(m.captures[1])
            end
        end
    catch
        # HEAD request failed or no Content-Disposition header
    end
    return nothing
end

"""
    determine_filename(url, tempfile_path)

Determine the best filename for a download using multiple strategies:
1. Content-Disposition header (via HEAD request, Downloads 1.6 fallback)
2. URL filename extraction (handles percent-encoding)
3. Temporary filename from Downloads.download
4. Fallback to URL path component
"""
function determine_filename(url::AbstractString, tempfile_path::AbstractString)
    tempfile_basename = basename(tempfile_path)

    # If Downloads generated a temp name (jl_*), try to find a better name
    if startswith(tempfile_basename, "jl_")
        # Try Content-Disposition first (only needed for Downloads 1.6)
        filename = try_content_disposition(url)
        filename !== nothing && return filename

        # Try extracting and decoding from URL (inlined url_filename logic)
        m = match(r"^[a-z][a-z+._-]*://[^#?]*/([^/#?]+)(?:[#?]|$)"i, url)
        if m !== nothing
            filename = url_unescape(m[1])
            filename !== nothing && return filename
        end

        # Fallback to simple URL parsing (without decoding)
        url_without_params = split(url, '?')[1]
        path_component = split(url_without_params, '/')[end]
        !isempty(path_component) && return path_component

        return "unknown_file"
    end

    # Downloads already found a good filename
    return tempfile_basename
end

# url_filename for progress hints in fetch_http
# Extracts and decodes the filename from URL
function url_filename(url::AbstractString)
    m = match(r"^[a-z][a-z+._-]*://[^#?]*/([^/#?]+)(?:[#?]|$)"i, url)
    m === nothing && return
    url_unescape(m[1])
end
