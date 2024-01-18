using Test
using DataDeps: fetch_default, fetch_base, fetch_http

@testset "easy https url" begin
    url = "https://www.angio.net/pi/digits/10000.txt"
    # This is easy because the filename is in the URL
    # So it works with both `fetch_base` and `fetch_http`
    # HTTP.jl has tests for much more difficult cases, and fetch_http supports those
    @testset "$fetch_func" for fetch_func in (fetch_default, fetch_base, fetch_http)
        mktempdir() do localdir
            localpath = withenv("DATADEPS_ALWAYS_ACCEPT" => true) do
                fetch_func(url, localdir)
            end
            @test isfile(localpath)
            @test localpath == joinpath(localdir, "10000.txt")
            @test stat(localpath).size == 10_001
        end
    end
end
