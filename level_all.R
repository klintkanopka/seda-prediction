
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
  select(-leaidC, -subject, -leaname, -stateabb, -czid,
         -starts_with("metro"), -starts_with("county"))

output <- d %>%
  arrange(nces_id, cohort, year) %>%
  select(-cohort, -year)

# hack-y bullshit
output[is.na(output)] <- 0

write_csv(output, file_level_all_cleaned)

n_samples <- 75

districts <- unique(output$nces_id)
val_dist <- sample(1:length(districts), n_samples)
test_dist <- sample(setdiff(1:length(districts), val_dist), n_samples)
train_dist <- setdiff(1:length(districts), union(val_dist, test_dist))

output %>%
  filter(nces_id %in% districts[train_dist]) %>%
  write_csv(file_level_all_train)

output %>%
  filter(nces_id %in% districts[val_dist]) %>%
  write_csv(file_level_all_val)

output %>%
  filter(nces_id %in% districts[test_dist]) %>%
  write_csv(file_level_all_test)

notify("datafiles written")
