# This file is a part of DataDeps.jl. License is MIT.

function unpack_cmd(file,directory,extension,secondary_extension)
    p7zip() do exe7z
        if secondary_extension == ".tar" || extension == ".tgz" || extension == ".tbz"
            # special handling for compressed tarballs
            return pipeline(`$exe7z x $file -y -so`, `$exe7z x -si -y -ttar -o$directory`)
        else
            return `$exe7z x $file -y -o$directory`
        end
    end
end

"""
    unpack(f; keep_originals=false)

Extracts the content of an archive in the current directory;
deleting the original archive, unless the `keep_originals` flag is set.
"""
function unpack(f; keep_originals=false)
    run(unpack_cmd(f, pwd(), last(splitext(f)), last(splitext(first(splitext(f))))))
    rm("pax_global_header"; force=true)  # Non-compliant tarball extractors dump out this file. It is meaningless (google it's filename for more)
    !keep_originals && rm(f)
end
