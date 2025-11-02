# Package

version = "0.1.0"
author = "CubixIII"
description = "The modular maze"
license = "?"

# Deps
requires "nim >= 1.2.0"
requires "nico >= 0.2.5"
requires "neo >= 0.3.0"

srcDir = "src"

task runr, "Runs polycore for current platform":
 exec "nim c -r -d:release --outdir:.. -o:polycore src/main.nim"

task rund, "Runs debug polycore for current platform":
 exec "nim c -r -d:debug --outdir:.. -o:polycore src/main.nim"

task release, "Builds polycore for current platform":
 exec "nim c -d:release --outdir:.. -o:polycore src/main.nim"

task debug, "Builds debug polycore for current platform":
 exec "nim c -d:debug --outdir:.. -o:polycore_debug src/main.nim"

task web, "Builds polycore for current web":
 exec "nim js -d:release --outdir:.. -o:polycore.js src/main.nim"

task webd, "Builds debug polycore for current web":
 exec "nim js -d:debug --outdir:.. -o:polycore.js src/main.nim"

task deps, "Downloads dependencies":
 exec "curl https://www.libsdl.org/release/SDL2-2.0.12-win32-x64.zip -o SDL2_x64.zip"
 exec "unzip SDL2_x64.zip"
 #exec "curl https://www.libsdl.org/release/SDL2-2.0.12-win32-x86.zip -o SDL2_x86.zip"
