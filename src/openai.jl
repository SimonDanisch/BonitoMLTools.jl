
function ask_openai(prompt, model, system=default_system())
    user = Dict("role" => "user", "content" => prompt)
    system = Dict("role" => "system", "content" => system)
    message = OpenAI.create_chat(ENV["OPENAI_API_KEY"], model, [user, system]).response[:choices][begin][:message][:content]
    return InteractiveMarkdown(message)
end

function ask_openai_image(prompt, model)
    response = create_images(
        ENV["OPENAI_API_KEY"], prompt, 1, "512x512"; model=model
    )
    url = response.response[:data][begin][:url]
    return DOM.img(; src=url, style="max-width: 500px")
end
