use chrono::{Duration, Local, NaiveDate};
use chronox::{DateRelativeParsing, DateDisplay, DateTimeFormat};
use crate::*;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Date(pub NaiveDate);

impl Date {
    pub fn now() -> Self {
        Self(Local::now().date_naive())
    }

    /// Parse a string following either Y-m-d or Y/m/d formats, with year and
    /// month being optional.
    pub fn from(&self, when: &str) -> Result<Self> {
        if when == "yesterday" {
            Ok(Self(self.0 - Duration::days(1)))
        } else if let Some(date) = self.0.parse_relative_date(when) {
            Ok(Self(date))
        } else {
            Err(Error::Date(when.to_string()))
        }
    }

    pub fn naive(&self) -> &NaiveDate {
        &self.0
    }

    pub fn display(&self, format: DateTimeFormat) -> DateDisplay {
        DateDisplay::new(self.0, format)
    }
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_date_from() {
        let date = Date(NaiveDate::from_ymd_opt(1974, 5, 6).unwrap());

        assert_eq!(
            &NaiveDate::from_ymd_opt(1974, 5, 5).unwrap(),
            date.from("yesterday").unwrap().naive());

        assert_eq!(
            &NaiveDate::from_ymd_opt(1974, 4, 5).unwrap(),
            date.from("04-05").unwrap().naive());

        assert_eq!(
            &NaiveDate::from_ymd_opt(1974, 4, 5).unwrap(),
            date.from("4/5").unwrap().naive());

        assert_eq!(
            &NaiveDate::from_ymd_opt(1974, 5, 10).unwrap(),
            date.from("10").unwrap().naive());
    }
}
