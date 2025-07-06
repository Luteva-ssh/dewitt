## Basic usage examples for the wavelet audio library

import math, sequtils, strformat
import ../src/dewitt

proc basicDWTExample() =
  echo "Basic DWT Example"
  echo "================="
  
  # Create a simple test signal
  let N = 64
  var signal = newSeq[float64](N)
  for i in 0..<N:
    signal[i] = sin(2.0 * PI * 5.0 * float64(i) / float64(N)) + 
                0.5 * sin(2.0 * PI * 15.0 * float64(i) / float64(N))
  
  echo fmt"Original signal length: {signal.len}"
  echo fmt"First 8 samples: {signal[0..7]}"
  
  # Perform DWT
  let dwt = newDWT(WaveletType.Haar)
  let (coeffs, lengths) = dwt.forward(signal)
  
  echo fmt"Transform coefficients length: {coeffs.len}"
  echo fmt"Low/High frequency lengths: {lengths}"
  
  # Reconstruct
  let reconstructed = dwt.inverse(coeffs, lengths)
  
  echo fmt"Reconstructed signal length: {reconstructed.len}"
  
  # Check reconstruction error
  var maxError = 0.0
  for i in 0..<min(signal.len, reconstructed.len):
    let error = abs(signal[i] - reconstructed[i])
    maxError = max(maxError, error)
  
  echo fmt"Maximum reconstruction error: {maxError}"

proc multiLevelExample() =
  echo "\nMulti-level DWT Example"
  echo "======================="
  
  # Create a more complex signal
  let N = 512
  var signal = newSeq[float64](N)
  for i in 0..<N:
    signal[i] = sin(2.0 * PI * 10.0 * float64(i) / float64(N)) + 
                0.5 * sin(2.0 * PI * 25.0 * float64(i) / float64(N)) +
                0.3 * sin(2.0 * PI * 60.0 * float64(i) / float64(N)) +
                0.1 * sin(2.0 * PI * 120.0 * float64(i) / float64(N))
  
  let dwt = newDWT(WaveletType.Daubechies4)
  let levels = 6
  
  echo fmt"Performing {levels}-level DWT on signal of length {N}"
  
  let (coeffs, lengths) = dwt.forwardMultiLevel(signal, levels)
  
  echo fmt"Number of coefficient bands: {lengths.len}"
  echo fmt"Band sizes: {lengths}"
  
  # Compute energy in each band
  var pos = 0
  for i in 0..<lengths.len:
    let bandCoeffs = coeffs[pos..<(pos + lengths[i])]
    let energy = computeEnergy(bandCoeffs)
    echo fmt"Band {i}: energy = {energy:>10.6f}"
    pos += lengths[i]
  
  # Reconstruct
  let reconstructed = dwt.inverseMultiLevel(coeffs, lengths)
  
  var totalError = 0.0
  for i in 0..<min(signal.len, reconstructed.len):
    totalError += abs(signal[i] - reconstructed[i])
  
  echo fmt"Total reconstruction error: {totalError}"

proc audioAnalysisExample() =
  echo "\nAudio Analysis Example"
  echo "====================="
  
  # Simulate audio signal (440 Hz tone with harmonics)
  let sampleRate = 44100
  let duration = 1.0  # 1 second
  let N = int(float64(sampleRate) * duration)
  
  var audioSignal = newSeq[float64](N)
  for i in 0..<N:
    let t = float64(i) / float64(sampleRate)
    audioSignal[i] = sin(2.0 * PI * 440.0 * t) +         # Fundamental
                     0.5 * sin(2.0 * PI * 880.0 * t) +   # 2nd harmonic
                     0.3 * sin(2.0 * PI * 1320.0 * t) +  # 3rd harmonic
                     0.1 * sin(2.0 * PI * 1760.0 * t)    # 4th harmonic
  
  echo fmt"Audio signal: {N} samples at {sampleRate} Hz"
  
  # Analyze with wavelets
  let analysis = analyzeAudio(audioSignal, WaveletType.Daubechies4, 8)
  
  echo fmt"Analysis levels: {analysis.levels}"
  echo fmt"Energy distribution:"
  
  for i in 0..<min(8, analysis.energyDistribution.len):
    echo fmt"  Band {i:>2}: {analysis.energyDistribution[i]:>8.6f}"
  
  # Extract features
  let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
  let audioAnalysis = analyzer.analyze(audioSignal, 6)
  let features = extractFeatures(audioAnalysis)
  
  echo fmt"Extracted features: {features}"

proc denoisingExample() =
  echo "\nDenoising Example"
  echo "================="
  
  # Create clean signal
  let N = 1024
  var cleanSignal = newSeq[float64](N)
  for i in 0..<N:
    cleanSignal[i] = sin(2.0 * PI * 50.0 * float64(i) / float64(N))
  
  # Add noise
  var noisySignal = newSeq[float64](N)
  for i in 0..<N:
    noisySignal[i] = cleanSignal[i] + 0.3 * sin(2.0 * PI * 200.0 * float64(i) / float64(N))
  
  # Compute SNR before denoising
  var signalPower = 0.0
  var noisePower = 0.0
  for i in 0..<N:
    signalPower += cleanSignal[i] * cleanSignal[i]
    let noise = noisySignal[i] - cleanSignal[i]
    noisePower += noise * noise
  
  let snrBefore = 10.0 * log10(signalPower / noisePower)
  echo fmt"SNR before denoising: {snrBefore:>6.2f} dB"
  
  # Denoise
  let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
  let denoised = analyzer.denoise(noisySignal, 0.1, 6)
  
  # Compute SNR after denoising
  var denoisedNoisePower = 0.0
  for i in 0..<min(N, denoised.len):
    let noise = denoised[i] - cleanSignal[i]
    denoisedNoisePower += noise * noise
  
  let snrAfter = 10.0 * log10(signalPower / denoisedNoisePower)
  echo fmt"SNR after denoising:  {snrAfter:>6.2f} dB"
  echo fmt"SNR improvement:      {snrAfter - snrBefore:>6.2f} dB"

proc waveletComparisonExample() =
  echo "\nWavelet Comparison Example"
  echo "========================="
  
  # Create test signal with sharp transitions
  let N = 256
  var signal = newSeq[float64](N)
  for i in 0..<N:
    if i < N div 4:
      signal[i] = 1.0
    elif i < N div 2:
      signal[i] = -1.0
    elif i < 3 * N div 4:
      signal[i] = 1.0
    else:
      signal[i] = -1.0
  
  let wavelets = @[WaveletType.Haar, WaveletType.Daubechies4, WaveletType.Daubechies8]
  
  for waveletType in wavelets:
    echo fmt"\n{waveletType} Wavelet:"
    let dwt = newDWT(waveletType)
    let (coeffs, lengths) = dwt.forwardMultiLevel(signal, 4)
    
    # Compute compression ratio (non-zero coefficients)
    var nonZeroCoeffs = 0
    for coeff in coeffs:
      if abs(coeff) > 1e-10:
        nonZeroCoeffs += 1
    
    let compressionRatio = float64(coeffs.len) / float64(nonZeroCoeffs)
    echo fmt"  Non-zero coefficients: {nonZeroCoeffs}/{coeffs.len}"
    echo fmt"  Compression ratio: {compressionRatio:>6.2f}"
    
    # Reconstruction error
    let reconstructed = dwt.inverseMultiLevel(coeffs, lengths)
    var mse = 0.0
    for i in 0..<min(signal.len, reconstructed.len):
      let error = signal[i] - reconstructed[i]
      mse += error * error
    mse /= float64(signal.len)
    
    echo fmt"  MSE: {mse:>12.8f}"

when isMainModule:
  basicDWTExample()
  multiLevelExample()
  audioAnalysisExample()
  denoisingExample()
  waveletComparisonExample()

