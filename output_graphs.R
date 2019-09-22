library(tidyverse)

test_d <- read_csv('test_preds/rnn_std_dm_1_32_5_0.01_0.0_250_model.csv')

ggplot(test_d, aes(x=y, y=y_hat)) +
  geom_point(color='red', alpha=0.6) +
  geom_abline(aes(slope=1, intercept=0), lty=2) +
  scale_y_continuous(limits=c(-3.5, 3.5)) +
  scale_x_continuous(limits = c(-3.5, 3.5)) +
  theme_bw()
