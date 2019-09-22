
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

tmp <- covariates %>% 
  mutate(nces_id = as.numeric(leaidC),
         cohort = year - grade - 2000) %>%
  inner_join(cells, by=c("nces_id", "year", "grade")) %>%
  inner_join(disc, by="nces_id") %>%
  select(nces_id, cohort, discrepancy, n_pooled, year, grade,
         perind, perasn, perhsp, perblk, perwht,
         perfrl, perrl, perell, perspeced,
         totenrl, nsch, ncharters, 
         stutch_wht, stutch_blk, stutch_hsp, stutch_all,
         percharter_all, percharter_wht, percharter_blk, percharter_hsp,
         hswhtblk, hswhthsp, hsflnfl, ppexp_tot, pprev_tot)

d <- tmp %>%
  group_by(nces_id, cohort) %>%
  arrange(year) %>%
  transmute(year = year,
            cohort_year = year*100 + cohort,
            discrepancy = discrepancy,
            n_pooled = n_pooled,
            d_n_pooled = n_pooled - lag(n_pooled),
            d_perind = perind - lag(perind), 
            d_perasn = perasn - lag(perasn), 
            d_perhsp = perhsp - lag(perhsp), 
            d_perblk = perblk - lag(perblk), 
            d_perwht = perwht - lag(perwht),
            d_perfrl = perfrl - lag(perfrl), 
            d_perrl = perrl - lag(perrl), 
            d_perell = perell - lag(perell), 
            d_perspeced = perspeced - lag(perspeced),
            d_totenrl  = totenrl - lag(totenrl), 
            d_nsch = nsch - lag(nsch), 
            d_ncharters = ncharters - lag(ncharters), 
            d_stutch_wht = stutch_wht - lag(stutch_wht), 
            d_stutch_blk = stutch_blk - lag(stutch_blk), 
            d_stutch_hsp = stutch_hsp - lag(stutch_hsp), 
            d_stutch_all = stutch_all - lag(stutch_all),
            d_percharter_all = percharter_all - lag(percharter_all), 
            d_percharter_wht = percharter_wht - lag(percharter_wht), 
            d_percharter_blk = percharter_blk - lag(percharter_blk), 
            d_percharter_hsp = percharter_hsp - lag(percharter_hsp),
            d_hswhtblk = hswhtblk - lag(hswhtblk), 
            d_hswhthsp = hswhthsp - lag(hswhthsp), 
            d_hsflnfl = hsflnfl - lag(hsflnfl), 
            d_ppexp_tot = ppexp_tot - lag(ppexp_tot), 
            d_pprev_tot = pprev_tot - lag(pprev_tot)) %>%
  ungroup() 

output <- d %>%
  filter(!is.na(d_n_pooled)) %>%
  select(-cohort, -year) %>%
  arrange(nces_id, cohort_year)

# hack-y bullshit
output[is.na(output)] <- 0

write_csv(output, file_all_cleaned)

n_samples <- 50

districts <- unique(output$nces_id)
val_dist <- sample(1:length(districts), n_samples)
test_dist <- sample(setdiff(1:length(districts), val_dist), n_samples)
train_dist <- setdiff(1:length(districts), union(val_dist, test_dist))

output %>%
  filter(nces_id %in% districts[train_dist]) %>%
  write_csv(file_all_train)

output %>%
  filter(nces_id %in% districts[val_dist]) %>%
  write_csv(file_all_val)

output %>%
  filter(nces_id %in% districts[test_dist]) %>%
  write_csv(file_all_test)

notify("datafiles written")
