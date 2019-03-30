# This file is a part of DataDeps.jl. License is MIT.
# Code for doing checksums etc.

##################
# Terminal methods

"""
    run_checksum(checksum, path)

THis runs the checksum on the files at the fetched_path.
And returns true or false base on if the checksum matchs.
(always true if no target sum given)
It is kinda flexible and accepts different kinds of behavour
to give different kinds of results.

If path (the second parameter) is a Vector,
then unless checksum is also a Vector,
the result is the xor of the all the file checksums.
"""
function run_checksum((hasher, expected_hash)::Tuple{<:Any, <:AbstractString}, path)
    actual_hash = hexchecksum(hasher, path)
    
    if actual_hash != expected_hash
        @warn "Checksum did not match" expected_hash actual_hash path
        return false
    else
        return true
    end
end


"""
Use `Any` to mark as not caring about the hash.
Use this for data that can change
"""
run_checksum(::Type{Any}, path) =  true

"""
If only a function is provided then assume the user is a developer,
wanting to know what hash-line to add to the Registration line.
"""
function run_checksum(hasher, path)
    res = hexchecksum(hasher, path)
    @warn("Checksum not provided, add to the Datadep Registration the following hash line",
          hash = hasher==sha2_256 ? res : (hasher, res)
         )
    return true
end

##############
# Non terminal methods
# These evetually redirect to one of the terminal methods

"""
Providing only a hash string,
results in defaulting to sha2_256,
with that string being the target
"""
run_checksum(hash::AbstractString, path) = run_checksum((sha2_256, hash), path)

"""
If `nothing` is provided then assume the user is a developer,
wanting to know what sha2_256 hash-line to add to the Registration line.
"""
run_checksum(::Nothing, path) = run_checksum(sha2_256, path)


"""
If a vector of paths is provided
and a vector of hashing methods (of any form)
then they are all required to match.
"""
function run_checksum(hash::AbstractVector, path::AbstractVector)
    all(run_checksum.(hash, path))
end



######################
# Actual executor

"""
    checksum(hasher=sha2_256, filename[/s])

Executes the hasher, on the file/files,
and returns a UInt8 array of the hash.
xored if there are multiple files
"""
checksum(hasher, filename) = open(hasher, filename, "r")
checksum(hasher, filenames::AbstractVector) = xor.(checksum.(hasher, filenames)...)

hexchecksum(hasher, filename) = bytes2hex(checksum(hasher, filename))
