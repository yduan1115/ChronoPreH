# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

install.packages("devtools")
library(devtools)
library(usethis)
use_git() #https://github.com/yduan1115/ChronoPreH

hello <- function() {
  print("Hello, world!")
}

#' Title of the Function
#'
#' Description of what the function does.
#'
#' @param x Description of the parameter `x`.
#' @return What the function returns.
#' @examples

# split a single string into many parts
x = "age, gender, height, BMI"
strsplit(x, split = ',')
str(strsplit(x, split=','))
unlist(strsplit(x, split=','))
strsplit(x, split=',')[[1]]

strsplit1 = function(x,split){
  strsplit(x,split=split)[[1]]
}























