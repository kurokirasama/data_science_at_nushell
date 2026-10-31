use std::collections::HashMap;
use std::error::Error;
use std::fs::File;
use std::io::{self, Read};

pub struct TabularDataset {
    pub headers: Vec<String>,
    pub rows: Vec<Vec<String>>,
}

impl TabularDataset {
    pub fn from_reader<R: Read>(reader: R) -> Result<Self, Box<dyn Error>> {
        let mut rdr = csv::ReaderBuilder::new()
            .has_headers(true)
            .flexible(true)
            .from_reader(reader);

        let headers: Vec<String> = rdr.headers()?.iter().map(|s| s.trim().to_string()).collect();
        let mut rows = Vec::new();
        for result in rdr.records() {
            let record = result?;
            let row: Vec<String> = record.iter().map(|s| s.trim().to_string()).collect();
            rows.push(row);
        }
        Ok(TabularDataset { headers, rows })
    }

    pub fn load(path_opt: Option<&str>) -> Result<Self, Box<dyn Error>> {
        match path_opt {
            Some("-") | None => {
                let stdin = io::stdin();
                Self::from_reader(stdin.lock())
            }
            Some(path) => {
                let file = File::open(path)?;
                Self::from_reader(file)
            }
        }
    }

    pub fn column_index(&self, name: &str) -> Option<usize> {
        self.headers.iter().position(|h| h.eq_ignore_ascii_case(name))
    }

    pub fn extract_numeric_features(
        &self,
        exclude: &[&str],
    ) -> (Vec<String>, Vec<Vec<f64>>) {
        let mut feature_indices = Vec::new();
        let mut feature_names = Vec::new();

        for (idx, name) in self.headers.iter().enumerate() {
            if exclude.iter().any(|ex| ex.eq_ignore_ascii_case(name)) {
                continue;
            }
            // Check if column is numeric across sample
            let is_num = self.rows.iter().take(20).all(|r| {
                if let Some(val) = r.get(idx) {
                    val.parse::<f64>().is_ok()
                } else {
                    false
                }
            });
            if is_num {
                feature_indices.push(idx);
                feature_names.push(name.clone());
            }
        }

        let mut matrix = Vec::with_capacity(self.rows.len());
        for row in &self.rows {
            let mut num_row = Vec::with_capacity(feature_indices.len());
            for &idx in &feature_indices {
                let val = row.get(idx).and_then(|s| s.parse::<f64>().ok()).unwrap_or(0.0);
                num_row.push(val);
            }
            matrix.push(num_row);
        }

        (feature_names, matrix)
    }

    pub fn extract_categorical_target(
        &self,
        target_col: &str,
    ) -> Result<(Vec<usize>, Vec<String>), Box<dyn Error>> {
        let idx = self
            .column_index(target_col)
            .ok_or_else(|| format!("Target column '{}' not found", target_col))?;

        let mut label_map: HashMap<String, usize> = HashMap::new();
        let mut class_names: Vec<String> = Vec::new();
        let mut target_vec = Vec::with_capacity(self.rows.len());

        for row in &self.rows {
            let label = row.get(idx).cloned().unwrap_or_default();
            let class_id = *label_map.entry(label.clone()).or_insert_with(|| {
                let next_id = class_names.len();
                class_names.push(label);
                next_id
            });
            target_vec.push(class_id);
        }

        Ok((target_vec, class_names))
    }

    pub fn extract_numeric_target(&self, target_col: &str) -> Result<Vec<f64>, Box<dyn Error>> {
        let idx = self
            .column_index(target_col)
            .ok_or_else(|| format!("Target column '{}' not found", target_col))?;

        let mut target_vec = Vec::with_capacity(self.rows.len());
        for row in &self.rows {
            let val = row.get(idx).and_then(|s| s.parse::<f64>().ok()).unwrap_or(0.0);
            target_vec.push(val);
        }
        Ok(target_vec)
    }
}

pub fn exit_on_broken_pipe<F>(f: F)
where
    F: FnOnce() -> Result<(), Box<dyn Error>>,
{
    if let Err(e) = f() {
        let err_str = format!("{:?}", e);
        if err_str.contains("BrokenPipe") || err_str.contains("Broken pipe") {
            std::process::exit(0);
        }
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}
