### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 141d7baa-1ee5-41ef-b2f1-595485227d5f
using Pkg

# ╔═╡ 43d14102-d639-499c-97eb-133cd0491273
Pkg.activate("../")

# ╔═╡ fe43bd55-4851-4ee2-a73d-ec429f804079
using PlutoUI, Plots

# ╔═╡ 55801cee-f20e-4eef-90a1-10b9d4e31806
using DSP

# ╔═╡ 406f3ad5-1dbe-45f9-b0c1-66a803cbdd30
include("DIO.jl")

# ╔═╡ c117609b-f95e-4dd5-9c35-28988cfe341a
f0_floor = 60f0

# ╔═╡ 5ad59b0e-150a-4af4-ad1f-74bc9bc1b4f8
f0_ceil = 600f0

# ╔═╡ 76a80d24-a48e-44b5-9bb1-01f7dc4098e5
sample_rate = 16000

# ╔═╡ b18f547d-ddbb-47c3-8f38-b2f2d36a63e2
md"harmonics: $(@bind harmonics Slider(1:5, show_value=true, default=1))"

# ╔═╡ c5b03da4-f8ca-4006-886e-25711f2dee2c
md"loudness: $(@bind loudness Slider(0:0.05:1, show_value=true, default=1.0))"

# ╔═╡ efd6bb71-46e9-46c5-bd55-d6ee5d20d9a0
md"frequency: $(@bind frequency Slider(60:600, show_value=true, default=60)) Hz"

# ╔═╡ cc5f7d6a-c62e-4e6c-8273-b24c594c68f2
md"phase: $(@bind phase Slider(0:0.01:10, show_value=true, default=0))"

# ╔═╡ 9047ffdd-390b-40aa-a161-708ef1da9ca6
sine_wave = (f0, A, ϕ) -> x -> Float32(A * sin(f0 * 2π * x + ϕ))

# ╔═╡ fbb1f675-09d9-4beb-a5d0-228fb8a1ae6e
harmonic_signal = (f0, loudness, ϕ, harmonics::Vector, range) -> begin
    if loudness == 0
        return zeros(length(range))
    end
    res = sum([
        sine_wave(i * f0, harmonic, ϕ).(range)
        for (i, harmonic) ∈ enumerate(harmonics)
    ])
    res .*= loudness / rms(res)
    res
end

# ╔═╡ 115bedd1-90d2-40fd-af71-7f742488584e
begin
	duration = 0.1
	t = 0:1/sample_rate:duration
	y = harmonic_signal(frequency, loudness, phase, [1f0 for i in 1:harmonics], t)
	y = y .|> Float32

	dio = DIO.Dio(f0_ceil, f0_floor, sample_rate)
	attenuated_ys = DIO.attenuate_harmonics(dio)(y)
	plots = [
		begin
			range = 1:length(attenuated_y)
			detected_xs = filter(x -> !isnothing(x), DIO.apply_detectors_chain(dio, range, attenuated_y, dio.noise_floor, DIO.full_period))
			detected_ys = [attenuated_y[i] for i in Int.(round.(detected_xs))]
		
			detected_pitches = attenuated_ys .|> DIO.detect_pitch(dio)
			selected_candidate = detected_pitches |> DIO.select_candidate((value=0f0, confidence=0f0))
		
			plot(
				attenuated_y,
				label=nothing,
				linewidth=2,
				ylimits=(min(-1, attenuated_y...), max(1, attenuated_y...)),
				title=attenuated_y |> DIO.detect_pitch(dio)
			)
			scatter!([(a,b) for (a,b) in zip(detected_xs, detected_ys)])
		 end
		 for attenuated_y in attenuated_ys
	]
	plot(plots..., size=(1000,500), layout=@layout[[a b]; [c d]; e])
end

# ╔═╡ Cell order:
# ╠═141d7baa-1ee5-41ef-b2f1-595485227d5f
# ╠═43d14102-d639-499c-97eb-133cd0491273
# ╠═fe43bd55-4851-4ee2-a73d-ec429f804079
# ╠═55801cee-f20e-4eef-90a1-10b9d4e31806
# ╠═406f3ad5-1dbe-45f9-b0c1-66a803cbdd30
# ╟─c117609b-f95e-4dd5-9c35-28988cfe341a
# ╟─5ad59b0e-150a-4af4-ad1f-74bc9bc1b4f8
# ╟─76a80d24-a48e-44b5-9bb1-01f7dc4098e5
# ╟─b18f547d-ddbb-47c3-8f38-b2f2d36a63e2
# ╟─c5b03da4-f8ca-4006-886e-25711f2dee2c
# ╟─efd6bb71-46e9-46c5-bd55-d6ee5d20d9a0
# ╟─cc5f7d6a-c62e-4e6c-8273-b24c594c68f2
# ╟─115bedd1-90d2-40fd-af71-7f742488584e
# ╟─9047ffdd-390b-40aa-a161-708ef1da9ca6
# ╟─fbb1f675-09d9-4beb-a5d0-228fb8a1ae6e
