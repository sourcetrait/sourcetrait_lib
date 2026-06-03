use crate::*;

pub fn note_for_date(notes_dir: &NotesDir, note: &Note, from: Option<Date>) -> Result<PathBuf> {
    assert!(note.kind() == NoteKind::Today);
    
    let date = note.date().expect("today note date");
    let mut previous_contents = None;
    if let Some(from_date) = from {
        let from_note_dir = notes_dir
            .kind_dir(NoteKind::Today)
            .join(from_date.display(DateTimeFormat::YmSlash).to_string());

        let from_file = from_note_dir
            .join(format!("{}-{}.md",
                note.kind(),
                from_date.display(DateTimeFormat::YmdDash).to_string()));

        if !from_file.is_file() {
            return Err(Error::NoDayNotes(from_date));
        }

        let mut skip = true;
        previous_contents = Some(fs::read_to_string(&from_file)
            .map_err(|e| Error::Io(format!("Unable to read daily note file: {}", from_file.display()), e))?
            .lines()
            .filter(|l| {
                if skip {
                    if l.starts_with("---") {
                        skip = false;
                    }

                    false
                } else {
                    true
                }
            })
            .collect::<Vec<_>>()
            .join("\n"));
    }

    let note_dir = notes_dir
        .kind_dir(NoteKind::Today)
        .join(date.display(DateTimeFormat::YmSlash).to_string());

    if !note_dir.is_dir() {
        fs::create_dir_all(&note_dir)
            .map_err(|e| Error::Io(format!("Unable to create note directory: {}", note_dir.display()), e))?;
    }

    let note_file = note_dir
        .join(format!("{}-{}.md",
            note.kind(),
            date.display(DateTimeFormat::YmdDash).to_string()));

    if !note_file.is_file() {
        let vars = build_template_vars(date, None);
        let template_str = render_template_str(note.note_type().default_template_str(), vars);
        fs::write(&note_file, &template_str)
            .map_err(|e| Error::Io(format!("Unable to write note file: {}", note_file.display()), e))?;
    }

    if let Some(previous_contents) = previous_contents {
        let current = fs::read_to_string(&note_file)
            .map_err(|e| Error::Io(format!("Unable to read note file: {}", note_file.display()), e))?;
        let content = format!("{current}\n{previous_contents}");

        fs::write(&note_file, &content)
            .map_err(|e| Error::Io(format!("Unable to write note file: {}", note_file.display()), e))?;
    }
    
    Ok(note_file)
}

pub fn note_for_topic(notes_dir: &NotesDir, note: &Note) -> Result<PathBuf> {
    assert!(note.kind() != NoteKind::Today);
    let topic = note.topic().expect("topical note");
    let date = Date::now();
    let topic_title = topic.to_title_case();
    let topic = topic.to_kebab_case();
    
    let note_dir = notes_dir.kind_dir(note.kind());

    if !note_dir.is_dir() {
        fs::create_dir_all(&note_dir)
            .map_err(|e| Error::Io(format!("Unable to create note directory: {}", note_dir.display()), e))?;
    }

    let note_file = note_dir
        .join(format!("{}-{topic}.md", note.kind()).to_string());

    if !note_file.is_file() {
        let vars = build_template_vars(&date, Some(&topic_title));
        let template_str = render_template_str(note.note_type().default_template_str(), vars);
        fs::write(&note_file, &template_str)
            .map_err(|e| Error::Io(format!("Unable to write note file: {}", note_file.display()), e))?;
    }

    Ok(note_file)
}

pub fn note_for_optional_topic(notes_dir: &NotesDir, note: &Note) -> Result<PathBuf> {
    assert!(note.note_type().is_topical_optional());
    
    if note.topic().is_some() {
        return note_for_topic(notes_dir, note);
    }
        
    let note_dir = notes_dir.kind_dir(note.kind());

    if !note_dir.is_dir() {
        fs::create_dir_all(&note_dir)
            .map_err(|e| Error::Io(format!("Unable to create note directory: {}", note_dir.display()), e))?;
    }

    let note_file = note_dir.join(format!("{}.md", note.kind()));

    if !note_file.is_file() {
        let date = Date::now();
        let vars = build_template_vars(&date, None);
        let template_str = render_template_str(note.note_type().default_template_str(), vars);
        fs::write(&note_file, &template_str)
            .map_err(|e| Error::Io(format!("Unable to write note file: {}", note_file.display()), e))?;
    }

    Ok(note_file)
}