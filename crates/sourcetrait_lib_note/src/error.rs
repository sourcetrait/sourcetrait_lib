use crate::*;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("{0}")]
    Io(String, #[source] std::io::Error),
    #[error("{0}")]
    ParseToml(String, #[source] toml::de::Error),
    #[error("{0}")]
    Exec(String, #[source] std::io::Error),
    #[error("{0} :: {1}")]
    Cmd(String, String),
    #[error("Unable to parse date: {0}")]
    Date(String),
    #[error("No daily notes for: {}", .0.display(DateTimeFormat::YmdDash))]
    NoDayNotes(Date),
    #[error("{0}")]
    InvalidNote(String)
}

pub type Result<T> = std::result::Result<T, Error>;
