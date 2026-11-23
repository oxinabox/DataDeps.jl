# This file is a part of DataDeps.jl. License is MIT.

"""
    splitpath(path)

The opposite of `joinpath`,
splits a path unto each of its directories names / filename (for the last).
"""
function splitpath(path::AbstractString)
   ret=String[]
   prev_path = path
   while(true)
       path, lastpart = splitdir(path)
       length(lastpart)>0 && pushfirst!(ret, lastpart)
       length(path)==0 && break
       if prev_path==path
            # catch the casewhere path begins with a root
            pushfirst!(ret, path)
            break
       end
       prev_path = path
   end
   return ret
end

########################################
# Environment variable stuff

"""
    env_bool(key)

Checks for an environment variable and fuzzy converts it to a bool
"""
env_bool(key, default=false) = haskey(ENV, key) ? lowercase(ENV[key]) ∉ ["0","","false", "no"] : default

"""
    should_abort_on_error()

Returns true if interactive prompts should be replaced by automatic aborts.
Controlled by `DATADEPS_ABORT_ON_ERROR` environment variable;
defaults to the value of the `CI` environment variable.
"""
should_abort_on_error() = env_bool("DATADEPS_ABORT_ON_ERROR", env_bool("CI"))

"""
    split_load_path(str, windows=Sys.iswindows())

Splits a list of paths, like the contents of `DATADEPS_LOAD_PATH`, into its entries.

The entries are separated by colons (`:`) on all systems.
On Windows, the colon of a drive letter at the start of an entry (e.g. `C:\\` or `C:/`)
is not treated as a separator, also after a `\\\\?\\` or `\\\\.\\` prefix.
Windows does not allow colons in file names otherwise.

Empty entries are kept, so `split_load_path("")` returns `[""]`.
"""
function split_load_path(str::AbstractString, windows::Bool=Sys.iswindows())
    windows || return split(str, ':')
    entries = String[]
    start = firstindex(str)  # start of the current entry
    for i in findall(==(':'), str)
        entry = str[start:prevind(str, i)]  # the current entry, up to this colon
        rest = str[nextind(str, i):end]     # everything after this colon
        if is_drive_colon(entry, rest)
            continue  # part of the path, not a separator
        end
        push!(entries, entry)
        start = nextind(str, i)
    end
    push!(entries, str[start:end])
    return entries
end

# Extended-length and device path prefixes, `\\?\` and `\\.\`
const WINDOWS_PATH_PREFIXES = ("\\\\?\\", "\\\\.\\")

"""
    is_drive_colon(entry, rest)

Whether a colon is the colon of a drive letter, like in `C:\\…`,
given the `entry` before it (since the last separator) and the `rest` of the string after it.
"""
function is_drive_colon(entry::AbstractString, rest::AbstractString)
    if !(startswith(rest, '\\') || startswith(rest, '/'))
        return false  # a drive colon is followed by a path separator: `C:\` or `C:/`
    elseif any(prefix -> startswith(entry, prefix), WINDOWS_PATH_PREFIXES)
        return is_drive_letter(entry[5:end])  # `\\?\C:\…` or `\\.\C:\…`
    else
        return is_drive_letter(entry)  # `C:\…`
    end
end

is_drive_letter(s::AbstractString) = length(s) == 1 && ('A' <= s[1] <= 'Z' || 'a' <= s[1] <= 'z')

"""
    env_list(key)

Checks for an environment variable and converts it to a list of paths,
see [`split_load_path`](@ref) for the separator.
"""
env_list(key, default=String[]) = haskey(ENV, key) ? split_load_path(ENV[key]) : default




#########################################
# User input stuff

"""
    better_readline(stream = stdin)
A version of `readline` that does not immediately return an empty string if the stream is closed.
It will attempt to reopen the stream and if that fails then throw an error.
"""
function better_readline(stream = stdin)
    if !isopen(stream)
        Base.reseteof(stream)
        isopen(stream) || throw(Base.IOError("Could not open stream.", -1))
    end

    return readline(stream)
end


"""
    bool_input

Prompted the user for a yes or no.
"""
function input_bool(prompt="")::Bool
    input_choice(prompt, 'y','n')=='y'
end

"""
    input_choice

Prompted the user for one of a list of options
"""
function input_choice(prompt, options::Vararg{Char})::Char
    for _ in 1:10
        println(prompt)
        println("["*join(options, '/')*"]")
        response = better_readline()
        length(response)==0 && continue
        reply = lowercase(first(response))
        for opt in lowercase.(options)
            reply==opt && return opt
        end
    end
    error(
        "Either user provided invalid input 10 times; or something has " *
        "gone wrong with the IO reading. Please comment on: \n\t" *
        "https://github.com/oxinabox/DataDeps.jl/issues/104"
    )
end

"""
    input_choice

Prompts the user for one of a list of options.
Takes a vararg of tuples of Letter, Prompt, Action (0 argument function)

Example:
```
input_choice(
    ('A', "Abort -- errors out", ()->error("aborted")),
    ('X', "eXit -- exits normally", ()->exit()),
    ('C', "Continue -- continues running", ()->nothing)),
)

```
"""
function input_choice(options::Vararg{Tuple{Char, <:AbstractString, Any}})
    acts = Dict{Char, Any}()
    prompt = ""
    chars = Char[]
    for (cc, prmt, act) in options
        prompt*="\n [$cc] $prmt"
        push!(chars, cc)
        acts[lowercase(cc)] = act
    end
    prompt*="\n"

    acts[input_choice(prompt, chars...)]()
end
