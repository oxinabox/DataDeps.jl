# This file is a part of DataDeps.jl. License is MIT.
module DataDeps

using HTTP
using Reexport
@reexport using SHA

export DataDep, ManualDataDep
export register, resolve, @datadep_str
export unpack


include("types.jl")

include("util.jl")
include("registration.jl")

include("filename_solving.jl")
include("locations.jl")
include("verification.jl")

include("resolution.jl")
include("resolution_automatic.jl")
include("resolution_manual.jl")

include("helpers.jl")
include("deprecations.jl")

end # module
