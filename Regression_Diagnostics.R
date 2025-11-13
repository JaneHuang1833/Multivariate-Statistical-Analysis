##======= Exercises 3-14 =======##
a=read.table("Tab4-8.txt",header=T)
dim(a); mode(a)
a[1:10,]

####============图方法（模型拟合前）===========####
## 一维图
Y=a[,1]
par(mfrow=c(2,2))	
hist(Y)
stem(Y)  # Y的茎叶图
dotchart(Y)
boxplot(Y)

## 二维图（图矩阵）
cor(a[,-1])
pairs(a[,-1])

## 三维图
X=t(t(a[,c(2:7)]))
n=nrow(X); p=ncol(X)
Y=a[,1]
lm1=lm(Y~X)

summary(lm1)
anova(lm1)


####============图方法（模型拟合后）===========####
par(mfrow=c(2,2))
## 4.7 检验线性及误差项的正态性、同方差性、独立性

## QQ 图

plot(lm1)

Yhat=fitted(lm1)
e=residuals(lm1)
Leverge=influence(lm1)$hat #杠杆值
sigma=summary(lm1)$sigma
#r=(e/sigma)*/(sqrt-Leverge))
r=rstandard(lm1) #标准化残差


qqnorm(r,ylab="Standardized residuals")
qqline(r)            ##绘制标准化残差的QQ图

## 标准化残差对自变量散点图 
par(mfrow=c(2,3))
plot(X[,1],r,xlab="X1",ylab=expression(paste(";Standardized","; residuals")))
plot(X[,2],r,xlab="X2",ylab=expression(paste(";Standardized","; residuals")))
plot(X[,3],r,xlab="X3",ylab=expression(paste(";Standardized",";residuals")))
plot(X[,4],r,xlab="X4",ylab=expression(paste(";Standardized","; residuals")))
plot(X[,5],r,xlab="X5",ylab=expression(paste(";Standardized","; residuals")))
plot(X[,6],r,xlab="X6",ylab=expression(paste(";Standardized","; residuals")))

## 标准化残差对拟合值散点图 ##
plot(Yhat,r,xlab="Fitted";,ylab=expression(paste("Standardized","residuals";)))

##标准化残差顺序图##
plot(r)


## 4.8节 异常点、高杠杆点、强影响点 检验有无强影响观测

Leverge=influence(lm1) #杠杆值

C=cooks.distance(lm1)      ## Cook 距离

DFITS=dffits(lm1)    ## Welsch and Kuh 度量

## Hadi度量
d_square=(e/sqrt(sum(e^2)))^2
H=(Leverge/(1-Leverge))+(p+1)*(1/(1-Leverge))*(d_square/(1-d_square))

par(mfrow=c(2,2))
plot(r)
plot(C)
plot(DFITS)
plot(H)

#位势-残差图
pot=Leverge/(1-Leverge)
res=(p+1)*(1/(1-Leverge))*(d_square/(1-d_square))
plot(res,pot, xlab="Residual",ylab="Potential")

text(res[34], pot[34], labels=34,adj=(.05)) # 标注强影响点
text(res[38], pot[38], labels=38,adj=(1))

# 判断是否为异常点
r[abs(r) > 2] 

# 判断是否为高杠杆点
Leverge[Leverge>2*(p+1)/n]
sort(H, decreasing = TRUE)[1:5]

#----筛选变量----
library(car)
X_1234 = X[,1:4]
X_12345 = X[,1:5]
X_12346 = X[,-5]
lm6=lm(Y~X_12346)  

# 添加变量图
avPlots(lm6) # 每个变量都有一张图

# 残差加分量图
crPlots(lm(Y~X1+X2+X3+X4+X6,data=data.frame(Y,X)))

summary(lm6)


