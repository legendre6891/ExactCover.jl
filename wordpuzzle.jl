using ExactCover
import Random: shuffle

"""
Given a N × M grid, and a location (x, y) on that grid, return the list of
admissible directions for placing `word` at that location.
"""
function possible_directions(N, M, word :: String, x, y)
    return possible_directions(N, M, length(word), x, y)
end

function possible_directions(N, M, L :: Int, x, y)
    result = Tuple{Int, Int}[]

    if !(1 <= x <= N)
        return result
    end

    if !(1 <= y <= M)
        return result
    end

    for i in -1:1, j in -1:1
        if i == 0 && j == 0
            continue
        end

        fx, fy = x + (L - 1) * i, y + (L - 1) * j
        if 1 <= fx <= N && 1 <= fy <= M
            push!(result, tuple(i, j))
        end
    end

    return result
end


function color_characters(x, y, i, j, word)
    collect(((x + (c-1) * i, y + (c-1) * j), char) for (c, char) in enumerate(word))
end


function setup(N, M, wordlist)
    problem = ExactCoverProblem(wordlist, Iterators.product(1:N, 1:M))
    grid = reshape(collect(Iterators.product(1:N, 1:M)), :)
    for word in shuffle(wordlist)
        for (x, y) in shuffle(grid)
            for (i, j) in shuffle(possible_directions(N, M, word, x, y))
                option!(problem, [word, color_characters(x, y, i, j, word)...])
            end
        end
    end
    return problem
end

function print_puzzle(puzzle)
    for row in eachrow(puzzle)
        for c in row
            print(c, ' ')
        end
        println()
    end
end


function create_puzzle(N, M, problem, solution)
    puzzle = Array{Char}(undef, N, M)        
    fill!(puzzle, '⋅')

    options = [problem.options[i] for i in solution]
    placements = [o[2:end] for o in options]
    for p in placements
        translate = TRANSLATE_OPTION(problem, p)
        for ((i, j), c) in translate
            puzzle[i, j] = c
        end
    end
    return puzzle
end

N, M = 14, 8
wordlist = ["SFOGLINA", "NANKAI",
"JOHNSHOPKINS", "INTERNATIONAL",
"MONETARY", "FUND", "WORLDBANK", "ECONOMICS",
"SIXFLAGS", "KARAOKE", "MANCHESTER"]


function random_solution(N, M, wordlist)
    problem = setup(N, M, wordlist)
    soln = first(solve(problem))
    puzzle = create_puzzle(N, M, problem, soln)
    print_puzzle(puzzle)

    return count(c -> c == '⋅', puzzle)
end

