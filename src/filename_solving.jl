
"""
    get_filename(remotepath)

Given a remotepath (URL) returns the filename that it should be saved to locally.
"""
function get_filename(remotepath)
    headers = get_headers(remotepath)
    filename_match = match(r"Content\-Disposition\:.*filename=(.*)", headers)
    if filename_match == nothing
        # couldn't get it from the headers
        basename(remotepath)
    else
        strip(filename_match[1])
    end
end


downloadcmd = nothing

@static if is_windows()
    function get_headers(url)
        # WARNING: On windows this doesn't get all the headers
        # it only gets content-disposition, which is all we need
        # If that is not set, then it returns "" (the empty string)
        ps = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
        prog ="""
            \$request = [System.Net.WebRequest]::Create('$url')
            \$request.UserAgent = "Julia DataDeps.jl"
            \$request.Method = "HEAD"
            \$request.GetResponse().Headers["Content-Disposition"]
            """
        readstring(`$ps -NoProfile -Command "$prog"`)
    end
else
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

