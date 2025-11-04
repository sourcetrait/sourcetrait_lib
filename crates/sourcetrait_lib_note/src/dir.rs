use std::{fs, ops::Deref, path::{Path, PathBuf}};
use strum::IntoEnumIterator;

use crate::*;

pub struct NotesDir(PathBuf);

impl Deref for NotesDir {
    type Target = Path;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl NotesDir {
    pub fn new(dir: PathBuf) -> Self {
        Self(dir)
    }

    pub fn init(&self) -> Result<()> {
        let notes_dir = &self.0;
        for kind in NoteKind::iter() {
            let dir_name: &'static str = kind.into();
            let kind_dir = notes_dir.join(dir_name);
            if !kind_dir.is_dir() {
               fs::create_dir_all(&kind_dir)
                   .map_err(|e| Error::Io(format!("Unable to create note dir: {}", kind_dir.display()), e))?;
            }
        }

        Ok(())
    }

    pub fn kind_dir(&self, kind: NoteKind) -> PathBuf {
        let dir_name: &'static str = kind.into();
        self.join(dir_name)
    }

    pub fn templates_dir(&self) -> PathBuf {
        self.join(".templates")
    }
}
