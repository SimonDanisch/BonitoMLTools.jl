
struct TextArea
    value::Observable{String}
    # For resetting the value
    targetvalue::Observable{String}
    cols::Observable{Int}
    rows::Observable{Int}
    attributes::Dict{Symbol,Any}
end

function TextArea(prompt::String; cols=50, rows=5, attributes...)
    TextArea(prompt, prompt, Observable{Int}(cols), Observable{Int}(rows), Dict{Symbol,Any}(attributes))
end

function Bonito.jsrender(session::Session, tf::TextArea)
    css = Styles(get(tf.attributes, :style, Styles()), Bonito.BUTTON_STYLE)
    ta = DOM.textarea(tf.targetvalue[];
        cols=tf.cols,
        rows=tf.rows,
        onchange=js"event => $(tf.value).notify(event.srcElement.value);",
        tf.attributes...,
        style=css
    )

    onjs(session, tf.targetvalue, js"""(value=> {
        $(ta).value = value;
    })""")

    return Bonito.jsrender(session, ta)
end

# https://loading.io/css/
function Spinner(; color="black", size="4px", style="solid")
    ripple_css = Asset(joinpath(@__DIR__, "ripple.css"))
    c = Bonito.convert_css_attribute(color)
    style = Styles("border" => "$size $style $c")
    return DOM.div(ripple_css, DOM.div(style=style), DOM.div(), class="lds-ripple")
end

function Bonito.jsrender(session::Session, task::Task)
    result = Observable{Any}(Spinner())
    @async begin
        try
            result[] = fetch(task)
        catch e
            result[] = DOM.div("Error: $e")
        end
    end
    return Bonito.jsrender(session, result)
end


struct JLEvalEditor
    source::String
end

function Bonito.jsrender(s::Session, editor::JLEvalEditor)
    editor = CodeEditor("julia"; initial_source=editor.source, height="400")
    eval_button = Button("eval")
    output = Observable(DOM.div())
    editor_module = Base.Module(gensym("EditorModule"))
    on(s, eval_button.value) do click
        src = editor.onchange[]
        result = "no result"
        try
            result = editor_module.eval(editor_module, Bonito.parseall(src))
        catch e
            result = sprint(showerror, e)
        end
        output[] = DOM.div(result)
    end
    return Bonito.jsrender(s, DOM.div(editor, eval_button, output, style="width: 90ch"))
end

struct InteractiveMarkdown
    source::String
end

function Bonito.jsrender(session::Session, imd::InteractiveMarkdown)
    markdown = Markdown.parse(imd.source)
    style = Styles("overflow-x" => "hidden")
    replacements = Dict(
        Markdown.Code => (session, node) -> begin
            DOM.div(JLEvalEditor(node.code), width="90ch", style=style)
        end
    )
    md = Bonito.replace_expressions(session, markdown, replacements)
    js = js"{
        const div = document.getElementById('output')
        div.scrollTop = div.scrollHeight;
    }"
    return Bonito.jsrender(session, DOM.div(md, js))
end

struct TextInput
    value::Observable{String}
    placeholder::String
    text::TextArea
end

function TextInput(placeholder::String; attributes...)
    name = gensym("MessageText")
    text = TextArea(placeholder; id=name, attributes...)
    return TextInput(Observable(placeholder), placeholder, text)
end

function Bonito.jsrender(s::Session, tf::TextInput)
    button = Button("ask")
    name = tf.text.attributes[:id]
    enter_js = js"""
    const ta_div = document.getElementById($(name))
    ta_div.addEventListener("keydown", function(e) {
        if (e.key === "Enter") {
            $(tf.value).notify(ta_div.value)
            console.log("Enter pressed")
            e.preventDefault()
        }
    })
    """
    on(s, button.value) do click
        tf.text.value[] = ""
        tf.text.targetvalue[] = ""
        tf.value[] = tf.text.value[]
    end
    return Bonito.jsrender(s, Col(tf.text, button, enter_js; gap="0px"))
end
