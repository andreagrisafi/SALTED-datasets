# SALTED example: water monomer dataset

by Zekun Lou, 27.06.2024

Please follow the [tutorial](https://fhi-aims-club.gitlab.io/tutorials/fhi-aims-with-salted).

Please run `tar xzvf data.tar` to decompress the trainset data dir if you want to test trainset related criterions like density fitting RMSE.

## About

- get_df_error
```text
% MAE = 0.8611622020848769
```

- validation
```text
% RMSE: 9.680e-01
```

- get_ml_error
```text
% MAE = 0.835204718117146
```

- collect_energies
```text
Mean absolute errors (eV/atom):
Electrostatic energy: 0.010159641166615075
XC energy: 0.019076590166666563
Total energy: 0.00044581299997616954
```


## Commands

```bash
# preparations
sbatch --array=1-4 run_aims.sbatch.sh  # remember to change var $DATADIR
ln -s ./qmdata/coefficients coefficients; ln -s ./qmdata/overlaps overlaps; ln -s ./qmdata/projections projections
sbatch move_data.sbatch.sh
python -m salted.get_basis_info
python -m salted.aims.get_df_err > logs/get_df_err.out

# SALTED workflow
sbatch dcpt.sbatch.sh
sbatch rkhs.sbatch.sh
sbatch regression.sbatch.sh
sbatch validation.sbatch.sh

# prediction
sbatch pred.sbatch.sh
sbatch --array=1-10 run_aims_predict.sbatch.sh
sbatch --array=1 run_aims.sbatch.sh  # remember to change var $DATADIR
python -m salted.aims.get_ml_err > logs/get_ml_err.out
python -m salted.aims.collect_energies > logs/collect_energies.out
```

