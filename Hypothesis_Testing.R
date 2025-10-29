'''
对一下数据进行但总体和多总体均值和协方差矩阵的假设检验
> print(data)
    SiO2   FeO  K2O group
1  47.22  5.06 0.10     A
2  47.45  4.35 0.15     A
3  47.52  6.85 0.12     A
4  47.86  4.19 0.17     A
5  47.31  7.57 0.18     A
6  54.33  6.22 0.12     B
7  56.17  3.31 0.15     B
8  54.40  2.43 0.22     B
9  52.62  5.92 0.12     B
10 43.12 10.33 0.05     C
11 42.05  9.67 0.08     C
12 42.50  9.62 0.02     C
13 40.77  9.68 0.04     C
'''


data <- read.table("3-12.txt", header = FALSE, col.names = c("SiO2", "FeO", "K2O"))

group <- factor(c(rep("A",5), rep("B",4), rep("C",4)))# 添加地区标签
data$group <- group


# (1) 检验协方差矩阵是否相等 —— Box’s M test
library(biotools)
box_m_result <- boxM(data[,1:3], data$group)
cat("\n(1) Box's M 检验结果：\n")
print(box_m_result)


# (2) 检验 A vs B 是否均值相等 —— Hotelling's T² 检验
library(ICSNP)

ab_data  <- droplevels(subset(data, group %in% c("A", "B")))
X <- as.matrix(ab_data[ab_data$group == "A", 1:3])  # 组A数据矩阵
Y <- as.matrix(ab_data[ab_data$group == "B", 1:3])  # 组B数据矩阵

T2_result <- ICSNP::HotellingsT2(X, Y) # 两样本 Hotelling T^2 检验

cat("\n(2) Hotelling's T² 检验（A vs B）：\n")
print(T2_result)

# (3) 三组均值是否相等 —— MANOVA
manova_result <- manova(cbind(SiO2, FeO, K2O) ~ group, data = data)
cat("\n(3) MANOVA 检验结果（三组均值相等）：\n")
summary(manova_result, test = "Wilks")

#====================#
# (4) 检验三种化学成分是否相互独立 —— 计算相关系数与显著性检验

vars <- data[, 1:3]

# ①计算皮尔逊相关系数矩阵
cor_matrix <- cor(vars, method = "pearson")
cat("\n(4.1) 三个变量的皮尔逊相关系数矩阵：\n")
print(round(cor_matrix, 4))

# 各对变量的显著性检验（使用 cor.test）
var_names <- colnames(vars)
cat("\n(4.2) 各对变量的相关系数显著性检验结果：\n")

for(i in 1:(ncol(vars)-1)){
  for(j in (i+1):ncol(vars)){
    test_res <- cor.test(vars[[i]], vars[[j]], method = "pearson")
    cat("\n", var_names[i], " vs ", var_names[j], ":\n")
    cat("  相关系数 r =", round(test_res$estimate,4), "\n")
    cat("  p值 =", round(test_res$p.value,5), "\n")
    if(test_res$p.value < 0.05){
      cat("  → 结论：显著相关（拒绝独立假设）\n")
    } else {
      cat("  → 结论：不显著相关（不能拒绝独立假设）\n")
    }
  }
}

# 可视化散点图矩阵
pairs(vars, main = "Pairwise Scatterplot of Chemical Components",
      pch = 19, col = as.numeric(data$group))


