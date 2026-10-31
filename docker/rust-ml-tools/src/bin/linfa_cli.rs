use clap::{Parser, Subcommand};
use linfa::traits::{Fit, Predict, Transformer};
use linfa::DatasetBase;
use linfa_clustering::KMeans;
use linfa_reduction::Pca;
use ndarray::Array2;
use rust_ml_tools::TabularDataset;
use std::error::Error;
use std::io;

#[derive(Parser)]
#[command(name = "linfa-cli", about = "Linfa Machine Learning CLI for Nushell")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// K-Means unsupervised clustering
    Kmeans {
        /// Number of clusters (k)
        #[arg(short, long, default_value_t = 3)]
        k: usize,

        /// Maximum iterations
        #[arg(long, default_value_t = 100)]
        max_iter: u64,

        /// Optional target/label column to exclude from clustering
        #[arg(short, long, default_value = "type")]
        exclude: String,

        /// Input CSV file path (or stdin)
        #[arg(short, long)]
        input: Option<String>,
    },
    /// Principal Component Analysis (PCA) projection
    Pca {
        /// Number of principal components
        #[arg(short, long, default_value_t = 2)]
        components: usize,

        /// Optional target/label column to exclude from projection
        #[arg(short, long, default_value = "type")]
        exclude: String,

        /// Input CSV file path (or stdin)
        #[arg(short, long)]
        input: Option<String>,
    },
}

fn main() {
    rust_ml_tools::exit_on_broken_pipe(run);
}

fn run() -> Result<(), Box<dyn Error>> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Kmeans {
            k,
            max_iter,
            exclude,
            input,
        } => {
            let ds = TabularDataset::load(input.as_deref())?;
            let (feature_names, x_mat) = ds.extract_numeric_features(&[&exclude]);
            if x_mat.is_empty() {
                return Err("No numerical features found for clustering".into());
            }

            let nrows = x_mat.len();
            let ncols = feature_names.len();
            let mut flat = Vec::with_capacity(nrows * ncols);
            for row in x_mat {
                flat.extend(row);
            }

            let arr = Array2::from_shape_vec((nrows, ncols), flat)?;
            let dataset = DatasetBase::from(arr);

            let model = KMeans::params(k)
                .max_n_iterations(max_iter)
                .fit(&dataset)
                .map_err(|e| format!("KMeans fitting error: {:?}", e))?;

            let cluster_assignments = model.predict(&dataset);

            let mut wtr = csv::Writer::from_writer(io::stdout());
            let mut out_headers = vec!["cluster".to_string()];
            out_headers.extend(ds.headers.clone());
            wtr.write_record(&out_headers)?;

            for (i, &cluster_id) in cluster_assignments.iter().enumerate() {
                let mut record = vec![cluster_id.to_string()];
                record.extend(ds.rows[i].clone());
                wtr.write_record(&record)?;
            }
            wtr.flush()?;
        }
        Commands::Pca {
            components,
            exclude,
            input,
        } => {
            let ds = TabularDataset::load(input.as_deref())?;
            let (feature_names, x_mat) = ds.extract_numeric_features(&[&exclude]);
            if x_mat.is_empty() {
                return Err("No numerical features found for PCA".into());
            }

            let nrows = x_mat.len();
            let ncols = feature_names.len();
            let mut flat = Vec::with_capacity(nrows * ncols);
            for row in x_mat {
                flat.extend(row);
            }

            let arr = Array2::from_shape_vec((nrows, ncols), flat)?;
            let dataset = DatasetBase::from(arr);

            let pca = Pca::params(components)
                .fit(&dataset)
                .map_err(|e| format!("PCA fitting error: {:?}", e))?;

            let projected = pca.transform(dataset);
            let proj_mat = projected.records();

            let mut wtr = csv::Writer::from_writer(io::stdout());
            let mut out_headers = Vec::new();
            for c in 1..=components {
                out_headers.push(format!("pc_{}", c));
            }
            out_headers.extend(ds.headers.clone());
            wtr.write_record(&out_headers)?;

            for i in 0..nrows {
                let mut record = Vec::with_capacity(components + ds.headers.len());
                for c in 0..components {
                    record.push(format!("{:.6}", proj_mat[[i, c]]));
                }
                record.extend(ds.rows[i].clone());
                wtr.write_record(&record)?;
            }
            wtr.flush()?;
        }
    }
    Ok(())
}
