# This file is a part of DataDeps.jl. License is MIT.


"""
    get_filename(remotepath)

Given a remotepath (URL) returns the filename that it should be saved to locally.
"""
function get_filename(remotepath)
    filename = try
        try_get_filename(remotepath)
    catch err
        # Catch *everything* here, as we can always recover and there are many things that can go wrong
        warn("Could not resolve filename due to")
        warn(err)

        filename = nothing
    end

    ret = if filename == nothing
        warn("falling back to using final part of remotepath")
        # couldn't get it from the headers
        basename(remotepath)
    else
        filename
    end
    ret
end


"""
    try_get_filename(url)

Uses as HEAD request, to attempt to retrieve the filename from the HTTP headers.
Returns a string or nothing if it failes
"""
function try_get_filename(url)
    if lowercase(url[1:4])=="http"
        resp = HTTP.request("HEAD", url,  ["User-Agent"=>"DataDeps.jl (http-lib: HTTP.jl; lang: Julia)"]);
        content_disp = get(Dict(resp.headers),"Content-Disposition","");
        raw = match(r"filename\s*=\s*(.*)", content_disp); # TECHDEBT: Consider if more of this should be moved to process header filename

        process_header_filename(raw)
    else
        nothing
    end
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

process_header_filename(::Void) = nothing
