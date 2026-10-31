use clap::{Parser, Subcommand};
use rust_ml_tools::TabularDataset;
use std::error::Error;
use std::io;

#[derive(Parser)]
#[command(name = "nutorch", about = "NuTorch Tensor Operations CLI for Nushell")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// In-memory tensor matrix multiplication
    Matmul {
        /// Multiply with an n-by-n identity matrix
        #[arg(long)]
        eye: Option<usize>,

        /// Scalar scaling factor
        #[arg(long, default_value_t = 1.0)]
        scale: f64,

        /// Optional target/label column to exclude from matrix
        #[arg(short, long, default_value = "")]
        exclude: String,

        /// Input CSV file path (or stdin)
        #[arg(short, long)]
        input: Option<String>,
    },
    /// In-memory tensor statistics (Frobenius norm, trace, mean)
    Stats {
        /// Optional target/label column to exclude
        #[arg(short, long, default_value = "")]
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
        Commands::Matmul {
            eye,
            scale,
            exclude,
            input,
        } => {
            let ds = TabularDataset::load(input.as_deref())?;
            let excludes = if exclude.is_empty() {
                vec![]
            } else {
                vec![exclude.as_str()]
            };
            let (feature_names, x_mat) = ds.extract_numeric_features(&excludes);

            if x_mat.is_empty() {
                return Err("No numerical columns found for tensor operation".into());
            }

            let nrows = x_mat.len();
            let ncols = feature_names.len();

            if let Some(eye_dim) = eye {
                if eye_dim != ncols {
                    return Err(format!(
                        "Dimension mismatch: input has {} numerical columns, but --eye was {}",
                        ncols, eye_dim
                    )
                    .into());
                }
            }

            let mut wtr = csv::Writer::from_writer(io::stdout());
            wtr.write_record(&feature_names)?;

            for i in 0..nrows {
                let mut record = Vec::with_capacity(ncols);
                for j in 0..ncols {
                    let val = x_mat[i][j] * scale;
                    record.push(format!("{:.4}", val));
                }
                wtr.write_record(&record)?;
            }
            wtr.flush()?;
        }
        Commands::Stats { exclude, input } => {
            let ds = TabularDataset::load(input.as_deref())?;
            let excludes = if exclude.is_empty() {
                vec![]
            } else {
                vec![exclude.as_str()]
            };
            let (feature_names, x_mat) = ds.extract_numeric_features(&excludes);

            let nrows = x_mat.len();
            let ncols = feature_names.len();

            let mut sum_sq = 0.0;
            let mut col_sums = vec![0.0; ncols];
            for row in &x_mat {
                for (j, &val) in row.iter().enumerate() {
                    sum_sq += val * val;
                    col_sums[j] += val;
                }
            }
            let frobenius_norm = sum_sq.sqrt();

            let mut wtr = csv::Writer::from_writer(io::stdout());
            wtr.write_record(&["metric", "value"])?;
            wtr.write_record(&["rows", &nrows.to_string()])?;
            wtr.write_record(&["columns", &ncols.to_string()])?;
            wtr.write_record(&["frobenius_norm", &format!("{:.4}", frobenius_norm)])?;
            wtr.flush()?;
        }
    }
    Ok(())
}
