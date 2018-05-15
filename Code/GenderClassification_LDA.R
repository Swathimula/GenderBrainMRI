# This will fit a LDA classifier to determine Gender based on Brain Area
# Author: Swathi M. Mula
# Date Created:   May 11, 2018
# Last Modififed: May 14, 2018
#########################################################################################

library(MASS)

# Read CSV file which has Gender and BrainArea information into R
filename = "/Users/swathi/Documents/Projects/Mula_MIDAS_2018/Results/ProcessedDatabase3.csv"
MRIData <- read.csv(filename, header=TRUE, sep=",")

# The high-leverage points are found to be 53, 71, 82 as found in GenderClassfication_LR.R
# Removing the high-leverage points
MRIData = MRIData[-c(53,71,82),] 

# Fitting the LDA classifier to the entire data frame
lda.fit <- lda(Gender~BrainArea, data = MRIData)

# Predictions from the full model
lda.predict <- predict(lda.fit, MRIData)

# Training Error from the full model
Train_Error = sum(lda.predict$class == MRIData$Gender)/nrow(MRIData)

# Number of rows of the full data frame
rowlength = nrow(MRIData)

# We will estimate the K-fold Cross-validation test error
K = 10
Kf = ceiling(nrow(MRIData)/K);
test.error = rep(0,K);
train.error = rep(0,K);

# Randomizing the order of the subjects
set.seed(3)
index = sample(nrow(MRIData),nrow(MRIData))

# Temporary variables
i = 1
j = 0

set.seed(3)

# Determining the estimate of K-fold Cross-validation test error 
for (k in 1:K){
  i = j+1
  j = i+Kf-1

  if(k == K){
    j = nrow(MRIData)
  }
  
  # Subset of the full-model
  k_MRI = MRIData[-index[i:j],] 
  
  # LDA fit to the subset model
  klda.fit <- lda(Gender~BrainArea,k_MRI)
  
  # Predictions from the above LDA fit
  klda.predict <- predict(klda.fit, MRIData[index[i:j],])
  
  # Test error estimate of the kth round 
  test.error[k] = mean(klda.predict$class != MRIData$Gender[index[i:j]])

  # Train error estimate of the kth round
  klda.predict <- predict(klda.fit, MRIData[-index[i:j],])
  train.error[k] = mean(klda.predict$class != MRIData$Gender[-index[i:j]])
}

# K-fold test error rate
Test_Error = mean(test.error)