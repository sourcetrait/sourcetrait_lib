use std::path::{Path, PathBuf};
use derive_builder as builder;
use tomlx::{FromToml, ToStarterToml, ToToml};
use crate::*;

pub const NOTES_DIR_NAME: &'static str = "notes";

const EDITOR_CMD: &'static str ="$EDITOR";

#[derive(Debug, builder::Builder, Clone, serde::Serialize, serde::Deserialize)]
pub struct NoteConfig {
    /// should default to ~/Documents/notes equivalent on OS
    notes_dir: PathBuf,
    editor: String,
}

#[derive(Default, Debug, Clone, serde::Serialize, serde::Deserialize, builder::Builder)]
#[builder(default)]
pub struct NoteConfigInput {
    /// defaults to ~/Documents/notes equivalent on OS
    notes_dir: Option<PathBuf>,
    /// defaults to $EDITOR
    editor: Option<String>,
}

impl NoteConfigInput {
    pub fn builder() -> NoteConfigInputBuilder {
        NoteConfigInputBuilder::default()
    }
}

impl FromToml for NoteConfigInput {}

impl NoteConfig {
    pub fn builder() -> NoteConfigBuilder {
        NoteConfigBuilder::create_empty()
    }

    pub fn from_input(
        input: NoteConfigInput,
        user_documents_dir: PathBuf
    ) -> Self
    {
        Self {
            notes_dir: input.notes_dir
                .unwrap_or_else(|| user_documents_dir.join(NOTES_DIR_NAME)),
            editor: input.editor
                .unwrap_or_else(|| EDITOR_CMD.to_string()),
        }
    }

    pub fn notes_dir(&self) -> &Path {
        &self.notes_dir
    }

    pub fn editor(&self) -> &str {
        &self.editor
    }
}

impl FromToml for NoteConfig {}
impl ToToml for NoteConfig {}
impl ToStarterToml for NoteConfig {}
