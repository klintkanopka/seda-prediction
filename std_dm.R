std <- function(x, na.rm = TRUE) (x - mean(x, na.rm = na.rm)) / sd(x, na.rm)
nrm <- function(x, na.rm = TRUE) (x - min(x, na.rm = na.rm)) / (max(x, na.rm - na.rm) - min(x, na.rm = na.rm))
dm <- function(x, na.rm = TRUE) (x - mean(x, na.rm = na.rm))

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
  inner_join(disc, by="nces_id")

drp_var <- vars(fips, stateabb, starts_with("metro"), starts_with("micro"),
                czid, starts_with("county"), czid, cdcode, ends_with("fleslope"))
maybe_drp_var <- vars(gslo, gshi, elmtch)
nrm_var <- vars(starts_with("ratstutch"), starts_with("flunch_"))
std_var <- vars(ind, asn, hsp, blk, wht, frl, nonfrl, rl, nonrl, frlunch,
                nonfrlunch, totenrl, nsch, ncharters, speced, ell, tottch, aides,
                corsup, starts_with("stutch"), starts_with("diffstutch"),
                starts_with("ppexp"), starts_with("inc"), starts_with("paredV"),
                starts_with("educV"))
std_keep_var <- vars(starts_with("per"), baplus_wht, poverty517_wht, snap_wht, 
                     singmom_wht, samehouse_wht, unemp_wht, baplus_hsp, 
                     poverty517_hsp, snap_hsp, singmom_hsp, samehouse_hsp,
                     unemp_hsp, baplus_blk, poverty517_blk, snap_blk, singmom_blk,
                     samehouse_blk, unemp_blk, baplus_all, poverty517_all,
                     singmom_all, snap_all, samehouse_all, unemp_all, pctenglish1,
                     pctenglish2, pctenglish3, pctforeign, pctmexico, pctpuerto,
                     pctcuba, pctcentral, pctsouth, starts_with("gini"), 
                     starts_with("baplus"), starts_with("pov"), starts_with("occ"),
                     starts_with("inlf"), starts_with("unemp"), 
                     teenbirth_all, sesall, seswht, sesblk)

output <- d %>%  
  mutate(discrepancy = scale(discrepancy)) %>%
  select(-leaidC, -leaname, -fips, -stateabb, -subject, 
         -starts_with("metro"), -starts_with("micro"),
         -czid, -starts_with("county"), -czid, -cdcode, -ends_with("fleslope"), 
         -gslo, -gshi, -elmtch) %>%
  mutate_at(nrm_var, list(nrm = nrm)) %>%
  mutate_at(std_var, list(std = std)) %>%
  mutate_at(std_keep_var, list(std = std)) %>%
  group_by(nces_id, cohort) %>%
  mutate_at(vars(ends_with("_std")), list(dm = dm)) %>%
  mutate_at(vars(ends_with("_nrm")), list(dm = dm)) %>%
  ungroup() %>%
  select(-ratstutch_whtblk,
         -ratstutch_whthsp,
         -flunch_wht,
         -flunch_blk,
         -flunch_hsp) %>%
  select(-ind, -asn, -hsp, -blk, -wht, -frl, -nonfrl, -rl, -nonrl, -frlunch,
         -nonfrlunch, -totenrl, -nsch, -ncharters, -speced, -ell, -tottch, -aides,
         -corsup, 
         -stutch_wht,
         -stutch_blk,
         -stutch_hsp,
         -diffstutch_blkwht,
         -diffstutch_hspwht,
         -ppexp_tot,
         -ppexp_inst,
         -incrat9010all,
         -incrat9050all,
         -incrat5010all,
         -inc50blk,
         -incrat9010blk,
         -incrat9050blk,
         -incrat5010blk,
         -inc50hsp,
         -incrat9010hsp,
         -incrat9050hsp,
         -incrat5010hsp,
         -inc50wht,
         -incrat9010wht,
         -incrat9050wht,
         -incrat5010wht,
         -paredVblkwht,
         -paredVhspwht,
         -incVblkwht,
         -incVhspwht,
         -incVmalfem,
         -educVmalfem) %>%
  arrange(nces_id, cohort, year) %>%
  select(-cohort, -year)

colSums(is.na(output))

# hack-y bullshit
output[is.na(output)] <- 0

write_csv(output, file_std_dm_cleaned)

n_samples <- 94

districts <- unique(output$nces_id)
val_dist <- sample(1:length(districts), n_samples)
test_dist <- sample(setdiff(1:length(districts), val_dist), n_samples)
train_dist <- setdiff(1:length(districts), union(val_dist, test_dist))

output %>%
  filter(nces_id %in% districts[train_dist]) %>%
  write_csv(file_std_dm_train)

output %>%
  filter(nces_id %in% districts[val_dist]) %>%
  write_csv(file_std_dm_val)

output %>%
  filter(nces_id %in% districts[test_dist]) %>%
  write_csv(file_std_dm_test)

notify("datafiles written")
