use crate::*;

#[derive(Debug)]
pub struct ShellOptions {
    pub name: String,
}

pub fn shell(opts: ShellOptions) -> BoxResult<()> {
    let mut cmd = Command::new(PODMAN);
    cmd.args(&["run", "-it", BOX_IMAGE_SOURCE]);
    match cmd.status() {
        Ok(exit) if exit.success() => Ok(()), 
        Ok(exit) => Err(BoxError::PullImage { src: BOX_IMAGE_SOURCE.into(), code: exit.code().expect("code") }),
        _ => Err(BoxError::PullImage { src: BOX_IMAGE_SOURCE.into(), code: 127 }),
    }
}
