# DataDeps
<!--
[![Build Status](https://travis-ci.org/oxinabox/DataDeps.jl.svg?branch=master)](https://travis-ci.org/oxinabox/DataDeps.jl)

[![Coverage Status](https://coveralls.io/repos/oxinabox/DataDeps.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/oxinabox/DataDeps.jl?branch=master)

[![codecov.io](http://codecov.io/github/oxinabox/DataDeps.jl/coverage.svg?branch=master)](http://codecov.io/github/oxinabox/DataDeps.jl?branch=master)
-->


## Users
There are 3 classes of users of DataDeps, they are not types of people, but types of packages/projects:

 - **ProviderUsers**: Packages such as MLDatasets.jl, and CorpusLoaders.jl, whos purpose is to provide access to standard datasets. Other packages wanting to use these datasets don't use DataDeps directly, they use the Provider package, which gives a nice interface to that data.
 - **ProjectUsers**: Packages, that need a dataset or two, possibly for testing, possibly for running experiments, possibly for normally functioning. A key class of these is code that corresponds to a scientific investigation. E.g. the code for some ML paper with a fancy new technique. The fact that these are using DataDeps directly means the data is a bit obsure, as it is not provided by a ProviderUser package. 
 - **CasualUsers**: By which I mean people just working in the REPL, not using modules etc. These are not the target of the DataDeps.jl, but worth bearing in mind they exist. These users are probably happy with just using `download`. However, early in prototyping a package idea, or when debugging something the other user types may look like the **CasualUser**.


## Data Storage Locations
There are 4 possible locations any piece of data might reasonably be located, once downloaded.

 - **PackageLoc**: For a package, the data might be located somewhere in the package directory. For example: `~/.julia/v0.6/ExamplePackage/deps/data/` It is only usable by that package.
 - **UserLoc**: Data that is usable by any package, but only by this user. Should be set-able by an environment variable. Good locations include: `~/.datadeps/datastore/` and `~/.julia/v0.6/DataDeps/datastore/`
 - **GlobalLoc**: Data that is usable by anyone. Important, because for very large data you might not want multiple copies of it on one computer. Location should also be settable by an environment variable. Good locations are `/usr/local/share/datadeps/datastore` for this computer, and `/usr/share/datadeps/datastore` for if it is shared across the network.
 - **CwdLoc**: The current working directory. This is not a good location, but it is the location used by the **CasualUser**, and may be important for debugging etc.
 
 
 
## Registering Data
When I say registoring data I don't mean in some common shared by everyone repository (like METADATA.jl),
I mean writing the specification of the data that gives the information on how it is to be fetched.

 
 
 
