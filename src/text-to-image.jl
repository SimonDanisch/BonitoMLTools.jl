using Colors, ImageShow
using Colors: N0f8
using Bonito

include("longrunning.jl")
include("widgets.jl")
include("stabilityai-sdxl-turbo.jl")

text2image = stability_ai_sdxl_turbo()
text2image("Hello my name is") |> fetch

function img2binary(img)
    io = IOBuffer()
    show(io, MIME"image/png"(), img)
    return Bonito.BinaryAsset(take!(io), "image/png")
end


App() do
    text = TextArea("")
    button = Button("Generate")
    img_task = Observable{Any}()
    map!(img_task, button.value) do _
        prompt = text.value[]
        isempty(prompt) && return DOM.div("Please enter a prompt")
        return @async begin
            task = text2image(prompt)
            img = fetch(task)
            println("img ist fetched")
            binary = img2binary(img)
            DOM.img(src=binary, width=512, height=512)
        end
    end

    output = DOM.div(Centered(img_task), style=Styles("width" => "100%"))

    return Grid(text, button, output)
end
