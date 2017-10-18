# DataDeps
<!--
[![Build Status](https://travis-ci.org/oxinabox/DataDeps.jl.svg?branch=master)](https://travis-ci.org/oxinabox/DataDeps.jl)

[![Coverage Status](https://coveralls.io/repos/oxinabox/DataDeps.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/oxinabox/DataDeps.jl?branch=master)

[![codecov.io](http://codecov.io/github/oxinabox/DataDeps.jl/coverage.svg?branch=master)](http://codecov.io/github/oxinabox/DataDeps.jl?branch=master)
-->


## Users
There are 3 classes of users of DataDeps:

 - **ProviderUsers**: Packages such as MLDatasets.jl, and CorpusLoaders.jl, whos purpose is to provide access to standard datasets. Other packages wanting to use these datasets don't use DataDeps directly, they use the Provider package, which gives a nice interface to that data.
 - **ProjectUsers**: Packages, that need a dataset or two, possibly for testing, possibly for running experiments, possibly for normally functioning. A key class of these is code that corresponds to a scientific investigation. E.g. the code for some ML paper with a fancy new technique. The fact that these are using DataDeps directly means the data is a bit obsure, as it is not provided by a ProviderUser package. - **CasualUsers**: By which I mean people just working in the REPL, not using modules etc. These are not the target of the DataDeps.jl, but worth bearing in mind they exist. These users are probably happy with just using `download`.
