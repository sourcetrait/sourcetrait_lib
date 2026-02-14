pub trait SerdeJsonValueExt {
    fn into_object(self) -> Option<serde_json::Map<String, serde_json::Value>>;
    fn into_string(self) -> Option<String>;
}

impl SerdeJsonValueExt for serde_json::Value {
    fn into_object(self) -> Option<serde_json::Map<String, serde_json::Value>> {
        match self {
            serde_json::Value::Object(o) => Some(o),
            _ => None,
        }
    }
    
    fn into_string(self) -> Option<String> {
        match self {
            serde_json::Value::String(s) => Some(s),
            _ => None,
        }
    }
}

pub trait SerdeJsonMapExt {
    fn take_string(&mut self, key: &str) -> Option<String>;
    fn take_object(&mut self, key: &str) -> Option<serde_json::Map<String, serde_json::Value>>;
}

impl SerdeJsonMapExt for serde_json::Map<String, serde_json::Value> {
    fn take_string(&mut self, key: &str) -> Option<String> {
        self.remove(key).and_then(|v| v.into_string())
    }
    
    fn take_object(&mut self, key: &str) -> Option<serde_json::Map<String, serde_json::Value>> {
        self.remove(key).and_then(|v| v.into_object())
    }
}