# This file is a part of DataDeps.jl. License is MIT.
module DataDeps
using p7zip_jll

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


function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{typeof(resolve), DataDep, String, String})   # time: 0.007738324
end

_precompile_()

end # module
