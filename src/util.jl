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
# Enviroment variable stuff

"""
    env_bool(key)

Checks for an enviroment variable and fuzzy converts it to a bool
"""
env_bool(key, default=false) = haskey(ENV, key) ? lowercase(ENV[key]) ∉ ["0","","false", "no"] : default

"""
    env_list(key)

Checks for an enviroment variable and converts it to a list of strings, sperated with a colon
"""
env_list(key, default=String[]) = haskey(ENV, key) ? split(ENV[key], ":") : default




#########################################
# User input stuff

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
    while(true)
        println(prompt)
        println("["*join(options, '/')*"]")
        response = readline()
        length(response)==0 && continue
        reply = lowercase(first(response))
        for opt in lowercase.(options)
            reply==opt && return opt
        end
    end
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
