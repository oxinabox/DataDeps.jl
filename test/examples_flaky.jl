using Base.Test
using DataDeps

# These Tests are too Flaky to run on CI
# They should run fine on any properly configured machine
# but do to the webserver hosting them having perculuarities
# they are overly fragile to things like SSL versions

if DataDeps.env_bool("DATADEPS_ENABLE_FLAKY_TESTS")
    @testset "Data.Gov Babynames" begin
        RegisterDataDep(
            "Baby Names",
            """
            Dataset: Baby Names from Social Security Card Applications-National Level Data
            Website: https://catalog.data.gov/dataset/baby-names-from-social-security-card-applications-national-level-data
            License: CC0

            The data (name, year of birth, sex and number) are from a 100 percent sample of Social Security card applications after 1879.
            """,
            ["https://www.ssa.gov/oact/babynames/names.zip",
            "https://catalog.data.gov/harvest/object/f8ab4d49-b6b4-47d8-b1bb-b18187094f35"
             # Interestingly this metadata file fails on windows to resolve to filename to save to
             # See warnings, The `mv` in post_fetch_method is the work-around.
            ],
            Any, # Test that there is no warning about checksum. This data is updated annually
            #TODO : Automate this test with new 0.7 test_warn stuff
            ;
            post_fetch_method = [unpack, f->mv(f, "metadata551randstuff.json")]
        )

        @test !any(endswith.(readdir(datadep"Baby Names"), "zip"))
        @test first(eachline(joinpath(datadep"Baby Names", "yob2016.txt")))=="Emma,F,19414"
        @test filemode(joinpath(datadep"Baby Names", "metadata551randstuff.json")) > 0
    end
end
