using Pkg;
Pkg.activate(pwd())
using PythonCall
const torch = pyimport("torch")
const trans = pyimport("transformers")

# Set the default device to CUDA
torch.set_default_device("cuda")

# Load the model and tokenizer
model = trans.AutoModelForCausalLM.from_pretrained("microsoft/phi-2", torch_dtype="auto", flash_attn=false, flash_rotary=false, fused_dense=true, device_map="cuda", trust_remote_code=true)
tokenizer = trans.AutoTokenizer.from_pretrained("microsoft/phi-2", trust_remote_code=true)

# Prepare inputs
inputs = tokenizer("def print_prime(n):\n   \"\"\"\n   Print all primes between 1 and n\n   \"\"\"", return_tensors="pt", return_attention_mask=false)

# Generate outputs
outputs = model.generate(;kwargs(inputs)..., max_length=200)
text = tokenizer.batch_decode(outputs)[1]
