using Pkg; Pkg.activate(pwd())

include("longrunning.jl")
include("tinyllama.jl")
include("widgets.jl")


# We use the tokenizer's chat template to format each message - see https://huggingface.co/docs/transformers/main/en/chat_templating


llama = tiny_llama()

function ask(llama, text)
    messages = [
        Dict(
            "role" => "system",
            "content" => "You are a friendly chatbot who always responds in the style a great person",
        ),
        Dict(
            "role" => "user",
            "content" => text
        )
    ]
    outputs = fetch(llama(messages))
    text = outputs[1]["generated_text"]
    return split(text, "\n")[end]
end

add MakieCore#sd/2d-resize Makie#sd/2d-resize WGLMakie#sd/2d-resize
App() do
    text = TextArea("")
    button = Button("ask")
    input = Col(text, button; gap="0px")
    style = Styles("background-color" => "lightblue")
    output = Observable(Grid())

    on(button.value) do click
        question = text.value[]
        isempty(question) && return
        text.value[] = ""
        node = output[]
        style = Styles("justify-self" => "end", "width" => "200px")
        push!(Bonito.children(node), Card(DOM.p(question); style=style))
        notify(output)
        text.targetvalue[] = ""
        task = @async begin
            answer = ask(llama, question)
            DOM.p(answer)
        end
        style = Styles("justify-self" => "start", "width" => "200px")
        answer = Card(Centered(task); style=style)
        push!(Bonito.children(node), answer)
        notify(output)
    end

    grid_style = Styles("height" => "500px")
    return Grid(Card(output; style=style), input; rows="5fr 1fr", align_items="stretch", style=grid_style)
end
