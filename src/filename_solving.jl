
"""
    get_filename(remotepath)

Given a remotepath (URL) returns the filename that it should be saved to locally.
"""
function get_filename(remotepath)
    filename_match = try
        try_get_filename(remotepath)
    catch err
        # Catch *everything* here, as we can always recover and there are many things that can go wrong
        warn("Could not resolve filename due to")
        warn(err)
        warn("falling back to using final part of remotepath")
        filename_match = nothing
    end

    ret = if filename_match == nothing
        # couldn't get it from the headers
        basename(remotepath)
    else
        strip(filename_match[1])
    end
    ret
end


"""
    try_get_filename(url)

Uses as HEAD request, to attempt to retrieve the filename from the HTTP headers.
Returns a regex Match or nothing
"""
function try_get_filename(url)
    resp = HTTP.request("HEAD", url,  ["User-Agent"=>"DataDeps.jl (http-lib: HTTP.jl; lang: Julia)"]);
    content_disp = get(Dict(resp.headers),"Content-Disposition","");
    match(r"filename=\"(.*)\"", content_disp);
end
