std <- function(x, na.rm = TRUE) (x - mean(x, na.rm = na.rm)) / sd(x, na.rm)
nrm <- function(x, na.rm = TRUE) (x - min(x, na.rm = na.rm)) / (max(x, na.rm - na.rm) - min(x, na.rm = na.rm))
dm <- function(x, na.rm = TRUE) (x - mean(x, na.rm = na.rm))
delta <- function(x) x - lag(x)

disc <- read_dta(file_TN_disc_dist) %>%
  bind_rows(read_dta(file_MA_disc_dist)) %>%
  bind_rows(read_dta(file_MI_disc_dist)) %>%
  filter(subject == "pooled")

cells <- read_dta(file_TN_cells_dist) %>%
  bind_rows(read_dta(file_MA_cells_dist)) %>%
  bind_rows(read_dta(file_MI_cells_dist)) %>%
  filter(growth_pooled == 1) %>%
  select(nces_id, year, grade, n_pooled)

covariates <- read_dta(file_cov_pooled) %>%
  filter(stateabb %in% c("MA", "MI", "TN")) 

d <- covariates %>% 
  mutate(nces_id = as.numeric(leaidC)) %>%
  inner_join(disc, by="nces_id") %>%
  select(-leaidC, -leaname, -fips, -stateabb, -starts_with("metro"), -czid,
         -countyid, -countyname, -cdcode, -subject, -nces_id, -incVblkwht, -incVhspwht,
         -incVmalfem, -profocc_blk, -snap_blk, -rent_blk, -singmom_blk, -samehouse_blk,
         -poverty517_blk, -sesallimp1, -sesallimp2, -seswhtimp1, -seswhtimp2, -sesblkimp1, 
         -sesblkimp2, -seshspimp1, -seshspimp2, -rural, -perwht, -pernonfrl, -nonfrl, -nonrl,
         -totenrl, -pernonrl, -occ_all,
         -sesblk, -paredVblkwht, -paredVhspwht,
         -ginihsp, -giniblk, -starts_with("incrat"), -starts_with("pct"),
         -seshsp, -starts_with("inc"), -starts_with("poverty517"), 
         -starts_with("singmom"), -starts_with("snap"))
colSums(is.na(d))
names(d)
spec <- formula(paste(names(d)[length(names(d))], paste(names(d)[1:length(names(d))-1], collapse=" + "), sep=" ~ "))


m <- lm(spec, data=d)
summary(m)



d_trimmed <- d[,colSums(is.na(d))<=10]
spec <- formula(paste(names(d_trimmed)[length(names(d_trimmed))], paste(names(d_trimmed)[1:length(names(d_trimmed))-1], collapse=" + "), sep=" ~ "))
d_trimmed <- na.omit(d_trimmed)
m <- lm(spec, data=d_trimmed)
summary(m)

y_hat <- predict(m, type="response")
mse <- mean((d_trimmed$discrepancy - y_hat)^2)

library(randomForest)

rf <- randomForest(spec, data=d_trimmed, na.action=na.omit, ntree=5000, importnace=TRUE)
nn <- neuralnet(spec, data=d_trimmed, hidden=c(20, 10, 5), rep=10)

