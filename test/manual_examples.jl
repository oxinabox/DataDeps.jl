using DataDeps
using Base.Test


@testset "Manual included" begin 
    RegisterDataDep(
        "Example",
        """
        This manual datadep should have been installed with the package.
        If you are seeing this message something has gone wrong.
        Try removing and then adding the package back again.
        If that doesn't work raise an issue on the repo.
        """
    )

    content = readstring(datadep"Example"*"/loremipsum.txt")
    @test startswith(content, "lorem ipsum dolor sit amet")
end
