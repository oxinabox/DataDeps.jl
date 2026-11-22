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

using DataDeps: split_load_path
@testset "split_load_path" begin
    @testset "non-Windows: split at every colon" begin
        @test split_load_path("/a/b", false) == ["/a/b"]
        @test split_load_path("/a:/b/c", false) == ["/a", "/b/c"]
        @test split_load_path("", false) == [""]  # see #89
        @test split_load_path("/a:", false) == ["/a", ""]
    end

    @testset "Windows: semicolon separated" begin
        @test split_load_path(raw"C:\Users\me\data", true) == [raw"C:\Users\me\data"]
        @test split_load_path(raw"C:\a;D:\b", true) == [raw"C:\a", raw"D:\b"]
        @test split_load_path("C:/a;d:/b", true) == ["C:/a", "d:/b"]
        @test split_load_path(raw"\\server\share;C:\a", true) == [raw"\\server\share", raw"C:\a"]
        @test split_load_path(raw"C:\a;", true) == [raw"C:\a", ""]
        @test split_load_path("", true) == [""]  # see #89
    end

    @testset "Windows: colon separated fallback (backwards compatibility)" begin
        @test split_load_path("C:/a", true) == ["C:/a"]
        @test split_load_path(raw"C:\a:D:\b", true) == [raw"C:\a", raw"D:\b"]
        @test split_load_path(raw"C:\a:\b", true) == [raw"C:\a", raw"\b"]
        @test split_load_path(raw"\a:\b", true) == [raw"\a", raw"\b"]
        @test split_load_path("a:b", true) == ["a", "b"]
    end

    @testset "Windows: drive letters in extended-length and device paths" begin
        @test split_load_path(raw"\\?\C:\data", true) == [raw"\\?\C:\data"]
        @test split_load_path(raw"\\.\C:\data", true) == [raw"\\.\C:\data"]
        @test split_load_path(raw"\\?\C:\a:\\?\D:\b", true) == [raw"\\?\C:\a", raw"\\?\D:\b"]
        @test split_load_path(raw"C:\a:\\?\D:\b", true) == [raw"C:\a", raw"\\?\D:\b"]
        @test split_load_path(raw"\\?\UNC\server\share:C:\a", true) == [raw"\\?\UNC\server\share", raw"C:\a"]
    end
end
