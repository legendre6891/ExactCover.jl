mutable struct ExactCoverProblem

    # These are dictionaries mapping a keyable object
    # to a integer index.
    primary_names
    secondary_names
    color_names


    # The reverse index, where the i-th index contains
    # the keyable object above.
    primary_array
    secondary_array
    color_array

    N₁ :: Int
    N₂ :: Int

    # number of colors
    K :: Int

    options :: Vector{Vector{Union{Int, Tuple{Int, Int}}}}

    labels :: Vector{String}
end

function ExactCoverProblem(primary_items, secondary_items)
    primary_array   = reshape(collect(primary_items), :)
    secondary_array = reshape(collect(secondary_items), :)

    p_dict = Dict(zip(primary_array, Iterators.countfrom()))
    N₁ = length(primary_array)

    s_dict = Dict(zip(secondary_array, Iterators.countfrom(N₁ + 1)))
    N₂ = length(secondary_array)


    ExactCoverProblem(
        p_dict, s_dict, Dict(),
        primary_array, secondary_array, Dict(),
        N₁, N₂, 0, 
        [], [])
end

function option!(problem :: ExactCoverProblem, items, label=nothing)
    option = []

    for (i, item) in enumerate(items)
        # There are three possibilities.
        #     - the item is primary
        #     - the item is secondary
        #     - the "item" is actually of the form (item, color)
        if haskey(problem.primary_names, item)
            push!(option, problem.primary_names[item])
        elseif haskey(problem.secondary_names, item)
            # A secondary item with no given color is given
            # colors zero to match algorithm in the
            # link table
            push!(option, (problem.secondary_names[item], 0))
        else
            it, color = item
            if !haskey(problem.color_names, color)
                problem.K += 1
                problem.color_names[color] = problem.K
                problem.color_array[problem.K] = color
            end
            push!(option, (problem.secondary_names[it], problem.color_names[color]))
        end

        if !isnothing(label)
            push!(problem.labels, label)
        else
            push!(problem.labels, string(i))
        end
    end
    push!(problem.options, option)
end

@inline LABEL(p :: ExactCoverProblem, i) = p.labels[i]



function TRANSLATE_OPTION(problem :: ExactCoverProblem, option)
    map(option) do id
        if typeof(id) == Int
            if 1 <= id <= problem.N₁
                problem.primary_array[id]
            else
                problem.secondary_array[id - problem.N₁]
            end
        else
            x, y = id
            (problem.secondary_array[x - problem.N₁], problem.color_array[y])
        end
    end
end
