
"""
    env_bool(key)

Checks for an enviroment variable and fuzzy converts it to a bool
"""
env_bool(key) = haskey(ENV, key) && lowercase(ENV[key]) ∉ ["0","","false", "no"]


"""
    bool_input

Prompted the user for a yes or no.
"""
function bool_input(prompt="")::Bool
    choise_input(prompt, 'y','n')=='y'
end

"""
    choice_input

Prompted the user for one of a list of options
"""
function choice_input(prompt="", options::Vararg{Char})::Bool
    while(true)
        info(prompt)
        info("["*join(options, '/')*"]")
        reply = lowercase(first(readline()))
        for opt in options
            reply==opt && return opt
        end
    end
end
