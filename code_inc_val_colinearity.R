#try out ----------
set.seed(1234)
library(MASS)
library(mvtnorm)
find.sigma <- function(corr=1, sigma1=1, sigma2=1 ){
  covar <- corr*(sqrt(sigma1*sigma2))
  sigma <- matrix(c(sigma1,covar,covar,sigma2),2,2)
  return(sigma)
}

cor_xx = .7
n <- 1000
ntest <- 1000
b <-c(sqrt(.05), sqrt(.01))
mytcks = seq(0,1,length.out = 91)
mytcks_rev = seq(1,0,length.out = 91)
rho <- seq(1,.1,length.out = 91)
rho_rev <- seq(.1,1, length.out = 91)
measerror <- (1-rho)/rho
mease_err_diff <- cbind(measerror, sort(measerror, decreasing = T))

R = 100

fit_full <- array(0, dim = c(R, length(measerror), ntest))
fit <- array(0, dim = c(R,length(measerror),ntest))
err <- matrix(0,R,length(measerror))
err_full <- matrix(0,R,length(measerror))
for( i in 1:R){
  cat("\rReplication ", i,"of", R)
  X <- mvrnorm(n, c(0,0), Sigma = find.sigma(cor_xx))
  y <- X%*%b  + rnorm(n, sd = sqrt(1- sum(b^2)))
  Xnew <- mvrnorm(ntest, c(0,0), Sigma = find.sigma(cor_xx))
  ynew <- Xnew%*%b  + rnorm(ntest, sd = sqrt(1- sum(b^2)))
  
  for( c in 1:nrow(mease_err_diff)){
    Xer <- X + cbind(rnorm(n, sd = sqrt(mease_err_diff[c,1])),
                     rnorm(n, sd = sqrt(mease_err_diff[c,2])))
    a = lm(y ~ Xer[,1] + 0)
    a_full = lm(y~Xer+0)
    bls = coef(a)
    bls_full = coef(a_full)
    fit[i,c,] = Xnew[,1]*bls
    fit_full[i,c,] = Xnew%*%bls_full
    err[i,c] = mean((ynew-fit[i,c,])^2)
    err_full[i,c] = mean((ynew-fit_full[i,c,])^2)
  }
}


# plot including points for prediction with both x1 and x2
plot(mytcks, colMeans(err_full),'p', pch = ".", 
     cex = 5, col = "red",xlim = c(0,1), 
     ylim = c(min(c(colMeans(err_full), colMeans(err))) - .01 , 
              max(c(colMeans(err_full), colMeans(err))) + .01),
     xaxt = "n" , xlab = "Reliability x1", ylab = "Prediction error")
abline(v = mytcks[which.min(colMeans(err_full))], col = 'red')

# axes labels
axis(1, at = mytcks[seq(1,91,by = 10)], labels = rho[seq(1,91,by = 10)], las = 2)
axis(3, at = mytcks[seq(1,91,by = 10)], labels = rho_rev[seq(1,91, by = 10)], las =2)
mtext("Reliability x2", side=3, line = 3)
mtext(paste("Rx1y = ", b[1]^2,"", "Rx2y = ", b[2]^2), side = 4)

# points for prediction with only x1
points(mytcks, colMeans(err), col = "green", pch = ".", cex=5)
abline(v = mytcks[which.min(colMeans(err))], col = 'green')


