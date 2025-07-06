## Unit tests for audio processing functionality

import unittest, math, sequtils
import ../src/wavelet/[audio_utils, dwt_core, wavelets]

suite "Audio Processing Tests":
  
  test "Audio analyzer creation":
    let analyzer = newAudioAnalyzer(WaveletType.Haar)
    check analyzer != nil
  
  test "Window functions":
    let N = 16
    let samples = newSeq[float64](N).mapIt(1.0)
    
    let rect = applyWindow(samples, Rectangular)
    let hamming = applyWindow(samples, Hamming)
    let hanning = applyWindow(samples, Hanning)
    let blackman = applyWindow(samples, Blackman)
    
    check rect.len == N
    check hamming.len == N
    check hanning.len == N
    check blackman.len == N
    
    # Rectangular window should be unchanged
    for i in 0..<N:
      check abs(rect[i] - 1.0) < 1e-10
    
    # Other windows should have different values
    check hamming[0] != hamming[N div 2]
    check hanning[0] != hanning[N div 2]
    check blackman[0] != blackman[N div 2]
  
  test "Normalization":
    let samples = @[2.0, 4.0, -6.0, 8.0]
    let normalized = normalize(samples)
    
    check normalized.len == samples.len
    let maxVal = normalized.mapIt(abs(it)).max()
    check abs(maxVal - 1.0) < 1e-10
  
  test "Pre-emphasis filter":
    let samples = @[1.0, 2.0, 3.0, 4.0, 5.0]
    let preEmphasized = preEmphasize(samples, 0.97)
    
    check preEmphasized.len == samples.len
    check abs(preEmphasized[0] - samples[0]) < 1e-10
    
    for i in 1..<samples.len:
      let expected = samples[i] - 0.97 * samples[i - 1]
      check abs(preEmphasized[i] - expected) < 1e-10
  
  test "Audio analysis":
    let analyzer = newAudioAnalyzer(WaveletType.Haar)
    let N = 64
    var samples = newSeq[float64](N)
    
    # Create test signal with multiple frequencies
    for i in 0..<N:
      samples[i] = sin(2.0 * PI * 5.0 * float64(i) / float64(N)) + 
                   0.5 * sin(2.0 * PI * 15.0 * float64(i) / float64(N))
    
    let analysis = analyzer.analyze(samples, 4)
    
    check analysis.levels == 4
    check analysis.energyDistribution.len > 0
    check analysis.coefficients.len > 0
    check analysis.lengths.len > 0
    check analysis.originalLength == N
    
    # Energy distribution should sum to approximately 1
    let totalEnergy = analysis.energyDistribution.sum()
    check abs(totalEnergy - 1.0) < 1e-10
  
  test "Denoising":
    let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
    let N = 128
    var cleanSignal = newSeq[float64](N)
    var noisySignal = newSeq[float64](N)
    
    # Create clean signal
    for i in 0..<N:
      cleanSignal[i] = sin(2.0 * PI * 10.0 * float64(i) / float64(N))
    
    # Add noise
    for i in 0..<N:
      noisySignal[i] = cleanSignal[i] + 0.1 * sin(2.0 * PI * 50.0 * float64(i) / float64(N))
    
    let denoised = analyzer.denoise(noisySignal, 0.05, 5)
    
    check denoised.len == N
    
    # Denoised signal should be closer to clean signal than noisy signal
    var noisyError = 0.0
    var denoisedError = 0.0
    for i in 0..<N:
      noisyError += abs(noisySignal[i] - cleanSignal[i])
      denoisedError += abs(denoised[i] - cleanSignal[i])
    
    check denoisedError < noisyError
  
  test "Feature extraction":
    let analyzer = newAudioAnalyzer(WaveletType.Haar)
    let N = 64
    var samples = newSeq[float64](N)
    
    for i in 0..<N:
      samples[i] = sin(2.0 * PI * 8.0 * float64(i) / float64(N))
    
    let analysis = analyzer.analyze(samples, 3)
    let features = extractFeatures(analysis)
    
    check features.len > 0
    check features[0] >= 0.0  # Total energy should be non-negative
  
  test "WAV file simulation":
    let audio = loadWAV("test.wav")
    check audio.samples.len > 0
    check audio.sampleRate > 0
    check audio.channels > 0
    
    # Test saving
    saveWAV(audio, "output.wav")

when isMainModule:
  echo "Running Audio tests..."
