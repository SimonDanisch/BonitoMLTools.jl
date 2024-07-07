
function ask(prompt, model)
    message = create_chat(
        ENV["OPENAI_API_KEY"],
        model,
        [
            Dict("role" => "user", "content" => prompt),
            Dict("role" => "system", "content" => "You are a helpful assistant that provides Julia code wrapped in ```julia ... ``` blocks any other language just in ``` ... ``` blocks.
                You keep the answers short.
                Make sure you're only using Makie api calls that actually exist as of version Makie@0.20.
                For Makie code, use the WGLMakie backend and remember, that figure resolution got renamed to size.
                Example for a valid makie code:
                    ```julia
                    f = Figure(size=(600, 400));
                    ax = Axis(f[1, 1]);
                    scatter(ax, 1:4)`.
                    Dont call display on it")
        ]
    ).response[:choices][begin][:message][:content]
    return InteractiveMarkdown(message)
end

function image(prompt, model)
    response = create_images(
        ENV["OPENAI_API_KEY"],
        prompt,
        1,
        "512x512",
        model=model
    ).response
    return DOM.img(src=response[:data][begin][:url], style="max-width: 500px")
end

function oai_prompt(prompt, model)
    if occursin("dall-e", model)
        return image(prompt, model)
    else
        return ask(prompt, model)
    end
end
