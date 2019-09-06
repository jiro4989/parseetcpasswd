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

