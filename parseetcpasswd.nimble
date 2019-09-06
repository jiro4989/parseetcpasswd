# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
packageName   = "parseetcpasswd"

# Dependencies

requires "nim >= 0.20.2"

import strformat

task docs, "Generate documents":
  exec &"nimble doc src/{packageName}.nim -o:docs/{packageName}.html"

task checkFormat, "Checking that codes were formatted":
  var errCount = 0
  for f in listFiles("src"):
    let tmpFile = f & ".tmp"
    exec &"nimpretty --output:{tmpFile} {f}"
    if readFile(f) != readFile(tmpFile):
      inc errCount
    rmFile tmpFile
  exec &"exit {errCount}"

task ci, "Run CI":
  exec "nim -v"
  exec "nimble -v"
  exec "nimble check"
  exec "nimble checkFormat"
  exec "nimble install -Y"
  exec "nimble test -Y"
  exec "nimble docs -Y"
