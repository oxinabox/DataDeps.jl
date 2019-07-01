# Usage for developers (including researchers)

## Examples
 - [The aformentioned blog post](http://white.ucc.asn.au/2018/01/18/DataDeps.jl-Repeatabled-Data-Setup-for-Repeatable-Science.html)
 - [Examples in the test code](https://github.com/oxinabox/DataDeps.jl/blob/master/test/examples.jl)
 - [Manual examples from the test code](https://github.com/oxinabox/DataDeps.jl/blob/master/test/examples_manual.jl)

## Installation
As normal for julia packages install DataDeps.jl using:

```
pkg> add DataDeps
```

This will add `DataDeps` to your `Project.toml` file, so it will be automatically installed for end-users.


## Accessing a DataDep

### Using a datadep string or `resolve` to get hold of the data.
For any registered DataDep (see below), `datadep"Name"`, returns a path to a folder containing the data.
If when that string macro is evaluated no such folder exists, then DataDeps will swing into action and coordinate the acquisition of the data into a folder, then return the path that now contains the data.

You can also use `datadep"Name/subfolder/file.txt"` (and similar) to get a path to the file at  `subfolder/file.txt` within the data directory for `Name`.
Just like when using the plain `datadep"Name"` this will if required downloadload the whole datadep (**not** just the file).
However, it will also engage additional features to verify that that file exists (and is readable),
and if not will attempt to help the user resolve the situation.
This is useful if files may have been deleted by mistake, or if a `ManualDataDep` might have been incorrectly installed.


#### Advanced: Programtic resolution 
If your datadep name (or path) is in a variable (called `namepath` say)  you can use

```
@datadep_str namepath
```
rather than the datadep string macro.



### Installing Data Lazily
Most packages using more than one data source, will want to download them only when the user requires them.
That is to say if the user never calls a function that requires that data, then the data should not be downloaded.

DataDeps.jl resolves the dependency when a `datadep"Name"` string is evaluated.
If no code containing a data dependency string is run, then no data will be downloaded

The basic way is to hide the datadep in some code not being evaluated except on a condition.
For example, say some webcam security system can be run in training mode, in which case data should be used from the datadep,
or in deployment mode, in which case the data should be read from the webcam's folder:

```
data_folder = training_mode ? datadep"SecurityFootage" : "/srv/webcam/today"       
```
The data will not be downloaded if `training_mode==false`, because the referred to folder is never required.
Of-course if the data was already downloaded, then it wouldn't be downloaded again either way.

Another example of a particularly nice way of doing this is to use the datadep string as the default value for a function paramater
`function predict(path=datadep"SecurityFootage")`.
If the user passses a value when they call `predict` then the datadep string will never be evaluated.
So the data will not be sourced via DataDeps.jl


### Installing Data Eagerly
If you want the data to be installed when the package is first loaded,
just put the datadep string `datadep"Name"` anywhere it will immediately run.
For example, in the `__init__` function immediately after the registration block.
(Do not put it at global scope as otherwise it will run before `__init__` and thus error.


If you want it to be installed at `Pkg.build` time.
This is theoretically possible, but not advised, using `deps/build.jl`.
Note: that user IO is not possibly during `Pkg.build`, so the prompt to accept the download will not be shown.
You thus must have `ENV["DATADEPS_ALWAYS_ACCEPT"]="true"` set, or it will fail.
If you do do this, you will need to ensure the registration code is specified in the package as well, so that DataDeps.jl can local the files downloaded at build-time.



## Registering a DataDep
When we say registering a DataDep we do not mean a centralised universal shared registry.
Registring simply means defining the specifics of the DataDep in your code.
This is done in a declaritie manner.

A DataDeps registration is a block of code declaring a dependency.
You should put it somewhere that it will be executed before any other code in your script that depends on that data.
In most cases it is best to put it inside the  [modules's `__init__()` function](https://docs.julialang.org/en/latest/manual/modules/#Module-initialization-and-precompilation-1).
Note that `include` works weirdly when called inside a function, so if you want to put the registration block in another file that you `include`, you are best off either defininte `__init__` in that file, or defining a function (e.g `init_data()`) which will be called by `__init__`.


To do the actual registration one just  calls `register(::AbstractDataDep)`.
The rest of this section is basically about the constructors for the `DataDep` type.
It is pretty flexible. Best is to see the examples above.

The basic Registration block looks like: (Type parameters are shown below are a simplifaction)
```
register(DataDep(
    name::String,
    message::String,
    remote_path::Union{String,Vector{String}...},
    [checksum::Union{String,Vector{String}...},]; # Optional, if not provided will generate
    # keyword args (Optional):
    fetch_method=http_download # (remote_filepath, local_directory_path)->local_filepath
    post_fetch_method=identity # (local_filepath)->Any
))
```

### Required Fields

 - *Name**: the name used to refer to this datadep, coresponds to a folder name where it will be stored
    - It can have spaces or any other character that is allowed in a Windows filestring (which is a strict subset of the restriction for unix filenames).
 - *Message*: A message displayed to the user for they are asked if they want to downloaded it.
    - This is normally used to give a link to the original source of the data, a paper to be cited etc.
 - *remote_path*: where to fetch the data from. Normally a string or strings) containing an URL
    - This is usually a string, or a vector of strings (or a vector of vector... see [Recursive Structure](@ref) below)

### Optional Fields
 - *checksum* this is very flexible, it is used to check the files downloaded correctly
    - By far the most common use is to just provide a SHA256 sum as a hex-string for the files
    - If not provided, then a warning message with the  SHA256 sum is displayed. This is to help package devs workout the sum for there files, without using an external tool. You can also calculate it using [Preupload Checking](@ref).
    - If you want to use a different hashing algorithm, then you can provide a tuple `(hashfun, targethex)`
        - `hashfun` should be a function which takes an IOStream, and returns a `Vector{UInt8}`.
	      - Such as any of the functions from [SHA.jl](https://github.com/staticfloat/SHA.jl), eg `sha3_384`, `sha1_512`
	      - or `md5` from [MD5.jl](https://github.com/oxinabox/MD5.jl)
  - If you want to use a different hashing algorithm, but don't know the sum, you can provide just the `hashfun` and a warning message will be displayed, giving the correct tuple of `(hashfun, targethex)` that should be added to the registration block.
	- If you don't want to provide a checksum,  because your data can change pass in the type `Any` which will suppress the warning messages. (But see above warnings about "what if my data is dynamic")
    - Can take a vector of checksums, being one for each file, or a single checksum in which case the per file hashes are `xor`ed to get the target hash. (See [Recursive Structure](@ref))


 -  `fetch_method=http_download` a function to run to download the files.
    - Function should take 2 parameters `(remote_filepath, local_directorypath)`, and can must return the local filepath to the file downloaded
    - Can take a vector of methods, being one for each file, or a single method, in which case that method is used to download all of them. (See [Recursive Structure](@ref) below)
	- Overloading this lets you change things about how the download is done -- the transport protocol.
	- The default is suitable for HTTP[/S], without auth. Modifying it can add authentication or an entirely different protocol (e.g. git, google drive etc)
	- This function is also responsible for workout out what the local file should be called (as this is protocol dependent)
	
	
 - `post_fetch_method` a function to run after the files have download
    - Should take the local filepath as its first and only argument. Can return anything.
    - Default is to do nothing.
    - Can do what it wants from there, but most likes wants to extract the file into the data directory.
    - towards this end DataDeps includes a command: `unpack` which will extract an compressed folder, deleting the original.
    - It should be noted that it `post_fetch_method` runs from within the data directory
       - which means operations that just write to the current working directory (like `rm` or `mv` or ```run(`SOMECMD`))``` just work.
       - You can call `cwd()` to get the the data directory for your own functions. (Or `dirname(local_filepath)`)
    - Can take a vector of methods, being one for each file, or a single method, in which case that ame method is applied to all of the files. (See [Recursive Structure](@ref))
    - You can check this as part of [Preupload Checking](@ref).


### Recursive Structure
`fetch_method`, `post_fetch_method` and `checksum` all can match the structure of `remote_path`.
If `remote_path` is just an single path, then they each must be single items.
If `remote_path` is a vector, then if those properties are a vector (which must be the same length) then they are applied each to the corresponding element; or if not then it is applied to all of them.
This means you can for example provide check-sums per file, or per-the-all.
It also means you can specify different `post_fetch_methods` for different files, e.g. doing nothing to some, and extracting others.
Further more this applies recursively.

For example:
```
register(DataDep("eg", "eg message",
    ["http//example.com/text.txt", "http//example.com/sub1.zip", "http//example.com/sub2.zip"]
    post_fetch_method = [identity, file->run(`unzip $file`), file->run(`unzip $file`)]
))
```
So `identity`  (i.e. nothing) will be done to the first paths resulting file, and the second and third will be unzipped.

can also be written:
```
register(DataDep("eg", "eg message",
    ["http//example.com/text.txt", ["http//example.com/sub1.zip", "http//example.com/sub2.zip"]]
    post_fetch_method = [identity, file->run(`unzip $file`)]
))
```
The unzip will be applied to both elements in the child array



### ManualDataDep
ManualDataDeps are datadeps that have to be managed by some means outside of DataDeps.jl,
but DataDeps.jl will still provide the convient `datadep"MyData"` string macro for finding them.
As mentions above, if you put the data in your git repo for your package under `deps/data/NAME` then it will be managed by julia package manager.

A manual DataDep registration is just like a normal `DataDep` registration,
except that only a `name` and `message` are provided.
Inside the message you should give instructions on how to acquire the data.
Again see the [examples](#examples)



### DataDepsGenerators
[DataDepsGenerators.jl](https://github.com/oxinabox/DataDepsGenerators.jl) is a julia package to help generate DataDeps registration blocks from well-known data sources.
It attempts to use webscraping and such to workout what should be in the registration block.
You can then edit the generated code to make it suitable for your use.
(E.g. remove excessive information in the message)

## Assuming direct control and customization
The hierachy of methods for acquiring a datadep is:

`datadep"name/path"` ▶ `resolve("name/path", @__FILE__)` ▶ `resolve(::AbstractDataDep, "name", @__FILE__)` ▶ `download(::DataDep)`

One can make use of this at various levels to override the default generally sane behavior.
Most of the time you shouldn't have to -- the normal point of customization is in setting the `post_fetch_method`, and occasionally `fetch_method` or  `hash=(hashmethod, key)`.


## `download` for low-level programmatic resolution.
For more hardcore devs customising the user experience,
and people needing to do debugging you may assume (nearly) full control over the download operation
by directly invoking the method `Base.download(::DataDep, localpath; kwargs...)`.
It is fully documented in its docstring.



## Preupload Checking

Preupload checking exists to help package developers check their DataDeps on local files before they upload them.
It checks the **checksum** is filled in and matchs, and that the `post_fetch_method` can be run without throwing any exceptions.

For example, if I wished to check the UCI banking data, from a local file called `bank.zip`,
with the registration as below:

```
register(
    DataDep(
        "UCI Banking",
        """
        Dataset: Bank Marketing Data Set
        Authors: S. Moro, P. Cortez and P. Rita.
        Website: https://archive.ics.uci.edu/ml/datasets/bank+marketing
        This dataset is public available for research. The details are described in [Moro et al., 2014].
        Please include this citation if you plan to use this database:
        [Moro et al., 2014] S. Moro, P. Cortez and P. Rita. A Data-Driven Approach to Predict the Success of Bank Telemarketing. Decision Support Systems, Elsevier, 62:22-31, June 2014
        """,
        [
        "https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank.zip",
        "https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip"
        ]
		#NOTE: I am not providing a checksum here
		;
        post_fetch_method = unpack
    )
);
```

then we would do so by calling `preupload_check`, passing in the DataDep name, and the local file.


```
julia> preupload_check("UCI Banking", "./bank.zip")
┌ Warning: Checksum not provided, add to the Datadep Registration the following hash line
│   hash = "\"99d7e8eb12401ed278b793984423915411ea8df099e1795f9fefe254f513fe5e\""
└ @ DataDeps D:\White\Documents\GitHub\DataDeps.jl\src\verification.jl:44

7-Zip [64] 16.04 : Copyright (c) 1999-2016 Igor Pavlov : 2016-10-04

Scanning the drive for archives:
1 file, 579043 bytes (566 KiB)

Extracting archive: C:\Users\White\AppData\Local\Temp\jl_72FA.tmp\bank.zip
--
Path = C:\Users\White\AppData\Local\Temp\jl_72FA.tmp\bank.zip
Type = zip
Physical Size = 579043

Everything is Ok

Files: 3
Size:       5075686
Compressed: 579043
true
```

Notice that it has issued a *warning* that the checksum was not provided,
and has output the hash that needs to be added to the registration block.
But it has not issued any warnings about the `unpack`.
The `fetch_method` is never invoked.

It is good to use preupload checking before you upload files.
It can make debugging easier.
