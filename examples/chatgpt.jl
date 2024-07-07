using BonitoMLTools, Bonito, WGLMakie
using BonitoMLTools: oai_prompt, TextInput
using Markdown

App() do session
    WGLMakie.activate!(resize_to=(:parent, nothing))
    input = TextInput("")
    model = Dropdown(["gpt-4o", "gpt-3.5-turbo", "dall-e-3"])

    output = Observable(Grid())

    msg_style = Styles(
        "max-width" => "800px", "background-color" => "#eee",
        "padding" => "10px", "overflow-wrap" => "break-word"
    )

    on(input.value) do question
        isempty(question) && return

        node = output[]
        style = Styles(msg_style, "justify-self" => "end")
        push!(Bonito.children(node), Card(DOM.p(Markdown.parse(question)); padding="10px", style=style))
        notify(output)

        task = @async begin
            answer = oai_prompt(question, model.value[])
            DOM.p(answer, js"{
                const div = document.getElementById('output')
                div.scrollTop = div.scrollHeight;
            }")
        end
        style = Styles(msg_style, "justify-self" => "start", "text-align" => "left")
        answer = Card(task; style=style)
        push!(Bonito.children(node), answer)
        notify(output)
    end

    area_style = Styles(
        "background-color" => "lightblue",
        "min-height" => "400px", "overflow-y" => "scroll")

    msg_area = Card(output; style=area_style, id="output")

    input_area = Centered(Row(DOM.div(model), input;
        columns="auto auto", gap="5px",
        justify_content="center"))

    grid_style = Styles("overflow-y" => "hidden", "height" => "100vh")

    style = Styles(
        CSS("body", "height" => "100vh", "overflow-y" => "hidden", "padding" => "20px", "margin" => "0"),
    )
    app = Grid(
        msg_area,
        input_area; style=grid_style, width="100%",
        rows = "auto fit-content", columns="100%",
        align_content="start",
        justify_content="center", justify_items="stretch"
    )
    return DOM.div(
        style, Bonito.MarkdownCSS,
        app
    )
end
rm(Bonito.bundle_path(Bonito.Websocket))
rm(Bonito.bundle_path(Bonito.BonitoLib))
