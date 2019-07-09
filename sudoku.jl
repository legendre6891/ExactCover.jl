using ExactCover
board = "530070000600000000098000060800000003400803000000020006060000280000400005000000000"

function box(i, j)
    3 * div(i - 1, 3) + div(j - 1, 3) + 1
end

function sudoku(board)
    P = Set(Iterators.product(1:9, 1:9))
    R = Set(Iterators.product(1:9, 1:9))
    C = Set(Iterators.product(1:9, 1:9))
    Q = Set(Iterators.product(1:9, 1:9))

    for (z, b) in enumerate(board)
        k = b - '0'
        #println(typeof(k), " ", b, " ", k)
        if 1 <= k && k <= 9
            i, j = divrem(z - 1, 9)
            i = i + 1
            j = j + 1
            x = box(i, j)

            delete!(P, (i, j))
            delete!(R, (i, k))
            delete!(C, (j, k))
            delete!(Q, (x, k))
        end
    end
    universe :: Vector{Tuple{Char, Int, Int}} = []
    for (i, j) in P
        push!(universe, ('p', i, j))
    end

    for (i, k) in R
        push!(universe, ('r', i, k))
    end

    for (j, k) in C
        push!(universe, ('c', j, k))
    end

    for (x, k) in Q
        push!(universe, ('q', x, k))
    end

    problem = ExactCoverProblem(universe, [])

    for i = 1:9, j = 1:9, k = 1:9
        x = box(i, j)
        if (i, j) in P && (i, k) in R && (j, k) in C && (x, k) in Q
            option!(problem, [('p', i, j), ('r', i, k), ('c', j, k), ('q', x, k)])
        end
    end

    return problem
end
