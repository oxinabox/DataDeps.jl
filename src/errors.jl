
"""
For when there is no valid location available to save to.
"""
struct NoValidPathError <: Exception
    msg::String
end

"""
For when a users has selected to abourt
"""
struct UserAbortError <: Exception
    msg::String
end
abort(msg) = throw(UserAbortError(msg))


"""
DisabledError
For when functionality that is disabled is attempted to be used
"""
struct DisabledError <: Exception
    msg::String
end

