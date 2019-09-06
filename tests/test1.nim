import unittest

import parseetcpasswd

const
  testFile1 = "tests/in/passwd"

let
  passwd1 =
    Passwd(
      userName: "root",
      password: "x",
      uid: 0,
      gid: 0,
      comment: "",
      homeDir: "/root",
      loginShell: "/usr/bin/zsh",
    )[]
  passwd2 =
    Passwd(
      userName: "user1234",
      password: "x",
      uid: 1000,
      gid: 1000,
      comment: "user1234",
      homeDir: "/home/user1234",
      loginShell: "/usr/bin/zsh",
    )[]

suite "func parseEtcPasswd":
  setup:
    let data = readFile(testFile1)
  test "Parse string":
    check data.parseEtcPasswd[0][] == passwd1
    check data.parseEtcPasswd[1][] == passwd2

suite "func readEtcPasswdFile":
  test "Read file":
    check testFile1.readEtcPasswdFile[0][] == passwd1
    check testFile1.readEtcPasswdFile[1][] == passwd2
