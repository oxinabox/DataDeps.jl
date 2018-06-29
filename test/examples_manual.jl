using DataDeps
using Test


@testset "Manual included" begin
    register(ManualDataDep(
        "Example",
        """
        This manual datadep should have been installed with the package.
        If you are seeing this message something has gone wrong.
        Try removing and then adding the package back again.
        If that doesn't work raise an issue on the repo.
        """
    ))

    content = read(datadep"Example"*"/loremipsum.txt", String)
    @test startswith(content, "lorem ipsum dolor sit amet")
end


if DataDeps.env_bool("DATADEPS_ENABLE_MANUAL_TESTS")
    @testset "Manual nonincluded" begin
        register(ManualDataDep(
            "Kafta",
            """
            Please go to
                https://www.gutenberg.org/ebooks/5200
                and download the Plain Text version as `mm.txt`
                Note this must be done manually as Project Gutenberg does not allow directly linking to their ebooks.
                only to the canonical catalog entry (See https://www.gutenberg.org/wiki/Gutenberg:Information_About_Linking_to_our_Pages)
            """
        ))

        @test first(readlines(datadep"Kafta"*"/mm.txt")) == "\ufeffThe Project Gutenberg EBook of Metamorphosis, by Franz Kafka"
    end
end
