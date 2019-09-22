library(glmnet)
library(e1071)

train_data <- d_trimmed

X <- as.matrix(train_data[,-ncol(train_data)])
Y <- scale(train_data$discrepancy)
train_data$discrepancy <- Y

K <- 10
folds <- sample(1:K, length(Y), replace=T)

spec <- formula(
  paste(names(train_data)[length(names(train_data))], 
        paste(names(train_data)[1:length(names(train_data))-1], 
                            collapse=" + "), 
                            sep=" ~ "))

# OLS
m1 <- lm(spec, data=train_data)
# LASSO
m2 <- cv.glmnet(x=X, y=Y, alpha=1)
# ridge
m3 <- cv.glmnet(x=X, y=Y, alpha=0)

alpha_grid <- seq(0, 1, by=0.05)
net_mse <- matrix(NA, length(alpha_grid), K+1)
for (k in 1:K){
  for (i in seq_along(alpha_grid)){
    m_tmp <- cv.glmnet(x=X[folds != k,], y=Y[folds != k], alpha=alpha_grid[i])
    Y_tmp <- predict(m_tmp, newx = X[folds == k,],
                     s=m_tmp$lambda.min, type="response")
    net_mse[i,k] <- mean( (Y[folds == k] - Y_tmp)^2)
  }
}
net_mse[,K+1] <- rowSums(net_mse[,1:K])
net_mse

alpha_opt <- alpha_grid[which(net_mse[,K+1] == min(net_mse[,K+1]))]
m4 <- cv.glmnet(x=X, y=Y, alpha=alpha_opt)

# alpha_opt = 0.8

# Random Forest - mtry = 74
trees <- 1500

m5 <- tuneRF(y=train_data$discrepancy, x=train_data[,-ncol(train_data)],
             ntree=trees, doBest=TRUE)
mtry <- m5$mtry

# SVM Polynomial Kernel
tuned_svm_out<- tune.svm(spec, data=train_data, kernel="polynomial",
                         degree=2:4, gamma=10^(-4:-2))
m6 <- tuned_svm_out$best.model
gamma <- m6$gamma
degree <- m6$degree


# k-fold cross validate SL

sl_preds <- matrix(NA, length(Y), 6)
colnames(sl_preds) <- c("m1", "m2", "m3", "m4", "m5", "m6")
for (k in 1:K){
  print(paste("fold: ",k,sep=""))
  m1_tmp <- lm(spec, data=train_data[folds != k,])
  print(" lm done")
  m2_tmp <- cv.glmnet(x=X[folds != k,], y=Y[folds != k], alpha=1)
  print(" LASSO done")
  m3_tmp <- cv.glmnet(x=X[folds != k,], y=Y[folds != k], alpha=0)
  print(" ridge done")
  m4_tmp <- cv.glmnet(x=X[folds != k,], y=Y[folds != k], alpha=alpha_opt)
  print(" elastic net done")
  m5_tmp <- randomForest(spec, data=train_data[folds != k,],
                         mtry=mtry, ntree=trees)
  print(" random forest done")
  m6_tmp <- svm(spec, data=train_data[folds!=k,],
                kernel="polynomial", gamma=gamma, degree=degree)
  print(" svm done")
  tmp_preds <- cbind(predict(m1_tmp, newdata=train_data[folds==k,],
                             type="response"),
                     predict(m2_tmp, newx=X[folds==k,],
                             s=m2_tmp$lambda.min, type="response"),
                     predict(m3_tmp, newx=X[folds==k,],
                             s=m3_tmp$lambda.min, type="response"),
                     predict(m4_tmp, newx=X[folds==k,],
                             s=m4_tmp$lambda.min, type="response"),
                     predict(m5_tmp, newdata=train_data[folds==k,],
                             type="response"),
                     predict(m6_tmp, newdata=train_data[folds==k,],
                             type="response")
  )
  sl_preds[folds==k,] <- tmp_preds
  print(" predictions done!")
}

# MSE Check

mses <- c()
for (i in 1:6){
  mses[i] <- mean((Y - sl_preds[,i])^2)
}
mses

# SL Regression

sl_d <- as.data.frame(sl_preds)
sl_d$Y <- Y
sl_spec <- formula("Y ~ m1 + m2 + m3 + m4 + m5 + m6 - 1")
sl_lm <- lm(sl_spec, data=sl_d)
summary(sl_lm)

sl_y_hat <- predict(sl_lm,type="response")
sl_mse <- mean((sl_d$Y - sl_y_hat)^2)
sl_mse


