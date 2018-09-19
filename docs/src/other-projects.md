# Other similar packages:
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
  
