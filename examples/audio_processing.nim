## Advanced audio processing examples

import math, sequtils, strformat
import ../src/dewitt

proc spectralAnalysisExample() =
  echo "Spectral Analysis with Wavelets"
  echo "==============================="
  
  # Create a signal with multiple frequency components
  let sampleRate = 44100
  let duration = 2.0
  let N = int(float64(sampleRate) * duration)
  
  var signal = newSeq[float64](N)
  for i in 0..<N:
    let t = float64(i) / float64(sampleRate)
    signal[i] = sin(2.0 * PI * 261.63 * t) +      # C4
                0.8 * sin(2.0 * PI * 329.63 * t) + # E4
                0.6 * sin(2.0 * PI * 392.00 * t)   # G4 (C major chord)
  
  # Apply windowing
  let windowedSignal = applyWindow(signal, WindowType.Hanning)
  
  # Analyze with different wavelets
  let wavelets = @[WaveletType.Haar, WaveletType.Daubechies4, WaveletType.Daubechies8]
  
  for waveletType in wavelets:
    echo fmt"\nAnalysis with {waveletType}:"
    let analyzer = newAudioAnalyzer(waveletType)
    let analysis = analyzer.analyze(windowedSignal, 8)
    
    echo fmt"  Energy distribution (first 6 bands):"
    for i in 0..<min(6, analysis.energyDistribution.len):
      echo fmt"    Band {i}: {analysis.energyDistribution[i]:>8.6f}"
    
    let features = extractFeatures(analysis)
    echo fmt"  Features: {features[0..min(4, features.high)]}"

proc adaptiveFilteringExample() =
  echo "\nAdaptive Filtering Example"
  echo "========================="
  
  # Create signal with time-varying noise
  let N = 2048
  var cleanSignal = newSeq[float64](N)
  var noisySignal = newSeq[float64](N)
  
  for i in 0..<N:
    let t = float64(i) / float64(N)
    cleanSignal[i] = sin(2.0 * PI * 20.0 * t)
    
    # Time-varying noise
    let noiseAmp = 0.1 + 0.2 * t  # Noise increases over time
    let noise = noiseAmp * sin(2.0 * PI * 100.0 * t)
    noisySignal[i] = cleanSignal[i] + noise
  
  # Analyze noise characteristics
  let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
  let noiseAnalysis = analyzer.analyze(noisySignal, 6)
  
  # Adaptive threshold based on energy distribution
  let highFreqEnergy = noiseAnalysis.energyDistribution[1..^1].sum()
  let adaptiveThreshold = 0.1 * sqrt(highFreqEnergy)
  
  echo fmt"High frequency energy: {highFreqEnergy:>8.6f}"
  echo fmt"Adaptive threshold: {adaptiveThreshold:>8.6f}"
  
  # Apply adaptive denoising
  let denoised = analyzer.denoise(noisySignal, adaptiveThreshold, 6)
  
  # Compare results
  var originalMSE = 0.0
  var denoisedMSE = 0.0
  
  for i in 0..<min(N, denoised.len):
    let origError = noisySignal[i] - cleanSignal[i]
    let denoisedError = denoised[i] - cleanSignal[i]
    originalMSE += origError * origError
    denoisedMSE += denoisedError * denoisedError
  
  originalMSE /= float64(N)
  denoisedMSE /= float64(N)
  
  echo fmt"Original MSE: {originalMSE:>10.8f}"
  echo fmt"Denoised MSE: {denoisedMSE:>10.8f}"
  echo fmt"Improvement: {originalMSE / denoisedMSE:>6.2f}x"

proc musicAnalysisExample() =
  echo "\nMusic Analysis Example"
  echo "====================="
  
  # Simulate a musical phrase with different instruments
  let sampleRate = 44100
  let noteLength = sampleRate div 4  # Quarter note
  let totalSamples = noteLength * 8
  
  var musicSignal = newSeq[float64](totalSamples)
  
  # Piano-like attack (sharp onset, exponential decay)
  proc pianoNote(freq: float64, startSample: int, length: int) =
    for i in 0..<length:
      if startSample + i < totalSamples:
        let t = float64(i) / float64(sampleRate)
        let envelope = exp(-3.0 * t)  # Exponential decay
        let harmonics = sin(2.0 * PI * freq * t) +
                       0.5 * sin(2.0 * PI * freq * 2.0 * t) +
                       0.3 * sin(2.0 * PI * freq * 3.0 * t)
        musicSignal[startSample + i] += envelope * harmonics
  
  # Add notes: C-E-G-C progression
  pianoNote(261.63, 0, noteLength)          # C4
  pianoNote(329.63, noteLength, noteLength)  # E4
  pianoNote(392.00, noteLength * 2, noteLength)  # G4
  pianoNote(523.25, noteLength * 3, noteLength)  # C5
  
  # Repeat with different timing
  pianoNote(261.63, noteLength * 4, noteLength div 2)
  pianoNote(329.63, noteLength * 4 + noteLength div 2, noteLength div 2)
  pianoNote(392.00, noteLength * 5, noteLength div 2)
  pianoNote(523.25, noteLength * 5 + noteLength div 2, noteLength div 2)
  
  # Analyze musical structure
  let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
  
  # Segment-wise analysis
  let segmentLength = noteLength
  let numSegments = totalSamples div segmentLength
  
  echo fmt"Analyzing {numSegments} segments of {segmentLength} samples each"
  
  for segment in 0..<numSegments:
    let startIdx = segment * segmentLength
    let endIdx = min(startIdx + segmentLength, totalSamples)
    let segmentSignal = musicSignal[startIdx..<endIdx]
    
    if segmentSignal.len > 0:
      let analysis = analyzer.analyze(segmentSignal, 5)
      let features = extractFeatures(analysis)
      
      echo fmt"Segment {segment + 1}:"
      echo fmt"  Spectral centroid: {features[3]:>8.4f}"
      echo fmt"  Spectral entropy:  {features[4]:>8.4f}"
      echo fmt"  Low freq energy:   {features[1]:>8.4f}"

proc realTimeSimulation() =
  echo "\nReal-time Processing Simulation"
  echo "==============================="
  
  # Simulate real-time processing with overlapping windows
  let sampleRate = 44100
  let windowSize = 1024
  let hopSize = windowSize div 2
  let totalSamples = sampleRate * 2  # 2 seconds
  
  # Create continuous signal
  var continuousSignal = newSeq[float64](totalSamples)
  for i in 0..<totalSamples:
    let t = float64(i) / float64(sampleRate)
    continuousSignal[i] = sin(2.0 * PI * 440.0 * t) +
                         0.1 * sin(2.0 * PI * 2000.0 * t)  # Signal + noise
  
  let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
  var processedSignal = newSeq[float64](totalSamples)
  
  # Process overlapping windows
  let numWindows = (totalSamples - windowSize) div hopSize + 1
  echo fmt"Processing {numWindows} overlapping windows"
  
  var avgProcessingTime = 0.0
  
  for window in 0..<numWindows:
    let startIdx = window * hopSize
    let endIdx = min(startIdx + windowSize, totalSamples)
    
    if endIdx - startIdx == windowSize:
      let windowSignal = continuousSignal[startIdx..<endIdx]
      
      # Simulate processing time measurement
      let startTime = cpuTime()
      let denoised = analyzer.denoise(windowSignal, 0.05, 4)
      let endTime = cpuTime()
      
      avgProcessingTime += endTime - startTime
      
      # Overlap-add reconstruction
      for i in 0..<denoised.len:
        if startIdx + i < totalSamples:
          processedSignal[startIdx + i] += denoised[i] * 0.5  # Overlap factor
  
  avgProcessingTime /= float64(numWindows)
  
  echo fmt"Average processing time per window: {avgProcessingTime * 1000:>6.2f} ms"
  echo fmt"Real-time factor: {(float64(hopSize) / float64(sampleRate)) / avgProcessingTime:>6.2f}"
  
  # Compute overall improvement
  var originalEnergy = 0.0
  var processedEnergy = 0.0
  
  for i in 0..<totalSamples:
    originalEnergy += continuousSignal[i] * continuousSignal[i]
    processedEnergy += processedSignal[i] * processedSignal[i]
  
  echo fmt"Energy reduction: {(1.0 - processedEnergy / originalEnergy) * 100:>6.2f}%"

when isMainModule:
  spectralAnalysisExample()
  adaptiveFilteringExample()
  musicAnalysisExample()
  realTimeSimulation()

