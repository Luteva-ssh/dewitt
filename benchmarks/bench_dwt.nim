## Performance benchmarks for DWT implementation

import times, math, sequtils, strformat
import ../src/wavelet/[dwt_core, wavelets, audio_utils]

proc benchmarkDWT() =
  echo "DWT Performance Benchmarks"
  echo "=========================="
  
  let sizes = @[256, 512, 1024, 2048, 4096, 8192]
  let wavelets = @[WaveletType.Haar, WaveletType.Daubechies4, WaveletType.Daubechies8]
  
  for waveletType in wavelets:
    echo fmt"\n{waveletType} Wavelet:"
    let dwt = DWT(waveletType: waveletType)
    dwt.initializeWavelet()
    
    for size in sizes:
      # Generate test signal
      var signal = newSeq[float64](size)
      for i in 0..<size:
        signal[i] = sin(2.0 * PI * 10.0 * float64(i) / float64(size)) + 
                    0.5 * sin(2.0 * PI * 25.0 * float64(i) / float64(size))
      
      # Benchmark forward transform
      let startTime = cpuTime()
      let iterations = 100
      
      for _ in 0..<iterations:
        let (coeffs, lengths) = dwt.forward(signal)
        
      let endTime = cpuTime()
      let avgTime = (endTime - startTime) / float64(iterations)
      
      echo fmt"  Size {size:>4}: {avgTime*1000:>8.3f} ms per transform"

proc benchmarkMultiLevel() =
  echo "\nMulti-level DWT Benchmarks"
  echo "========================="
  
  let size = 4096
  let levels = @[3, 4, 5, 6, 7]
  let dwt = DWT(waveletType: WaveletType.Daubechies4)
  dwt.initializeWavelet()
  
  # Generate test signal
  var signal = newSeq[float64](size)
  for i in 0..<size:
    signal[i] = sin(2.0 * PI * 10.0 * float64(i) / float64(size)) + 
                0.3 * sin(2.0 * PI * 30.0 * float64(i) / float64(size)) +
                0.1 * sin(2.0 * PI * 80.0 * float64(i) / float64(size))
  
  for level in levels:
    let startTime = cpuTime()
    let iterations = 50
    
    for _ in 0..<iterations:
      let (coeffs, lengths) = dwt.forwardMultiLevel(signal, level)
      
    let endTime = cpuTime()
    let avgTime = (endTime - startTime) / float64(iterations)
    
    echo fmt"  {level} levels: {avgTime*1000:>8.3f} ms per transform"

proc benchmarkAudioAnalysis() =
  echo "\nAudio Analysis Benchmarks"
  echo "========================"
  
  let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
  let sizes = @[1024, 2048, 4096, 8192]
  
  for size in sizes:
    # Generate complex audio signal
    var signal = newSeq[float64](size)
    for i in 0..<size:
      signal[i] = sin(2.0 * PI * 440.0 * float64(i) / 44100.0) +
                  0.5 * sin(2.0 * PI * 880.0 * float64(i) / 44100.0) +
                  0.3 * sin(2.0 * PI * 1760.0 * float64(i) / 44100.0)
    
    let startTime = cpuTime()
    let iterations = 50
    
    for _ in 0..<iterations:
      let analysis = analyzer.analyze(signal, 6)
      
    let endTime = cpuTime()
    let avgTime = (endTime - startTime) / float64(iterations)
    
    echo fmt"  Size {size:>4}: {avgTime*1000:>8.3f} ms per analysis"

proc benchmarkDenoising() =
  echo "\nDenoising Benchmarks"
  echo "==================="
  
  let analyzer = newAudioAnalyzer(WaveletType.Daubechies4)
  let size = 4096
  
  # Generate noisy signal
  var signal = newSeq[float64](size)
  for i in 0..<size:
    signal[i] = sin(2.0 * PI * 440.0 * float64(i) / 44100.0) +
                0.1 * sin(2.0 * PI * 5000.0 * float64(i) / 44100.0)  # High freq noise
  
  let startTime = cpuTime()
  let iterations = 20
  
  for _ in 0..<iterations:
    let denoised = analyzer.denoise(signal, 0.05, 6)
    
  let endTime = cpuTime()
  let avgTime = (endTime - startTime) / float64(iterations)
  
  echo fmt"  Denoising: {avgTime*1000:>8.3f} ms per operation"

when isMainModule:
  benchmarkDWT()
  benchmarkMultiLevel()
  benchmarkAudioAnalysis()
  benchmarkDenoising()

