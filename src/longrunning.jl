using Malt, Pkg

struct LongRunning
    worker::Malt.Worker
    call::Function
end

function (lr::LongRunning)(args...; kw...)
    return Malt.remote_eval(lr.worker, lr.call(args...; kw...))
end

function LongRunning(prompt_func::Function, setup::Expr)
    p = Pkg.project()
    worker = Malt.Worker(exeflags="--project=$(dirname(p.path))")
    Malt.remote_eval(worker, setup)
    return LongRunning(worker, prompt_func)
end
