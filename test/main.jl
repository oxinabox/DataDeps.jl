using DataDeps
using Base.Test
using ExpectationStubs

# HACK: todo, work out how ExpectationStubs should be changed to make this make sense
Base.open(stub::Stub, t::Any, ::AbstractString) = stub(t)

withenv("DATADEPS_ALWAY_ACCEPT"=>"true") do
    @testset "automatic download" begin
        @stub dummyhash
        @expect(dummyhash(::Any) = [0x12, 0x34])

        @stub dummydown
        @expect(dummydown("http://www.example.com/eg.zip", ::String) = "eg.zip")

        RegisterDataDep( "Test1",
         "A dummy message",
         "http://www.example.com/eg.zip", # the remote-path to fetch it from, normally an URL. Passed to the `fetch_method`
         (dummyhash, "1234"), #A hash that is used to check the data is right.
         fetch_method=dummydown
        )

        @test endswith(datadep"Test1", "Test1/") || endswith(datadep"Test1", "Test1\\")

        @test all_expectations_used(dummyhash)
        @test all_expectations_used(dummydown)

        rm(datadep"Test1"; recursive=true) # delete the directory
    end

    @testset "sanity check the macro's behaviour with variables" begin
        var = "foo/bar"
        macroexpand(:(@datadep_str var)) # this line would throw an error if the varibles were being handle wrong
        @test true
    end

end
