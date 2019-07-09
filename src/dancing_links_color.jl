@with_table function hideC(p)
  q = p + 1
  while q ≠ p
    x ← TOP(q)
    
    if x ≤ 0
      q ← ULINK(q)
    elseif COLOR(q) < 0
      q += 1
    else
      u ← ULINK(q)
      d ← DLINK(q)
      
      DLINK(u) ← d
      ULINK(d) ← u

      LEN(x) ← LEN(x) - 1
      q += 1 
    end
  end
  return
end


@with_table function coverC(i)
  p ← DLINK(i)
  while p ≠ i
    hideC(table, p)
    p ← DLINK(p)
  end

  l ← LLINK(i)
  r ← RLINK(i)

  RLINK(l) ← r
  LLINK(r) ← l
  return
end


@with_table function unhideC(p)
  q = p - 1
  while q ≠ p
    x ← TOP(q)
    if x ≤ 0
      q ← DLINK(q)
    elseif COLOR(q) < 0
      q = q - 1
    else
      u ← ULINK(q)
      d ← DLINK(q)

      DLINK(u) ← q
      ULINK(d) ← q

      LEN(x) ← LEN(x) + 1
      q = q - 1
    end
  end
  return
end


@with_table function uncoverC(i)
  l ← LLINK(i)
  r ← RLINK(i)

  RLINK(l) ← i
  LLINK(r) ← i

  p ← ULINK(i)
  while p ≠ i
    unhideC(table, p)
    p ← ULINK(p)
  end
  return
end


@with_table function commit(p, j)
    if COLOR(p) == 0
        coverC(table, j)
    elseif COLOR(p) > 0
        purify(table, p)
    end
end

@with_table function purify(p)
    c ← COLOR(p)
    i ← TOP(p)
    q ← DLINK(i)

    while q != i
        if COLOR(q) != c
            hideC(table, q)
        else
            COLOR(q) ← -1
        end
        q ← DLINK(q)
    end
end

@with_table function uncommit(p, j)
    if COLOR(p) == 0
        uncoverC(table, j)
    elseif COLOR(p) > 0
        unpurify(table, p)
    end
end

@with_table function unpurify(p)
    c ← COLOR(p)
    i ← TOP(p)

    q ← ULINK(i)
    while q != i
        if COLOR(q) < 0
            COLOR(q) ← c
        else
            unhideC(table, q)
        end
        q ← ULINK(q)
    end
end

function count_color(table :: LinkTable, sizehint :: Int = 10)
    X = Vector{Int}(undef, 0);
    sizehint!(X, sizehint)
    
    count = 0

    @label c1
    l = 0
    N = table.N
    Z = table.Z


    @label c2
    if RLINK(table, 0) == 0
        count += 1
        @goto c8
    end


    @label c3
    i = choice = RLINK(table, 0)
    theta = LEN(table, i)

    i = RLINK(table, i)
    while i != 0
        len = LEN(table, i)
        if theta > len
            choice = i
            theta = len
        end
        i = RLINK(table, i)
    end 
    i = choice


    @label c4
    coverC(table, i)

    if l == length(X)
        push!(X, DLINK(table, i))
    else
        X[l+1] = DLINK(table, i)
    end


    @label c5
    if X[l+1] == i
        @goto c7
    end
    p = X[l+1] + 1
    while p != X[l+1]
        j = TOP(table, p)
        if j <= 0
            p = ULINK(table, p)
        else
            commit(table, p, j)
            p += 1
        end
    end
    l = l + 1
    @goto c2

    
    @label c6
    p = X[l+1] - 1
    while p != X[l+1]
        j = TOP(table, p)
        if j <= 0
            p = DLINK(table, p)
        else
            uncommit(table, p, j)
            p = p - 1
        end
    end
    i = TOP(table, X[l+1])
    X[l+1] = DLINK(table, X[l+1])
    @goto c5


    @label c7
    uncoverC(table, i)


    @label c8
    if l == 0
        return count
    else
        l = l - 1
        @goto c6
    end
end


@resumable function solve_color(table :: LinkTable, sizehint :: Int = 10) :: Vector{Int}
    X = Vector{Int}(undef, 0);
    sizehint!(X, sizehint)
    
    @label c1
    l = 0
    N = table.N
    Z = table.Z


    @label c2
    if RLINK(table, 0) == 0
        @yield map(x->OPTION_INDEX(table, x), X[1:l])
        @goto c8
    end


    @label c3
    i = choice = RLINK(table, 0)
    theta = LEN(table, i)

    i = RLINK(table, i)
    while i != 0
        len = LEN(table, i)
        if theta > len
            choice = i
            theta = len
        end
        i = RLINK(table, i)
    end 
    i = choice


    @label c4
    coverC(table, i)

    if l == length(X)
        push!(X, DLINK(table, i))
    else
        X[l+1] = DLINK(table, i)
    end


    @label c5
    if X[l+1] == i
        @goto c7
    end
    p = X[l+1] + 1
    while p != X[l+1]
        j = TOP(table, p)
        if j <= 0
            p = ULINK(table, p)
        else
            commit(table, p, j)
            p += 1
        end
    end
    l = l + 1
    @goto c2

    
    @label c6
    p = X[l+1] - 1
    while p != X[l+1]
        j = TOP(table, p)
        if j <= 0
            p = DLINK(table, p)
        else
            uncommit(table, p, j)
            p = p - 1
        end
    end
    i = TOP(table, X[l+1])
    X[l+1] = DLINK(table, X[l+1])
    @goto c5


    @label c7
    uncoverC(table, i)


    @label c8
    if l > 0
        l = l - 1
        @goto c6
    end
end

