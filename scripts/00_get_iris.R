
iris_path <- "data/iris.csv"
# if(!file.exists(iris_path)){
data("iris")
write.csv(iris, iris_path, row.names = FALSE)
# }
