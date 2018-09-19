var documenterSearchIndex = {"docs": [

{
    "location": "apiref.html#",
    "page": "API Reference",
    "title": "API Reference",
    "category": "page",
    "text": ""
},

{
    "location": "apiref.html#API-Reference-1",
    "page": "API Reference",
    "title": "API Reference",
    "category": "section",
    "text": ""
},

{
    "location": "apiref.html#DataDeps.resolve-Tuple{AbstractString,Any}",
    "page": "API Reference",
    "title": "DataDeps.resolve",
    "category": "method",
    "text": "resolve(\"name/path\", @__FILE__)\n\nIs the function that lives directly behind the datadep\"name/path\" macro. If you are working the the names of the datadeps programatically, and don\'t want to download them by mistake; it can be easier to work with this function.\n\nNote though that you must include @__FILE__ as the second argument, as DataDeps.jl uses this to allow reading the package specific deps/data directory. Advanced usage could specify a different file or nothing, but at that point you are on your own.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.resolve-Tuple{DataDeps.AbstractDataDep,Any,Any}",
    "page": "API Reference",
    "title": "DataDeps.resolve",
    "category": "method",
    "text": "resolve(datadep, inner_filepath, calling_filepath)\n\nReturns a path to the folder containing the datadep. Even if that means downloading the dependancy and putting it in there.\n\n - `inner_filepath` is the path to the file within the data dir\n - `calling_filepath` is a path to the file where this is being invoked from\n\nThis is basically the function the lives behind the string macro datadep\"DepName/inner_filepath\".\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.unpack-Tuple{Any}",
    "page": "API Reference",
    "title": "DataDeps.unpack",
    "category": "method",
    "text": "unpack(f; keep_originals=false)\n\nExtracts the content of an archive in the current directory; deleting the original archive, unless the keep_originals flag is set.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#Public-API-1",
    "page": "API Reference",
    "title": "Public API",
    "category": "section",
    "text": "Modules = [DataDeps]\nPrivate = false\nOrder = [:function]"
},

{
    "location": "apiref.html#Base.download-Tuple{DataDep,Any}",
    "page": "API Reference",
    "title": "Base.download",
    "category": "method",
    "text": "Base.download(\n    datadep::DataDep,\n    localdir;\n    remotepath=datadep.remotepath,\n    skip_checksum=false,\n    i_accept_the_terms_of_use=nothing)\n\nA method to download a datadep. Normally, you do not have to download a data dependancy manually. If you simply cause the string macro datadep\"DepName\", to be exectuted it will be downloaded if not already present.\n\nInvoking this download method manually is normally for purposes of debugging, As such it include a number of parameters that most people will not want to use.\n\nlocaldir: this is the local directory to save to.\nremotepath: the remote path to fetch the data from, use this e.g. if you can\'t access the normal path where the data should be, but have an alternative.\nskip_checksum: setting this to true causes the checksum to not be checked. Use this if the data has changed since the checksum was set in the registry, or for some reason you want to download different data.\ni_accept_the_terms_of_use: use this to bypass the I agree to terms screen. Useful if you are scripting the whole process, or using annother system to get confirmation of acceptance.\nFor automation perposes you can set the enviroment variable DATADEPS_ALWAYS_ACCEPT\nIf not set, and if DATADEPS_ALWAYS_ACCEPT is not set, then the user will be prompted.\nStrictly speaking these are not always terms of use, it just refers to the message and permission to download.\n\nIf you need more control than this, then your best bet is to construct a new DataDep object, based on the original,  and then invoke download on that.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps._resolve-Tuple{DataDeps.AbstractDataDep,Any}",
    "page": "API Reference",
    "title": "DataDeps._resolve",
    "category": "method",
    "text": "The core of the resolve function without any user friendly file stuff, returns the directory\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.accept_terms-Tuple{DataDep,Any,Any,Nothing}",
    "page": "API Reference",
    "title": "DataDeps.accept_terms",
    "category": "method",
    "text": "accept_terms(datadep, localpath, remotepath, i_accept_the_terms_of_use)\n\nEnsurses the user accepts the terms of use; otherwise errors out.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.checksum-Tuple{Any,Any}",
    "page": "API Reference",
    "title": "DataDeps.checksum",
    "category": "method",
    "text": "checksum(hasher=sha2_256, filename[/s])\n\nExecutes the hasher, on the file/files, and returns a UInt8 array of the hash. xored if there are multiple files\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.checksum_pass-Tuple{Any,Any}",
    "page": "API Reference",
    "title": "DataDeps.checksum_pass",
    "category": "method",
    "text": "checksum_pass(hash, fetched_path)\n\nEnsures the checksum passes, and handles the dialog with use user when it fails.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.determine_save_path",
    "page": "API Reference",
    "title": "DataDeps.determine_save_path",
    "category": "function",
    "text": "determine_save_path(name)\n\nDetermines the location to save a datadep with the given name to.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.ensure_download_permitted-Tuple{}",
    "page": "API Reference",
    "title": "DataDeps.ensure_download_permitted",
    "category": "method",
    "text": "ensure_download_permitted()\n\nThis function will throw an error if download functionality has been disabled. Otherwise will do nothing.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.env_bool",
    "page": "API Reference",
    "title": "DataDeps.env_bool",
    "category": "function",
    "text": "env_bool(key)\n\nChecks for an enviroment variable and fuzzy converts it to a bool\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.env_list",
    "page": "API Reference",
    "title": "DataDeps.env_list",
    "category": "function",
    "text": "env_list(key)\n\nChecks for an enviroment variable and converts it to a list of strings, sperated with a colon\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.fetch_http-Tuple{Any,Any}",
    "page": "API Reference",
    "title": "DataDeps.fetch_http",
    "category": "method",
    "text": "fetch_http(remotepath, localdir)\n\nPass in a HTTP[/S] URL  and a directory to save it to, and it downloads that file, returing the local path. This is using the HTTP protocol\'s method of defining filenames in headers, if that information is present.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.get_filename-Tuple{Any}",
    "page": "API Reference",
    "title": "DataDeps.get_filename",
    "category": "method",
    "text": "get_filename(remotepath)\n\nGiven a remotepath (URL) returns the filename that it should be saved to locally.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.handle_missing-Tuple{DataDep,Any}",
    "page": "API Reference",
    "title": "DataDeps.handle_missing",
    "category": "method",
    "text": "handle_missing(datadep::DataDep, calling_filepath)::String\n\nThis function is called when the datadep is missing.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.input_bool",
    "page": "API Reference",
    "title": "DataDeps.input_bool",
    "category": "function",
    "text": "bool_input\n\nPrompted the user for a yes or no.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.input_choice-Tuple{Any,Vararg{Char,N} where N}",
    "page": "API Reference",
    "title": "DataDeps.input_choice",
    "category": "method",
    "text": "input_choice\n\nPrompted the user for one of a list of options\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.input_choice-Tuple{Vararg{Tuple{Char,#s12,Any} where #s12<:AbstractString,N} where N}",
    "page": "API Reference",
    "title": "DataDeps.input_choice",
    "category": "method",
    "text": "input_choice\n\nPrompts the user for one of a list of options. Takes a vararg of tuples of Letter, Prompt, Action (0 argument function)\n\nExample:\n\ninput_choice(\n    (\'A\', \"Abort -- errors out\", ()->error(\"aborted\")),\n    (\'X\', \"eXit -- exits normally\", ()->exit()),\n    (\'C\', \"Continue -- continues running\", ()->nothing)),\n)\n\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.is_valid_name-Tuple{Any}",
    "page": "API Reference",
    "title": "DataDeps.is_valid_name",
    "category": "method",
    "text": "is_valid_name(name)\n\nThis checks if a datadep name is valid. This basically means it must be a valid folder name on windows.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.list_local_paths-Tuple{String,Any}",
    "page": "API Reference",
    "title": "DataDeps.list_local_paths",
    "category": "method",
    "text": "list_local_paths( name|datadep, [calling_filepath|module|nothing])\n\nLists all the local paths to a given datadep. This may be an empty list\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.preferred_paths",
    "page": "API Reference",
    "title": "DataDeps.preferred_paths",
    "category": "function",
    "text": "preferred_paths(calling_filepath; use_package_dir=true)\n\nreturns the datadeps loadpath plus if callingfilepath is provided and use_package_dir=true and is currently inside a package directory then it also includes the path to the dataseps in that folder.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.process_header_filename-Tuple{RegexMatch}",
    "page": "API Reference",
    "title": "DataDeps.process_header_filename",
    "category": "method",
    "text": "process_header_filename(raw)\n\nDeal with some of the weird and varied ways filenames can be given. Not full coverage, but getting the common cases.\n\nReturn nothing if input is nothing\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.run_checksum-Tuple{AbstractArray{T,1} where T,AbstractArray{T,1} where T}",
    "page": "API Reference",
    "title": "DataDeps.run_checksum",
    "category": "method",
    "text": "If a vector of paths is provided and a vector of hashing methods (of any form) then they are all required to match.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.run_checksum-Tuple{AbstractString,Any}",
    "page": "API Reference",
    "title": "DataDeps.run_checksum",
    "category": "method",
    "text": "Providing only a hash string, results in defaulting to sha2_256, with that string being the target\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.run_checksum-Tuple{Any,Any}",
    "page": "API Reference",
    "title": "DataDeps.run_checksum",
    "category": "method",
    "text": "If only a function is provided then assume the user is a developer, wanting to know what hash-line to add to the Registration line.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.run_checksum-Tuple{Nothing,Any}",
    "page": "API Reference",
    "title": "DataDeps.run_checksum",
    "category": "method",
    "text": "If nothing is provided then assume the user is a developer, wanting to know what sha2_256 hash-line to add to the Registration line.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.run_checksum-Tuple{Tuple{#s12,#s51} where #s51<:AbstractString where #s12,Any}",
    "page": "API Reference",
    "title": "DataDeps.run_checksum",
    "category": "method",
    "text": "run_checksum(checksum, path)\n\nTHis runs the checksum on the files at the fetched_path. And returns true or false base on if the checksum matchs. (always true if no target sum given) It is kinda flexible and accepts different kinds of behavour to give different kinds of results.\n\nIf path (the second parameter) is a Vector, then unless checksum is also a Vector, the result is the xor of the all the file checksums.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.run_checksum-Tuple{Type{Any},Any}",
    "page": "API Reference",
    "title": "DataDeps.run_checksum",
    "category": "method",
    "text": "Use Any to mark as not caring about the hash. Use this for data that can change\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.run_fetch-Tuple{Any,Any,Any}",
    "page": "API Reference",
    "title": "DataDeps.run_fetch",
    "category": "method",
    "text": "run_fetch(fetch_method, remotepath, localdir)\n\nexecutes the fetchmethod on the given remotepath, into the local directory and local paths. Performs in (async) parallel if multiple paths are given\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.run_post_fetch-Tuple{Any,Any}",
    "page": "API Reference",
    "title": "DataDeps.run_post_fetch",
    "category": "method",
    "text": "run_post_fetch(post_fetch_method, fetched_path)\n\nexecutes the postfetchmethod on the given fetched path, Performs in (async) parallel if multiple paths are given\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.safer_joinpath-Tuple{Any,Vararg{Any,N} where N}",
    "page": "API Reference",
    "title": "DataDeps.safer_joinpath",
    "category": "method",
    "text": "safer_joinpath(basepart, parts...)\n\nA variation on joinpath, that is more resistant to directory traveral attack The parts to be joined (excluding the basepart), are not allowed to contain .., or begin with a /. If they do then this throws an DomainError.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.splitpath-Tuple{AbstractString}",
    "page": "API Reference",
    "title": "DataDeps.splitpath",
    "category": "method",
    "text": "splitpath(path)\n\nThe opposite of joinpath, splits a path unto each of its directories names / filename (for the last).\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.try_determine_load_path-Tuple{String,Any}",
    "page": "API Reference",
    "title": "DataDeps.try_determine_load_path",
    "category": "method",
    "text": "try_determine_load_path(name)\n\nTrys to find a local path to the datadep with the given name. If it fails then it returns nothing.\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.try_determine_package_datadeps_dir-Tuple{Any}",
    "page": "API Reference",
    "title": "DataDeps.try_determine_package_datadeps_dir",
    "category": "method",
    "text": "try_determine_package_datadeps_dir(filepath)\n\nTakes a path to a file. If that path is in a package\'s folder, Then this returns a path to the deps/data dir for that package (as a Nullable). Which may or may not exist. If not in a package returns null\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.try_get_filename-Tuple{Any}",
    "page": "API Reference",
    "title": "DataDeps.try_get_filename",
    "category": "method",
    "text": "try_get_filename(url)\n\nUses as HEAD request, to attempt to retrieve the filename from the HTTP headers. Returns a string or nothing if it failes\n\n\n\n\n\n"
},

{
    "location": "apiref.html#DataDeps.uv_access-Tuple{Any,DataDeps.AccessMode}",
    "page": "API Reference",
    "title": "DataDeps.uv_access",
    "category": "method",
    "text": "uv_access(path, mode)\n\nCheck access to a path. Returns 2 results, first an error code (0 for all good), and second an error message. https://stackoverflow.com/a/47126837/179081\n\n\n\n\n\n"
},

{
    "location": "apiref.html#Internal-1",
    "page": "API Reference",
    "title": "Internal",
    "category": "section",
    "text": "Modules = [DataDeps]\nPrivate = true\nOrder = [:function]"
},

{
    "location": "for-contributors.html#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": ""
},

{
    "location": "for-contributors.html#Extending-DataDeps.jl-for-Contributors-1",
    "page": "-",
    "title": "Extending DataDeps.jl for Contributors",
    "category": "section",
    "text": "Feel free (encouraged even) to open issues and make PRs."
},

{
    "location": "for-contributors.html#Internal-Docstrings-1",
    "page": "-",
    "title": "Internal Docstrings",
    "category": "section",
    "text": "As well as the usual all the publicly facing methods having docstrings, most of the internal methods do also. You can view them in the source; or via the julia REPL etc. Hopefully the internal docstrings make it clear how each method is used."
},

{
    "location": "for-contributors.html#Creating-custom-AbstractDataDep-types-1",
    "page": "-",
    "title": "Creating custom AbstractDataDep types",
    "category": "section",
    "text": "The primary point of extension for DataDeps.jl is in developers defining their own DataDep types. 99% of developers won\'t need to do this, a ManualDataDep or a normal (automatic) DataDep covers most use cases. However, if for example you want to have a DataDep that after the download is complete and after the post_fetch_method is run, does an additional validation, or some data synthesis step that requires working with multiple of the files simultaneously (which post_fetch_method can not do), or a SemiManualDataDep where the user does some things and then other things happen automatically, then this can be done by creating your own AbstractDataDep type.The code for ManualDataDep is a good place to start looking to see how that is done. You can also encapsulate an DataDep as one of the elements of your new type.If you do this you might like to contribute the type back up to this repository, so others can use it also. Particularly, if it is something that generalises beyond your specific usecase."
},

{
    "location": "for-end-users.html#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": ""
},

{
    "location": "for-end-users.html#Usage-for-end-users-1",
    "page": "-",
    "title": "Usage for end-users",
    "category": "section",
    "text": "The main goal of DataDeps.jl is to simplify life for the user. They should just forget about the data their package needs."
},

{
    "location": "for-end-users.html#Moving-Data-1",
    "page": "-",
    "title": "Moving Data",
    "category": "section",
    "text": "Moving data is a great idea. DataDeps.jl is in favour of moving data When data is automatically downloaded it will almost always go to the same location. The first (existant, writable) directory on your DATADEPS_LOADPATH. Which by-default is ~/.julia/datadeps/. (If you delete this, it will go to another location But you can move them from there to anywhere in the DATADEPS_LOADPATH. (See below)If you have a large chunk of data that everyone in your lab is using (e.g. a 1TB video corpora), you probably want to shift it to a shared area, like /usr/share/datadeps. Even if you don\'t have write permissions, you can have a sysadmin move it, and so long as you still have read permission DataDeps.jl will find it and use it for you."
},

{
    "location": "for-end-users.html#The-Load-Path-1",
    "page": "-",
    "title": "The Load Path",
    "category": "section",
    "text": "The Load Path is the list of paths that DataDeps.jl looks in when trying to resolve a data dependency. If it doesn\'t find the data in any of them it will download the data.It has 3 sources:the package load path:\ndetermined from the package where the datadep\"NAME\" was used\nThe user defined load path\ndetermined from the contents of the environment variable DATADEPS_LOAD_PATH\nthis can be a colon separated list (Like most unix path variables)\nthe standard load path\ndepends on your system and configuration\nnormally starts with user specific locations like your home directory, and expands out to shared locations\nSee below lists of examples\nThis can be disabled by setting the DATADEPS_NO_STANDARD_LOAD_PATH environment variable.In general it should by default include just about anywhere you might want to put the data. If it doesn\'t, please file an issue. (Unless your location is super-specific, e.g. /MyUniName/student/commons/datadeps). As mentioned you can add things to the load path by setting the environment variable DATADEPS_LOAD_PATH. You can also make symlinks from the locations on the loadpath to other locations where the data really is, if you\'ld rather do that.When loading data the load path is searched in order for a readable folder of the right now. When saving data is it is searched in order, skipping the package load path, for a writable directory. Simple way to avoid part of the standard loadpath being used for saving is to delete it, or make it unwritable. You can (and should when desired) move things around between any folder in the load path without redownloading."
},

{
    "location": "for-end-users.html#Unix-Standard-Load-Path-1",
    "page": "-",
    "title": "Unix Standard Load Path",
    "category": "section",
    "text": "For the user oxinabox/home/wheel/oxinabox/.julia/datadeps\n/home/wheel/oxinabox/datadeps\n/scratch/datadeps\n/staging/datadeps\n/usr/share/datadeps\n/usr/local/share/datadeps"
},

{
    "location": "for-end-users.html#Windows-Standard-Load-Path-1",
    "page": "-",
    "title": "Windows Standard Load Path",
    "category": "section",
    "text": "For the user oxinabox, when using JuliaPro 0.6.2.1, on windows 7. (Other configurations should be fairly similar).C:\\Users\\oxinabox\\AppData\\Local\\JuliaPro-0.6.2.1\\pkgs-0.6.2.1\\datadeps\nC:\\Users\\oxinabox\\datadeps\nC:\\Users\\oxinabox\\AppData\\Roaming\\datadeps\nC:\\Users\\oxinabox\\AppData\\Local\\datadeps\nC:\\ProgramData\\datadeps\nC:\\Users\\Public\\datadeps"
},

{
    "location": "for-end-users.html#Having-multiple-copies-of-the-same-DataDir-1",
    "page": "-",
    "title": "Having multiple copies of the same DataDir",
    "category": "section",
    "text": "You probably don\'t want to have multiple copies of a DataDir with the same name. DataDeps.jl will try to handle it as gracefuly as it can. But having different DataDep under the same name, is probably going to lead to packages loading the wrong one. Except if they are (both) located in their packages deps/data folder.By moving a package\'s data dependency into its package directory under deps/data, it becomes invisible except to that package. For example ~/.julia/v0.6/EXAMPLEPKG/deps/data/EXAMPLEDATADEP/, for the package EXAMPLEPKG, and the datadep EXAMPLEDATADEP.Ideally though you should probably raise an issue with the package maintainers and see if one (or both) of them want to change the DataDep name.Note also when it comes to file level loading, e.g. datadep\"Name/subfolder/file.txt\", DataDeps does not check all folders with that Name (if you have multiples). If the file is not in the first folder it finds you will be presented with the recovery dialog, from which the easiest option is to select to delete the folder and retry, since that will result in it checking the second folder (as the first one does not exist)."
},

{
    "location": "for-end-users.html#Configuration-1",
    "page": "-",
    "title": "Configuration",
    "category": "section",
    "text": "Currently configuration is done via Enviroment Variables. It is likely to stay that way, as they are also easy to setup in CI tools. You can set these in the .juliarc file using the ENV dictionary if you don\'t want to mess up your .profile. However, most people shouldn\'t need to. DataDeps.jl tries to have very sensible defaults.DATADEPS_ALWAYS_ACCEPT – bypasses the confirmation before downloading data. Set to true (or similar string)\nThis is provided for scripting (in particular CI) use\nNote that it remains your responsibility to understand and read any terms of the data use (this is remains true even if you don\'t turn on this bypass)- If the `CI` environment variable is set to true, then DataDeps.jl will refuse to do any download until either `DATADEPS_ALWAYS_ACCEPT` is set to true or false. This is to prevent various hanging in CI.\n- default `false`DATADEPS_LOAD_PATH – The list of paths to be prepended to the standard loadpath to save and load data from\nBy default this is empty, but it can be a colon separated list (like most unix path variables). For more details see above\nDATADEPS_NO_STANDARD_LOAD_PATH if this is set to true (default false), then the aforementioned list of standard loadpath files is not included\nDATADEPS_DISABLE_DOWNLOAD – causes any action that would result in the download being triggered to throw an exception.\nuseful e.g. if you are in an environment with metered data, where your datasets should have already been downloaded earlier, and if there were not you want to respond to the situation rather than let DataDeps download them for you.\ndefault false\nDATADEPS_DISABLE_ERROR_CLEANUP – By default DataDeps.jl will cleanup the directory the datadep was being downloaded to if there is an error during the resolution (In any of the fetch, checksum, or post_fetch). For debugging purposes you may wish to disable this cleanup step so you can interrogate the files by hand."
},

{
    "location": "for-pkg-devs.html#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": ""
},

{
    "location": "for-pkg-devs.html#Usage-for-developers-(including-researchers)-1",
    "page": "-",
    "title": "Usage for developers (including researchers)",
    "category": "section",
    "text": ""
},

{
    "location": "for-pkg-devs.html#Examples-1",
    "page": "-",
    "title": "Examples",
    "category": "section",
    "text": "the aformentioned blog post\nExamples in the test code\nManual examples from the test code"
},

{
    "location": "for-pkg-devs.html#Installation-1",
    "page": "-",
    "title": "Installation",
    "category": "section",
    "text": "As normal for julia packages install DataDeps.jl using:pkg> add DataDepsThis will add DataDeps to your Project.toml file, so it will be automatically installed for end-users."
},

{
    "location": "for-pkg-devs.html#Using-a-datadep-string-or-resolve-to-get-hold-of-the-data.-1",
    "page": "-",
    "title": "Using a datadep string or resolve to get hold of the data.",
    "category": "section",
    "text": "For any registered DataDep (see below), datadep\"Name\", returns a path to a folder containing the data. If when that string macro is evaluated no such folder exists, then DataDeps will swing into action and coordinate the acquisition of the data into a folder, then return the path that now contains the data.You can also use datadep\"Name/subfolder/file.txt\" (and similar) to get a path to the file at  subfolder/file.txt within the data directory for Name. Just like when using the plain datadep\"Name\" this will if required downloadload the whole datadep (not just the file). However, it will also engage additional features to verify that that file exists (and is readable), and if not will attempt to help the user resolve the situation. This is useful if files may have been deleted by mistake, or if a ManualDataDep might have been incorrectly installed."
},

{
    "location": "for-pkg-devs.html#Installing-Data-Lazily-1",
    "page": "-",
    "title": "Installing Data Lazily",
    "category": "section",
    "text": "Most packages using more than one data source, will want to download them only when the user requires them. That is to say if the user never calls a function that requires that data, then the data should not be downloaded.DataDeps.jl resolves the dependency when a datadep\"Name\" string is evaluated. If no code containing a data dependency string is run, then no data will be downloadedThe basic way is to hide the datadep in some code not being evaluated except on a condition. For example, say some webcam security system can be run in training mode, in which case data should be used from the datadep, or in deployment mode, in which case the data should be read from the webcam\'s folder:data_folder = training_mode ? datadep\"SecurityFootage\" : \"/srv/webcam/today\"       The data will not be downloaded if training_mode==false, because the referred to folder is never required. Of-course if the data was already downloaded, then it wouldn\'t be downloaded again either way.Another example of a particularly nice way of doing this is to use the datadep string as the default value for a function paramater function predict(path=datadep\"SecurityFootage\"). If the user passses a value when they call predict then the datadep string will never be evaluated. So the data will not be sourced via DataDeps.jl"
},

{
    "location": "for-pkg-devs.html#Installing-Data-Eagerly-1",
    "page": "-",
    "title": "Installing Data Eagerly",
    "category": "section",
    "text": "If you want the data to be installed when the package is first loaded, just put the datadep string datadep\"Name\" anywhere it will immediately run. For example, in the __init__ function immediately after the registration block.If you want it to be installed at Pkg.build time. The best thing to do is to put your data dep registration block in a file (eg src/dataregistrations.jl), and then include it into deps/build.jl followed by putting in the datadep string somewhere at global scope. (Including would be done by include(pathjoin(@__DIR__,\"..\",\"src\",\"dataregistrations.jl\"). One would also include that registrations file into the __init__ function in the  main source of the package as well."
},

{
    "location": "for-pkg-devs.html#Registering-a-DataDep-1",
    "page": "-",
    "title": "Registering a DataDep",
    "category": "section",
    "text": "When we say registering a DataDep we do not mean a centralised universal shared registry. Registring simply means defining the specifics of the DataDep in your code. This is done in a declaritie manner.A DataDeps registration is a block of code declaring a dependency. You should put it somewhere that it will be executed before any other code in your script that depends on that data. In most cases it is best to put it inside the  modules\'s __init__() function.To do the actual registration one just  calls register(::AbstractDataDep). The rest of this section is basically about the constructors for the DataDep type. It is pretty flexible. Best is to see the examples above.The basic Registration block looks like: (Type parameters are shown below are a simplifaction)register(DataDep(\n    name::String,\n    message::String,\n    remote_path::Union{String,Vector{String}...},\n    [checksum::Union{String,Vector{String}...},]; # Optional, if not provided will generate\n    # keyword args (Optional):\n    fetch_method=http_download # (remote_filepath, local_directory_path)->local_filepath\n    post_fetch_method=identity # (local_filepath)->Any\n))"
},

{
    "location": "for-pkg-devs.html#Required-Fields-1",
    "page": "-",
    "title": "Required Fields",
    "category": "section",
    "text": "*Name**: the name used to refer to this datadep, coresponds to a folder name where it will be stored\nIt can have spaces or any other character that is allowed in a Windows filestring (which is a strict subset of the restriction for unix filenames).\nMessage: A message displayed to the user for they are asked if they want to downloaded it.\nThis is normally used to give a link to the original source of the data, a paper to be cited etc.\nremote_path: where to fetch the data from. Normally a string or strings) containing an URL\nThis is usually a string, or a vector of strings (or a vector of vector... see Recursive Structure below)"
},

{
    "location": "for-pkg-devs.html#Optional-Fields-1",
    "page": "-",
    "title": "Optional Fields",
    "category": "section",
    "text": "checksum this is very flexible, it is used to check the files downloaded correctly\nBy far the most common use is to just provide a SHA256 sum as a hex-string for the files\nIf not provided, then a warning message with the  SHA256 sum is displayed. This is to help package devs workout the sum for there files, without using an external tool.\nIf you want to use a different hashing algorithm, then you can provide a tuple (hashfun, targethex)\nhashfun should be a function which takes an IOStream, and returns a Vector{UInt8}.      - Such as any of the functions from [SHA.jl](https://github.com/staticfloat/SHA.jl), eg `sha3_384`, `sha1_512`\n      - or `md5` from [MD5.jl](https://github.com/oxinabox/MD5.jl)If you want to use a different hashing algorithm, but don\'t know the sum, you can provide just the hashfun and a warning message will be displayed, giving the correct tuple of (hashfun, targethex) that should be added to the registration block.- If you don\'t want to provide a checksum,  because your data can change pass in the type `Any` which will suppress the warning messages. (But see above warnings about \"what if my data is dynamic\")\n- Can take a vector of checksums, being one for each file, or a single checksum in which case the per file hashes are `xor`ed to get the target hash. (See [Recursive Structure](@ref) below)fetch_method=http_download a function to run to download the files.\nFunction should take 2 parameters (remote_filepath, local_directorypath), and can must return the local filepath to the file downloaded\nCan take a vector of methods, being one for each file, or a single method, in which case that method is used to download all of them. (See Recursive Structure below)- Overloading this lets you change things about how the download is done -- the transport protocol.\n- The default is suitable for HTTP[/S], without auth. Modifying it can add authentication or an entirely different protocol (e.g. git, google drive etc)\n- This function is also responsible for workout out what the local file should be called (as this is protocol dependent)post_fetch_method a function to run after the files have download\nShould take the local filepath as its first and only argument. Can return anything.\nDefault is to do nothing.\nCan do what it wants from there, but most likes wants to extract the file into the data directory.\ntowards this end DataDeps includes a command: unpack which will extract an compressed folder, deleting the original.\nIt should be noted that it post_fetch_method runs from within the data directory\nwhich means operations that just write to the current working directory (like rm or mv or run(`SOMECMD`)) just work.\nYou can call cwd() to get the the data directory for your own functions. (Or dirname(local_filepath))\nCan take a vector of methods, being one for each file, or a single method, in which case that ame method is applied to all of the files. (See Recursive Structure below)"
},

{
    "location": "for-pkg-devs.html#Recursive-Structure-1",
    "page": "-",
    "title": "Recursive Structure",
    "category": "section",
    "text": "fetch_method, post_fetch_method and checksum all can match the structure of remote_path. If remote_path is just an single path, then they each must be single items. If remote_path is a vector, then if those properties are a vector (which must be the same length) then they are applied each to the corresponding element; or if not then it is applied to all of them. This means you can for example provide check-sums per file, or per-the-all. It also means you can specify different post_fetch_methods for different files, e.g. doing nothing to some, and extracting others. Further more this applies recursively.For example:register(DataDep(\"eg\", \"eg message\",\n    [\"http//example.com/text.txt\", \"http//example.com/sub1.zip\", \"http//example.com/sub2.zip\"]\n    post_fetch_method = [identity, file->run(`unzip $file`), file->run(`unzip $file`)]\n))So identity  (i.e. nothing) will be done to the first paths resulting file, and the second and third will be unzipped.can also be written:register(DataDep(\"eg\", \"eg message\",\n    [\"http//example.com/text.txt\", [\"http//example.com/sub1.zip\", \"http//example.com/sub2.zip\"]]\n    post_fetch_method = [identity, file->run(`unzip $file`)]\n))The unzip will be applied to both elements in the child array"
},

{
    "location": "for-pkg-devs.html#ManualDataDep-1",
    "page": "-",
    "title": "ManualDataDep",
    "category": "section",
    "text": "ManualDataDeps are datadeps that have to be managed by some means outside of DataDeps.jl, but DataDeps.jl will still provide the convient datadep\"MyData\" string macro for finding them. As mentions above, if you put the data in your git repo for your package under deps/data/NAME then it will be managed by julia package manager.A manual DataDep registration is just like a normal DataDep registration, except that only a name and message are provided. Inside the message you should give instructions on how to acquire the data. Again see the examples"
},

{
    "location": "for-pkg-devs.html#DataDepsGenerators-1",
    "page": "-",
    "title": "DataDepsGenerators",
    "category": "section",
    "text": "DataDepsGenerators.jl is a julia package to help generate DataDeps registration blocks from well-known data sources. It attempts to use webscraping and such to workout what should be in the registration block. You can then edit the generated code to make it suitable for your use. (E.g. remove excessive information in the message)"
},

{
    "location": "for-pkg-devs.html#Assuming-direct-control-and-customization-1",
    "page": "-",
    "title": "Assuming direct control and customization",
    "category": "section",
    "text": "The hierachy of methods for acquiring a datadep is:datadep\"name/path\" ▶ resolve(\"name/path\", @__FILE__) ▶ resolve(::AbstractDataDep, \"path\", @__FILE__) ▶ download(::DataDep)One can make use of this at various levels to override the default generally sane behavior. Most of the time you shouldn\'t have to – the normal point of customization is in setting the post_fetch_method, and occasionally fetch_method or  hash=(hashmethod, key)."
},

{
    "location": "for-pkg-devs.html#Advanced:-resolve-for-high-level-programmatic-resolution-1",
    "page": "-",
    "title": "Advanced: resolve for high-level programmatic resolution",
    "category": "section",
    "text": "resolve(\"name/path\", @__FILE__) is the functional form of datadep\"name/path. If you are really worried about resolving a datadep early, or of you are generating the names pragmatically, or you just really feel uncomfortable about string macros, you can use resolve(namepath, @__FILE__). You can (basically) equivalently use @datadep_str namepath. Passing in the @__FILE__ is important as it allows access to the package\'s \"private\" data deps location (PKGNAME/deps/data), which may be needed incase of datadep name conflicts; or for ManualDataDeps that are included in the repo. You could passing something else to bypass this \"privacy\".It comes in a number of flavors for which you can read the docstring ?resolve. Including resolve(::AbstactDataDep, innerpath, @__FILE__), which can directly download a datadep."
},

{
    "location": "for-pkg-devs.html#download-for-low-level-programmatic-resolution.-1",
    "page": "-",
    "title": "download for low-level programmatic resolution.",
    "category": "section",
    "text": "For more hardcore devs customising the user experience, and people needing to do debugging you may assume (nearly) full control over the download operation by directly invoking the method Base.download(::DataDep, localpath; kwargs...). It is fully documented in its docstring."
},

{
    "location": "index.html#",
    "page": "DataDeps.jl Documentation",
    "title": "DataDeps.jl Documentation",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#DataDeps.jl-Documentation-1",
    "page": "DataDeps.jl Documentation",
    "title": "DataDeps.jl Documentation",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Index-1",
    "page": "DataDeps.jl Documentation",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "intro.html#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": ""
},

{
    "location": "intro.html#What-is-DataDeps?-1",
    "page": "-",
    "title": "What is DataDeps?",
    "category": "section",
    "text": "DataDeps is a package for simplifying the management of data in your julia application. In particular it is designed to simplify the process of getting static files from some server into the local machine, and making programs know where that data is.For a few examples of its usefulness see this blog post"
},

{
    "location": "intro.html#Usage-in-Brief:-1",
    "page": "-",
    "title": "Usage in Brief:",
    "category": "section",
    "text": ""
},

{
    "location": "intro.html#I-want-to-use-some-data-I-have-in-my-project.-What-do?-1",
    "page": "-",
    "title": "I want to use some data I have in my project. What do?",
    "category": "section",
    "text": "The short version is:Stick your data anywhere with a open HTTP link. (Skip this if it is already online.)\nWrite a DataDep registration block.\nRefer to the data using datadep\"Dataname/file.csv etc as if it were a file path, and DataDeps.jl will sort out getting in onto your system.\nFor CI purposes set the DATADEPS_ALWAYS_ACCEPT environment variable."
},

{
    "location": "intro.html#Where-can-I-store-my-data-online?-1",
    "page": "-",
    "title": "Where can I store my data online?",
    "category": "section",
    "text": "Where ever you want, so long as it gives an Open HTTP(/s) link to download it. ** I use an OwnCloud instance hosted by our national research infastructure.\nResearch data hosting like FigShare are a good idea.\nYou can just stick it on your website hosting if you are operating a website.\nI\'d like to hear if anyone has tested GoogleDrive or DropBox etc.**(In theory other protocols and auth can be supported by using a different fetch_method)"
},

{
    "location": "intro.html#Why-not-store-the-data-in-Git?-1",
    "page": "-",
    "title": "Why not store the data in Git?",
    "category": "section",
    "text": "Git is good for files that meet 3 requirements:Plain text (not binary)\nSmallish (Github will not accept files >50Mb in size)\nDynamic (Git is version control, it is good at knowing about changes)There is certainly some room around the edges for this, like storing a few images in the repository is OK, but storing all of ImageNet is a no go. For those edge cases ManualDataDeps are good (see below).DataDeps.jl is good for:Any file format\nAny size\nStatic (that is to say it doesn\'t change)The main use case is downloading large datasets for machine learning, and corpora for NLP. In this case the data is not even normally yours to begin with. It lives on some website somewhere. You don\'t want to copy and redistribute it; and depending on liscensing you may not even be allowed to."
},

{
    "location": "intro.html#But-my-data-is-dynamic-1",
    "page": "-",
    "title": "But my data is dynamic",
    "category": "section",
    "text": "Well how dynamic? If you are willing to tag a new relase of your package each time the data changes, then maybe this is no worry, but maybe it is.But the real question is, is DataDeps.jl really suitable for managing your data properly in the first place. DataDeps.jl does not provide for versioning of data – you can\'t force users to download new copies of your data using DataDeps. There are work arounds, such as using DataDeps.jl + deps/build.jl to rm(datadep\"MyData\", recursive=true, force=true every package update. Or considering each version of the data as a different datadep with a different name. DataDeps.jl may form part of your overall solution or it may not. That is a discussion to have on Slack or Discourse (feel free to tag me, I am @oxinabox on both). See also the list of related packages at the bottomThe other option is that if your data a good fit for git. If it is in overlapping area of plaintext & small (or close enough to those things), then you could add it as a ManualDataDep in and include it in the git repo in the  deps/data/ folder of your package. The ManuaulDataDep will not need manual installation if it is being installed via git."
},

{
    "location": "other-projects.html#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": ""
},

{
    "location": "other-projects.html#Other-similar-packages:-1",
    "page": "-",
    "title": "Other similar packages:",
    "category": "section",
    "text": "DataDeps.jl isn\'t the answer to all your download needs. It is focused squarely on static data. It might not be good for your use case.Alternatives that I am aware of are:RemoteFiles.jl: keeps local files up to date with remotes. In someways it is the opposite of DataDeps.jl (which means it is actually very similar in many ways).\nBinaryProvider.jl downloads binaries intended as part of a build chain. I\'m pretty sure you can trick it into downloading data.\nBase.download if your situtation is really simple just sticking a download into the deps/build.jl file might do you just fine.Outside of julia\'s ecosystem isPython: Quilt. Quilt uses a centralised data store, and allows the user to download the data as Python packages containing it in serialised from. It might be possible to use PyCall.jl to use this from julia.\nR: suppdata, features extra stuff relating to published datasets (See also DataDepsGenerators.jl), it might be possible to use RCall.jl to use this from julia.\nNode/Commandline: Datproject I\'m not too familiar with this, it is a bit of an ecosystem of its own. I think using it from the commandline might satisfy many people\'s needs. Or automating it with shell calls in build.jl."
},

]}
