# This file is a part of DataDeps.jl. License is MIT.
module DataDeps

using HTTP
using Reexport
@reexport using SHA

export DataDep, ManualDataDep
export register, resolve, @datadep_str, preupload_check
export unpack

include("errors.jl")
include("types.jl")

include("util.jl")
include("registration.jl")


include("locations.jl")
include("verification.jl")

include("resolution.jl")
include("resolution_automatic.jl")
include("resolution_manual.jl")

include("preupload.jl")

include("fetch_helpers.jl")
include("post_fetch_helpers.jl")

end # module
