# wavelet_audio.nimble
version       = "0.1.0"
author        = "Janni Adamski"
description   = "Discrete Wavelet Transform (DWT - here 'dewitt') for Audio Analysis"
license       = "MIT"
srcDir        = "src"
bin           = @["dewitt"]
binDir        = "bin"

# Dependencies
requires "nim >= 1.6.0"

# Tasks
task test, "Run tests":
  exec "nim c -r tests/test_dwt.nim"
  exec "nim c -r tests/test_audio.nim"

task docs, "Generate documentation":
  exec "nim doc --project --index:on --git.url:https://github.com/Luteva-ssh/dewitt --git.commit:main --outdir:docs src/dewitt.nim"

task benchmark, "Run benchmarks":
  exec "nim c -d:release -r benchmarks/bench_dwt.nim"

