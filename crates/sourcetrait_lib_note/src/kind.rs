use crate::*;

#[derive(Debug, Clone, Copy, PartialEq, Eq,
    strum::Display, strum::IntoStaticStr, strum::AsRefStr, strum::EnumIter, strum::EnumString)]
#[strum(serialize_all = "kebab-case")]
pub enum NoteKind {
    Today,
    Idea,
    Todo,
    Plan,
}

#[derive(Debug, Clone, PartialEq, Eq, strum::Display)]
#[strum(serialize_all = "kebab-case")]
pub enum NoteType {
    Today(Date),
    Idea(String),
    Todo(String),
    Plan(Option<String>),
}

impl NoteType {
    pub fn kind(&self) -> NoteKind {
        match self {
            Self::Today(_) => NoteKind::Today,
            Self::Idea(_) => NoteKind::Idea,
            Self::Todo(_) => NoteKind::Todo,
            Self::Plan(_) => NoteKind::Plan,
        }
    }
    
    pub fn topic(&self) -> Option<&str> {
        match self {
            Self::Today(_) => None,
            Self::Idea(topic) => Some(topic),
            Self::Todo(topic) => Some(topic),
            Self::Plan(topic) => topic.as_deref(),
        }
    }
    
    pub fn date(&self) -> Option<&Date> {
        match self {
            Self::Today(date) => Some(date),
            _ => None,
        }
    }
    
    pub fn is_topical(&self) -> bool {
        match self {
            Self::Today(_) => false,
            Self::Idea(_) => true,
            Self::Todo(_) => true,
            Self::Plan(topic) => topic.is_some(),
        }
    }
    
    pub fn is_topical_optional(&self) -> bool {
        match self {
            Self::Today(_) => false,
            Self::Idea(_) => false,
            Self::Todo(_) => false,
            Self::Plan(_) => true,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Note(NoteType);

impl Note {
    pub fn new(note_type: NoteType) -> Self {
        Self (note_type)
    }
    
    pub fn from_filepath(notes_dir: &NotesDir, file: &Path) -> NoteResult<Self> {
        let dir: &Path = notes_dir;
        let relpath = file.strip_prefix(dir)
            .map_err(|_| Error::InvalidNote(format!("File is not in the notes directory: {}", file.display())))?;
        
        let mut path_components = relpath.components();
        let kind_dir_name = path_components.next()
            .ok_or_else(|| Error::InvalidNote(format!("Unexpected note type: {}", file.display())))?
            .as_os_str().to_string_lossy();
        
        let kind = NoteKind::from_str(&kind_dir_name)
            .map_err(|_| Error::InvalidNote(format!("Unable to determine note type for file path: {}", file.display())))?;
        
        if relpath.extension().is_none_or(|s| s != "md") {
            return Err(Error::InvalidNote(format!("Not a markdown file: {}", file.display())));
        }
        
        let filestem = relpath.file_stem()
            .ok_or_else(|| Error::InvalidNote(format!("Unable to determine note type for file path: {}", file.display())))?
            .to_string_lossy();
        
        let mut parts = filestem.split('-');
        let prefix = parts.next();
        let rest = parts.collect::<Vec<_>>().join("-");
        
        if prefix.is_none() || prefix.is_some_and(|s| s != kind.as_ref()) {
            return Err(Error::InvalidNote(format!("Unable to determine note type for file name: {filestem}")));
        }
        
        let note_type = match kind {
            NoteKind::Today => {
                let date = NaiveDate::parse_from_str(&rest, DateTimeFormat::YmdDash.strftime_format())
                    .map_err(|_| Error::InvalidNote(format!("Unable to determine note type for file path: {}", file.display())))?;
                
                NoteType::Today(Date(date))
            },
            NoteKind::Idea => NoteType::Idea(rest),
            NoteKind::Todo => NoteType::Todo(rest),
            NoteKind::Plan => if rest.is_empty() {
                NoteType::Plan(None)
            } else {
                NoteType::Plan(Some(rest))
            }
        };
        
        Ok(Note::new(note_type))
    }
    
    pub fn note_type(&self) -> &NoteType {
        &self.0
    }
    
    pub fn kind(&self) -> NoteKind {
        self.0.kind()
    }
    
    pub fn topic(&self) -> Option<&str> {
        self.0.topic()
    }
    
    pub fn date(&self) -> Option<&Date> {
        self.0.date()
    }
}
