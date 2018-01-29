using DataDeps
using Base.Test
import DataDeps.get_filename

@testset "not requiring headers" begin
    @test get_filename("https://www.angio.net/pi/digits/10000.txt") == "10000.txt"
end


@testset "using headers" begin
    # From http://test.greenbytes.de/tech/tc2231/

    
    @test "foo.html" == get_filename("http://test.greenbytes.de/tech/tc2231/attwithasciifilename.asis")

    @test "attonly.asis" == get_filename("http://test.greenbytes.de/tech/tc2231/attonly.asis")


    @test_broken "\"quoting\" tested.html" == get_filename("http://test.greenbytes.de/tech/tc2231/attwithasciifnescapedquote.asis")

    @test_broken "ä-%41.html" == get_filename("http://test.greenbytes.de/tech/tc2231/attwithfilenamepctandiso.asis")

end
