use crate::*;

#[derive(Debug)]
pub struct PodImage {
    pub source: String,
    pub name: String,
    pub version: (u32, u32, u32),
    pub alias: Option<String>,
}

impl PodImage {
    pub fn source(&self) -> &str { &self.source }
    pub fn name(&self) -> &str { &self.name }
    pub fn version(&self) -> (u32, u32, u32) { self.version }
    pub fn alias(&self) -> Option<&str> { self.alias.as_deref() }
}

impl PodImage {
    pub async fn from_source<S: Into<String> + AsRef<str>>(source: S) -> SandboxResult<Self> {
        Self::from_source_as(source, None, None).await
    }
    
    pub async fn from_source_as<S: Into<String> + AsRef<str>>(source: S, user: Option<&str>, passwd: Option<&str>) -> SandboxResult<Self> {
        let source = source.into();
        let (_manifest, mut config) = Self::pull_oci_as(&source, user, passwd).await?;
        
        let mut labels = config.take_object("labels")
            .ok_or_else(|| SandboxError::ParseOciConfig { src: source.clone(), err: ParseConfigErr::MissingLabel })?;
        let name = labels.take_string("name")
            .ok_or_else(|| SandboxError::ParseOciConfig { src: source.clone(), err: ParseConfigErr::MissingLabel })?;
        let version = labels.take_string("version")
            .ok_or_else(|| SandboxError::ParseOciConfig { src: source.clone(), err: ParseConfigErr::MissingLabel })?;
        
        let Some(version) = version.split('.')
            .map(str::parse::<u32>)
            .collect::<Result<Vec<_>, _>>()
            .ok()
            .and_then(|v| if v.len() == 3 { Some((v[0], v[1], v[2])) } else { None })
        else {
            return Err(SandboxError::ParseOciConfig { src: source.into(), err: ParseConfigErr::MissingLabel });
        };
        
        Ok(Self {
            source,
            name,
            version,
            alias: None,
        })
    }
    
    fn source_reference(source: &str) -> SandboxResult<r::oci::Reference> {
        r::oci::Reference::from_str(source)
            .map_err(|e| SandboxError::ParseSource { src: source.into(), source: e })
    }
    
    async fn pull_oci_as(source: &str, user: Option<&str>, passwd: Option<&str>) -> SandboxResult<(r::oci::ImageManifest, json::Map<String, json::Value>)> {
        let reference = Self::source_reference(source)?;
        
        let auth = if user.is_some() && passwd.is_some() {
            r::oci::RegistryAuth::Basic(
                user.unwrap_or_default().to_string(),
                passwd.unwrap_or_default().to_string()
            ) 
        } else {
            r::oci::RegistryAuth::Anonymous
        }; 
        
        let (manifest, _digest, config) = r::oci::Client::default()
            .pull_manifest_and_config(&reference, &auth)
            .await
            .map_err(|e| SandboxError::PullManifest { src: source.into(), source: e })?;
        
        let config = json::from_str::<json::Value>(&config)
            .map_err(|e| SandboxError::ParseOciConfig { src: source.into(), err: ParseConfigErr::Json(e) })?
            .into_object()
            .ok_or_else(|| SandboxError::ParseOciConfig { src: source.into(), err: ParseConfigErr::MissingLabel })?;
        
        Ok((manifest, config))
    }
}
