## Unit tests for DWT core functionality

import unittest, math, sequtils
import ../src/wavelet/[dwt_core, wavelets]

suite "DWT Core Tests":
  
  test "Haar wavelet forward transform":
    let dwt = DWT(waveletType: WaveletType.Haar)
    dwt.initializeWavelet()
    let signal = @[1.0, 2.0, 3.0, 4.0]
    let (coeffs, lengths) = dwt.forward(signal)
    
    check coeffs.len > 0
    check lengths.len == 2
    check lengths[0] + lengths[1] == coeffs.len
  
  test "Haar wavelet perfect reconstruction":
    let dwt = DWT(waveletType: WaveletType.Haar)
    dwt.initializeWavelet()
    let signal = @[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
    let (coeffs, lengths) = dwt.forward(signal)
    let reconstructed = dwt.inverse(coeffs, lengths)
    
    check reconstructed.len >= signal.len
    for i in 0..<signal.len:
      check abs(reconstructed[i] - signal[i]) < 1e-10
  
  test "Daubechies4 wavelet transform":
    let dwt = DWT(waveletType: WaveletType.Daubechies4)
    dwt.initializeWavelet()
    let signal = @[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
    let (coeffs, lengths) = dwt.forward(signal)
    
    check coeffs.len > 0
    check lengths.len == 2
  
  test "Multi-level DWT":
    let dwt = DWT(waveletType: WaveletType.Haar)
    dwt.initializeWavelet()
    let signal = @[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0]
    let (coeffs, lengths) = dwt.forwardMultiLevel(signal, 3)
    
    check coeffs.len > 0
    check lengths.len > 1
    
    let reconstructed = dwt.inverseMultiLevel(coeffs, lengths)
    for i in 0..<min(signal.len, reconstructed.len):
      check abs(reconstructed[i] - signal[i]) < 1e-8
  
  test "Energy computation":
    let coeffs = @[1.0, 2.0, 3.0, 4.0]
    let energy = computeEnergy(coeffs)
    let expected = 1.0 + 4.0 + 9.0 + 16.0
    check abs(energy - expected) < 1e-10
  
  test "Soft thresholding":
    let coeffs = @[-3.0, -1.0, 0.5, 2.0, 4.0]
    let threshold = 1.5
    let result = softThreshold(coeffs, threshold)
    let expected = @[-1.5, 0.0, 0.0, 0.5, 2.5]
    
    for i in 0..<result.len:
      check abs(result[i] - expected[i]) < 1e-10
  
  test "Empty signal handling":
    let dwt = DWT(waveletType: WaveletType.Haar)
    dwt.initializeWavelet()
    let signal: seq[float64] = @[]
    let (coeffs, lengths) = dwt.forward(signal)
    
    check coeffs.len == 0
    check lengths.len == 0
  
  test "Small signal handling":
    let dwt = DWT(waveletType: WaveletType.Haar)
    dwt.initializeWavelet()
    let signal = @[1.0, 2.0]
    let (coeffs, lengths) = dwt.forward(signal)
    let reconstructed = dwt.inverse(coeffs, lengths)
    
    check reconstructed.len >= signal.len
    for i in 0..<signal.len:
      check abs(reconstructed[i] - signal[i]) < 1e-10

when isMainModule:
  echo "Running DWT tests..."

