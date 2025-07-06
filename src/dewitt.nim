## Discrete Wavelet Transform for Audio Analysis
## 
## This module provides a comprehensive implementation of DWT algorithms
## optimized for audio signal processing and analysis.

import math, sequtils, algorithm
import wavelet_audio/[wavelets, dwt_core, audio_utils]

export wavelets, dwt_core, audio_utils

# Main entry point and convenience functions
proc newDWT*(waveletType: WaveletType): DWT =
  ## Create a new DWT instance with specified wavelet
  result = DWT(waveletType: waveletType)
  result.initializeWavelet()

proc analyzeAudio*(samples: seq[float64], waveletType: WaveletType = WaveletType.Daubechies4, 
                   levels: int = 5): AudioAnalysis =
  ## High-level audio analysis function
  let analyzer = newAudioAnalyzer(waveletType)
  result = analyzer.analyze(samples, levels)

when isMainModule:
  # Example usage
  echo "Wavelet Audio Analysis Library"
  echo "==============================="
  
  # Create test signal
  let N = 1024
  var signal = newSeq[float64](N)
  for i in 0..<N:
    signal[i] = sin(2.0 * PI * 10.0 * float64(i) / float64(N)) + 
                0.5 * sin(2.0 * PI * 25.0 * float64(i) / float64(N))
  
  # Perform DWT analysis
  let analysis = analyzeAudio(signal, WaveletType.Daubechies4, 6)
  
  echo "Signal length: ", signal.len
  echo "Number of decomposition levels: ", analysis.levels
  echo "Energy distribution: ", analysis.energyDistribution[0..min(5, analysis.energyDistribution.high)]

