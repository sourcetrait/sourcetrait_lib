use crate::*;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum IsRunningOptions {
    /// Is the podman machine running
    Machine,
    /// Is a container running?
    Container {
        /// The name of the container
        name: String,
    },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IsRunning {
    NotRunning,
    Running,
    /// containers only
    NotFound,
}

impl IsRunning {
    pub const fn as_bool(&self) -> bool { matches!(self, Self::Running) }
    
    pub const fn from_bool(b: bool) -> Self {
        if b { Self::Running } else { Self::NotRunning }
    }
}

impl Display for IsRunning {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NotRunning => f.write_str("not running"),
            Self::Running => f.write_str("running"),
            Self::NotFound => f.write_str("not found"),
        }
    }
}

pub trait CommandExt { fn squelched_status(&mut self) -> io::Result<ExitStatus>; }
impl CommandExt for Command {
    fn squelched_status(&mut self) -> io::Result<ExitStatus> {
        self.stdout(process::Stdio::null());
        self.stdin(process::Stdio::null());
        self.stderr(process::Stdio::null());
        self.status()
    }
}

pub fn is_running(opts: IsRunningOptions) -> SandboxResult<IsRunning> {
    match opts {
        IsRunningOptions::Machine => {
            let mut cmd = Command::new(PODMAN);
            cmd.arg("info");
            match cmd.squelched_status() {
                Ok(exit) if exit.success() => Ok(IsRunning::Running), 
                Ok(_) => Ok(IsRunning::NotRunning),
                Err(e) => {
                    dbg!(e);
                    Err(SandboxError::PodmanInfo { src: BOX_IMAGE_SOURCE.into(), code: 127 })
                }
            }
        },
        IsRunningOptions::Container{ name } => {
            let mut cmd = Command::new(PODMAN);
            cmd.args(&["ps", "-q", "-f"]);
            cmd.arg(format!("name={name}"));
            match cmd.output() {
                Ok(output) => match output.status.success() {
                    true => Ok(IsRunning::from_bool({
                        !output.stdout.trim_ascii().is_empty()
                    })),
                    false => Err(SandboxError::PodmanInfo {
                        src: BOX_IMAGE_SOURCE.into(),
                        code: output.status.code().unwrap_or(127)
                    }),
                },
                _ => Err(SandboxError::PodmanInfo { src: BOX_IMAGE_SOURCE.into(), code: 127 }),
            }
        },
    }
}
