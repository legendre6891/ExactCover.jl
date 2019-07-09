@with_table function hide(p)
  q = p + 1
  while q ≠ p
    x ← TOP(q)
    
    if x ≤ 0
      q ← ULINK(q)
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


@with_table function cover(i)
  p ← DLINK(i)
  while p ≠ i
    hide(table, p)
    p ← DLINK(p)
  end

  l ← LLINK(i)
  r ← RLINK(i)

  RLINK(l) ← r
  LLINK(r) ← l
  return
end


@with_table function unhide(p)
  q = p - 1
  while q ≠ p
    x ← TOP(q)
    if x ≤ 0
      q ← DLINK(q)
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


@with_table function uncover(i)
  l ← LLINK(i)
  r ← RLINK(i)

  RLINK(l) ← i
  LLINK(r) ← i

  p ← ULINK(i)
  while p ≠ i
    unhide(table, p)
    p ← ULINK(p)
  end
  return
end


function count_colorless(table :: LinkTable, sizehint :: Int = 10)
    X = Vector{Int}(undef, 0);
    sizehint!(X, sizehint)
    
    count = 0

    @label x1
    l = 0
    N = table.N
    Z = table.Z


    @label x2
    if RLINK(table, 0) == 0
        count += 1
        @goto x8
    end


    @label x3
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


    @label x4
    cover(table, i)

    if l == length(X)
        push!(X, DLINK(table, i))
    else
        X[l+1] = DLINK(table, i)
    end


    @label x5
    if X[l+1] == i
        @goto x7
    end
    p = X[l+1] + 1
    while p != X[l+1]
        j = TOP(table, p)
        if j <= 0
            p = ULINK(table, p)
        else
            cover(table, j)
            p += 1
        end
    end
    l = l + 1
    @goto x2

    
    @label x6
    p = X[l+1] - 1
    while p != X[l+1]
        j = TOP(table, p)
        if j <= 0
            p = DLINK(table, p)
        else
            uncover(table, j)
            p = p - 1
        end
    end
    i = TOP(table, X[l+1])
    X[l+1] = DLINK(table, X[l+1])
    @goto x5


    @label x7
    uncover(table, i)


    @label x8
    if l == 0
        return count
    else
        l = l - 1
        @goto x6
    end
end


@resumable function solve_colorless(table :: LinkTable, sizehint :: Int = 10) :: Vector{Int}
    X = Vector{Int}(undef, 0);
    sizehint!(X, sizehint)
    
    @label x1
    l = 0
    N = table.N
    Z = table.Z


    @label x2
    if RLINK(table, 0) == 0
        @yield map(x->OPTION_INDEX(table, x), X[1:l])
        @goto x8
    end


    @label x3
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


    @label x4
    cover(table, i)

    if l == length(X)
        push!(X, DLINK(table, i))
    else
        X[l+1] = DLINK(table, i)
    end


    @label x5
    if X[l+1] == i
        @goto x7
    end
    p = X[l+1] + 1
    while p != X[l+1]
        j = TOP(table, p)
        if j <= 0
            p = ULINK(table, p)
        else
            cover(table, j)
            p += 1
        end
    end
    l = l + 1
    @goto x2

    
    @label x6
    p = X[l+1] - 1
    while p != X[l+1]
        j = TOP(table, p)
        if j <= 0
            p = DLINK(table, p)
        else
            uncover(table, j)
            p = p - 1
        end
    end
    i = TOP(table, X[l+1])
    X[l+1] = DLINK(table, X[l+1])
    @goto x5


    @label x7
    uncover(table, i)


    @label x8
    if l > 0
        l = l - 1
        @goto x6
    end
end
