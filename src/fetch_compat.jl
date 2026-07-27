# This file is a part of DataDeps.jl. License is MIT.

# Compatibility shim for Downloads v1.6 (Julia 1.10 LTS)
# Implements filename handling backported from Downloads.jl v1.7+

## Getting file names from URLs and Responses

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

# Special names on Windows: CON PRN AUX NUL COM1-9 LPT1-9
# we spell out uppercase/lowercase because of locales
# these are dangerous with or without an extension
const WIN_SPECIAL_NAMES = r"^(
    [Cc][Oo][Nn] |
    [Pp][Rr][Nn] |
    [Aa][Uu][Xx] |
    [Nn][Uu][Ll] |
    [Cc][Oo][Mm][1-9] |
    [Ll][Pp][Tt][1-9]
)(\.|$)"x

"""
    is_safe_filename(name)

Check if a filename is safe to use (backported from Downloads.jl v1.7+).
Prevents path traversal, Windows special names, control characters, etc.
"""
function is_safe_filename(name::AbstractString)
    isvalid(name) || return false
    '/' in name && return false
    name in ("", ".", "..") && return false
    any(iscntrl, name) && return false
    if Sys.iswindows()
        name[end] ∈ ". " && return false
        any(in("\"*:<>?\\|"), name) && return false
        contains(name, WIN_SPECIAL_NAMES) && return false
    end
    return true
end

is_safe_filename(::Nothing) = false

"""
    url_filename(url)

Extract and validate filename from URL (backported from Downloads.jl v1.7+).
Returns `nothing` if no valid filename can be extracted or if unsafe.
"""
function url_filename(url::AbstractString)
    m = match(r"^[a-z][a-z+._-]*://[^#?]*/([^/#?]+)(?:[#?]|$)"i, url)
    if m !== nothing
        name = url_unescape(m[1])
        is_safe_filename(name) && return name
    end
    return nothing
end

"""
    try_content_disposition(url)

Try to get filename from Content-Disposition header via HEAD request.
Returns `nothing` if unsuccessful or if filename is unsafe.
Note: Only needed for Downloads < v1.7; newer versions handle this automatically.
"""
function try_content_disposition(url::AbstractString)
    try
        response = Downloads.request(url, method="HEAD")
        for (key, val) in response.headers
            if lowercase(key) == "content-disposition"
                # Simple regex extraction (Downloads 1.7 has more sophisticated parsing)
                m = match(r"filename=\s*\"?([^\";]+)\"?", val)
                if m !== nothing
                    filename = String(m.captures[1])
                    is_safe_filename(filename) && return filename
                end
            end
        end
    catch
        # HEAD request failed or no Content-Disposition header
    end
    return nothing
end

"""
    resolve_filename(url, tempfile_path)

Resolve the best filename for a download using multiple strategies:
1. Content-Disposition header (via HEAD request, Downloads 1.6 fallback)
2. URL filename extraction (handles percent-encoding and safety checks)
3. Temporary filename from Downloads.download
4. Fallback to safe default
"""
function resolve_filename(url::AbstractString, tempfile_path::AbstractString)
    tempfile_basename = basename(tempfile_path)

    # If Downloads generated a temp name (jl_*), try to find a better name
    if startswith(tempfile_basename, "jl_")
        # Try Content-Disposition first (only needed for Downloads 1.6)
        filename = try_content_disposition(url)
        filename !== nothing && return filename

        # Try extracting and decoding from URL with safety checks
        filename = url_filename(url)
        filename !== nothing && return filename

        # Fallback to simple URL parsing (without decoding)
        url_without_params = split(url, '?')[1]
        path_component = split(url_without_params, '/')[end]
        if !isempty(path_component) && is_safe_filename(path_component)
            return path_component
        end

        return "download"  # Safe default
    end

    # Downloads already found a filename, but verify it's safe
    is_safe_filename(tempfile_basename) && return tempfile_basename
    return "download"  # Safe default if unsafe
end
