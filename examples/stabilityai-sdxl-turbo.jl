
const stability_ai_sdxl_turbo_setup = quote
    using PythonCall, CondaPkg
    using Colors
    using Colors: N0f8
    function convert_py_img(image)
        return map([(i, j) for i in 1:pyconvert(Int, image.width), j in 1:pyconvert(Int, image.height)]) do (i, j)
            r, g, b = pyconvert.(Int, image.getpixel((j - 1, i - 1)))
            RGB{N0f8}(r / 255, g / 255, b / 255)
        end
    end
    const diffusers = pyimport("diffusers")
    const torch = pyimport("torch")
    const Text2Image = diffusers.AutoPipelineForText2Image
    const text2image_pipe = Text2Image.from_pretrained("stabilityai/sdxl-turbo", torch_dtype=torch.float16, variant="fp16")
    text2image_pipe.to("cuda")
end

function stability_ai_sdxl_turbo()
    function prompt_func(prompt; num_inference_steps=1, guidance_scale=0.0)
        quote
            image = text2image_pipe(prompt=$(prompt), num_inference_steps=$num_inference_steps, guidance_scale=$guidance_scale).images[0]
            return convert_py_img(image)
        end
    end
    return LongRunning(prompt_func, stability_ai_sdxl_turbo_setup)
end
