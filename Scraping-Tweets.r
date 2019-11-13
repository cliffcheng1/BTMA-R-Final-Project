library(jsonlite)
library(stringr)
library(dplyr)
library(lubridate)

#Here I used different url bases so it can flow with the other scraping
temp.document2 <- list('anything')
trump.tweetdata <- data.frame()
url_base3 <- 'http://www.trumptwitterarchive.com/data/realdonaldtrump/'
url_base4 <- '.json'


#Instead of while looped, i used for loop from 2017-present, because Trump has been president since 2017
#Also I used a third-party archive to get the tweets because Twitter is protected by API
for(j in 2017:2019){
  url2 <- paste0(url_base3, j, url_base4)
  temp.document2 <- fromJSON(txt=url2)
  temp.data2 <- cbind(temp.document2$created_at,
                      temp.document2$text
                      )
  trump.tweetdata <- rbind(trump.tweetdata, temp.data2)
}
colnames(trump.tweetdata) <- c('date', 'content')


#Filtering for relevant keywords. Replace the green part with whatever
trump.tweetdata <- trump.tweetdata %>%
  filter(str_detect(content, "China | Chinese | Xi | Jinping"))


#Since the .json file has a weird time format, I created a new dataframe to correctly format to yyyy-mm-dd
#First I split it into multiple columns
tweets.dateformat <- str_split_fixed(trump.tweetdata$date," ",6)
tweets.dateformat <- as.data.frame(tweets.dateformat)

#Naming the columns
colnames(tweets.dateformat) <- c('dayofweek','month','dayofmonth','time','null','year')
tweets.dateformat <- data.frame(tweets.dateformat$year,tweets.dateformat$month,tweets.dateformat$dayofmonth)

#Changing month abbreviations to numbers
######THERES PROB A MORE SIMPLE WAY TO DO THIS#####
colnames(tweets.dateformat) <- c('year','month','day')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Jan",'1')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Feb",'2')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Mar",'3')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Apr",'4')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "May",'5')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Jun",'6')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Jul",'7')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Aug",'8')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Sep",'9')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Oct",'10')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Nov",'11')
tweets.dateformat$month <- str_replace(tweets.dateformat$month, "Dec",'12')

#Putting it into the right format, and using lubridate to classify it
trump.tweetdates <- ymd(paste(tweets.dateformat$year,tweets.dateformat$month,tweets.dateformat$day,sep='-'))
trump.tweetdates <- as.data.frame(trump.tweetdates)
trump.tweets <- cbind(trump.tweetdates,trump.tweetdata$content)
colnames(trump.tweets) <- c('date', 'content')
trump.tweets$date <- as.Date(trump.tweets$date)


#Selecting dates after 2017-01-20 cause thats when he started presidency
trump.tweets <- trump.tweets %>%
  select(date,content) %>%
    filter(date >= as.Date('2017-01-20'))


#Clean up junk objects in environment
rm(temp.data2)
rm(temp.document2)
rm(trump.tweetdata)
rm(trump.tweetdates)
rm(tweets.dateformat)
rm(j)
rm(url_base3)
rm(url_base4)
rm(url2)