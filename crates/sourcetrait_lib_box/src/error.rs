use crate::*;

#[derive(Debug, snafu::Snafu)]
pub enum BoxError {
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
    Ssh {
        container: String,
        source: io::Error,
    },
}

#[derive(Debug)]
pub enum ParseConfigErr {
    Json(json::Error),
    MissingLabel,
}

pub type BoxResult<T> = Result<T, BoxError>;