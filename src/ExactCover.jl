module ExactCover

using OffsetArrays
using ResumableFunctions

include("helper_macros.jl")
include("exact_cover_problem.jl")
include("link_table.jl")
include("dancing_links_colorless.jl")
include("dancing_links_color.jl")

(export ExactCoverProblem, option!, dump, LinkTable,
        TRANSLATE_OPTION, OPTION_INDEX, LABEL,
        solve_colorless, solve_color, solve,
        count_colorless, count_color)

function solve(problem :: ExactCoverProblem, sizehint :: Int = 10)
    table = LinkTable(problem)
    if problem.K > 0
        return solve_color(table, sizehint)
    else
        return solve_colorless(table, sizehint)
    end
end

function solve(problem :: ExactCoverProblem, colored :: Bool, sizehint :: Int = 10)
    table = LinkTable(problem)
    if colored
        return solve_color(table, sizehint)
    else
        return solve_colorless(table, sizehint)
    end
end


end # module


