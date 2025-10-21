install.packages("ranger")
library(tidyverse)
library(caret)
library(randomForest)
library(MASS)
library(dplyr)
library(caret)
library(pROC)
library(ggplot2)
library(tidyr)

flood <- read.csv("flood.csv")
head(flood)


dim(flood)



names(flood)


# 2.2 Check missing values
na_summary <- colSums(is.na(flood))
na_summary

# 2.3 Data types
str(flood)

dup_count <- sum(duplicated(flood))
cat("Duplicate rows:", dup_count, "\n")

# 3. Split into train/test
set.seed(123)
trainIndex <- createDataPartition(flood$FloodProbability, p = 0.8, list = FALSE)
train <- flood[trainIndex, ]
test  <- flood[-trainIndex, ]
cat("Train rows:", nrow(train), "| Test rows:", nrow(test), "\n")

# 4. Linear Regression
lm_model <- lm(FloodProbability ~ ., data = train)
summary(lm_model)
# Predictions and evaluation
lm_pred <- predict(lm_model, newdata = test)
lm_rmse <- sqrt(mean((lm_pred - test$FloodProbability)^2))
lm_r2 <- cor(lm_pred, test$FloodProbability)^2
cat("Linear Regression → RMSE:", lm_rmse, " R²:", lm_r2, "\n")
pred_df <- data.frame(
  Actual = test$FloodProbability,
  Predicted = lm_pred
)


# Predicted vs actual for LR
ggplot(data = tibble(obs = test$FloodProbability, pred = lm_pred), aes(x = obs, y = pred)) +
  geom_point(alpha = 0.3,size=1) + geom_abline(slope = 1, intercept = 0, color = "darkred") +
  labs(title = "LR: Predicted vs Actual", x = "Observed", y = "Predicted")



#install.packages("ranger")
library(ranger)
rf_model <- ranger(FloodProbability ~ ., data = train, num.trees = 200, importance = "impurity",keep.inbag = TRUE)
# Predictions and Evaluation metrics
rf_pred <- predict(rf_model, data = test)$predictions
rf_rmse <- sqrt(mean((rf_pred - test$FloodProbability)^2))
rf_r2 <- cor(rf_pred, test$FloodProbability)^2
cat("Ranger Random Forest → RMSE:", rf_rmse, " R²:", rf_r2, "\n")

# Predicted vs actual for RF
ggplot(data = tibble(obs = test$FloodProbability, pred = rf_pred), aes(x = obs, y = pred)) +
  geom_point(alpha = 0.3) + geom_abline(slope = 1, intercept = 0, color = "red") +
  labs(title = "Ranger RF: Predicted vs Actual", x = "Observed", y = "Predicted")



# 1. Create binary label
train_cl <- train %>% mutate(FloodRisk = ifelse(FloodProbability > 0.5, 1, 0))
test_cl  <- test  %>% mutate(FloodRisk = ifelse(FloodProbability > 0.5, 1, 0))
# 2. Handle missing values (simple option: drop rows with NA)
train_cl <- na.omit(train_cl)
test_cl  <- na.omit(test_cl)
# 3. Convert character -> factor and align factor levels
# Convert character columns to factors in train and test
for(col in names(train_cl)) {
  if(is.character(train_cl[[col]])) train_cl[[col]] <- as.factor(train_cl[[col]])
}
for(col in names(test_cl)) {
  if(is.character(test_cl[[col]])) test_cl[[col]] <- as.factor(test_cl[[col]])
}
for(col in names(train_cl)) {
  if(is.factor(train_cl[[col]])) {
    if(col %in% names(test_cl)) {
      test_cl[[col]] <- factor(test_cl[[col]], levels = levels(train_cl[[col]]))
    }
  }
}
# 4. Build predictor list (exclude FloodProbability and FloodRisk)
clf_predictors <- setdiff(names(train_cl), c("FloodProbability", "FloodRisk"))
# Sanity check: ensure predictors exist in test too
missing_in_test <- setdiff(clf_predictors, names(test_cl))
if(length(missing_in_test) > 0) {
  stop("Predictor columns missing in test set: ", paste(missing_in_test, collapse = ", "))
}
glm_formula <- as.formula(paste("FloodRisk ~", paste(clf_predictors, collapse = " + ")))
# 5. Fit logistic regression (GLM)
glm_model <- glm(glm_formula, data = train_cl, family = binomial(link = "logit"))
cat("\nModel fitted. Number of coefficients:", length(coef(glm_model)), "\n")
# 6. Predict probabilities and classes on test set
glm_probs <- predict(glm_model, newdata = test_cl, type = "response")
# threshold for classification
threshold <- 0.5
glm_pred_class <- ifelse(glm_probs > threshold, 1, 0)
# Ensure factors for caret::confusionMatrix have identical levels
pred_factor <- factor(glm_pred_class, levels = c(0,1))
ref_factor  <- factor(test_cl$FloodRisk, levels = c(0,1))
# 7. Confusion matrix & caret metrics
conf <- caret::confusionMatrix(pred_factor, ref_factor, positive = "1")
print(conf)

ggplot(data = tibble(obs = test_cl$FloodProbability, pred = glm_probs),
       aes(x = obs, y = pred)) +
  geom_jitter(color = "darkblue", alpha = 0.6, width = 0.01, height = 0.01, size = 2) +
  geom_abline(slope = 1, intercept = 0, color = "darkred", size = 1.2) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dotted") +
  labs(
    title = "GLM (Logistic Regression): Predicted vs Actual FloodProbability",
    x = "Observed FloodProbability",
    y = "Predicted FloodProbability"
  ) +
  theme_minimal()
