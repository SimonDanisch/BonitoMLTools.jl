using BonitoMLTools, Bonito, WGLMakie
using BonitoMLTools: ask_ai, TextInput
using Markdown
# Make sure plots resize to message area
WGLMakie.activate!(; resize_to=(:parent, nothing))
# Needs ENV["OPENAI_API_KEY"] and ENV["CLAUDE_API_KEY"]

body_style = Styles(
    CSS(
        "body",
        "height" => "100vh",
        "overflow-y" => "hidden",
        "padding" => "20px",
        "margin" => "0",
    ),
    CSS(
        "textarea",
        "font-size" => "25px",
    )
)

msg_style = Styles(
    "max-width" => "800px",
    "background-color" => "rgb(252, 252, 252)",
    "padding" => "10px",
    "overflow-wrap" => "break-word",
)

area_style = Styles(
    "background-color" => "lightblue",
    "min-height" => "400px",
    "overflow-y" => "auto",
)

app_style = Styles("overflow-y" => "hidden", "height" => "100vh")

function add_message!(output, content, align)
    style = Styles(
        msg_style,
        "justify-self" => align == "left" ? "start" : "end",
        "text-align" => align,
    )
    card = Card(content; style=style)
    push!(Bonito.children(output[]), card)
    notify(output)
    return
end

App() do session
    input = TextInput("")
    model = Dropdown(["claude-3-sonnet", "dall-e-3", "gpt-4o", "gpt-3.5-turbo"])

    output = Observable(Grid())

    on(input.value) do question
        add_message!(output, Markdown.parse(question), "right")
        task = @async ask_ai(question, model.value[])
        add_message!(output, task, "left")
        return
    end

    msg_area = Card(output; style=area_style)

    input_area = Centered(
        Row(
            DOM.div(model),
            input;
            columns="auto auto",
            gap="5px",
            justify_content="center",
        ),
    )

    app = Grid(
        msg_area,
        input_area;
        style=app_style,
        rows="auto fit-content",
        columns="100%",
        align_content="start",
    )
    return DOM.div(body_style, Bonito.MarkdownCSS, app)
end
