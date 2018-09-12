using DataDeps
using Test
using ExpectationStubs


# HACK: todo, work out how ExpectationStubs should be changed to make this make sense
Base.open(stub::Stub, t::Any, ::AbstractString) = stub(t)

withenv("DATADEPS_ALWAYS_ACCEPT"=>"true") do
    @testset "automatic download" begin
        @stub dummyhash
        @expect(dummyhash(::Any) = [0x12, 0x34])

        @stub dummydown
        @expect(dummydown("http://www.example.com/eg.zip", ::String) = joinpath(@__DIR__, "eg.zip"))
            # HACK: this gives a directory, because we can't trivially mock out the cd

        register(DataDep( "Test1",
         "A dummy message",
         "http://www.example.com/eg.zip",
         (dummyhash, "1234"),#
         fetch_method=dummydown
        ))

        @test endswith(datadep"Test1", "Test1") || endswith(datadep"Test1", "Test1/") ||  endswith(datadep"Test1", "Test1\\")
        
        @test all_expectations_used(dummyhash)
        @test all_expectations_used(dummydown)

        rm(datadep"Test1"; recursive=true) # delete the directory
    end

    @testset "sanity check the macro's behaviour with variables" begin
        var = "foo/bar"
        macroexpand(@__MODULE__, :(@datadep_str var)) # this line would throw an error if the varibles were being handle wrong
        @test true
    end


    @testset "Ensure when errors occur the datadep will still retrydownloading" begin
        @testset "error in checksum" begin
            @stub dummydown
            @expect dummydown(::Any, ::Any) = @__FILE__ # give path to an actual file so `open` works
            

            register(DataDep("TestErrorChecksum", "dummy message", "http://example.void",
                             (error, "1234"); # this will throw an error
                             fetch_method=dummydown))
            @test_throws ErrorException datadep"TestErrorChecksum"
            @test @usecount(dummydown(::Any, ::Any)) == 1
            
            @test_throws ErrorException datadep"TestErrorChecksum"
            @test @usecount(dummydown(::Any, ::Any)) == 2 # it should have tried to download again
        end

        @testset "error in post fetch" begin
            @stub dummydown
            @expect dummydown(::Any, ::Any) = joinpath(@__DIR__, "eg.zip")
            
            register(DataDep("TestErrorPostFetch", "dummy message", "http://example.void", Any,
                             fetch_method=dummydown,
                             post_fetch_method = error
                            ))
            @test_throws ErrorException datadep"TestErrorPostFetch"
            @test @usecount(dummydown(::Any, ::Any)) == 1
            
            @test_throws ErrorException datadep"TestErrorPostFetch"
            @test @usecount(dummydown(::Any, ::Any)) == 2 # it should have tried to download again
        end


        @testset "error in fetch" begin
            use_count = 0
            function error_down(rp,lp)
                use_count += 1
                error("no download for you")
            end

            register(DataDep("TestErrorFetch", "dummy message", "http://example.void", Any,
                             fetch_method = error_down
                            ))
            @test_throws ErrorException datadep"TestErrorFetch"
            @test use_count == 1
            
            @test_throws ErrorException datadep"TestErrorFetch"
            @test use_count == 2 # it should have tried to download again
        end
    end
end




@testset "Ensure disabled if in CI #70" begin
    withenv("CI"=> "true") do
        @assert !haskey(ENV, "DATADEPS_ALWAYS_ACCEPT")
        @stub dummydown
        @expect dummydown(::Any, ::Any) = @__FILE__ # give path to an actual file so `open` works

        register(DataDep("TestErrorInCI", "dummy message", "http://example.void", Any,
                         fetch_method=dummydown))
        @test_throws DataDeps.DisabledError datadep"TestErrorInCI"
        @test @usecount(dummydown(::Any, ::Any)) == 0
        
    end
end
