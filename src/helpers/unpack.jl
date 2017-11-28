if isunix() && Sys.KERNEL != :FreeBSD
    function unpack(file,directory,extension,secondary_extension)
        if ((extension == ".gz" || extension == ".Z") && secondary_extension == ".tar") || extension == ".tgz"
            return (`tar xzf $file --directory=$directory`)
        elseif (extension == ".bz2" && secondary_extension == ".tar") || extension == ".tbz"
            return (`tar xjf $file --directory=$directory`)
        elseif extension == ".xz" && secondary_extension == ".tar"
            return pipeline(`unxz -c $file `, `tar xv --directory=$directory`)
        elseif extension == ".tar"
            return (`tar xf $file --directory=$directory`)
        elseif extension == ".zip"
            return (`unzip -x $file -d $directory`)
        elseif extension == ".gz"
            return pipeline(`mkdir $directory`, `cp $file $directory`, `gzip -d $directory/$file`)
        end
        error("I don't know how to unpack $file")
    end
end

if Sys.KERNEL == :FreeBSD
    # The `tar` on FreeBSD can auto-detect the archive format via libarchive.
    # The supported formats can be found in libarchive-formats(5).
    # For NetBSD and OpenBSD, libarchive is not available.
    # For macOS, it is. But the previous unpack function works fine already.
    function unpack(file, dir, ext, secondary_ext)
        tar_args = ["--no-same-owner", "--no-same-permissions"]
        return pipeline(
            `/bin/mkdir -p $dir`,
            `/usr/bin/tar -xf $file -C $dir $tar_args`)
    end
end

if is_windows()
    const exe7z = joinpath(JULIA_HOME, "7z.exe")

    function unpack(file,directory,extension,secondary_extension)
        if ((extension == ".Z" || extension == ".gz" || extension == ".xz" || extension == ".bz2") &&
                secondary_extension == ".tar") || extension == ".tgz" || extension == ".tbz"
            return pipeline(`$exe7z x $file -y -so`, `$exe7z x -si -y -ttar -o$directory`)
        elseif (extension == ".zip" || extension == ".7z" || extension == ".tar" ||
                (extension == ".exe" && secondary_extension == ".7z"))
            return (`$exe7z x $file -y -o$directory`)
        end
        error("I don't know how to unpack $file")
    end
end


"""
    unpack(f)

Extracts the content of an archive in the current directory
"""
unpack(f) = unpack(f, pwd(), last(splitext(f)), last(first(splitext(f))))

