using Test
using DataDeps
using DelimitedFiles

ENV["DATADEPS_ALWAYS_ACCEPT"] = true

@testset "Pi" begin
    register(DataDep(
     "Pi",
     "There is no real reason to download Pi, unlike say lists of prime numbers, it is always faster to compute than it is to download. No matter how many digits you want.",
     "https://www.angio.net/pi/digits/10000.txt",
     sha2_256
    ))

    pi_string = read(datadep"Pi/10000.txt", String)
    @test parse(Float64, pi_string) ≈ π
    @test parse(BigFloat, pi_string) ≈ π

end

@testset "Primes" begin
    register(DataDep(
     "Primes",
     "These are the first 65 thousand primes. Still faster to calculate locally.",
     "http://staffhome.ecm.uwa.edu.au/~00061811/pub/primes.txt",

     "d6524d63a5cf5e5955568cc96b72b3f39258af4f0f79c61cbc01d8853e587f1b"
     #Important: this is a hash I didn't calculate, so is a test that our checksum methods actually align with the normal values.
    ))

    data = readdlm(datadep"Primes/primes.txt", ',')
    primes = data[4:end, 2] #skip fist 3

    #If these really are prime then will not have factors
    @test !any(isinteger.(primes./2))
    @test !any(isinteger.(primes./3))
    @test !any(isinteger.(primes./5))

end


@testset "TrumpTweets" begin
    # This tests demostrates how the `post_fetch_method` can be used to synthesize new files

    register(DataDep("TrumpTweets",
    """
    Tweets from 538's article:
    [The World’s Favorite Donald Trump Tweets](https://fivethirtyeight.com/features/the-worlds-favorite-donald-trump-tweets/)

    Includes a filtered view that is the tweats filtered to remove any tweets that @mention anyone,
    so no conversations etc, just announcements of opinions/thoughts.

    Used under Creative Commons Attribution 4.0 International License.
    """,
    "https://raw.githack.com/fivethirtyeight/data/master/trump-twitter/realDonaldTrump_poll_tweets.csv",
    "5a63b6cb2503a20517b5d41bd73e821ffbfdddd5cdc1977a547f1c925790bb15",
    post_fetch_method = function(in_fn) # Multiline anon function.
        out_fn = "nonmentions_"*basename(in_fn)
        print(out_fn)
        open(out_fn, "w") do out_fh
            for line in eachline(in_fn)
                if '@' ∉ line
                    println(out_fh, line)
                end
            end
        end

    end
    ))

    # Read the original file
    all_tweets = Set(eachline(datadep"TrumpTweets/realDonaldTrump_poll_tweets.csv"))
    # Read the file that we are generating
    nonmentions_tweets = Set(eachline(datadep"TrumpTweets/nonmentions_realDonaldTrump_poll_tweets.csv"))
    # Use them both
    mentions_tweets = setdiff(all_tweets, nonmentions_tweets)
    @test length(mentions_tweets) > 0
    @test all(Ref('@') .∈ collect(mentions_tweets))
end




@testset "MNIST" begin

    register(DataDep(
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
        # TODO : automate this test with new 0.7 stuff
    ))


    register(DataDep(
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
    ))
read(datadep"MNIST"*"/train-labels-idx1-ubyte.gz")
    @test read(datadep"MNIST"*"/train-labels-idx1-ubyte.gz") == read(datadep"MNIST train"*"/train-labels-idx1-ubyte.gz")
end



@testset "UCI Banking" begin
    register(DataDep(
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

         post_fetch_method = unpack
    ))

    data, header = readdlm(datadep"UCI Banking/bank.csv", ';', header=true)
    @test size(header) == (1,17)
    @test size(data) == (4521,17)

end


@testset "UCI Adult, Hierarchical checksums" begin
    # This is an example of using hierachacy in the remote URLs,
    # and similar (partially matching up to depth) hierachacy in the checksums
    # for processing some groups of elements differently to others.
    # Doing this with checksums is not particularly useful
    # But the same thing applies to `fetch_method` and `post_fetch_method`.
    # So for example the
    register(DataDep(
        "UCI Adult",
        """
    	Dataset: Adult Data Set UCI ML Repository
    	Website: https://archive.ics.uci.edu/ml/datasets/Adult
    	Abstract : Predict whether income exceeds \$50K/yr based on census data.  Also known as "Census Income" dataset.

    	If you make use of this data it is requested that you cite:
    	- Lichman, M. (2013). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, School of Information and Computer Science.
    	""",
        [
            [
                "https://archive.ics.uci.edu/ml/datasets/../machine-learning-databases/adult/adult.data",
                "https://archive.ics.uci.edu/ml/datasets/../machine-learning-databases/adult/adult.test"
            ],

            [
                "https://archive.ics.uci.edu/ml/datasets/../machine-learning-databases/adult/Index",
                [
                    "https://archive.ics.uci.edu/ml/datasets/../machine-learning-databases/adult/adult.names"
                    "https://archive.ics.uci.edu/ml/datasets/../machine-learning-databases/adult/old.adult.names"
                ]
             ]
        ],
        [
            "f9a9220df6bc5d9848bf450fd9ad45b9496503551af387d4a1bbe38ce1f8fc38", #adult.data ⊻ adult.test
            [
             "c53c35ce8a0eb10c12dd4b73830f3c94ae212bb388389d3763bce63e8d6bc684", #Index
             "818481d320861c4b623626ff6fab3426ad93dae4434b7f54ca5a0f357169c362" # adult.names ⊻ old.adult.names
            ]
        ]
    ))

    @test length(collect(eachline(datadep"UCI Adult/adult.names"))) == 110

end


@testset "gzipped source code" begin
	register(DataDep("DataDeps Source v0.5.0",
		"""
		This is the source code of DataDeps.jl v0.5.0
        This test checked we can unpack gzipped tarballs.
        """,
		"https://github.com/oxinabox/DataDeps.jl/archive/v0.5.0.tar.gz",
		"cd1fc3e58b4272ec559d1c5bcda5e4f0339647dab709baa2d507a73f3a89168d";
        post_fetch_method=DataDeps.unpack
	));
    @test length(readdir(datadep"DataDeps Source v0.5.0")) == 2
end
