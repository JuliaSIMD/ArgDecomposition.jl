module ArgDecomposition

export flatten_to_tuple, reassemble_tuple

struct StaticType{T} end
gettype(::StaticType{T}) where {T} = T

function _append_fields!(t::Expr, body::Expr, sym::Symbol, ::Type{T}) where {T}
  for f ∈ 1:fieldcount(T)
    TF = fieldtype(T, f)
    Base.issingletontype(TF) && continue
    gfcall = Expr(:call, getfield, sym, f)
    if fieldcount(TF) ≡ 0
      push!(t.args, gfcall)
    elseif TF <: DataType
      push!(t.args, :(StaticType{$gfcall}()))
    else
      newsym = gensym(sym)
      push!(body.args, Expr(:(=), newsym, gfcall))
      _append_fields!(t, body, newsym, TF)
    end
  end
  return nothing
end
@generated function flatten_to_tuple(r::T) where {T}
  body = Expr(:block, Expr(:meta,:inline))
  t = Expr(:tuple)
  if Base.issingletontype(T)
    nothing
  elseif fieldcount(T) ≡ 0
    push!(t.args, :r)
  elseif T <: DataType
    push!(t.args, :(StaticType{r}()))
  else
    _append_fields!(t, body, :r, T)
  end
  push!(body.args, t)
  body
end
function rebuild_fields(offset::Int, ::Type{T}) where {T}
  call = (T <: Tuple) ? Expr(:tuple) : Expr(:new, T)
  for f ∈ 1:fieldcount(T)
    TF = fieldtype(T, f)
    if Base.issingletontype(TF)
      push!(call.args, TF.instance)
    elseif fieldcount(TF) ≡ 0
      push!(call.args, :($getfield(t, $(offset += 1), false)))
    elseif TF <: DataType
      push!(call.args, :($gettype($getfield(t, $(offset += 1), false))))
    else
      arg, offset = rebuild_fields(offset, TF)
      push!(call.args, arg)      
    end
  end
  return call, offset
end
@generated function reassemble_tuple(::Type{T}, t::Tuple) where {T}
  if Base.issingletontype(T)
    return T.instance
  elseif fieldcount(T) ≡ 0
    call = :($getfield(t, 1, false))
  elseif T <: DataType
    call = :($gettype($getfield(t, 1, false)))
  else
    call, _ = rebuild_fields(0, T)
  end
  Expr(:block, Expr(:meta,:inline), call)
end

end
