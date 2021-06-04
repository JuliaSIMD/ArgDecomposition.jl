using ArgDecomposition
using Documenter

DocMeta.setdocmeta!(ArgDecomposition, :DocTestSetup, :(using ArgDecomposition); recursive=true)

makedocs(;
    modules=[ArgDecomposition],
    authors="chriselrod <elrodc@gmail.com> and contributors",
    repo="https://github.com/JuliaSIMD/ArgDecomposition.jl/blob/{commit}{path}#{line}",
    sitename="ArgDecomposition.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaSIMD.github.io/ArgDecomposition.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaSIMD/ArgDecomposition.jl",
)
