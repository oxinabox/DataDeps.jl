
# Extending DataDeps.jl for Contributors
Feel free (encouraged even) to open issues and make PRs.

## Internal Docstrings
As well as the usual all the publicly facing methods having docstrings,
most of the internal methods do also.
You can view them in the source; or via the julia REPL etc.
Hopefully the internal docstrings make it clear how each method is used.

## Creating custom `AbstractDataDep` types
The primary point of extension for DataDeps.jl is in developers defining their own DataDep types.
99% of developers won't need to do this, a `ManualDataDep` or a normal (automatic) `DataDep` covers most use cases.
However, if for example you want to have a DataDep that after the download is complete and after the `post_fetch_method` is run, does an additional validation, or some data synthesis step that requires working with multiple of the files simultaneously (which `post_fetch_method` can not do), or a `SemiManualDataDep` where the user does some things and then other things happen automatically, then this can be done by creating your own `AbstractDataDep` type.

The code for `ManualDataDep` is a good place to start looking to see how that is done.
You can also encapsulate an `DataDep` as one of the elements of your new type.

If you do this you might like to contribute the type back up to this repository, so others can use it also.
Particularly, if it is something that generalises beyond your specific usecase.

