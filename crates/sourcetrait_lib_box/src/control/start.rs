use crate::*;

/// Options to start a container
#[derive(Debug)]
pub struct StartOptions {
    /// Container name
    pub name: String,
}

pub fn start(opts: StartOptions) -> BoxResult<()> {
    match is_running(IsRunningOptions::Container{ name: opts.name.clone() })? {
        IsRunning::NotRunning => {},
        IsRunning::Running => return Ok(()),
        IsRunning::NotFound => return Err(BoxError::ContainerNotFound {
            container: opts.name,
        }),
    }
    
    let mut cmd = Command::new(PODMAN);
    cmd.stdout(process::Stdio::null());
    cmd.args(&["start", opts.name.as_str()]);
    match cmd.status() {
        Ok(exit) if exit.success() => Ok(()), 
        Ok(exit) => Err(BoxError::Command {
            code: exit.code(),
            err: CommandErr::StartContainer { name: opts.name },
        }),
        Err(source) => Err(BoxError::ExecuteCommand {
            err: CommandErr::StartContainer { name: opts.name },
            source,
        }),
    }
}