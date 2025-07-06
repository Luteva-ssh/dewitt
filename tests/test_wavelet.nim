## Unit tests for wavelet coefficient definitions

import unittest, math, sequtils
import ../src/wavelet/wavelets

suite "Wavelet Coefficient Tests":
  
  test "Haar wavelet coefficients":
    let coeffs = getWaveletCoeffs(WaveletType.Haar)
    
    check coeffs.low_pass.len == 2
    check coeffs.high_pass.len == 2
    check coeffs.rec_low.len == 2
    check coeffs.rec_high.len == 2
    
    # Check orthogonality
    let sqrt2 = sqrt(2.0)
    check abs(coeffs.low_pass[0] - 1.0/sqrt2) < 1e-10
    check abs(coeffs.low_pass[1] - 1.0/sqrt2) < 1e-10
  
  test "Daubechies4 wavelet coefficients":
    let coeffs = getWaveletCoeffs(WaveletType.Daubechies4)
    
    check coeffs.low_pass.len == 4
    check coeffs.high_pass.len == 4
    check coeffs.rec_low.len == 4
    check coeffs.rec_high.len == 4
    
    # Check normalization
    let norm = sqrt(coeffs.low_pass.mapIt(it * it).sum())
    check abs(norm - 1.0) < 1e-10
  
  test "Daubechies8 wavelet coefficients":
    let coeffs = getWaveletCoeffs(WaveletType.Daubechies8)
    
    check coeffs.low_pass.len == 9
    check coeffs.high_pass.len == 9
  
  test "Biorthogonal wavelet coefficients":
    let coeffs22 = getWaveletCoeffs(WaveletType.Biorthogonal22)
    let coeffs44 = getWaveletCoeffs(WaveletType.Biorthogonal44)
    
    check coeffs22.low_pass.len == 5
    check coeffs44.low_pass.len == 9
  
  test "Coefficient normalization":
    var coeffs = @[1.0, 2.0, 3.0, 4.0]
    normalizeCoeffs(coeffs)
    
    let norm = sqrt(coeffs.mapIt(it * it).sum())
    check abs(norm - 1.0) < 1e-10

when isMainModule:
  echo "Running Wavelet coefficient tests..."

