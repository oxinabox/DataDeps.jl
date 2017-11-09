# DataDeps


Please provide feedback by raising issues, or making PRs.

The plan can be found at [plan](plan.jl).
It might be a little outdated.



## Configuration

Currently configuration is done via Enviroment Variables.
It is likely to stay that way, as they are also easy to setup in CI tools.

 - `DATADEPS_ALWAY_ACCEPT` -- bypasses the confirmation before downloading data. Set to `true` (or similar string)
    - This is provided for scripting (in particular CI) use
    - Note that it remains your responsibility to understand and read any terms of the data use (this is remains true even if you don't turn on this bypass)
	- default `false`
 - `DATADEPS_LOAD_PATH` -- The list of paths, other than the package directory (`PKGNAME/deps/data`) to save and load data from
 - `DATADEPS_PKGDIR_FIRST` -- check/attempt to save in  `PKGNAME/deps/data` before everything in `DATADEPS_LOAD_PATH`, rather than after.
    - default `false`
 - `DATADEPS_DISABLE_DOWNLOAD` -- causes any action that would result in the download being triggered to throw an exception.
   - useful e.g. if you are in an environment with metered data, where your datasets should have already been downloaded earlier, and if there were not you want to respond to the situation rather than let DataDeps download them for you.
   - default `false`
