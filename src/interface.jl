function default_system()
    return """
    You are a helpful assistant that provides Julia code wrapped in ```julia ... ``` blocks any other language just in ``` ... ``` blocks.
    Please no other code block with `julia`
    You keep the answers short.
    Make sure you're only using Makie api calls that actually exist as of version Makie@0.20.
    For Makie code, use the WGLMakie backend and remember, that figure resolution got renamed to size.
    Example for a valid makie code:
        ```julia
        f = Figure(size=(600, 400));
        ax = Axis(f[1, 1]);
        scatter(ax, 1:4)`.
        ```
        Dont call display on it
    """
end

function ask_ai(prompt, model, system=default_system())
    if occursin("dall-e", model)
        return ask_openai_image(prompt, model)
    elseif occursin("gpt", model)
        return ask_openai(prompt, model, system)
    elseif occursin("claude", model)
        return query_claude(prompt, model, system)
    else
        return error("Model $(model) unknown")
    end
end
