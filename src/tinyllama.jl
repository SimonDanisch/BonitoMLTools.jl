
const tiny_llama_setup = quote
    using PythonCall, CondaPkg
    const torch = pyimport("torch")
    const transformers = pyimport("transformers")
    const pipeline = transformers.pipeline
    const text2text = pipeline("text-generation", model="TinyLlama/TinyLlama-1.1B-Chat-v1.0", torch_dtype=torch.bfloat16, device_map="auto")
end

function tiny_llama()
    function prompt_func(messages; tokenize=false, add_generation_prompt=true, max_new_tokens=256, do_sample=true, temperature=0.7, top_k=50, top_p=0.95)
        quote
            prompt = text2text.tokenizer.apply_chat_template($messages, tokenize=$tokenize, add_generation_prompt=$add_generation_prompt)
            outputs = text2text(prompt, max_new_tokens=$max_new_tokens, do_sample=$do_sample, temperature=$temperature, top_k=$top_k, top_p=$top_p)
            return map(x -> pyconvert(Dict, x), outputs)
        end
    end
    return LongRunning(prompt_func, tiny_llama_setup)
end
