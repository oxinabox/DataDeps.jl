## Usage for developers (including researchers)

### Examples
 - [the aformentioned blog post](http://white.ucc.asn.au/2018/01/18/DataDeps.jl-Repeatabled-Data-Setup-for-Repeatable-Science.html)
 - [Examples in the test code](https://github.com/oxinabox/DataDeps.jl/blob/master/test/examples.jl)
 - [Manual examples from the test code](https://github.com/oxinabox/DataDeps.jl/blob/master/test/examples_manual.jl)

### Installation
As normal for julia packages install DataDeps.jl using:

```
pkg> add DataDeps
```

This will add `DataDeps` to your `Project.toml` file, so it will be automatically installed for end-users.

### Using a datadep string or `resolve` to get hold of the data.
For any registered DataDep (see below), `datadep"Name"`, returns a path to a folder containing the data.
If when that string macro is evaluated no such folder exists, then DataDeps will swing into action and coordinate the acquisition of the data into a folder, then return the path that now contains the data.

You can also use `datadep"Name/subfolder/file.txt"` (and similar) to get a path to the file at  `subfolder/file.txt` within the data directory for `Name`.
Just like when using the plain `datadep"Name"` this will if required downloadload the whole datadep (**not** just the file).
However, it will also engage additional features to verify that that file exists (and is readable),
and if not will attempt to help the user resolve the situation.
This is useful if files may have been deleted by mistake, or if a ManualDataDep might have been incorrectly installed.


#### Installing Data Lazily
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


#### Installing Data Eagerly
If you want the data to be installed when the package is first loaded,
just put the datadep string `datadep"Name"` anywhere it will immediately run.
For example, in the `__init__` function immediately after the registration block.

If you want it to be installed at `Pkg.build` time.
The best thing to do is to put your data dep registration block in a file (eg `src/dataregistrations.jl`),
and then `include` it into `deps/build.jl` followed by putting in the datadep string somewhere at global scope.
(Including would be done by `include(pathjoin(@__DIR__,"..","src","dataregistrations.jl"`).
One would also `include` that registrations file into the `__init__` function in the  main source of the package as well.





### Registering a DataDep
When we say registering a DataDep we do not mean a centralised universal shared registry.
Registring simply means defining the specifics of the DataDep in your code.
This is done in a declaritie manner.

A DataDeps registration is a block of code declaring a dependency.
You should put it somewhere that it will be executed before any other code in your script that depends on that data.
In most cases it is best to put it inside the  [modules's `__init__()` function](https://docs.julialang.org/en/stable/manual/modules/#Module-initialization-and-precompilation-1).


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


 -  `fetch_method=http_download` a function to run to download the files.
    - Function should take 2 parameters `(remote_filepath, local_directorypath)`, and can must return the local filepath to the file downloaded
    - Can take a vector of methods, being one for each file, or a single method, in which case that method is used to download all of them. (See [Recursive Structure](Recursive Structure) below)
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
    - Can take a vector of methods, being one for each file, or a single method, in which case that ame method is applied to all of the files. (See [Recursive Structure](Recursive Structure) below)


#### Recursive Structure
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



#### ManualDataDep
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


### Assuming direct control and customization
The hierachy of methods for acquiring a datadep is:

`datadep"name/path"` ▶ `resolve("name/path", @__FILE__)` ▶ `resolve(::AbstractDataDep, "path", @__FILE__)` ▶ `download(::DataDep)`

One can make use of this at various levels to override the default generally sane behavior.
Most of the time you shouldn't have to -- the normal point of customization is in setting the `post_fetch_method`, and occasionally `fetch_method` or  `hash=(hashmethod, key)`.

#### Advanced: `resolve` for high-level programmatic resolution
`resolve("name/path", @__FILE__)` is the functional form of `datadep"name/path`.
If you are really worried about resolving a datadep early, or of you are generating the names pragmatically, or you just really feel uncomfortable about string macros, you can use `resolve(namepath, @__FILE__)`.
You can (basically) equivalently use `@datadep_str namepath`.
Passing in the `@__FILE__` is important as it allows access to the package's "private" data deps location (`PKGNAME/deps/data`),
which may be needed incase of datadep name conflicts; or for `ManualDataDep`s that are included in the repo.
You could passing something else to bypass this "privacy".


It comes in a number of flavors for which you can read the docstring `?resolve`.
Including `resolve(::AbstactDataDep, innerpath, @__FILE__)`, which can directly download a datadep.



#### `download` for low-level programmatic resolution.
For more hardcore devs customising the user experience,
and people needing to do debugging you may assume (nearly) full control over the download operation
by directly invoking the method `Base.download(::DataDep, localpath; kwargs...)`.
It is fully documented in its docstring.


