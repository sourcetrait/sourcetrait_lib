use crate::*;

#[derive(Debug)]
pub struct PullOptions {
    pub source: String,
}

pub fn pull(opts: PullOptions) -> SandboxResult<()> {
    match opts.source.as_str() {
        BOX_IMAGE_ALIAS | BOX_IMAGE_SOURCE => return pull_box(),
        _ => {}
    }
    
    todo!()
}

pub fn pull_box() -> SandboxResult<()> {
    let mut cmd = Command::new(PODMAN);
    cmd.args(&["pull", BOX_IMAGE_SOURCE]);
    match cmd.status() {
        Ok(exit) if exit.success() => Ok(()), 
        Ok(exit) => Err(SandboxError::PullImage { src: BOX_IMAGE_SOURCE.into(), code: exit.code().expect("code") }),
        _ => Err(SandboxError::PullImage { src: BOX_IMAGE_SOURCE.into(), code: 127 }),
    }
}