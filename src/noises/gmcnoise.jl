"""
    GmcNoise(kernel{<:SingularModel}, g1::UnitaryWhiteNoise, g2::UnitaryWhiteNoise)

Noise process generated by the Gaussian Multiplicative Chaos theory.
Responsable for the intermittency effects.
"""
struct GmcNoise{T}<:AbstractNoise
    wr::Vector{Float64}
    wk::Vector{ComplexF64}
    γ::Float64
    ker::Kernel{<:SingularModel}
    g1::UnitaryWhiteNoise
    g2::UnitaryWhiteNoise
    function GmcNoise(ker::Kernel{<:SingularModel}, g1::UnitaryWhiteNoise, g2::UnitaryWhiteNoise, γ::Real)
        g1_x = irfft(g1.wk, length(ker.cη))
        σ_sq = 2*sum(abs.(ker.Lk[2:end]).^2)
        wr = g1_x .* exp.(γ .* realization(ker, g2) .- γ^2 .* σ_sq)
        wk = rfft(wr)
        new{Float64(γ)}(wr, wk, γ, ker, g1, g2)
    end
end

#alias for the γ = 0 case
const TrivialGmcNoise = GmcNoise{Float64(0)}