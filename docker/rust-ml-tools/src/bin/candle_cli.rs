use candle_core::{Device, Tensor};
use clap::{Parser, Subcommand};
use rust_ml_tools::TabularDataset;
use std::error::Error;
use std::io;

#[derive(Parser)]
#[command(name = "candle-cli", about = "Candle Pure-Rust Tensor Operations for Nushell")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// In-memory tensor matrix multiplication and linear projection
    Matmul {
        /// Projection dimension (number of output features)
        #[arg(short, long, default_value_t = 2)]
        dims: usize,

        /// Seed for deterministic projection weights
        #[arg(long, default_value_t = 42)]
        seed: u64,

        /// Optional target/label column to exclude from numerical projection
        #[arg(short, long, default_value = "type")]
        exclude: String,

        /// Input CSV file path (or stdin)
        #[arg(short, long)]
        input: Option<String>,
    },
    /// Forward evaluation through a Multi-Layer Perceptron (MLP)
    ForwardMlp {
        /// Hidden layer units
        #[arg(long, default_value_t = 16)]
        hidden: usize,

        /// Output logits dimension
        #[arg(short, long, default_value_t = 2)]
        classes: usize,

        /// Optional target column to exclude from features
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
    let device = Device::Cpu;

    match cli.command {
        Commands::Matmul {
            dims,
            seed: _,
            exclude,
            input,
        } => {
            let ds = TabularDataset::load(input.as_deref())?;
            let (feature_names, x_mat) = ds.extract_numeric_features(&[&exclude]);
            if x_mat.is_empty() {
                return Err("No numerical features found for Candle matmul".into());
            }

            let nrows = x_mat.len();
            let ncols = feature_names.len();
            let mut flat = Vec::with_capacity(nrows * ncols);
            for row in x_mat {
                for v in row {
                    flat.push(v as f32);
                }
            }

            let x_tensor = Tensor::from_vec(flat, (nrows, ncols), &device)?;
            // Deterministic orthogonal/projection weights
            let mut w_flat = Vec::with_capacity(ncols * dims);
            for i in 0..ncols {
                for j in 0..dims {
                    let val = (((i * 7 + j * 13 + 17) % 100) as f32 - 50.0) / 100.0;
                    w_flat.push(val);
                }
            }
            let w_tensor = Tensor::from_vec(w_flat, (ncols, dims), &device)?;
            let projected = x_tensor.matmul(&w_tensor)?;
            let proj_vec: Vec<f32> = projected.flatten_all()?.to_vec1()?;

            let mut wtr = csv::Writer::from_writer(io::stdout());
            let mut out_headers = Vec::new();
            for d in 1..=dims {
                out_headers.push(format!("tensor_dim_{}", d));
            }
            out_headers.extend(ds.headers.clone());
            wtr.write_record(&out_headers)?;

            for i in 0..nrows {
                let mut record = Vec::with_capacity(dims + ds.headers.len());
                for d in 0..dims {
                    let val = proj_vec[i * dims + d];
                    record.push(format!("{:.6}", val));
                }
                record.extend(ds.rows[i].clone());
                wtr.write_record(&record)?;
            }
            wtr.flush()?;
        }
        Commands::ForwardMlp {
            hidden,
            classes,
            exclude,
            input,
        } => {
            let ds = TabularDataset::load(input.as_deref())?;
            let (feature_names, x_mat) = ds.extract_numeric_features(&[&exclude]);
            if x_mat.is_empty() {
                return Err("No numerical features found for Candle MLP".into());
            }

            let nrows = x_mat.len();
            let ncols = feature_names.len();
            let mut flat = Vec::with_capacity(nrows * ncols);
            for row in x_mat {
                for v in row {
                    flat.push(v as f32);
                }
            }

            let x_tensor = Tensor::from_vec(flat, (nrows, ncols), &device)?;

            // Layer 1: X * W1
            let mut w1_flat = Vec::with_capacity(ncols * hidden);
            for i in 0..ncols {
                for j in 0..hidden {
                    w1_flat.push((((i * 11 + j * 19 + 23) % 100) as f32 - 50.0) / 100.0);
                }
            }
            let w1 = Tensor::from_vec(w1_flat, (ncols, hidden), &device)?;
            let h1 = x_tensor.matmul(&w1)?.relu()?;

            // Layer 2: H1 * W2
            let mut w2_flat = Vec::with_capacity(hidden * classes);
            for i in 0..hidden {
                for j in 0..classes {
                    w2_flat.push((((i * 17 + j * 29 + 31) % 100) as f32 - 50.0) / 100.0);
                }
            }
            let w2 = Tensor::from_vec(w2_flat, (hidden, classes), &device)?;
            let logits = h1.matmul(&w2)?;
            let logits_vec: Vec<f32> = logits.flatten_all()?.to_vec1()?;

            let mut wtr = csv::Writer::from_writer(io::stdout());
            let mut out_headers = Vec::new();
            for c in 0..classes {
                out_headers.push(format!("logit_{}", c));
            }
            out_headers.extend(ds.headers.clone());
            wtr.write_record(&out_headers)?;

            for i in 0..nrows {
                let mut record = Vec::with_capacity(classes + ds.headers.len());
                for c in 0..classes {
                    record.push(format!("{:.6}", logits_vec[i * classes + c]));
                }
                record.extend(ds.rows[i].clone());
                wtr.write_record(&record)?;
            }
            wtr.flush()?;
        }
    }
    Ok(())
}
