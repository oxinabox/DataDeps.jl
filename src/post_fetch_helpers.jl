# This file is a part of DataDeps.jl. License is MIT.

"""
    unpack(f; keep_originals=false)

Extracts the content of an archive in the current directory;
deleting the original archive, unless the `keep_originals` flag is set.
"""
function unpack(f; keep_originals=false)
    file,directory,extension,secondary_extension = f, first(splitext(f)), last(splitext(f)), last(splitext(first(splitext(f))))

    p7zip() do p7zip_executable_path
        try
            if secondary_extension == ""
                run(`$p7zip_executable_path e $file -o$directory -y`)
            else
                intermediate_dir, intermediate_file = first(splitdir(file)), directory
                directory = first(splitext(intermediate_file))

                # 7z x creates intermediate compressed file
                run(`$p7zip_executable_path x $file -o$intermediate_dir -y`)
                # 7z e extracts the intermediate file and places content in a directory
                run(`$p7zip_executable_path e $intermediate_file -o$directory -y`)
                # once this process is successful intermediate file is deleted
                rm(intermediate_file)
            end
        catch err
            throw(ArgumentError("failed to extract specified file. Please check if the path is correct, if yes, either the file has an unsupported extension or corrupt."))
        end
    end

    rm("pax_global_header"; force=true)# Non-compliant tarball extractors dump out this file. It is meaningly (google it's filename for more)
    !keep_originals && rm(f)
end
