
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
       length(lastpart)>0 && unshift!(ret, lastpart)
       length(path)==0 && break
       if prev_path==path
            # catch the casewhere path begins with a root
            unshift!(ret, path)
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
env_bool(key) = haskey(ENV, key) && lowercase(ENV[key]) ∉ ["0","","false", "no"]



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
        info(prompt)
        info("["*join(options, '/')*"]")
        reply = lowercase(first(readline()))
        for opt in options
            reply==opt && return opt
        end
    end
end
