# execve error

This very short program exhibits a regression in Rust nightly (definitely on `1.32.0-nightly (15d770400 2018-11-06)`, I think starting on `8b096314a 2018-11-02`).

On versions prior to that, it did not produce any error.

## Stable output:

```sh
$ strace -e trace=execve ./target/debug/rust-repro-execve 
execve("./target/debug/rust-repro-execve", ["./target/debug/rust-repro-execve"], 0x7ffe0a95c200 /* 104 vars */) = 0
execve("/bin/true", ["true"], 0x7fedf1821010 /* 0 vars */) = 0
+++ exited with 0 +++
```

## nightly 2018-11-06 output:

```sh
$ strace -e trace=execve ./target/debug/rust-repro-execve 
execve("./target/debug/rust-repro-execve", ["./target/debug/rust-repro-execve"], 0x7ffd4502b190 /* 104 vars */) = 0
execve("true", ["true"], 0x561a58edbb80 /* 0 vars */) = -1 ENOENT (No such file or directory)
error: No such file or directory (os error 2)
+++ exited with 0 +++
```
