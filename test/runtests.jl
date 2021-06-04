using ArgDecomposition
using Test

@testset "ArgDecomposition.jl" begin

  for t ∈ (
    Val(4), Float32, 8.9, (a = 3, b = (3,2), d = Float64, e = (1f0, '2', 3.0, 4, 0x05)),
    (a = 3, b = (3,(2,21f0,3.0)), c = "hello, world!", d = Float64, e = (1f0, '2', 3.0, 4, 0x05))
  )
    
    ft = flatten_to_tuple(t)
    @test ft isa Tuple
    rt = reassemble_tuple(typeof(t), ft)
    @test rt === t
  end  
end
