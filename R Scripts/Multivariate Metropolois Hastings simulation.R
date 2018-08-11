## Bivariate Metropolis Hastings Simulation

## This code will work for any dimensional metropolis hastings algorithm.  We just redifine 
## the function to have more parameters and account for the intialization 

n<-100000 ## How many samples do you want?
x<-rep(0,n) ## make the empty boxes
y<-rep(0,n) ## make the empty boxes
x[1]<-1 ## Fill the first box for x
y[1]<-1 ## Fill the first box y
sigma<-1
sigma2<-1
keep<-rep(0,n)
u<-rep(0,n)

fxy<-function(x,y){
  
  ((cos(4*x))^2+(sin(3*y))^2+(cos((3*x)+(2*y)))^2)/(exp((x)^2+(y)^2))
  
}

for(i in 2:n){
  
  xp<-rnorm(1,x[i-1],sigma) # candidate value
  yp<-rnorm(1,y[i-1],sigma2)
  
  # posterior probability evaluated at current value, pi(x_1)
  pcur<-fxy(x[i-1],y[i-1])
  
  #posterior probability evaluated at candidate value, pi(x_i)
  pcan<-fxy(xp,yp)
  
  #Probability of accepting candidate value
  keep[i]<-min(1,pcan/pcur)
  
  #Uniform random value
  u[i]<- runif(1,0,1)
  
  
  if (u[i]<keep[i]) {
    x[i] <- xp # Current value of x_i
    y[i]<-yp  # Current value of y_i
  } else {
    x[i] <- x[i-1]
    y[i]<-y[i-1]
  }
  
}

# Create the Graphics
## Load library packeges
library(viridis)
library(viridisLite)
library(tibble)
library(ggplot2)
library(ggExtra)
library(tidyverse)
library(mosaic)

# Store simulated posterior values in a tibble
# Use tail() to remove the burn-in values
post.sim <- tibble(x.sim = tail(x, -1000), 
                   y.sim = tail(y, -1000))

# Marginal Histogram Plot
p <- ggplot(post.sim, aes(x.sim, y.sim)) +
  geom_point(size = .1) +
  theme_bw()
ggMarginal(p, type = "histogram", color = "white", bins = 50)

# Density Contour Plot / Level Scale Density Plot
ggplot(post.sim, aes(x.sim, y.sim)) +
  stat_density_2d(aes(fill = ..level..), geom = "polygon") + 
  labs(title = "Level Scale Density Plot") +
  scale_fill_viridis() +
  theme_bw()

# Summaries of x and y
summary(x)
summary(y)

# 95% credible intervals for x and y
quantile(x, c(0.025,0.975))
quantile(y, c(0.025, 0.975))
