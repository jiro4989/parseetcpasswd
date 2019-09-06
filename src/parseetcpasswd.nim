import strutils
from strformat import `&`

const
  etcPasswdPath* = "/etc/passwd"

type
  Passwd* = ref PasswdObj
  PasswdObj* = object
    userName*: string
    password*: string
    uid*: int
    gid*: int
    comment*: string
    homeDir*: string
    loginShell*: string

proc `$`*(p: Passwd): string

template parseEtcPasswdTmpl(content: string, passwd: Passwd, body: untyped) =
  for line in content.splitLines:
    # ignore comment line
    if line.startsWith("#"):
      continue

    let cols = line.split(":")
    if cols.len < 7:
      echo line, " is illegal."
      continue

    passwd = Passwd(
      userName: cols[0],
      password: cols[1],
      uid: cols[2].parseInt,
      gid: cols[3].parseInt,
      comment: cols[4],
      homeDir: cols[5],
      loginShell: cols[6],
    )
    body

proc parseEtcPasswd*(content: string): seq[Passwd] =
  ## Returns passwd objects from string.
  runnableExamples:
    let p = parseEtcPasswd("user1234:x:1000:1000:user1234:/home/user1234:/usr/bin/zsh")
    doAssert p[0][] == Passwd(
      userName: "user1234",
      password: "x",
      uid: 1000,
      gid: 1000,
      comment: "user1234",
      homeDir: "/home/user1234",
      loginShell: "/usr/bin/zsh",
    )[]

  var passwd: Passwd
  content.parseEtcPasswdTmpl(passwd):
    result.add(passwd)

proc readEtcPasswdFile*(filename: string): seq[Passwd] =
  ## Returns passwd objects from file.
  runnableExamples:
    let p = readEtcPasswdFile("tests/in/passwd")
    doAssert p[0][] == Passwd(
      userName: "root",
      password: "x",
      uid: 0,
      gid: 0,
      comment: "",
      homeDir: "/root",
      loginShell: "/usr/bin/zsh",
    )[]
    doAssert p[1][] == Passwd(
      userName: "user1234",
      password: "x",
      uid: 1000,
      gid: 1000,
      comment: "user1234",
      homeDir: "/home/user1234",
      loginShell: "/usr/bin/zsh",
    )[]

  result = readFile(filename).parseEtcPasswd

proc writeEtcPasswd*(filename: string, passwds: varargs[Passwd]) =
  ## Writes to `filename` file from passwd objects.
  runnableExamples:
    let p = Passwd(
      userName: "user1234",
      password: "x",
      uid: 1000,
      gid: 1000,
      comment: "user1234",
      homeDir: "/home/user1234",
      loginShell: "/usr/bin/zsh",
    )
    writeEtcPasswd("tests/out/write_etc_passwd_1.passwd", p)

  var lines: seq[string]
  for passwd in passwds:
    lines.add($passwd)
  let content = lines.join("\n")
  writeFile(filename, content)

proc lookupEtcPasswdWithUid*(uid: int, content: string): Passwd =
  ## Lookups passwd string with uid.
  runnableExamples:
    let content =
      "root:x:0:0::/root:/usr/bin/zsh\n" &
      "user1234:x:1000:1000:user1234:/home/user1234:/usr/bin/zsh"
    let p = lookupEtcPasswdWithUid(1000, content)
    doAssert p[] == Passwd(
      userName: "user1234",
      password: "x",
      uid: 1000,
      gid: 1000,
      comment: "user1234",
      homeDir: "/home/user1234",
      loginShell: "/usr/bin/zsh",
    )[]

  var passwd: Passwd
  content.parseEtcPasswdTmpl(passwd):
    if passwd.uid == uid:
      return passwd

proc lookupEtcPasswdFileWithUid*(uid: int, filename: string): Passwd =
  ## Lookups passwd file with uid.
  runnableExamples:
    let p = lookupEtcPasswdFileWithUid(1001, "tests/in/passwd")
    doAssert p[] == Passwd(
      userName: "user2222",
      password: "x",
      uid: 1001,
      gid: 1002,
      comment: "comment",
      homeDir: "/home/user2222",
      loginShell: "/usr/bin/zsh",
    )[]

  lookupEtcPasswdWithUid(uid, readFile(filename))

proc lookupEtcPasswdWithGid*(gid: int, content: string): Passwd =
  ## Lookups passwd string with gid.
  runnableExamples:
    let content =
      "root:x:0:0::/root:/usr/bin/zsh\n" &
      "user2222:x:1001:1002:comment:/home/user2222:/usr/bin/zsh"
    let p = lookupEtcPasswdWithGid(1002, content)
    doAssert p[] == Passwd(
      userName: "user2222",
      password: "x",
      uid: 1001,
      gid: 1002,
      comment: "comment",
      homeDir: "/home/user2222",
      loginShell: "/usr/bin/zsh",
    )[]

  var passwd: Passwd
  content.parseEtcPasswdTmpl(passwd):
    if passwd.gid == gid:
      return passwd

proc lookupEtcPasswdFileWithGid*(gid: int, filename: string): Passwd =
  ## Lookups passwd file with gid.
  runnableExamples:
    let p = lookupEtcPasswdFileWithGid(1002, "tests/in/passwd")
    doAssert p[] == Passwd(
      userName: "user2222",
      password: "x",
      uid: 1001,
      gid: 1002,
      comment: "comment",
      homeDir: "/home/user2222",
      loginShell: "/usr/bin/zsh",
    )[]

  lookupEtcPasswdWithGid(gid, readFile(filename))

proc `$`*(p: Passwd): string =
  runnableExamples:
    let p = readEtcPasswdFile("tests/in/passwd")
    doAssert $p[1] == "user1234:x:1000:1000:user1234:/home/user1234:/usr/bin/zsh"

  result = &"{p.userName}:{p.password}:{p.uid}:{p.gid}:{p.comment}:{p.homeDir}:{p.loginShell}"