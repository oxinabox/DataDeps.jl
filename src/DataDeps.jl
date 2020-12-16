# This file is a part of DataDeps.jl. License is MIT.
module DataDeps

if VERSION < v"1.3"
    # Load in `deps.jl`, complaining if it does not exist
    const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
    if !isfile(depsjl_path)
        error("DataDeps not installed properly, run `] build DataDeps`, restart Julia and try again")
    end
    include(depsjl_path)

    # Emulate `p7zip_jll` behaviour
    p7zip(f) = f(p7zip_exe)
else
    using p7zip_jll
end

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
