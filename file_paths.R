# directories
dir_data <- here::here("data")
dir_output <- here::here("output")

# original data files
file_MA_disc_dist <- path(dir_data, "MA_discrepancy_districts", ext="dta")
file_MI_disc_dist <- path(dir_data, "MI_discrepancy_districts", ext="dta")
file_TN_disc_dist <- path(dir_data, "TN_discrepancy_districts", ext="dta")

file_MA_cells_dist <- path(dir_data, "MA_cells_districts", ext="dta")
file_MI_cells_dist <- path(dir_data, "MI_cells_districts", ext="dta")
file_TN_cells_dist <- path(dir_data, "TN_cells_districts", ext="dta")

file_covariates <- path(dir_data, "SEDA_cov_geodist_long_v21", ext="dta")
file_cov_pooled <- path(dir_data, "SEDA_cov_geodist_pool_v21", ext="dta")
file_dy_covariates <- path(dir_data, "SEDA_cov_geodist_poolyr_v21", ext="dta")

file_MA_cleaned <- path(dir_data, "MA_cleaned", ext="csv")
file_MI_cleaned <- path(dir_data, "MI_cleaned", ext="csv")
file_TN_cleaned <- path(dir_data, "TN_cleaned", ext="csv")
file_all_cleaned <- path(dir_data, "all_cleaned", ext="csv")

file_all_train <- path(dir_data, "all_train", ext="csv")
file_all_val <- path(dir_data, "all_val", ext="csv")
file_all_test <- path(dir_data, "all_test", ext="csv")

file_level_lim_cleaned <- path(dir_data, "level_lim_cleaned", ext="csv")
file_level_lim_train <- path(dir_data, "level_lim_train", ext="csv")
file_level_lim_val <- path(dir_data, "level_lim_val", ext="csv")
file_level_lim_test <- path(dir_data, "level_lim_test", ext="csv")


file_level_all_cleaned <- path(dir_data, "level_all_cleaned", ext="csv")
file_level_all_train <- path(dir_data, "level_all_train", ext="csv")
file_level_all_val <- path(dir_data, "level_all_val", ext="csv")
file_level_all_test <- path(dir_data, "level_all_test", ext="csv")

file_level_std_cleaned <- path(dir_data, "level_std_cleaned", ext="csv")
file_level_std_train <- path(dir_data, "level_std_train", ext="csv")
file_level_std_val <- path(dir_data, "level_std_val", ext="csv")
file_level_std_test <- path(dir_data, "level_std_test", ext="csv")

file_std_out_cleaned <- path(dir_data, "std_out_cleaned", ext="csv")
file_std_out_train <- path(dir_data, "std_out_train", ext="csv")
file_std_out_val <- path(dir_data, "std_out_val", ext="csv")
file_std_out_test <- path(dir_data, "std_out_test", ext="csv")


file_std_dm_cleaned <- path(dir_data, "std_dm_cleaned", ext="csv")
file_std_dm_train <- path(dir_data, "std_dm_train", ext="csv")
file_std_dm_val <- path(dir_data, "std_dm_val", ext="csv")
file_std_dm_test <- path(dir_data, "std_dm_test", ext="csv")

file_delta_std_dm_cleaned <- path(dir_data, "delta_std_dm_cleaned", ext="csv")
file_delta_std_dm_train <- path(dir_data, "delta_std_dm_train", ext="csv")
file_delta_std_dm_val <- path(dir_data, "delta_std_dm_val", ext="csv")
file_delta_std_dm_test <- path(dir_data, "delta_std_dm_test", ext="csv")
