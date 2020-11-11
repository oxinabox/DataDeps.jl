# This file is a part of DataDeps.jl. License is MIT.

"""
    unpack(f; keep_originals=false)

Extracts the content of an archive in the current directory;
deleting the original archive, unless the `keep_originals` flag is set.
"""
function unpack(f; keep_originals=false)
    file = f # /home/hello/xyz.zip  |   /home/hello/xyz.tar.gz
    directory = first(splitext(f)) # /home/hello/xyz  |   /home/hello/xyz.tar
    extension = last(splitext(f)) # .zip    |   .gz
    secondary_extension = last(splitext(first(splitext(f)))) #  ""  |   .tar
    # p7zip() returns the path of 7z exectuable
    p7zip() do p7zip_executable_path
        try
            if secondary_extension == ""
                # for files with a single compression like .zip, .rar, etc.
                run(`$p7zip_executable_path e $file -o$directory -y`)
            else
                # files with secondary extension like .tar.gz, 
                # first extract .tar.gz to .tar in the directory where .tar.gz was present
                # this .tar is the intermediate file 
                # splitext("/home/filename.tar.gz") returns "/home/filename.tar" which is filename of our intermediate file
                intermediate_dir, intermediate_file = first(splitdir(file)), directory
                # directory in which data is to be extracted is split again
                # "/home/filename.tar" is converted to "/home/filename"
                directory = first(splitext(intermediate_file))
                # check out 7z docs for more information
                # 7z x creates intermediate compressed file
                run(`$p7zip_executable_path x $file -o$intermediate_dir -y`)
                # 7z e extracts the intermediate file and places content in a directory
                run(`$p7zip_executable_path e $intermediate_file -o$directory -y`)
                # once this process is successful intermediate file is deleted
                rm(intermediate_file)
            end
        catch err
            @warn "failed to extract specified file. Please check if the path is correct, if yes, either the file has an unsupported extension or corrupt."
            rethrow(err)
        end
    end
    !keep_originals && rm(f)
end
