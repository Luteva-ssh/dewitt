## Wavelet coefficient definitions and utilities
## 
## This module contains the mathematical definitions of various wavelet families
## including Haar, Daubechies, and Biorthogonal wavelets.

import math, sequtils

type
  WaveletType* = enum
    Haar
    Daubechies4
    Daubechies8
    Biorthogonal22
    Biorthogonal44

  WaveletCoeffs* = object
    low_pass*: seq[float64]
    high_pass*: seq[float64]
    rec_low*: seq[float64]
    rec_high*: seq[float64]

proc getWaveletCoeffs*(waveletType: WaveletType): WaveletCoeffs =
  ## Get wavelet coefficients for specified wavelet type
  case waveletType:
  of Haar:
    result.low_pass = @[0.7071067811865476, 0.7071067811865476]
    result.high_pass = @[-0.7071067811865476, 0.7071067811865476]
    result.rec_low = @[0.7071067811865476, 0.7071067811865476]
    result.rec_high = @[0.7071067811865476, -0.7071067811865476]
  
  of Daubechies4:
    # db4 coefficients
    result.low_pass = @[
      0.4829629131445341, 0.8365163037378079, 0.2241438680420134, -0.1294095225512604
    ]
    result.high_pass = @[
      -0.1294095225512604, -0.2241438680420134, 0.8365163037378079, -0.4829629131445341
    ]
    result.rec_low = @[
      -0.1294095225512604, 0.2241438680420134, 0.8365163037378079, 0.4829629131445341
    ]
    result.rec_high = @[
      -0.4829629131445341, 0.8365163037378079, -0.2241438680420134, -0.1294095225512604
    ]
  
  of Daubechies8:
    # db8 coefficients
    result.low_pass = @[
      0.32580343, 0.01094572, -0.84322608, 0.04068942, 0.41809227, -0.04068942, 
      -0.84322608, -0.01094572, 0.32580343
    ]
    result.high_pass = @[
      0.32580343, -0.01094572, -0.84322608, -0.04068942, 0.41809227, 0.04068942, 
      -0.84322608, 0.01094572, 0.32580343
    ]
    result.rec_low = result.low_pass
    result.rec_high = result.high_pass
  
  of Biorthogonal22:
    # bior2.2 coefficients
    result.low_pass = @[-0.1767766952966369, 0.3535533905932738, 1.0606601717798214, 0.3535533905932738, -0.1767766952966369]
    result.high_pass = @[0.0, 0.0, 0.7071067811865476, -0.7071067811865476, 0.0]
    result.rec_low = @[0.0, 0.0, 0.7071067811865476, 0.7071067811865476, 0.0]
    result.rec_high = @[0.1767766952966369, 0.3535533905932738, -1.0606601717798214, 0.3535533905932738, 0.1767766952966369]
  
  of Biorthogonal44:
    # bior4.4 coefficients - simplified version
    result.low_pass = @[
      0.03782845550699535, -0.023849465019380396, -0.11062440441842342, 0.37740285561265297,
      0.85269867900940344, 0.37740285561265297, -0.11062440441842342, -0.023849465019380396, 0.03782845550699535
    ]
    result.high_pass = @[
      0.0, 0.0, 0.0, 0.7071067811865476, -0.7071067811865476, 0.0, 0.0, 0.0, 0.0
    ]
    result.rec_low = result.low_pass
    result.rec_high = result.high_pass

proc normalizeCoeffs*(coeffs: var seq[float64]) =
  ## Normalize wavelet coefficients
  let norm = sqrt(coeffs.mapIt(it * it).sum())
  if norm > 0:
    coeffs = coeffs.mapIt(it / norm)

