using Revise
using DataDeps
using Base.Test

ENV["DATADEPS_ALWAY_ACCEPT"]=true

@testset "Pi" begin
    RegisterDataDep(
     "Pi",
     "There is no real reason to download Pi, unlike say lists of prime numbers, it is always faster to compute than it is to download. No matter how many digits you want.",
     "https://www.angio.net/pi/digits/10000.txt",
     sha2_256
    )

    pi_string = readstring(joinpath(datadep"Pi", "10000.txt"))
    @test parse(pi_string) ≈ π
    @test parse(BigFloat, pi_string) ≈ π

end

@testset "Primes" begin
    RegisterDataDep(
     "Primes",
     "These are the first 65 thousand primes. Still faster to calculate locally.",
     "http://staffhome.ecm.uwa.edu.au/~00061811/pub/primes.txt",

     "http://staffhome.ecm.uwa.edu.au/~00061811/pub/primes.sha256" |> download |> readstring |> split |> first
     #Important: this is a hash I didn't calculate, so is a test that our checksum methods actually align with the normal values.
    )

    data = readdlm(datadep"Primes"*"/primes.txt", ',')
    primes = data[4:end, 2] #skip fist 3
    
    #If these really are prime then will not have factors
    @test !any(isinteger.(primes./2))
    @test !any(isinteger.(primes./3))
    @test !any(isinteger.(primes./5))

end




@testset "MNIST" begin

    RegisterDataDep(
        "MNIST train",
        """
        Dataset: THE MNIST DATABASE of handwritten digits, (training subset)
        Authors: Yann LeCun, Corinna Cortes, Christopher J.C. Burges
        Website: http://yann.lecun.com/exdb/mnist/
        [LeCun et al., 1998a]
            Y. LeCun, L. Bottou, Y. Bengio, and P. Haffner.
            "Gradient-based learning applied to document recognition."
            Proceedings of the IEEE, 86(11):2278-2324, November 1998
        The files are available for download at the offical
        website linked above. We can download these files for you
        if you wish, but that doesn't free you from the burden of
        using the data responsibly and respect copyright. The
        authors of MNIST aren't really explicit about any terms
        of use, so please read the website to make sure you want
        to download the dataset.
        """,
        "http://yann.lecun.com/exdb/mnist/".*["train-images-idx3-ubyte.gz", "train-labels-idx1-ubyte.gz"];
        # Not providing a checksum at all so can check it gives output
    )


    RegisterDataDep(
        "MNIST",
        """
        Dataset: THE MNIST DATABASE of handwritten digits
        Authors: Yann LeCun, Corinna Cortes, Christopher J.C. Burges
        Website: http://yann.lecun.com/exdb/mnist/
        [LeCun et al., 1998a]
            Y. LeCun, L. Bottou, Y. Bengio, and P. Haffner.
            "Gradient-based learning applied to document recognition."
            Proceedings of the IEEE, 86(11):2278-2324, November 1998
        The files are available for download at the offical
        website linked above. We can download these files for you
        if you wish, but that doesn't free you from the burden of
        using the data responsibly and respect copyright. The
        authors of MNIST aren't really explicit about any terms
        of use, so please read the website to make sure you want
        to download the dataset.
        """,
        "http://yann.lecun.com/exdb/mnist/".*["train-images-idx3-ubyte.gz", "train-labels-idx1-ubyte.gz", "t10k-images-idx3-ubyte.gz", "t10k-labels-idx1-ubyte.gz"],
        "0bb1d5775d852fc5bb32c76ca15a7eb4e9a3b1514a2493f7edfcf49b639d7975"
    )
read(datadep"MNIST"*"/train-labels-idx1-ubyte.gz")
    @test read(datadep"MNIST"*"/train-labels-idx1-ubyte.gz") == read(datadep"MNIST train"*"/train-labels-idx1-ubyte.gz")
end


@testset "UCI Banking" begin
    RegisterDataDep(
        "UCI Banking",
        """
        Dataset: Bank Marketing Data Set
        Authors: S. Moro, P. Cortez and P. Rita.
        Website: https://archive.ics.uci.edu/ml/datasets/bank+marketing

        This dataset is public available for research. The details are described in [Moro et al., 2014].
        Please include this citation if you plan to use this database:
        [Moro et al., 2014] S. Moro, P. Cortez and P. Rita. A Data-Driven Approach to Predict the Success of Bank Telemarketing. Decision Support Systems, Elsevier, 62:22-31, June 2014
        """,
        [
        "https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank.zip",
        "https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip"
        ],
        [(SHA.sha1, "785118991cd7d7ee7d8bf75ea58b6fae969ac185"),
         (SHA.sha3_224, "01b53f5b69d0b169070219b4391c623d84ab17d4cea8c8895cbf951d")];

         post_fetch_method = file->run(`unzip $file`)
    )

    data, header = readdlm(datadep"UCI Banking"*"/bank.csv", ';', header=true)
    @test size(header) == (1,17)
    @test size(data) == (4521,17)

end





