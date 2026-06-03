use crate::*;

pub type NoteResult<T> = std::result::Result<T, NoteError>;

#[derive(Debug, snafu::Snafu)]
pub enum NoteError {
    FileIO {
        err: stdx::error::fs::FsErrMsg,
        noun: FileNoun,
        path: PathBuf,
        source: io::Error,
    },
    #[error("{0}")]
    ParseToml(String, #[source] toml::de::Error),
    #[error("{0}")]
    Exec(String, #[source] std::io::Error),
    #[error("{0} :: {1}")]
    Cmd(String, String),
    #[snafu(display("Unable to parse date: {when}"))]
    When {
        when: String
    },
    #[error("No daily notes for: {}", .0.display(DateTimeFormat::YmdDash))]
    NoDayNotes(Date),
    #[error("{0}")]
    InvalidNote(String)
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FileNoun {
    Note,
    NoteDir,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NoteInvalid {
    NotFound,
    KindUndetermined,
    KindUnknown,
    NotMarkdown,
}
