# This file is a part of DataDeps.jl. License is MIT.


abstract type AbstractDataDep end

"""
    ManualDataDep(name, message)

A DataDep for if the installation needs to be handled manually.
This can be done via Pkg/git if you put the dependency into the packages repo's `/deps/data` directory.
More generally, message should give instructions on how to setup the data.
"""
struct ManualDataDep <: AbstractDataDep
    name::String
    message::String
end

struct DataDep{H, R, F, P} <: AbstractDataDep
    name::String
    remotepath::R
    hash::H
    fetch_method::F
    post_fetch_method::P
    extra_message::String
end



"""
```
DataDep(
    name::String,
    message::String,
    remote_path::Union{String,Vector{String}...},
    [checksum::Union{String,Vector{String}...},]; # Optional, if not provided will generate
    # keyword args (Optional):
    fetch_method=fetch_default # (remote_filepath, local_directory)->local_filepath
    post_fetch_method=identity # (local_filepath)->Any
)
```

#### Required Fields

 - *Name**: the name used to refer to this datadep, coresponds to a folder name where it will be stored
    - It can have spaces or any other character that is allowed in a Windows filestring (which is a strict subset of the restriction for unix filenames).
 - *Message*: A message displayed to the user for they are asked if they want to downloaded it.
    - This is normally used to give a link to the original source of the data, a paper to be cited etc.
 - *remote_path*: where to fetch the data from. Normally a string or strings) containing an URL
    - This is usually a string, or a vector of strings (or a vector of vector... see [Recursive Structure](Recursive Structure) below)

#### Optional Fields
 - *checksum* this is very flexible, it is used to check the files downloaded correctly
    - By far the most common use is to just provide a SHA256 sum as a hex-string for the files
    - If not provided, then a warning message with the  SHA256 sum is displayed. This is to help package devs workout the sum for there files, without using an external tool.
    - If you want to use a different hashing algorithm, then you can provide a tuple `(hashfun, targethex)`
        - `hashfun` should be a function which takes an IOStream, and returns a `Vector{UInt8}`.
	      - Such as any of the functions from [SHA.jl](https://github.com/staticfloat/SHA.jl), eg `sha3_384`, `sha1_512`
	      - or `md5` from [MD5.jl](https://github.com/oxinabox/MD5.jl)
  - If you want to use a different hashing algorithm, but don't know the sum, you can provide just the `hashfun` and a warning message will be displayed, giving the correct tuple of `(hashfun, targethex)` that should be added to the registration block.

	- If you don't want to provide a checksum,  because your data can change pass in the type `Any` which will suppress the warning messages. (But see above warnings about "what if my data is dynamic")
    - Can take a vector of checksums, being one for each file, or a single checksum in which case the per file hashes are `xor`ed to get the target hash. (See [Recursive Structure](Recursive Structure) below)


 -  `fetch_method=fetch_default` a function to run to download the files.
    - Function should take 2 parameters (remotepath, local_directory), and must return a local filepath
    - It is responsible for determining what the local filename should be
    - Change this to change the transfer protocol, for example to use an auth'ed connection.
    - Default `fetch_default` which fully supports HTTP, and has fallbacks to support any type which overloads `Base.basename` and `Base.download` (see [`fetch_base`](@ref))
    - Can take a vector of methods, being one for each file, or a single method, in which case that method is used to download all of them. (See [Recursive Structure](Recursive Structure) below)
    - Very few people will need to override this if they are just downloading public HTTP files.

 - `post_fetch_method` a function to run after the files have download
    - Should take the local filepath as its first and only argument. Can return anything.
    - Default is to do nothing.
    - Can do what it wants from there, but most likes wants to extract the file into the data directory.
    - towards this end DataDeps includes a command: `unpack` which will extract an compressed folder, deleting the original.
    - It should be noted that it `post_fetch_method` runs from within the data directory
       - which means operations that just write to the current working directory (like `rm` or `mv` or ```run(`SOMECMD`))``` just work.
       - You can call `cwd()` to get the the data directory for your own functions. (Or `dirname(local_filepath)`)
    - Can take a vector of methods, being one for each file, or a single method, in which case that ame method is applied to all of the files. (See **Recursive Structure** in the README.md)
"""
function DataDep(name::String,
                 message::String,
                 remotepath, hash=nothing;
                 fetch_method=fetch_default,
                 post_fetch_method=identity)

    DataDep(name, remotepath, hash, fetch_method, post_fetch_method, message)
end
