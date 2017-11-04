# DataDeps


Please provide feedback by raising issues, or making PRs.

The plan can be found at [plan](plan.jl).
It might be a little outdated.



## Confinuration

Currently configuration is done via Enviroment Variables.
It is likely to stay that way, as they are also easy to setup in CI tools.

 - `DATADEPS_ALWAY_ACCEPT` -- bypasses the confirmation before downloading data. Set to `true` (or similar string)
    - This is provided for scripting (in particular CI) use
    - Note that it remains your responsibility to understand and read any terms of the data use (this is remains true even if you don't turn on this bypass)

	
