library("tidyverse")
library("dplyr")

setwd("/Users/michelleoraaali/Desktop")
gdata = read.csv("stressTurk_data_20181101.csv", header  = T, na.strings="--undefined--")
# gdata = gdata[gdata$index == '1',]
# write.csv(gdata,'stressTurk_data_20181101_1.csv')
# gdata = gdata[gdata$word != 'sp',]
# # code for wordnum
# new.df <- gdata %>%
#   group_by(participant, question, presentationnum)%>%
#   mutate(wordnum=row_number())
# 
# 
# # # code for getting Nth instance of question
# # nthdf <- new.df %>%
# #   group_by(participant,item, question, condition, wordnum) %>%
# #   mutate(Appearance=1:n())
# # #write.csv(nthdf,'nthdf.csv')
# 
# # # subsetting it to relevant Nth appearance
# # workingdf <- nthdf %>%
# #   filter (Appearance == 2)
# 
# write.csv(new.df,'newdf.csv')

normalize_data = function(df,col_name,remove_outliers){
  df[[col_name]] = scale(df[[col_name]])
  if(remove_outliers){
    df = df[df[[col_name]]>-2 & df[[col_name]]<2,]
  }
  return(df)
}

process_data = function(file_name){
  df <- read.csv(file_name,header = TRUE, fileEncoding="UTF-8",na.strings=c("", "NA"))
  
  
  #df = df[df$wordlabel != 'sp']
  df$item = as.factor(df$item)
  
  
  
  df_agent = df[(df$condition=='agent' | df$condition=='baseline') & df$wordnum=='2',]
  
  df_verb = df[(df$condition=='verb'| df$condition=='baseline') & df$wordnum=='4',]
  
  df_patient = df[(df$condition=='patient'| df$condition=='baseline') & df$wordnum=='5',]
  
  
  relevant_columns = c('participant','item','condition','duration','meanIntensity','meanpit','index')
  df_agent = df_agent[relevant_columns]
  df_verb = df_verb[relevant_columns]
  df_patient = df_patient[relevant_columns]
  
  df_agent = df_agent[df_agent$duration!='--undefined--' & df_agent$meanIntensity!='--undefined--' &  df_agent	$meanpit!='--undefined--' ,]
  df_agent = transform(df_agent,duration=as.numeric(duration))
  df_agent = transform(df_agent, meanIntensity = as.numeric(meanIntensity))
  df_agent = transform(df_agent, meanpit = as.numeric(meanpit))
  
  df_patient = df_patient[df_patient$duration!='--undefined--' & df_patient$meanIntensity!='--undefined--' &  df_patient$meanpit!='--undefined--' ,]
  df_patient = transform(df_patient,duration=as.numeric(duration))
  df_patient = transform(df_patient, meanIntensity = as.numeric(meanIntensity))
  df_patient = transform(df_patient, meanpit = as.numeric(meanpit))
  
  df_verb = df_verb[df_verb$duration!='--undefined--' & df_verb$meanIntensity!='--undefined--' &  df_verb$meanpit!='--undefined--' ,]
  df_verb = transform(df_verb,duration=as.numeric(duration))
  df_verb = transform(df_verb, meanIntensity = as.numeric(meanIntensity))
  df_verb = transform(df_verb, meanpit = as.numeric(meanpit))
  
  df_agent_duration = normalize_data(df_agent,'duration',TRUE)
  df_agent_meanIntensity = normalize_data(df_agent,'meanIntensity',TRUE)
  df_agent_meanpit = normalize_data(df_agent,'meanpit',TRUE)
  
  df_patient_duration = normalize_data(df_patient,'duration',TRUE)
  df_patient_meanIntensity = normalize_data(df_patient,'meanIntensity',TRUE)
  df_patient_meanpit = normalize_data(df_patient,'meanpit',TRUE)
  
  df_verb_duration = normalize_data(df_verb,'duration',TRUE)
  df_verb_meanIntensity = normalize_data(df_verb,'meanIntensity',TRUE)
  df_verb_meanpit = normalize_data(df_verb,'meanpit',TRUE)
  
  return(list(df_agent_duration, df_agent_meanIntensity, df_agent_meanpit, df_patient_duration, df_patient_meanIntensity, df_patient_meanpit,df_verb_duration, df_verb_meanIntensity, df_verb_meanpit))
}




run_regression = function(df,observation){
  r = lmer(get(observation) ~ condition + (1 + condition|participant) + (1 + condition | item), data=df)
  summary(r)
}

combine_datasets = function(agent,verb,patient){
  library(plyr)
  agent$condition = mapvalues(agent$condition,c('agent'),c('contrast'))
  verb$condition = mapvalues(verb$condition,c('verb'),c('contrast'))
  patient$condition = mapvalues(patient$condition,c('patient'),c('contrast'))
  
  agent$Location = 'Agent - Sandy'
  verb$Location = 'Verb - Kicking'
  patient$Location = "Patient - Andy"
  
  return(rbind(agent,verb,patient))
}

summarize_data = function(d){
  library(Rmisc)
  return(summarySE(d,measurevar='duration',groupvars=c('Location','condition')))
}


library(lme4)
library(zeallot)

file_name = 'stressTurk_data_20181101_2.csv'

c(df_agent_duration, df_agent_meanIntensity, df_agent_meanpit, df_patient_duration, df_patient_meanIntensity, df_patient_meanpit,df_verb_duration, df_verb_meanIntensity, df_verb_meanpit) %<-%process_data(file_name)


run_regression(df_agent_duration,'duration')
# run_regression(df_agent_meanIntensity,'meanIntensity')
# run_regression(df_agent_meanpit,'meanpit')

run_regression(df_patient_duration,'duration')
# run_regression(df_patient_meanIntensity,'meanIntensity')
# run_regression(df_patient_meanpit,'meanpit')

run_regression(df_verb_duration,'duration')
# run_regression(df_verb_meanIntensity,'meanIntensity')
# run_regression(df_verb_meanpit,'meanpit')





plot_data = function(d,title){
  library(ggplot2)
  ggplot(d, aes(x=Location, y=duration, fill=condition)) + 
    geom_bar(position=position_dodge(), stat="identity") +
    geom_errorbar(aes(ymin=duration-ci, ymax=duration+ci),
                  width=.2,                   
                  position=position_dodge(.9))+
    xlab("Location") +
    ylab("Duration") +
    scale_fill_hue(name="Condition", 
                   breaks=c("baseline", "contrast"),
                   labels=c("NonContrastive", "Contrastive")) +
    ggtitle(title) 
}


combined_dataset_duration = combine_datasets(df_agent_duration, df_verb_duration, df_patient_duration)
summarized_dataset_duration = summarize_data(combined_dataset_duration)


plot_data(summarized_dataset_duration,title='Effect of contrast on duration: Second Trials of Each Condition')