# This will fit Logistic Regression classifier to determine Gender based on Brain Area
# Author: Swathi M. Mula
# Date Created:   May 11, 2018
# Last Modififed: May 14, 2018
#########################################################################################

library(boot)

# Read CSV file which has Gender and BrainArea information into R
filename = "/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Results/ProcessedDatabase3.csv"
MRIData <- read.csv(filename, header=TRUE, sep=",")

# First we want to check for any high-leverage points
glm.fit.check <- glm(Gender~BrainArea, data = MRIData, family = binomial)

# Uncomment this to check for the high-leverage points
# par(mfrow = c(2,2))
# plot(glm.fit.check)

# The high-leverage points from the previous step are found to be 53, 71, 82
# Removing the high-leverage points
MRIData = MRIData[-c(53,71,82),] 

# Number of rows of the full data frame
rowlength = nrow(MRIData)

# Fitting the LR classifier to the entire data frame
glm.fit <- glm(Gender~BrainArea, data = MRIData, family = binomial)

# Estimating the predicted probabilities
glm.probs <- predict(glm.fit, type = "response")

# Estimating the training error rate
glm.pred <- rep('F',rowlength)
glm.pred[glm.probs > 0.5] <- 'M'
Train_Error = mean(glm.pred == MRIData$Gender)

# We will estimate the K-fold Cross-validation test error
set.seed(3)

# We want to see the K-fold CV test error for various values of K
test.error = rep(0,rowlength-1);

for (K in 2:rowlength){
  # Estimated K-fold CV test error for each K
  test.error[K-1] = cv.glm(MRIData, glm.fit, K = K)$delta[2] 
}


#Visualization of Results
attach(MRIData)
preds = predict(glm.fit, se = T)
se.bands.logit = cbind(preds$fit + 2*preds$se.fit, preds$fit - 2*preds$se.fit)
se.bands = exp(se.bands.logit)/(1+exp(se.bands.logit))

plot(BrainArea, glm.probs, ylim = c(0,1), cex = 0.5, pch = 20, col = "black", xlab = "Brain Area", ylab = "Pr(Gender = Male)")
points(BrainArea, se.bands[,1], ylim = c(0,1), cex = 2, pch = ".", col = "blue")
points(BrainArea, se.bands[,2], ylim = c(0,1), cex = 2, pch = ".", col = "blue")


