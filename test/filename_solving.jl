using DataDeps
using Base.Test
import DataDeps.get_filename

@testset "post processing" begin
    phf(x) = DataDeps.process_header_filename(match(r"(.*)",x))

    @test phf("foo.txt") == "foo.txt"
    @test phf("\"foo.txt\"") == "foo.txt"
    @test phf("\"bar \\\"zap zing\\\" foo.txt\"") == "bar \"zap zing\" foo.txt"
end

@testset "using headers" begin
    # From http://test.greenbytes.de/tech/tc2231/

    
    @test "foo.html" == get_filename("http://test.greenbytes.de/tech/tc2231/attwithasciifilename.asis")

    @test "foo.html" == get_filename("http://test.greenbytes.de/tech/tc2231/attwithasciifilenamenq.asis") # Technically invalid, but github API does this

    @test "attonly.asis" == get_filename("http://test.greenbytes.de/tech/tc2231/attonly.asis")

    @test "\"quoting\" tested.html" == get_filename("http://test.greenbytes.de/tech/tc2231/attwithasciifnescapedquote.asis")

    @test_broken "ä-%41.html" == get_filename("http://test.greenbytes.de/tech/tc2231/attwithfilenamepctandiso.asis")

end


@testset "not requiring headers" begin
    @test get_filename("https://www.angio.net/pi/digits/10000.txt") == "10000.txt"
end


