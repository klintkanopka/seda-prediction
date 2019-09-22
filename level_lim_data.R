
disc <- read_dta(file_TN_disc_dist) %>%
  bind_rows(read_dta(file_MA_disc_dist)) %>%
  bind_rows(read_dta(file_MI_disc_dist)) %>%
  filter(subject == "pooled")

cells <- read_dta(file_TN_cells_dist) %>%
  bind_rows(read_dta(file_MA_cells_dist)) %>%
  bind_rows(read_dta(file_MI_cells_dist)) %>%
  filter(growth_pooled == 1) %>%
  select(nces_id, year, grade, n_pooled)

covariates <- read_dta(file_covariates) %>%
  filter(stateabb %in% c("MA", "MI", "TN")) 

d <- covariates %>% 
  mutate(nces_id = as.numeric(leaidC),
         cohort = year - grade - 2000,
         cohort_year = year*100 + cohort) %>%
  inner_join(cells, by=c("nces_id", "year", "grade")) %>%
  inner_join(disc, by="nces_id") %>%
  select(nces_id, cohort, cohort_year, discrepancy, n_pooled, year, grade,
         perind, perasn, perhsp, perblk, perwht,
         perfrl, perrl, perell, perspeced,
         totenrl, nsch, ncharters, 
         stutch_wht, stutch_blk, stutch_hsp, stutch_all,
         percharter_all, percharter_wht, percharter_blk, percharter_hsp,
         hswhtblk, hswhthsp, hsflnfl, ppexp_tot, pprev_tot)

output <- d %>%
  arrange(nces_id, cohort, year) %>%
  select(-cohort, -year)

# hack-y bullshit
output[is.na(output)] <- 0

write_csv(output, file_level_lim_cleaned)

n_samples <- 94

districts <- unique(output$nces_id)
val_dist <- sample(1:length(districts), n_samples)
test_dist <- sample(setdiff(1:length(districts), val_dist), n_samples)
train_dist <- setdiff(1:length(districts), union(val_dist, test_dist))

output %>%
  filter(nces_id %in% districts[train_dist]) %>%
  write_csv(file_level_lim_train)

output %>%
  filter(nces_id %in% districts[val_dist]) %>%
  write_csv(file_level_lim_val)

output %>%
  filter(nces_id %in% districts[test_dist]) %>%
  write_csv(file_level_lim_test)

notify("datafiles written")
