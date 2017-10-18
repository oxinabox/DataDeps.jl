# DataDeps
Please provide feedback by raising issues, or making PRs.

<!--
[![Build Status](https://travis-ci.org/oxinabox/DataDeps.jl.svg?branch=master)](https://travis-ci.org/oxinabox/DataDeps.jl)

[![Coverage Status](https://coveralls.io/repos/oxinabox/DataDeps.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/oxinabox/DataDeps.jl?branch=master)

[![codecov.io](http://codecov.io/github/oxinabox/DataDeps.jl/coverage.svg?branch=master)](http://codecov.io/github/oxinabox/DataDeps.jl?branch=master)
-->


## Core ideas

 - **BinDeps for Data**
    - If your code depends on data or allows access to data, then you should be able to use DataDeps to fetch it.
 - **Folder Orientated** Each data dependency is a folder called the datadir.
    - wether it is 1 file, or a huge hierarchy 
 - **Only about getting data, not interpretting**
    - Filling that datadir folder with the right stuff is the job of DataDep.jl, 
    - Interpretretting the contents of that folder is the job of the consumer. That includes even knowing the names of the files inside the datadir.
 - **Lazy** Things are only downloaded when they are required. 
    - Can be made eager by forcing them to be required during execution of  `/deps/build.jl`
    - This is important to the **ProviderConsumer** class of consumer, see below. As they may provide interfaces for dozens of different sources of data.


## Consumer
There are 3 classes of users of DataDeps, they are not types of people, but types of packages/projects:

 - **ProviderConsumer**: Packages such as MLDatasets.jl, and CorpusLoaders.jl, whos purpose is to provide access to standard datasets. Other packages wanting to use these datasets don't use DataDeps directly, they use the Provider package, which gives a nice interface to that data. (It consumes the result of DataDeps, and gives something nicer to the end-user)
 - **ProjectConsumer**: Packages, that need a dataset or two, possibly for testing, possibly for running experiments, possibly for normally functioning. A key class of these is code that corresponds to a scientific investigation. E.g. the code for some ML paper with a fancy new technique. The fact that these are using DataDeps directly means the data is a bit obsure, as it is not provided by a ProviderUser package. 
 - **CasualConsumer**: By which I mean people just working in the REPL, not using modules etc. These are not the target of the DataDeps.jl, but worth bearing in mind they exist. These users are probably happy with just using `download`. However, early in prototyping a package idea, or when debugging something the other user types may look like the **CasualUser**.

We list them here for thinking about design decisions. 





## Data Storage Locations
There are 4 possible locations any piece of data might reasonably be located, once downloaded.

 - **PackageLoc**: For a package, the data might be located somewhere in the package directory. 
    - For example: `~/.julia/v0.6/ExamplePackage/deps/data/`
    - It is only usable by that package.
    - One could think of this as the universal location, in that files here will always be the same for all users of the package.
    - Downsides:
       - This is a place for code, not for data, and the data can utterly dwarf the size of the code.
       - It is also bad in that one will normally have the same data across multiple julia versions
       - No sharing between anything
    - Upsides:
       - Keeps close to the data user
       - Avoids name collisions
    - How to determine PackageLoc.
       - Determining Package is a bit tricky
       - One needs to consider that packages could be in `Pkg.Dir()` or somewhere in `LOADPATH`, or it could fail if not in a package.
       - @__FILE__ is useful for this, but it has to be called in the right file for it to work. Which may mean a macro must be used. I think a lot of this will be done via macro anyway, so it might not be a big deal         
 - **UserLoc**: Data that is usable by any package, but only by this user. Should be set-able by an environment variable. Good locations include: `~/.datadeps/datastore/` and `~/.julia/v0.6/DataDeps/datastore/`
 - **GlobalLoc**: Data that is usable by anyone. Important, because for very large data you might not want multiple copies of it on one computer. Location should also be settable by an environment variable. Good locations are `/usr/local/share/datadeps/datastore` for this computer, and `/usr/share/datadeps/datastore` for if it is shared across the network. arguably this could be two locations (networked and local) or even a list of locations.
 - **CwdLoc**: The current working directory. This is not a good location, but it is the location used by the **CasualUser**, and may be important for debugging etc.
 
### Loading Data from location 
When **loading data**, the locations should be checked in the order:
 1. **CwdLoc** so the user can override the data for various testing purpose by creating a folder in the current direction.
 2. **PackageLoc** as packageloc can't have name collisions
 3. **UserLoc** (more specific over more general)
 4. **GlobalLoc**
 if it is found in any of the locations, then that data should be used.
 If it is not found in any of those locations it should be **fetched**
 
 
 ### Fetching Data, and storing in a location
 
When **fetching data**, the location to store it should be:
  - set by an environment variable to one of **PackageLoc**, **UserLock**, or **GlobalLoc**,
  - if that variable is unset, then it should default to **PackageLoc** (the safest location), but user should be encouraged to set it.
  - If the store location is **PackageLoc**, and you are not in a package, it should give a warning and then fall back to **UserLoc**
 
The **fetch** command should also have a manual version, which takes the desired path as a parameter for the **CasualUser** usecase.
 
## Registering Data
When I say registoring data I don't mean in some common shared-by-everyone-in-the-world repository (like METADATA.jl),
I mean writing the specification of the data that gives the information on how it is to be fetched.
A data registration is a line in a `module` that looks something like:

```julia
RegisterDataDep(
 DataName #Unique name for this data, determines its foldername, and the name used to represent it in code
 "http://www.example.com/eg.zip", # the remote-path to fetch it from, normally an URL. Passed to the `fetch_method`
 md5"aa674eb1ffb744954a45f2460666b469", #A hash that is used to check the data is right.
 ; 
 fetch_method = download # the method used to fetch the data -- defaults to `download`, takes remote-path as its first argument and localpath as its last. 
 post_fetch_method = unzip # A function that is applied to local filepath from fetch_method, to get do any post processing. Defaults to `indentity`
 extra_message ="""This is an extra message to be shown before downloading file"""
```

There should be a helper function that the use called from the REPL,
that given some of the parameters, generates a stub.
In particular it should generate the hash.

## Validating data
One of the parameters when regististering is the hash.
This should be used after the download.

It might be nice to have some ability to optionally reshash the files, to check they havenot been modified
But hashing a folder is hard, and it would need some means of undoing the `post_fetch_method`.

## Predownload confirmation.
Prior to ever downloading something,
it should always deplay a message something like:

> DataDeps.jl has detected that you do not have $DataName installed.
> It will thus be fetching it from $remote_path, and storing it in $datastorelocation
> $extra_message
> Remember it is your responsibility to ensure you comply with the terms of use for this data.
> If you are not able to do so, do not proceed with download.
> Would you like to continue Y/N

and then prompt the user to say the agree to not be a baddy.

## Mirrors
Should mirrors be a thing?
I think it is an extra feature not needed til someone raises an issue about it.

## Using A data dep.

For the consumer,
wr



 
