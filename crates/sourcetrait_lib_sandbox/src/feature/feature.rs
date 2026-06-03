//use crate::*;

#[derive(Debug, PartialEq, Eq)]
pub struct Feature {
    pub snake: &'static str,
    pub name: &'static str,
    pub dependencies: &'static [FeatureKind],
}

#[derive(Debug, PartialEq, Eq)]
pub struct FeaturePreset {
    snake: &'static str,
    name: &'static str,
    features: &'static [FeatureKind],
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FeatureKind {
    Claude,
}

impl FeatureKind {
    pub const CLAUDE: Feature = Feature {
        snake: "claude",
        name: "Claude",
        dependencies: &[],
    };
    
    pub const fn feature(&self) -> &'static Feature {
        match self {
            Self::Claude => &Self::CLAUDE,
        }
    }
}

#[derive(Debug, PartialEq, Eq)]
pub enum FeaturePresetKind {
    Claude,
}

impl FeaturePresetKind {
    pub const CLAUDE: FeaturePreset = FeaturePreset {
        snake: "claude",
        name: "claude",
        features: &[FeatureKind::Claude],
    };
    
    pub const fn preset(&self) -> &'static FeaturePreset {
        match self {
            Self::Claude => &Self::CLAUDE,
        }
    }
}

