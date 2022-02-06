using BudanTables
using Documenter

DocMeta.setdocmeta!(BudanTables, :DocTestSetup, :(using BudanTables); recursive=true)

makedocs(;
    modules=[BudanTables],
    authors="Laura Brustenga i Moncusí <brust@math.ku.dk> and contributors",
    repo="https://github.com/LauraBMo/BudanTables.jl/blob/{commit}{path}#{line}",
    sitename="BudanTables.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://LauraBMo.github.io/BudanTables.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/LauraBMo/BudanTables.jl",
    devbranch="main",
)
