# DataDeps.jl Documentation

## What is DataDeps?
DataDeps is a package for simplifying the management of data in your julia application.
In particular it is designed to simplify the process of getting static files from some server into the local machine,
and making programs know where that data is.

For a few examples of its usefulness see [this blog post](http://white.ucc.asn.au/2018/01/18/DataDeps.jl-Repeatabled-Data-Setup-for-Repeatable-Science.html)

## Usage in Brief:
### I want to use some data I have in my project. What do?
The short version is:

1. Stick your data anywhere with a open HTTP link. (Skip this if it is already online.)
2. Write a DataDep registration block.
3. Refer to the data using `datadep"Dataname/file.csv` etc as if it were a file path, and DataDeps.jl will sort out getting in onto your system.
4. For CI purposes set the `DATADEPS_ALWAYS_ACCEPT` environment variable.

### Where can I store my data online?
Where ever you want, so long as it gives an Open HTTP(/s) link to download it. ** 

 - I use an OwnCloud instance hosted by our national research infastructure.
 - Research data hosting like FigShare are a good idea.
 - You can just stick it on your website hosting if you are operating a website.
 - I'd like to hear if anyone has tested GoogleDrive or DropBox etc.


**(In other protocols and auth can be supported by using a different `fetch_method`)


#### Why not store the data in Git?
Git is good for files that meet 3 requirements:

 - Plain text (not binary)
 - Smallish (Github will not accept files >50Mb in size)
 - Dynamic (Git is version control, it is good at knowing about changes)

There is certainly some room around the edges for this, like storing a few images in the repository is OK, but storing all of ImageNet is a no go. For those edge cases `ManualDataDep`s are good (see below).

DataDeps.jl is good for:

 - Any file format
 - Any size
 - Static (that is to say it doesn't change)

The main use case is downloading large datasets for machine learning, and corpora for NLP.
In this case the data is not even normally yours to begin with.
It lives on some website somewhere.
You don't want to copy and redistribute it;
and depending on liscensing you may not even be allowed to.

#### But my data is dynamic
Well how dynamic?
If you are willing to tag a new relase of your package each time the data changes, then maybe this is no worry, but maybe it is.

But the real question is, is DataDeps.jl really suitable for managing your data properly in the first place.
DataDeps.jl does not provide for versioning of data -- you can't force users to download new copies of your data using DataDeps.
There are work arounds, such as using DataDeps.jl + `deps/build.jl` to `rm(datadep"MyData", recursive=true, force=true` every package update. Or considering each version of the data as a different datadep with a different name.
DataDeps.jl may form part of your overall solution or it may not.
That is a discussion to have on [Slack](http://slackinvite.julialang.org/) or [Discourse](http://discourse.julialang.org/) (feel free to tag me, I am **@oxinabox** on both).
See also the list of related packages at the bottom

The other option is that if your data a good fit for git.
If it is in overlapping area of plaintext & small (or close enough to those things),
then you could add it as a `ManualDataDep` in and include it in the git repo in the  `deps/data/` folder of your package.
The ManuaulDataDep will not need manual installation if it is being installed via git.


## Other similar packages:

DataDeps.jl isn't the answer to everyone's download needs.
It is focused squarely on static data.
It is opinionated about providing user readable metadata at a prompt that must be accepted.
It doesn't try to understand what the data means at all.
It might not be good for your use case.

Alternatives that I am aware of are:

 - [RemoteFiles.jl](https://github.com/helgee/RemoteFiles.jl): keeps local files up to date with remotes. In someways it is the opposite of DataDeps.jl (which means it is actually very similar in many ways).
 - [BinaryProvider.jl](https://github.com/JuliaPackaging/BinaryProvider.jl) downloads binaries intended as part of a build chain. I'm pretty sure you can trick it into downloading data.
 - [`Base.download`](https://docs.julialang.org/en/stable/stdlib/file/#Base.download) if your situtation is really simple just sticking a `download` into the `deps/build.jl` file might do you just fine.

 Outside of julia's ecosystem is

  - [Python: Quilt](https://github.com/quiltdata/quilt). Quilt uses a centralised data store, and allows the user to download the data as Python packages containing it in serialised from. It *might* be possible to use PyCall.jl to use this from julia.
  - [R: suppdata](https://github.com/ropensci/suppdata), features extra stuff relating to published datasets (See also DataDepsGenerators.jl), it *might* be possible to use RCall.jl to use this from julia.
  - [Node/Commandline: Datproject](https://datproject.org/) I'm not too familiar with this, it is a bit of an ecosystem of its own. I think using it from the commandline might satisfy many people's needs. Or automating it with shell calls in `build.jl`.
  
