using DIO, DSP, Plots
using Test

f0_ceil = 600f0
f0_floor = 60f0
duration = 0.3
sample_rate = 16000
t = 0:1/sample_rate:duration

loudnesses = 0f0:0.2f0:1f0
f0s = f0_floor:f0_ceil
harmonics = 1:3

sine_wave = (f0, A, ϕ) -> x -> Float32(A * sin(f0 * 2π * x + ϕ))

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

@testset "No noise" begin
    for (loudness, f0, harmonics) in Iterators.product(loudnesses, f0s, harmonics)
        dio = Dio(f0_ceil, f0_floor, sample_rate)
        sound = harmonic_signal(f0, loudness, 0f0, [1f0 for i in 1:harmonics], t)
        contour = dio_contour(dio, sound)
        n = size(contour)[end]
        pred_f0 = sort(contour[1, :])[end÷2]
        confidence = sort(contour[2, :])[end÷2]
        if loudness > 0
            # accuracy is expected to be over 90%
            is_prediction_valid = min(pred_f0, f0) / max(pred_f0, f0, 1) >= 0.9f0
            @test is_prediction_valid
        else
            @test pred_f0 == 0f0
            @test confidence == 0f0
        end
    end
end
