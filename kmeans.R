## K means clustering

## distance metric
## euclidian distance
## correlation similarity
## binary distance (city block)


# an initial number of cluster
# a guess of cluster centroids
# 
x = rnorm(30, mean=100, sd = 10)
y = rnorm(30, mean = 100, sd = 20)
plot(x, y)
df = data.frame(x, y)

## determine the number of clusters by looking at within group sum of squares
wss = (nrow(df) - 1) * sum(apply(df, 2, var))   ## '1' indicates matrix 2' indicates columns
## analysis for between 2 and 15 groups
for (i in 2:15){
    wss[i] = sum(kmeans(df, centers = i)$withinss)
}
plot(1:15, wss, type="b", 
     xlab = "Number of Clusters", 
     ylab = "Within groups sum of squares")

## change number of centers depending on plot of SS
kmeansObj = kmeans(df, centers = 4)
names(kmeansObj)
kmeansObj$centers
plot(x, y, col = kmeansObj$cluster)
points(kmeansObj$centers, col = 1:7, pch = 3, lwd = 3)
