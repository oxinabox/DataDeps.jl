# Code for doing checksums etc.

"""
    run_checksum(checksum, path)

THis runs the checksum on the files at the fetched_path.
It is kinda flexible and accepts different kinds of behavour
to give different kinds of results.

If path (the second parameter) is a Vector,
then unless checksum is also a Vector,
the result is the xor of the all the file checksums.
"""
function run_checksum(hash::Tuple{<:Any, <:AbstractString}, path)
    hasher, target = hash
    checksum(hasher)(path) == target
end


"""
Providing only a hash string,
results in defaulting to sha2_256,
with that string being the target
"""
run_checksum(hash::AbstractString, path) = run_checksum((sha2_256, hash), path)


"""
If a vector of paths is provided
and a vector of hashing methods (of any form)
then they are all required to match.
"""
function run_checksum(hash::Vector, path::Vector)
    all(run_checksum.(hash, path))
end

"""
If only a function is provided then assume the user is a developer,
wanting to know what hash-line to add to the Registration line.
"""
function run_checksum(hasher, path)
    res = checksum(hasher)(path)
    info("Checksum not provided, add to the Datadep Registration the following hash line")
    if hasher==sha2_256
        info(repr(res))
    else
        info(repr((hasher, res)))
    end
    return true
end



"""
    checksum([hasher=sha2_256])

Helper function for constructing checksum checking functions.

 - `hasher` should be a function taking as its argument an IO stream returning a UInt8 byte array.
     - e.g the functions from SHA.jl: `sha2_256`, `sha_3_512`  etc
     - or an anon function around `digest` from Nettle.jl : `io->digest("MD5", io)`
 - `checksum` is a string representing that hash in hex

This returns a function which takes a filename (or filenames),
and returns true if the hash of the file matches the `checksum` string.
If multiple filenames are passed then their hashes are `xor`d
"""
function checksum(hasher=sha2_256)
    function (filenames...)
        checksum_bin = reduce(xor, open.(hasher, filenames))
        bytes2hex(checksum_bin)
    end
end
