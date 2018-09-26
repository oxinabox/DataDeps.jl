# Usage for end-users
The main goal of DataDeps.jl is to simplify life for the user.
They should just forget about the data their package needs.

## Moving Data
Moving data is a great idea.
DataDeps.jl is in favour of moving data
When data is automatically downloaded it will almost always go to the same location.
The first (existant, writable) directory on your `DATADEPS_LOADPATH`.
Which by-default is `~/.julia/datadeps/`.
(If you delete this, it will go to another location
But you can move them from there to anywhere in the `DATADEPS_LOADPATH`. (See below)

If you have a large chunk of data that everyone in your lab is using (e.g. a 1TB video corpora),
you probably want to shift it to a shared area, like `/usr/share/datadeps`.
Even if you don't have write permissions, you can have a sysadmin move it, and so long as you still have read permission DataDeps.jl will find it and use it for you.


### The Load Path
The Load Path is the list of paths that DataDeps.jl looks in when trying to resolve a data dependency.
If it doesn't find the data in any of them it will download the data.

It has 3 sources:
 - the package load path:
     - determined from the package where the `datadep"NAME"` was used
 - The user defined load path
     - determined from the contents of the environment variable `DATADEPS_LOAD_PATH`
     - this can be a colon separated list (Like most unix path variables)
 - the standard load path
     - depends on your system and configuration
     - normally starts with user specific locations like your home directory, and expands out to shared locations
     - See below lists of examples
     - This can be disabled by setting the `DATADEPS_NO_STANDARD_LOAD_PATH` environment variable.

In general it should by default include just about anywhere you might want to put the data.
If it doesn't, please file an issue. (Unless your location is super-specific, e.g. `/MyUniName/student/commons/datadeps`).
As mentioned you can add things to the load path by setting the environment variable `DATADEPS_LOAD_PATH`.
You can also make symlinks from the locations on the loadpath to other locations where the data really is, if you'ld rather do that.

When **loading data** the load path is searched in order for a readable folder of the right now.
When **saving data** is it is searched in order, skipping the package load path, for a writable directory.
Simple way to avoid part of the standard loadpath being used for saving is to delete it, or make it unwritable.
You can (and should when desired) move things around between any folder in the load path without redownloading.


### Unix Standard Load Path
For the user **oxinabox**

```bash
/home/wheel/oxinabox/.julia/datadeps
/home/wheel/oxinabox/datadeps
/scratch/datadeps
/staging/datadeps
/usr/share/datadeps
/usr/local/share/datadeps
```

### Windows Standard Load Path
For the user **oxinabox**, when using JuliaPro 0.6.2.1, on windows 7.
(Other configurations should be fairly similar).

```batch
C:\Users\oxinabox\AppData\Local\JuliaPro-0.6.2.1\pkgs-0.6.2.1\datadeps
C:\Users\oxinabox\datadeps
C:\Users\oxinabox\AppData\Roaming\datadeps
C:\Users\oxinabox\AppData\Local\datadeps
C:\ProgramData\datadeps
C:\Users\Public\datadeps
```


### Having multiple copies of the same DataDir
You probably don't want to have multiple copies of a DataDir with the same name.
DataDeps.jl will try to handle it as gracefuly as it can.
But having different DataDep under the same name, is probably going to lead to packages loading the wrong one.
Except if they are (both) located in their packages `deps/data` folder.

By moving a package's data dependency into its package directory under `deps/data`, it becomes invisible except to that package.
For example `~/.julia/v0.6/EXAMPLEPKG/deps/data/EXAMPLEDATADEP/`,
for the package `EXAMPLEPKG`, and the datadep `EXAMPLEDATADEP`.

Ideally though you should probably raise an issue with the package maintainers and see if one (or both) of them want to change the DataDep name.

Note also when it comes to file level loading, e.g. `datadep"Name/subfolder/file.txt"`,
DataDeps does not check all folders with that `Name` (if you have multiples).
If the file is not in the first folder it finds you will be presented with the recovery dialog,
from which the easiest option is to select to delete the folder and retry,
since that will result in it checking the second folder (as the first one does not exist).


## Configuration
Currently configuration is done via Enviroment Variables.
It is likely to stay that way, as they are also easy to setup in CI tools.
You can set these in the `.juliarc` file using the `ENV` dictionary if you don't want to mess up your `.profile`.
However, most people shouldn't need to.
DataDeps.jl tries to have very sensible defaults.

 - `DATADEPS_ALWAYS_ACCEPT` -- bypasses the confirmation before downloading data. Set to `true` (or similar string)
    - default `false`
    - Note that it remains your responsibility to understand and read any terms of the data use (this is remains true even if you don't turn on this bypass)    
    - This is provided for scripting (in particular CI) use
    - If the `CI` environment variable is set to true, `DATADEPS_ALWAYS_ACCEPT`  **must be set** to true or false. This is to prevent hanging in CI.
 - `DATADEP_PROGRESS_UPDATE_PERIOD` -- how often (in seconds) to print the progress to the log for the download
	- This is used by the default `fetch_method` and when implementing custom methods it is good to respect it.
	- default: `5` (seconds) usually; `Inf` (i.e. no updates) if `DATADEPS_ALWAYS_ACCEPT` is set.
 - `DATADEPS_LOAD_PATH` -- The list of paths to be prepended to the standard loadpath to save and load data from
    - By default this is empty, but it can be a colon separated list (like most unix path variables). [For more details see above](#The-Load-Path)
 - `DATADEPS_NO_STANDARD_LOAD_PATH` if this is set to `true` (default `false`), then the aforementioned list of standard loadpath files is not included
 - `DATADEPS_DISABLE_DOWNLOAD` -- causes any action that would result in the download being triggered to throw an exception.
   - useful e.g. if you are in an environment with metered data, where your datasets should have already been downloaded earlier, and if there were not you want to respond to the situation rather than let DataDeps download them for you.
   - default `false`
 - `DATADEPS_DISABLE_ERROR_CLEANUP` -- By default DataDeps.jl will cleanup the directory the datadep was being downloaded to if there is an error during the resolution (In any of the `fetch`, `checksum`, or `post_fetch`). For debugging purposes you may wish to disable this cleanup step so you can interrogate the files by hand.

