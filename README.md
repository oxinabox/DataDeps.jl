# DataDeps
Travis CI Master: [![Build Status](https://travis-ci.org/oxinabox/DataDeps.jl.svg?branch=master)](https://travis-ci.org/oxinabox/DataDeps.jl)
AppVeyor Master: [![Build status](https://ci.appveyor.com/api/projects/status/kpi2pgfnvx6yp9n4/branch/master?svg=true)](https://ci.appveyor.com/project/oxinabox/datadeps-jl-ld1pa/branch/master)



## See Also

### Software using DataDeps.jl
It might help to look at DataDeps.jl is being used to understand how it maybe used for your project.
Some of these add some additional abstraction or niceness for users on top of the DataDeps.jl core functionality.

 - [WordNet.jl](https://github.com/JuliaText/WordNet.jl)
 - [MLDatasets.jl](https://github.com/JuliaML/MLDatasets.jl/)
 - [CorpusLoaders.jl](https://github.com/JuliaText/CorpusLoaders.jl)
 - [Embeddings.jl](https://github.com/JuliaText/Embeddings.jl)

(Feel free to submit a PR adding a link your Package, or research script here.)

### Other similar packages:
DataDeps.jl isn't the answer to all your download needs.
It is focused squarely on static data.
It might not be good for your use case.

Alternatives that I am aware of are:

 - [RemoteFiles.jl](https://github.com/helgee/RemoteFiles.jl): keeps local files up to date with remotes. In someways it is the opposite of DataDeps.jl (which means it is actually very similar in many ways).
 - [BinaryProvider.jl](https://github.com/JuliaPackaging/BinaryProvider.jl) downloads binaries intended as part of a build chain. I'm pretty sure you can trick it into downloading data.
 - [`Base.download`](https://docs.julialang.org/en/stable/stdlib/file/#Base.download) if your situtation is really simple just sticking a `download` into the `deps/build.jl` file might do you just fine.

 Outside of julia's ecosystem is

  - [Python: Quilt](https://github.com/quiltdata/quilt). Quilt uses a centralised data store, and allows the user to download the data as Python packages containing it in serialised from. It *might* be possible to use PyCall.jl to use this from julia.
  - [R: suppdata](https://github.com/ropensci/suppdata), features extra stuff relating to published datasets (See also DataDepsGenerators.jl), it *might* be possible to use RCall.jl to use this from julia.
  - [Node/Commandline: Datproject](https://datproject.org/) I'm not too familiar with this, it is a bit of an ecosystem of its own. I think using it from the commandline might satisfy many people's needs. Or automating it with shell calls in `build.jl`.
  
  
 ### Links:

  - [ANN: thread on Discourse](https://discourse.julialang.org/t/ann-datadeps-jl-bindeps-for-data/8457/15)
  - [MLOSS](http://mloss.org/software/view/705/)
  - [Release Blog Post (as above)](http://white.ucc.asn.au/2018/01/18/DataDeps.jl-Repeatabled-Data-Setup-for-Repeatable-Science.html)
  - [DataDepsGenerators.jl (as above)](https://github.com/oxinabox/DataDepsGenerators.jl)
  - JuliaCon 2018 [Slides](https://figshare.com/articles/JuliaCon2018_DataDeps_jl_pdf/6949145), and [Video](https://youtu.be/kSlQpzccRaI)
 
 #### Paper Preprint
 [White, L.; Togneri, R.; Liu, W. & Bennamoun, M. DataDeps.jl: Repeatable Data Setup for Replicable Data Science ArXiv e-prints, 2018](https://arxiv.org/abs/1808.01091)
