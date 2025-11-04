use crate::*;

pub(crate) const TMPL_TODAY: &'static str = include_str!("../assets/note-templates/today.md.tmpl");
pub(crate) const TMPL_IDEA: &'static str = include_str!("../assets/note-templates/idea.md.tmpl");
pub(crate) const TMPL_TODO: &'static str = include_str!("../assets/note-templates/todo.md.tmpl");
pub(crate) const TMPL_PLAN: &'static str = include_str!("../assets/note-templates/plan.md.tmpl");
pub(crate) const TMPL_PLAN_TOPIC: &'static str = include_str!("../assets/note-templates/plan-topic.md.tmpl");

impl NoteType {
    pub fn default_template_str(&self) -> &'static str {
        match self {
            NoteType::Today(_) => TMPL_TODAY,
            NoteType::Idea(_) => TMPL_IDEA,
            NoteType::Todo(_) => TMPL_TODO,
            NoteType::Plan(topic) => if topic.is_some() {
                TMPL_PLAN_TOPIC
            } else {
                TMPL_PLAN
            },
        }
    }
}

pub fn render_template_str(tmpl: &str, vars: Vec<(&'static str, Cow<'_, str>)>) -> String {
    let mut output = tmpl.to_string();
    for (var, value) in vars {
        output = output.replace(&format!("{{{{{var}}}}}"), &value);
    }

    output
}

pub fn build_template_vars<'c>(date: &Date, topic: Option<&'c str>) -> Vec<(&'static str, Cow<'c, str>)> {
    Vec::from([
        ("long-date", Cow::Owned(date.display(DateTimeFormat::Long).to_string())),
        ("date", Cow::Owned(date.display(DateTimeFormat::YmdDash).to_string())),
        ("topic", Cow::Borrowed(topic.unwrap_or_default()))
    ])
}
