struct LinkTable    
    N :: Int
    Z :: Int
    
    llink :: OffsetArray{Int, 1, Vector{Int}}
    rlink :: OffsetArray{Int, 1, Vector{Int}}
    
    top :: Vector{Int}
    ulink :: Vector{Int}
    dlink :: Vector{Int}

    color :: OffsetArray{Int, 1, Vector{Int}}
end

function LinkTable(problem :: ExactCoverProblem)
    N₁ = problem.N₁
    N₂ = problem.N₂
    N = N₁ + N₂
    Z = N + sum(length, problem.options) + length(problem.options) + 1
    
    llink = OffsetArray{Int}(undef, 0:N+1)
    llink[0] = N₁
    for x in 1:N₁
        llink[x] = x-1
    end
    llink[N₁+1] = N + 1
    for x in N₁+2:N + 1
        llink[x] = x-1
    end

    
    rlink = OffsetArray{Int}(undef, 0:N+1)
    rlink[N₁] = 0
    for x in 0:N₁-1
        rlink[x] = x + 1
    end
    rlink[N + 1] = N₁+1
    for x in N₁+1:N
        rlink[x] = x + 1
    end

    
    top = Array{Int}(undef, Z)
    ulink = Array{Int}(undef, Z)
    dlink = Array{Int}(undef, Z)
    color = OffsetArray{Int}(undef, N+2:Z)

    fill!(top, 0)
    fill!(ulink, 0)
    fill!(dlink, 0)

    # calculate the top first
    for option in problem.options
        for item in option
            if typeof(item) == Tuple{Int, Int}
                top[item[1]] += 1
            else
                top[item] += 1
            end
        end
    end

    # now do the rest of TOP row by row,
    i = N
    spacers = []
    s = 0

    for x in 1:N
        ulink[x] = x
        dlink[x] = x
    end

    for (j, option) in enumerate(problem.options)
        i += 1

        # take care of the spacers
        top[i] = s
        s -= 1
        push!(spacers, i)

        if i >= N+2
            color[i] = 0
        end

        for item in option
            i += 1
            if typeof(item) == Tuple{Int, Int}
                it, c = item

                top[i] = it
                up = ulink[it]
                ulink[i], dlink[up] = up, i
                ulink[it] = i
                color[i] = c
            else
                top[i] = item
                up = ulink[item]
                ulink[i], dlink[up] = up, i
                ulink[item] = i
                color[i] = 0
            end
        end
    end
    i += 1
    color[i] = 0

    for last in 1:N
        dlink[ulink[last]] = last
    end

    top[Z] = s
    push!(spacers, Z)


    for (i, j) in zip(spacers[2:end], spacers)
        ulink[i] = j + 1
    end

    for (i, j) in zip(spacers, spacers[2:end])
        dlink[i] = j - 1
    end


# make sure all are true
    return LinkTable(N, Z, llink, rlink, top, ulink, dlink, color)
end

@inline LLINK(table, i) = @inbounds table.llink[i]
@inline RLINK(table, i) = @inbounds table.rlink[i]
@inline TOP(table, i)   = @inbounds table.top[i]
@inline LEN(table, i)   = @inbounds table.top[i]
@inline DLINK(table, i) = @inbounds table.dlink[i]
@inline ULINK(table, i) = @inbounds table.ulink[i]
@inline COLOR(table, i) = @inbounds table.color[i]

@inline SET_LLINK!(table, i, z) = @inbounds table.llink[i] = z
@inline SET_RLINK!(table, i, z) = @inbounds table.rlink[i] = z
@inline SET_TOP!(table, i, z)   = @inbounds table.top[i] = z
@inline SET_LEN!(table, i, z)   = @inbounds table.top[i] = z
@inline SET_ULINK!(table, i, z) = @inbounds table.ulink[i] = z
@inline SET_DLINK!(table, i, z) = @inbounds table.dlink[i] = z
@inline SET_COLOR!(table, i, z) = @inbounds table.color[i] = z


@with_table function OPTION_INDEX(o)
    while TOP(o) > 0
        o += 1
    end
    return -TOP(o)
end
