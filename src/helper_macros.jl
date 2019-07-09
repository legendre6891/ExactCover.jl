function expression_map(f, expression)
    if typeof(expression) ≠ Expr
        return expression
    end

    new_expr = f(expression)
    args = map(e -> expression_map(f, e), new_expr.args)

    Expr(new_expr.head, args...)
end

allupper(x) = all(y -> isuppercase(y), x)

function add_argument(sym, expression)
    head = expression.head
    args = expression.args

    if head == :call
        if allupper(string(args[1]))
            Expr(:call, args[1], sym, args[2:end]...)
        elseif args[1] == :←
            if typeof(args[2]) == Expr
                # PLACE(x) <- y
                # becomes SET_PLACE!(sym, x, y)
                @assert args[2].head == :call

                set_fn = Symbol("SET_", args[2].args[1], "!")
                target = args[2].args[2]
                value = args[3]

                Expr(:call, set_fn, sym, target, value)
            else
                @assert typeof(args[2]) == Symbol
                Expr(:(=), args[2], args[3:end]...)
            end
        else
            expression
        end
    else
        expression
    end
end

macro with_table(expr)
    @assert expr.head == :function
    args = expr.args

    func_args = Expr(:call, args[1].args[1], :table, args[1].args[2:end]...)
    transform = expression_map(e -> add_argument(:table, e), args[2])
    return Expr(:function, func_args, transform)
end
