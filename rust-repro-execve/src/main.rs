use std::process::Command;
use std::os::unix::process::CommandExt;

fn main() {
    let mut cmd = Command::new("true");
    cmd.env_clear();
    let err = cmd.exec();
    println!("error: {}", err);
}
