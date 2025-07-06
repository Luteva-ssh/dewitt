## Core DWT implementation
## 
## This module implements the core discrete wavelet transform algorithms
## including forward transform, inverse transform, and multi-level decomposition.

import math, sequtils, algorithm
import wavelets

type
  DWT* = ref object
    waveletType*: WaveletType
    coeffs: WaveletCoeffs
    
  DWTResult* = tuple
    coeffs: seq[float64]
    lengths: seq[int]

proc initializeWavelet*(dwt: DWT) =
  ## Initialize wavelet coefficients
  dwt.coeffs = getWaveletCoeffs(dwt.waveletType)

proc padSignal(signal: seq[float64], filterLen: int): seq[float64] =
  ## Pad signal for boundary conditions using symmetric extension
  let padLen = filterLen - 1
  result = newSeq[float64](signal.len + 2 * padLen)
  
  # Left padding (mirror)
  for i in 0..<padLen:
    result[i] = signal[padLen - 1 - i]
  
  # Original signal
  for i in 0..<signal.len:
    result[i + padLen] = signal[i]
  
  # Right padding (mirror)
  for i in 0..<padLen:
    result[signal.len + padLen + i] = signal[signal.len - 1 - i]

proc convolveDownsample(signal: seq[float64], filter: seq[float64]): seq[float64] =
  ## Convolve signal with filter and downsample by 2
  let outLen = signal.len div 2
  result = newSeq[float64](outLen)
  
  for i in 0..<outLen:
    var sum = 0.0
    for j in 0..<filter.len:
      let idx = 2 * i + j
      if idx < signal.len:
        sum += signal[idx] * filter[j]
    result[i] = sum

proc upsampleConvolve(signal: seq[float64], filter: seq[float64], outLen: int): seq[float64] =
  ## Upsample signal by 2 and convolve with filter
  result = newSeq[float64](outLen)
  
  for i in 0..<outLen:
    var sum = 0.0
    for j in 0..<filter.len:
      let idx = (i + j) div 2
      if (i + j) mod 2 == 0 and idx < signal.len:
        sum += signal[idx] * filter[j]
    result[i] = sum

proc forward*(dwt: DWT, signal: seq[float64]): DWTResult =
  ## Perform forward DWT on signal
  if signal.len == 0:
    return (coeffs: @[], lengths: @[])
  
  let filterLen = dwt.coeffs.low_pass.len
  let paddedSignal = padSignal(signal, filterLen)
  
  # Decomposition
  let lowFreq = convolveDownsample(paddedSignal, dwt.coeffs.low_pass)
  let highFreq = convolveDownsample(paddedSignal, dwt.coeffs.high_pass)
  
  # Combine coefficients
  result.coeffs = lowFreq & highFreq
  result.lengths = @[lowFreq.len, highFreq.len]

proc forwardMultiLevel*(dwt: DWT, signal: seq[float64], levels: int): DWTResult =
  ## Perform multi-level forward DWT
  var currentSignal = signal
  var allCoeffs: seq[float64] = @[]
  var allLengths: seq[int] = @[]
  
  for level in 0..<levels:
    if currentSignal.len < 2:
      break
      
    let (coeffs, lengths) = dwt.forward(currentSignal)
    if lengths.len < 2:
      break
    
    # Add high frequency coefficients
    allCoeffs = coeffs[lengths[0]..^1] & allCoeffs
    allLengths = @[lengths[1]] & allLengths
    
    # Continue with low frequency part
    currentSignal = coeffs[0..<lengths[0]]
  
  # Add final low frequency coefficients
  allCoeffs = currentSignal & allCoeffs
  allLengths = @[currentSignal.len] & allLengths
  
  result = (coeffs: allCoeffs, lengths: allLengths)

proc inverse*(dwt: DWT, coeffs: seq[float64], lengths: seq[int]): seq[float64] =
  ## Perform inverse DWT
  if coeffs.len == 0 or lengths.len < 2:
    return @[]
  
  let lowLen = lengths[0]
  let highLen = lengths[1]
  
  if lowLen + highLen != coeffs.len:
    return @[]
  
  let lowFreq = coeffs[0..<lowLen]
  let highFreq = coeffs[lowLen..<(lowLen + highLen)]
  
  let outLen = 2 * lowLen
  let lowRecon = upsampleConvolve(lowFreq, dwt.coeffs.rec_low, outLen)
  let highRecon = upsampleConvolve(highFreq, dwt.coeffs.rec_high, outLen)
  
  result = newSeq[float64](outLen)
  for i in 0..<outLen:
    result[i] = lowRecon[i] + highRecon[i]

proc inverseMultiLevel*(dwt: DWT, coeffs: seq[float64], lengths: seq[int]): seq[float64] =
  ## Perform multi-level inverse DWT
  if lengths.len == 0:
    return @[]
  
  var currentCoeffs = coeffs[0..<lengths[0]]
  var pos = lengths[0]
  
  for i in 1..<lengths.len:
    let highCoeffs = coeffs[pos..<(pos + lengths[i])]
    let combinedCoeffs = currentCoeffs & highCoeffs
    let combinedLengths = @[currentCoeffs.len, highCoeffs.len]
    
    currentCoeffs = dwt.inverse(combinedCoeffs, combinedLengths)
    pos += lengths[i]
  
  result = currentCoeffs

proc computeEnergy*(coeffs: seq[float64]): float64 =
  ## Compute energy of coefficient sequence
  result = coeffs.mapIt(it * it).sum()

proc softThreshold*(coeffs: seq[float64], threshold: float64): seq[float64] =
  ## Apply soft thresholding to coefficients
  result = newSeq[float64](coeffs.len)
  for i in 0..<coeffs.len:
    if abs(coeffs[i]) > threshold:
      result[i] = if coeffs[i] > 0: coeffs[i] - threshold else: coeffs[i] + threshold
    else:
      result[i] = 0.0

