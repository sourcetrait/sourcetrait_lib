use crate::*;

#[derive(Debug)]
pub struct SshOptions {
    pub container: String,
}

impl SshOptions {
    pub const DEFAULT_PORT: u16 = 21524;
    pub const DEFAULT_USERNAME: &'static str = "box";
}

const SSH: &'static str = "ssh";

pub fn ssh(opts: SshOptions) -> BoxResult<()> {
    let runopts = IsRunningOptions::Container { name: opts.container.clone() };
    if !is_running(runopts).is_ok_and(|r| r.as_bool()) {
        todo!("not running :: todo: start container here");
    }
    
    let mut cmd = Command::new(SSH);
    cmd.arg(format!("{}@localhost", SshOptions::DEFAULT_USERNAME));
    cmd.arg("-p");
    cmd.arg(SshOptions::DEFAULT_PORT.to_string());

    let err: Option<io::Error> = cfg_select! {
        unix => { Some(cmd.exec()) }
        _ => { cmd.spawn().err() }
    };

    match err {
        None => Ok(()), 
        Some(source) => Err(BoxError::ExecuteCommand {
            source: source,
            err: CommandErr::Ssh { container: opts.container },
        }),
    }
}
