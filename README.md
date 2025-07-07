# Wavelet Audio Analysis

A comprehensive Nim implementation of Discrete Wavelet Transform (DWT) for audio signal processing and analysis.

## Features

- **Complete DWT Implementation**: Forward and inverse transforms with multiple wavelet families
- **Audio Processing**: WAV file reading/writing, windowing, and preprocessing
- **Multiple Wavelets**: Haar, Daubechies (db4, db8), Biorthogonal wavelets
- **Analysis Tools**: Energy analysis, frequency decomposition, denoising
- **High Performance**: Optimized algorithms with efficient memory usage
- **Comprehensive Tests**: Unit tests and benchmarks included

## Wavelet Families Supported

- **Haar**: Simplest wavelet, good for signals with sharp transitions
- **Daubechies**: Orthogonal wavelets with various orders (db4, db8)
- **Biorthogonal**: Symmetric wavelets good for image/audio processing

## Installation

```bash
nimble install
```

## Usage

### Basic DWT Example

```nim
import wavelet_audio

# Create a test signal
let signal = @[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]

# Perform DWT
let dwt = newDWT(WaveletType.Haar)
let (coeffs, lengths) = dwt.forward(signal)

# Reconstruct signal
let reconstructed = dwt.inverse(coeffs, lengths)
```

### Audio Analysis Example

```nim
import wavelet_audio/audio

# Load audio file
let audio = loadWAV("input.wav")

# Analyze with DWT
let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
let analysis = analyzer.analyze(audio.samples, levels = 5)

# Get frequency band energies
echo "Energy distribution: ", analysis.energyDistribution
```

## API Reference

### Core DWT Classes

- `DWT`: Main wavelet transform class
- `WaveletType`: Enumeration of supported wavelets
- `AudioAnalyzer`: High-level audio analysis interface

### Key Methods

- `forward(signal)`: Perform forward DWT
- `inverse(coeffs, lengths)`: Perform inverse DWT
- `analyze(samples, levels)`: Analyze audio with multi-level DWT
- `denoise(signal, threshold)`: Remove noise using wavelet thresholding

## Building and Testing

```bash
# Run tests
nimble test

# Build release version
nim c -d:release src/wavelet_audio.nim

# Generate documentation
nimble docs
```

## Performance

The implementation is optimized for performance with:
- In-place operations where possible
- Efficient memory management
- SIMD-friendly algorithms
- Benchmark suite included

## Applications

- Audio denoising
- Feature extraction for music analysis
- Signal compression
- Time-frequency analysis
- Audio classification preprocessing

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions welcome! 

