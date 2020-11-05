using p7zip_jll

function unpack_cmd(file,directory,extension,secondary_extension)
    if ((extension == ".Z" || extension == ".gz" || extension == ".xz" || extension == ".bz2") && secondary_extension == ".tar") || extension == ".tgz" || extension == ".tbz" || extension == ".zip" || extension== ".gz" || extension == ".7z" || extension == ".tar" || (extension == ".exe" && secondary_extension == ".7z")
        output_dir = first(splitext(file))
        p7zip() do p7zip_executable_path
            run(`$p7zip_executable_path e $file -o$output_dir`)
        end
    else
        throw(ArgumentError("I don't know how to unpack $file"))
    end
end

"""
    unpack(f; keep_originals=false)

Extracts the content of an archive in the current directory;
deleting the original archive, unless the `keep_originals` flag is set.
"""
function unpack(f; keep_originals=false)
    unpack_cmd(f, pwd(), last(splitext(f)), last(splitext(first(splitext(f)))))
    rm("pax_global_header"; force=true)# Non-compliant tarball extractors dump out this file. It is meaningly (google it's filename for more)
    !keep_originals && rm(f)
end
