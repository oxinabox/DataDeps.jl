# This file is a part of DataDeps.jl. License is MIT.

@deprecate(
    RegisterDataDep(name::String,
        message::String,
        remotepath,
        hash=nothing;
        fetch_method=download,
        post_fetch_method=identity,
    ),
    register(DataDep(name::String,
        message::String,
        remotepath,
        hash;
        fetch_method=fetch_method,
        post_fetch_method=post_fetch_method)
    )
)

@deprecate(
    RegisterDataDep(name::String, message::String),
    register(ManualDataDep(name, message))
)
