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
    [hash::Union{String,Vector{String}...},]; # Optional, if not provided will generate
    # keyword args (Optional):
    fetch_method=fetch_default # (remote_filepath, local_directory_path)->local_filepath
    post_fetch_method=identity # (local_filepath)->Any
)
```

### Required Fields

 - `name`: the name used to refer to this datadep
    - Corresponds to a folder name where the datatep will be stored.
    - It can have spaces or any other character that is allowed in a Windows filestring (which is a strict subset of the restriction for unix filenames).
 - `message`: a message displayed to the user for they are asked if they want to download it
    - This is normally used to give a link to the original source of the data, a paper to be cited etc.
 - `remote_path`: where to fetch the data from
    - This is usually a string, or a vector of strings (or a vector of vectors... see [Recursive Structure](@ref) in the documentation for developers).

### Optional Fields
 - `hash`: used to check whether the files downloaded correctly
    - By far the most common use is to just provide a SHA256 sum as a hex-string for the files.
    - If not provided, then a warning message with the  SHA256 sum is displayed. This is to help package devs work out the sum for their files, without using an external tool. You can also calculate it using [Preupload Checking](@ref) in the documentation for developers.
    - If you want to use a different hashing algorithm, then you can provide a tuple `(hashfun, targethex)`.
      `hashfun` should be a function which takes an `IOStream`, and returns a `Vector{UInt8}`.
      Such as any of the functions from [SHA.jl](https://github.com/staticfloat/SHA.jl), eg `sha3_384`, `sha1_512`
      or `md5` from [MD5.jl](https://github.com/oxinabox/MD5.jl)
    - If you want to use a different hashing algorithm, but don't know the sum, you can provide just the `hashfun` and a warning message will be displayed, giving the correct tuple of `(hashfun, targethex)` that should be added to the registration block.
    - If you don't want to provide a checksum,  because your data can change pass in the type `Any` which will suppress the warning messages. (But see above warnings about "what if my data is dynamic").
    - Can take a vector of checksums, being one for each file, or a single checksum in which case the per file hashes are `xor`ed to get the target hash. (See [Recursive Structure](@ref) in the documentation for developers).


 -  `fetch_method=fetch_default`: a function to run to download the files
    - Function should take 2 parameters `(remote_filepath, local_directorypath)`, and can must return the local filepath to the file downloaded.
    - Default (`fetch_default`) can correctly handle strings containing HTTP[S] URLs, or any `remote_path` type which overloads `Base.basename` and `Base.download`, e.g. [`AWSS3.S3Path`](https://github.com/JuliaCloud/AWSS3.jl/).
    - Can take a vector of methods, being one for each file, or a single method, in which case that method is used to download all of them. (See [Recursive Structure](@ref) in the documentation for developers).
    - Overloading this lets you change things about how the download is done -- the transport protocol.
    - The default is suitable for HTTP[/S], without auth. Modifying it can add authentication or an entirely different protocol (e.g. git, google drive etc).
    - This function is also responsible to work out what the local file should be called (as this is protocol dependent).


 - `post_fetch_method`: a function to run after the files have been downloaded
    - Should take the local filepath as its first and only argument. Can return anything.
    - Default is to do nothing.
    - Can do what it wants from there, but most likely wants to extract the file into the data directory.
    - towards this end DataDeps.jl includes a command: `unpack` which will extract an compressed folder, deleting the original.
    - It should be noted that `post_fetch_method` runs from within the data directory.
       - which means operations that just write to the current working directory (like `rm` or `mv` or ```run(`SOMECMD`))``` just work.
       - You can call `cwd()` to get the the data directory for your own functions. (Or `dirname(local_filepath)`).
    - Can take a vector of methods, being one for each file, or a single method, in which case that same method is applied to all of the files. (See [Recursive Structure](@ref) in the documentation for developers).
    - You can check this as part of [Preupload Checking](@ref) in the documentation for developers.
"""
function DataDep(name::String,
                 message::String,
                 remotepath, hash=nothing;
                 fetch_method=fetch_default,
                 post_fetch_method=identity)

    DataDep(name, remotepath, hash, fetch_method, post_fetch_method, message)
end
