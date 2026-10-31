use burn::tensor::{Tensor, TensorData};
use burn_ndarray::{NdArray, NdArrayDevice};
use clap::{Parser, Subcommand};
use rust_ml_tools::TabularDataset;
use std::error::Error;
use std::io;

#[derive(Parser)]
#[command(name = "burn-cli", about = "Burn Deep Learning CLI for Nushell")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Train a neural MLP model on tabular data and output predictions
    TrainMlp {
        /// Target column name (e.g. quality or type)
        #[arg(short, long, default_value = "quality")]
        target: String,

        /// Number of training epochs
        #[arg(short, long, default_value_t = 15)]
        epochs: usize,

        /// Hidden layer size
        #[arg(long, default_value_t = 16)]
        hidden: usize,

        /// Learning rate
        #[arg(short, long, default_value_t = 0.01)]
        lr: f32,

        /// Input CSV file path (or stdin)
        #[arg(short, long)]
        input: Option<String>,
    },
}

type Backend = NdArray<f32>;

fn main() {
    rust_ml_tools::exit_on_broken_pipe(run);
}

fn run() -> Result<(), Box<dyn Error>> {
    let cli = Cli::parse();
    let device = NdArrayDevice::default();

    match cli.command {
        Commands::TrainMlp {
            target,
            epochs,
            hidden,
            lr,
            input,
        } => {
            let ds = TabularDataset::load(input.as_deref())?;
            let y_vec = ds.extract_numeric_target(&target)?;
            let (feature_names, x_mat) = ds.extract_numeric_features(&[&target]);

            if x_mat.is_empty() {
                return Err("No numerical features found for Burn MLP training".into());
            }

            let nrows = x_mat.len();
            let ncols = feature_names.len();

            let mut flat_x = Vec::with_capacity(nrows * ncols);
            for row in &x_mat {
                for &v in row {
                    flat_x.push(v as f32);
                }
            }

            let mut flat_y = Vec::with_capacity(nrows);
            for &y in &y_vec {
                flat_y.push(y as f32);
            }

            // Normalization (standard score) for stable gradient descent
            let mut means = vec![0.0f32; ncols];
            let mut stds = vec![0.0f32; ncols];
            for j in 0..ncols {
                let mut sum = 0.0f32;
                for i in 0..nrows {
                    sum += flat_x[i * ncols + j];
                }
                means[j] = sum / (nrows as f32);
                let mut var = 0.0f32;
                for i in 0..nrows {
                    let diff = flat_x[i * ncols + j] - means[j];
                    var += diff * diff;
                }
                stds[j] = (var / (nrows as f32)).sqrt().max(1e-4);
            }

            for i in 0..nrows {
                for j in 0..ncols {
                    flat_x[i * ncols + j] = (flat_x[i * ncols + j] - means[j]) / stds[j];
                }
            }

            let x_tensor = Tensor::<Backend, 2>::from_data(
                TensorData::new(flat_x, [nrows, ncols]),
                &device,
            );

            // Manual 2-layer MLP weights
            let mut w1_data = Vec::with_capacity(ncols * hidden);
            for i in 0..ncols {
                for j in 0..hidden {
                    w1_data.push((((i * 13 + j * 7 + 5) % 100) as f32 - 50.0) / 200.0);
                }
            }
            let mut w1 = Tensor::<Backend, 2>::from_data(
                TensorData::new(w1_data, [ncols, hidden]),
                &device,
            );

            let mut w2_data = Vec::with_capacity(hidden);
            for j in 0..hidden {
                w2_data.push((((j * 17 + 11) % 100) as f32 - 50.0) / 200.0);
            }
            let mut w2 = Tensor::<Backend, 2>::from_data(
                TensorData::new(w2_data, [hidden, 1]),
                &device,
            );

            let y_target = Tensor::<Backend, 2>::from_data(
                TensorData::new(flat_y, [nrows, 1]),
                &device,
            );

            // Iterative training loop
            for _ in 0..epochs {
                let h1 = x_tensor.clone().matmul(w1.clone());
                let mask = h1.clone().greater_equal_elem(0.0);
                let h1_act = h1.clone().mask_where(mask, h1.clone().mul_scalar(0.01));
                let preds = h1_act.clone().matmul(w2.clone());

                let diff = preds.sub(y_target.clone());
                let grad_w2 = h1_act.transpose().matmul(diff.clone()).mul_scalar(lr / (nrows as f32));
                w2 = w2.sub(grad_w2);

                let grad_h1 = diff.matmul(w2.clone().transpose());
                let grad_w1 = x_tensor
                    .clone()
                    .transpose()
                    .matmul(grad_h1)
                    .mul_scalar(lr / (nrows as f32));
                w1 = w1.sub(grad_w1);
            }

            let h1 = x_tensor.matmul(w1);
            let mask = h1.clone().greater_equal_elem(0.0);
            let h1_act = h1.clone().mask_where(mask, h1.mul_scalar(0.01));
            let final_preds = h1_act.matmul(w2);
            let pred_vals: Vec<f32> = final_preds
                .into_data()
                .to_vec()
                .map_err(|e| format!("{:?}", e))?;

            let mut wtr = csv::Writer::from_writer(io::stdout());
            let mut out_headers = vec!["actual".to_string(), "predicted".to_string()];
            out_headers.extend(ds.headers.clone());
            wtr.write_record(&out_headers)?;

            let target_idx = ds.column_index(&target).unwrap();
            for i in 0..nrows {
                let actual = &ds.rows[i][target_idx];
                let pred = format!("{:.3}", pred_vals[i]);
                let mut record = vec![actual.clone(), pred];
                record.extend(ds.rows[i].clone());
                wtr.write_record(&record)?;
            }
            wtr.flush()?;
        }
    }
    Ok(())
}
