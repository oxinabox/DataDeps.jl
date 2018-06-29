# This file is a part of DataDeps.jl. License is MIT.

# TODO Remove this whole thing once https://github.com/JuliaWeb/HTTP.jl/pull/273

"""
    fetch_http(remotepath, localdir)

Pass in a HTTP[/S] URL  and a directory to save it to,
and it downloads that file, returing the local path.
This is using the HTTP protocol's method of defining filenames in headers,
if that information is present.
"""
function fetch_http(remotepath, localdir)
    @assert(localdir |> isdir)
    filename = get_filename(remotepath)
    localpath = safer_joinpath(localdir, filename)
    Base.download(remotepath, localpath)
end


"""
    safer_joinpath(basepart, parts...)

A variation on `joinpath`, that is more resistant to directory traveral attack
The parts to be joined (excluding the `basepart`),
are not allowed to contain `..`, or begin with a `/`.
If they do then this throws an `DomainError`.
"""
function safer_joinpath(basepart, parts...)
    explain =  "Possible Directory Traversal Attack detected."
    for part in parts
        contains(part, "..") && throw(DomainError(part, "contains illegal string \"..\". $explain"))
        startswith(part, '/') && throw(DomainError(part, "begins with \"/\". $explain"))
    end
    joinpath(basepart, parts...)
end


"""
    get_filename(remotepath)

Given a remotepath (URL) returns the filename that it should be saved to locally.
"""
function get_filename(remotepath)
    filename = try
        try_get_filename(remotepath)
    catch err
        # Catch *everything* here, as we can always recover and there are many things that can go wrong
        @warn("Could not resolve filename due to")
        @warn(err)
        @warn("falling back to using final part of remotepath")
        filename = nothing
    end

    if filename == nothing
        # couldn't get it from the headers
        filename = basename(remotepath)
    end
    filename
end


"""
    try_get_filename(url)

Uses as HEAD request, to attempt to retrieve the filename from the HTTP headers.
Returns a string or nothing if it failes
"""
function try_get_filename(url)
    resp = HTTP.request("HEAD", url,  ["User-Agent"=>"DataDeps.jl (http-lib: HTTP.jl; lang: Julia)"]);
    content_disp = get(Dict(resp.headers),"Content-Disposition","");
    raw = match(r"filename\s*=\s*(.*)", content_disp); # TECHDEBT: Consider if more of this should be moved to process header filename

    process_header_filename(raw)
end

"""
    process_header_filename(raw)

Deal with some of the weird and varied ways filenames can be given.
Not full coverage, but getting the common cases.

Return nothing if input is nothing
"""
function process_header_filename(raw::RegexMatch)::String
    ret = raw[1]
    quoted_match = match(r"\"(.*)\"", ret)
    
    if quoted_match != nothing
        ret = unescape_string(quoted_match[1]) #It was in quotes, so it will be double escaped
    end
    
    strip(ret)
end

process_header_filename(::Nothing) = nothing
