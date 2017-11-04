# Code for doing checksums etc.

"""
    checksum([hasher=sha2_256], checksum::String)

Helper function for constructing checksum checking functions.

 - `hasher` should be a function taking as its argument an IO stream returning a UInt8 byte array.
     - e.g the functions from SHA.jl: `sha2_256`, `sha_3_512`  etc
     - or an anon function around `digest` from Nettle.jl : `io->digest("MD5", io)`
 - `checksum` is a string representing that hash in hex

This returns a function which takes a filename (or filenames),
and returns true if the hash of the file matches the `checksum` string.
If multiple filenames are passed then their hashes are `xor`d
"""
function check(hasher, checksum::AbstractString)
    function (filenames...)
        checksum == reduce(xor, open.(hasher, filenames))
    end
end

check(checksum::AbstractString) = check(sha2_256, checksum)

"""
    checkhash(dd::DataDep, filepath)

Determines if a the filepath has the right hash for that DataDep
"""
checkhash(dd::DataDep{<:AbstractString}, path) = check(dd.hash)(path)
checkhash(dd::DataDep{<:AbstractString}, paths::AbstractVector) = check(dd.hash)(path...)

checkhash(dd::DataDep, path) =  dd.hash(path)
checkhash(dd::DataDep, paths::AbstractVector) = dd.hash(path...)
