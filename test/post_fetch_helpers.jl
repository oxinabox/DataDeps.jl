using Test
using DataDeps: unpack, p7zip

# Runs `f()` and returns what would normally be printed to stdout
function capture_stdout(f)
    std = stdout
    r, w = redirect_stdout()
    try
        f()
    finally
        redirect_stdout(std)
        close(w)
    end
    output = read(r, String)
    return output
end

@testset "unpack" begin

    @testset "happy case" begin
        # Create dummy zip
        p7zip() do exe7z
            run(`$exe7z a assets/test.zip assets/file1.txt -bso0 -bsp0`)
        end

        output = capture_stdout() do
            unpack("assets/test.zip")
        end
        @test output == ""  # silent
    end

    @testset "sad case" begin
        # depending on Julia version may be ErrorException or ProcessFailedException
        @test_throws Union{ErrorException,ProcessFailedException} unpack("assets/non-existent.zip")
    end
end
