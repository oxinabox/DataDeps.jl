# DataDeps
Please provide feedback by raising issues, or making PRs.

The plan can be found at [plan](plan.jl).
It might be a little outdated.



## What is DataDeps?
DataDeps is a package for simplifying the management of data in your julia application.
In particular it is designed to make getting static data from some server into the local machine,
and making programs know where that data is trivial.


### Why not store the data in Git?
Git is good for files that meet 3 requirements:

 - Plain text (not binary)
 - Smallish (Github will not accept files >50Mb in size)
 - Dynamic (Git is version control, it is good at knowing about changes)

There is certainly some room around the edges for this, like sorting a few image in repository is OK, but storing all of ImageNet is a no go.

DataDeps.jl is good for:

 - Any file format
 - Any size
 - Static (that is to say it doesn't change)
 
The main use case is downloading large dataset for machine learning, and corpora for NLP.
In this case the data is not even normally yours to begin with.
It lives on some website somewhere.

#### But my data is dynamic
Well how dynamic?
If you are willing to tag a new relase of your package each time the data changes, then maybe this is no worry.
DataDeps.jl likes it if you provide a checksum for your data.
If you don't warnings will be displayed to the user.
(or if your checksum doesn't match, big warnings will be displayed, with an option to ignore).

You can work around this if you try (e.g. by defining it do that the checksum is downloaded from the server when it is checked).
But the real question is are you managing your data properly in the first place.
DataDeps.jl does not provide for versioning of data -- you can't force users to download new copies of your data using DataDeps.
(Again there are work arounds, such as using DataDeps.jl + `deps/build.jl` to `rm(datadep"MyData", recursive=true, force=true` every package update. Or considering each version of the data as a different datadep with a different name).
DataDeps.jl may form part of your overall solution or it may not.
That is a discussion to have on Slack or Discourse maybe. Or in the issues for this repo.

The other option is that if your data a good fit for git, then you could add it as a `ManualDataDep` in `deps/data/MyData`.


## Usage for package developers

### ManualDataDep

ManualDataDeps are datadeps that have to be managed by some means outside of DataDeps.jl,
but DataDeps.jl will still provide the convient `datadep"MyData"` string macro for finding them.
As mentions above, if you put the data in your git repo for your package under `deps/data/NAME` then it will be managed by julia package manager.


## Configuration

Currently configuration is done via Enviroment Variables.
It is likely to stay that way, as they are also easy to setup in CI tools.
You can set these in 

 - `DATADEPS_ALWAY_ACCEPT` -- bypasses the confirmation before downloading data. Set to `true` (or similar string)
    - This is provided for scripting (in particular CI) use
    - Note that it remains your responsibility to understand and read any terms of the data use (this is remains true even if you don't turn on this bypass)
	- default `false`
 - `DATADEPS_LOAD_PATH` -- The list of paths, other than the package directory (`PKGNAME/deps/data`) to save and load data from
    - default values is complex. On all systems it includes the equivalent of `~/.julia/datadeps`. It also includes a large number of other locations such as `/usr/share/datadeps` on linux, and `C:/ProgramData` on Windows.
 - `DATADEPS_PKGDIR_FIRST` -- check/attempt to save in  `PKGNAME/deps/data` before everything in `DATADEPS_LOAD_PATH`, rather than after.
    - default `false`
 - `DATADEPS_DISABLE_DOWNLOAD` -- causes any action that would result in the download being triggered to throw an exception.
   - useful e.g. if you are in an environment with metered data, where your datasets should have already been downloaded earlier, and if there were not you want to respond to the situation rather than let DataDeps download them for you.
   - default `false`


## DataDepsGenerators
[DataDepsGenerators.jl](https://github.com/oxinabox/DataDepsGenerators.jl) is a julia package to help generate DataDeps registration blocks from well known data sources.
It attempts to use webscraping and such to workout what should be in the registration block.




## Usage for users
