# ---------- 0. Install & load packages ----------
required_pkgs <- c("tidyverse","caret","randomForest","xgboost","pROC","glmnet","Metrics","data.table","corrplot")
installed <- rownames(installed.packages())
for(p in required_pkgs) if(!(p %in% installed)) install.packages(p, dependencies = TRUE)

library(tidyverse)
library(caret)
library(randomForest)
library(xgboost)
library(pROC)
library(glmnet)
library(Metrics)
library(data.table)
library(corrplot)
library(dplyr)


# ---------- 1. Load data ----------
# Replace filename with your actual csv file
df <- fread("flood.csv") %>% as.data.frame()
glimpse(df)
summary(df)
dim(df)

head(df)


# ---------- 2. Basic cleaning & checks ----------
# 2.1 Column names: tidy them
#names(df) <- make.names(names(df))


# 2.2 Check missing values
na_summary <- colSums(is.na(df))
na_summary


# 2.3 Data types
str(df)

# 2.4 Check duplicates (optional)
dup_count <- sum(duplicated(df))
cat("Duplicate rows:", dup_count, "\n")
# If duplicates large: df <- distinct(df)

# ---------- 3. Exploratory Data Analysis (EDA) ----------
# 3.1 Distribution of target (FloodProbability)
ggplot(df, aes(x = FloodProbability)) +
  geom_histogram(bins = 40) + ggtitle("Distribution of FloodProbability")

# 3.2 Correlation matrix for numeric features
num_vars <- df[, sapply(df, is.numeric)]
cor_mat <- cor(num_vars, use = "pairwise.complete.obs")
corrplot(cor_mat, tl.cex = 0.6)

# 3.4 Boxplots for checking outliers (example for first few numeric features)
num_plot_cols <- names(num_vars)[1:min(6, ncol(num_vars))]
df_subset <- df[, num_plot_cols]
df_long <- tidyr::pivot_longer(df_subset, everything(), names_to = "var", values_to = "val")

ggplot(df_long, aes(x = var, y = val)) +
  geom_boxplot() +
  ggtitle("Boxplots of features")

