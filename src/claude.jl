function query_claude(prompt, model, system=default_system())
    url = "https://api.anthropic.com/v1/messages"
    user = Dict("role" => "user", "content" => prompt)
    headers = [
        "Content-Type" => "application/json",
        "x-api-key" => ENV["CLAUDE_API_KEY"],
        "anthropic-version" => "2023-06-01",
    ]
    msg = Dict(
        "model" => "$(model)-20240229",
        "max_tokens" => 1024,
        "system" => system,
        "messages" => [user],
    )
    response = HTTP.post(url, headers, JSON3.write(msg))
    dict = JSON3.read(response.body)
    return InteractiveMarkdown(dict.content[1].text)
end
