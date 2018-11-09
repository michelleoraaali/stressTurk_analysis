library("dplyr")
setwd("/Users/michelleoraaali/Desktop")
gdata = read.csv("stressTurk_data_20181015_sort.csv", header  = T)
# gdata = transform(gdata,PresentationNum=as.numeric(PresentationNum))
# sort(gdata$PresentationNum, decreasing = FALSE)
colnames(gdata)

# code for word_num
new.df <- gdata %>% 
  group_by(participant, question, PresentationNum) %>% 
  mutate(wordnum=1:n())

# code for getting Nth instance of question
nthdf <- new.df %>%
  group_by(participant,item, question, condition, word_num) %>%
  mutate(Appearance=1:n())
#write.csv(nthdf,'nthdf.csv')