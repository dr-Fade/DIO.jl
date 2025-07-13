# DIO.jl

[![Build Status](https://github.com/dr-Fade/DIO.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/dr-Fade/DIO.jl/actions/workflows/CI.yml?query=branch%3Amaster)

This repository contains an implementation of the DIO algorithm for estimating the fundamental frequency (F0) of speech signals, as described in the article "A Fast and Accurate Fundamental Frequency Estimator" by Ryosuke Daido and Yuji Hisaminato with additions and improvements from "Adaptation of the WORLD framework for frame-by-frame real-time speech analysis" by Eugene Koshel.

## Features

- **Fast and Accurate**: Implements a method that provides fast and accurate F0 estimation suitable for real-time applications.
- **Recursive Moving Average (RMA) Filters**: Uses RMA filters to efficiently attenuate higher harmonics.
- **Enhanced Period Detector**: Capable of handling signals with significant harmonic content. The improvement in accuracy is achieved by adding the quadratic interpolation for estimating positive and negative peaks.
- **Real-Time Capability**: Suitable for high-quality speech analysis and synthesis in real-time.

## Usage

Here is a basic example of how to use the DIO module to estimate the fundamental frequency from an audio signal:

```julia
using DIO  # Import the DIO module

# Sample rate and F0 range for your application
sample_rate = 16000
f0_floor = 60.0
f0_ceil = 600.0

# Create a Dio object with specified parameters
dio = Dio(f0_ceil, f0_floor, sample_rate)

# Load or generate an audio signal (as a Vector{Float32})
audio_signal = ... # Your audio data here

# Estimate the F0 contour of the audio signal
f0_contour = dio_contour(dio, audio_signal; hop=1.0f0)

# `f0_contour` is a Matrix{Float32} with two rows:
# - First row: Estimated F0 values
# - Second row: Confidence scores for each estimate
```

For an interactive demo of the algorithm working with synthetic data of various frequencies and number of harmonics, see this [Pluto notebook](src/demo.jl).

To run it:
1. Clone the repo.
2. Navigate to in terminal and run the following commands:
```
$ julia
> ] activate
> ] instantiate
> using Pluto
> Pluto.run(notebook="src/demo.jl")
```
3. A new browser window will open with the interactive Pluto notebook.

## References

The algorithm is based on the papers:

* R. Daido and Y. Hisaminato, "A fast and accurate fundamental frequency estimator using recursive moving average filters.", in INTERSPEECH, 2016, pp. 2160–2164.
* Koshel Y. V. "Adaptation of the world framework for frame-by-frame real-time speech analysis", in System technologies. DOI 10.34185/1562-9945-5-148-2023-03, ISSN (print) 1562-9945, ISSN (on-line) 2707-7977. – V. 5 – №148 – 2023 – pp. 21–36
## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Feel free to contribute by submitting issues or pull requests. For any questions, please open an issue in this repository.
