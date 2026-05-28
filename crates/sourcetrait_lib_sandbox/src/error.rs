use crate::*;

pub type SandboxResult<T> = Result<T, SandboxError>;

#[derive(Debug, snafu::Snafu)]
pub enum SandboxError {
    ParseSource {
        src: String,
        source: r::oci::ParseError,
    },
    PullManifest {
        src: String,
        source: r::oci::DistributionError,
    },
    ParseOciConfig {
        src: String,
        err: ParseConfigErr,
    },
    PullImage {
        src: String,
        code: i32,
    },
    PodmanInfo {
        src: String,
        code: i32,
    },
    ContainerNotFound { container: String },
    Command {
        code: Option<i32>,
        err: CommandErr,
    },
    ExecuteCommand {
        source: io::Error,
        err: CommandErr,
    },
}

#[derive(Debug, Clone, PartialEq, Eq, snafu::Snafu)]
pub enum CommandErr {
    StartContainer {
        name: String,
    },
    Ssh {
        container: String,
    },
}

#[derive(Debug)]
pub enum ParseConfigErr {
    Json(json::Error),
    MissingLabel,
}


impl From<SandboxError> for snafu::Whatever {
    fn from(value: SandboxError) -> Self {
        todo!()
    }
}
