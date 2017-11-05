using Revise

using DataDeps
using Base.Test
using ExpectationStubs


withenv("DATADEPS_ALWAY_ACCEPT"="true") do
    @testset "automatic download" begin
        @stub dummycheck
        @expect(dummycheck(::String) = true)

        @stub dummydown
        @expect(dummydown("http://www.example.com/eg.zip", ::String) = "eg.zip")

        RegisterDataDep(
         "Test1",
         "http://www.example.com/eg.zip", # the remote-path to fetch it from, normally an URL. Passed to the `fetch_method`
         dummycheck, #A hash that is used to check the data is right.
         fetch_method=dummydown
        )

        @test datadep"Test1" isa String

        @test all_expectations_used(dummycheck)
        @test all_expectations_used(dummydown)
    end
end
