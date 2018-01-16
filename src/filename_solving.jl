
"""
    get_filename(remotepath)

Given a remotepath (URL) returns the filename that it should be saved to locally.
"""
function get_filename(remotepath)
    headers = get_headers(remotepath)
    filename_match = try_get_filename(remotepath)
    ret = if filename_match == nothing
        # couldn't get it from the headers
        basename(remotepath)
    else
        strip(filename_match[1])
    end
    @show ret
    ret
end


downloadcmd = nothing

@static if is_windows()
    "Returns a regex Match or nothing"
    function try_get_filename(url)
        ps = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
        prog ="""
            \$request = [System.Net.WebRequest]::Create('$url')
            \$request.UserAgent = "Julia DataDeps.jl"
            \$request.Method = "HEAD"
            \$request.GetResponse().Headers["Content-Disposition"]
            """
        content_disp = readstring(`$ps -NoProfile -Command "$prog"`)
        # If Content-Disposition is not set, then it returns "" (the empty string)
        # else returns a single line e.g. "attachment; filename=JuliaCI-Coverage.jl-v0.4.0-13-g35b8b49.tar.gz"

        # can be chill with this regex as the header is fully parsed
        match(r".*filename=(.*)", content_disp)
    end
else
    "Returns a regex Match or nothing"
    function try_get_filename(url)
        headers = get_headers(url)
        # be harsh with the following regex as it is not parsed
        # so need to make it as hard as possible for a pathological URL to break it.
        match(r"^\s*Content\-Disposition\:.*filename=(.*)\s*$"m, headers)
    end

    function get_headers(url)
        global downloadcmd
        if downloadcmd === nothing
            for checkcmd in (:curl, :wget) # fetch will not do this AFAIK
                if success(pipeline(`which $checkcmd`, DevNull))
                    downloadcmd = checkcmd
                    break
                end
            end
        end
        if downloadcmd == :curl
            readstring(`curl -sI -L $url`)
        elseif downloadcmd == :wget
            readstring(`wget --server-response --spider $url`)
        else
            error("no download agent available; install curl, or wget")
        end
    end
end

