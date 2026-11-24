using Test


using DataDeps: env_bool
@testset "Env Bool" begin
    withenv("A"=>"True") do
        @test env_bool("A")
    end
    withenv("B"=>"No") do
        @test !env_bool("B")
    end

    withenv("C"=>"") do
        @test !env_bool("C")
    end


    withenv("D"=>"0") do
        @test !env_bool("D")
    end

    withenv("E"=>"1") do
        @test env_bool("E")
    end
end

using DataDeps: env_list
@testset "env_list" begin
    list(value, windows) = withenv(() -> env_list("DATADEPS_TEST_LIST"; windows=windows), "DATADEPS_TEST_LIST" => value)

    withenv("DATADEPS_TEST_LIST" => nothing) do
        @test env_list("DATADEPS_TEST_LIST") == String[]
        @test env_list("DATADEPS_TEST_LIST", ["default"]) == ["default"]
    end

    @testset "non-Windows: split at every colon" begin
        @test list("/a/b", false) == ["/a/b"]
        @test list("/a:/b/c", false) == ["/a", "/b/c"]
        @test list("", false) == [""]  # see #89
        @test list("/a:", false) == ["/a", ""]
    end

    @testset "Windows: split at every semicolon" begin
        @test list(raw"C:\Users\me\data", true) == [raw"C:\Users\me\data"]
        @test list("C:/a", true) == ["C:/a"]
        @test list(raw"C:\a;D:\b", true) == [raw"C:\a", raw"D:\b"]
        @test list("C:/a;d:/b", true) == ["C:/a", "d:/b"]
        @test list(raw"\\server\share;C:\a", true) == [raw"\\server\share", raw"C:\a"]
        @test list(raw"\\?\C:\data", true) == [raw"\\?\C:\data"]
        @test list(raw"C:\a;", true) == [raw"C:\a", ""]
        @test list("", true) == [""]  # see #89
        # Colons are no longer separators on Windows
        @test list(raw"\a:\b", true) == [raw"\a:\b"]
    end
end
