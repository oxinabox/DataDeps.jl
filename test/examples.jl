using Revise
using DataDeps
using Base.Test

ENV["DATADEPS_ALWAY_ACCEPT"]=false

@testset "Pi" begin
    RegisterDataDep(
     "Pi",
     "There is no real reason to download Pi, unlike say lists of prime numbers, it is always faster to compute than it is to download. No matter how many digits you want.",
     "https://www.angio.net/pi/digits/10000.txt",
     sha2_256
    )

    @show datadep"Pi"
    pi_string = read(joinpath(datadep"Pi", "10000.txt"))


    rm(datadep"Pi"; recursive=true)
end
