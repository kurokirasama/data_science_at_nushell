use clap::{Parser, Subcommand};
use rust_ml_tools::TabularDataset;
use smartcore::ensemble::random_forest_classifier::{
    RandomForestClassifier, RandomForestClassifierParameters,
};
use smartcore::linalg::basic::matrix::DenseMatrix;
use std::error::Error;
use std::io;

#[derive(Parser)]
#[command(
    name = "smartcore-cli",
    about = "SmartCore Machine Learning CLI for Nushell"
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Fit a classification model and emit predictions
    FitPredict {
        /// Input CSV file path (or stdin)
        #[arg(short, long)]
        input: Option<String>,

        /// Target column name (e.g. type)
        #[arg(short, long, default_value = "type")]
        target: String,

        /// Model type: random-forest
        #[arg(short, long, default_value = "random-forest")]
        model: String,

        /// Number of trees for random forest
        #[arg(long, default_value_t = 100)]
        trees: usize,
    },
}

fn main() {
    rust_ml_tools::exit_on_broken_pipe(run);
}

fn run() -> Result<(), Box<dyn Error>> {
    let cli = Cli::parse();

    match cli.command {
        Commands::FitPredict {
            input,
            target,
            model: _,
            trees,
        } => {
            let ds = TabularDataset::load(input.as_deref())?;
            let (target_indices, class_names) =
                ds.extract_categorical_target(&target)?;
            let (feature_names, x_mat) =
                ds.extract_numeric_features(&[&target]);

            if x_mat.is_empty() {
                return Err("No numerical features found for training".into());
            }

            let nrows = x_mat.len();
            let ncols = feature_names.len();
            let mut flat = Vec::with_capacity(nrows * ncols);
            for row in x_mat {
                flat.extend(row);
            }
            let x = DenseMatrix::new(nrows, ncols, flat, false)?;
            let y = target_indices;

            let params = RandomForestClassifierParameters::default()
                .with_n_trees(trees as u16);
            let rf = RandomForestClassifier::fit(&x, &y, params)?;
            let y_hat = rf.predict(&x)?;

            let mut wtr = csv::Writer::from_writer(io::stdout());
            let mut out_headers =
                vec!["actual".to_string(), "predicted".to_string()];
            out_headers.extend(ds.headers.clone());
            wtr.write_record(&out_headers)?;

            let target_idx = ds.column_index(&target).unwrap();
            for i in 0..nrows {
                let actual_label = &ds.rows[i][target_idx];
                let pred_label = class_names
                    .get(y_hat[i])
                    .cloned()
                    .unwrap_or_else(|| y_hat[i].to_string());
                let mut record = vec![actual_label.clone(), pred_label];
                record.extend(ds.rows[i].clone());
                wtr.write_record(&record)?;
            }
            wtr.flush()?;
        }
    }
    Ok(())
}
