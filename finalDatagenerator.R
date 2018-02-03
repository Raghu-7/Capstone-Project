
### Loading required libraries and parameters
options(java.parameters = '-Xmx12g' )
library(RWekajars)
library(qdapDictionaries)
library(qdapRegex)
library(qdapTools)
library(RColorBrewer)
library(qdap)
library(NLP)
library(tm)
library(SnowballC)
library(slam)
library(RWeka)
library(rJava)
library(wordcloud)
library(stringr)
library(DT)
library(stringi)
library(ngram)
library(RWeka)

### Data acquisition

### Loading the dataset

fileURL <- "http://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
download.file(fileURL, destfile = "Dataset.zip")
unlink(fileURL)
unzip("Dataset.zip")

## Sampling

## Loading the original data set
blogs <- readLines("./Coursera-SwiftKey/final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul=TRUE)
news <- readLines("./Coursera-SwiftKey/final/en_US/en_US.news.txt", encoding = "UTF-8", skipNul=TRUE)
twitter <- readLines("./Coursera-SwiftKey/final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul=TRUE)

## Generate a random sample using 10% of data from all sources
sampleTwitter <- twitter[sample(1:length(twitter),5000)]
sampleNews <- news[sample(1:length(news),5000)]
sampleBlogs <- blogs[sample(1:length(blogs),5000)]

## Combine sample data
textSample <- c(sampleTwitter,sampleNews,sampleBlogs)
complete_text <- c(twitter,news,blogs)

## Save sample
writeLines(textSample, "textSample.txt")
writeLines(complete_text, "completeSample.txt")


### Check the size and length of the files and calculate the word count
blogsFile <- file.info("./Coursera-SwiftKey/final/en_US/en_US.blogs.txt")$size / 1024.0 / 1024.0
newsFile <- file.info("./Coursera-SwiftKey/final/en_US/en_US.news.txt")$size / 1024.0 / 1024.0
twitterFile <- file.info("./Coursera-SwiftKey/final/en_US/en_US.twitter.txt")$size / 1024.0 / 1024.0
sampleFile <- file.info("./Capstone_Project_Final/textSample.txt")$size / 1024.0 / 1024.0

blogsLength <- length(blogs)
newsLength <- length(news)
twitterLength <- length(twitter)
sampleLength <- length(textSample)

blogsWords <- sum(sapply(gregexpr("\\S+", blogs), length))
newsWords <- sum(sapply(gregexpr("\\S+", news), length))
twitterWords <- sum(sapply(gregexpr("\\S+", twitter), length))
sampleWords <- sum(sapply(gregexpr("\\S+", textSample), length))

fileSummary <- data.frame(
  fileName = c("Blogs","News","Twitter", "Combined Sample"),
  fileSize = c(round(blogsFile, digits = 1), 
               round(newsFile,digits = 1), 
               round(twitterFile, digits = 1),
               round(sampleFile, digits = 1)),
  lineCount = c(blogsLength, newsLength, twitterLength, sampleLength),
  wordCount = c(blogsWords, newsWords, twitterWords, sampleWords)                  
)

colnames(fileSummary) <- c("File Name", "File Size in Megabyte", "Line Count", "Word Count")
saveRDS(fileSummary, file = "fileSummary.Rda")
fileSummaryDF <- readRDS("fileSummary.Rda")



## Build a clean sample - remove profanity
theSampleCon <- file("textSample.txt")
theSample <- readLines(theSampleCon)
close(theSampleCon)

profanityWords <- read.table("./Capstone_Project_Final/profanitywords.txt", header = FALSE)
badwords <- tolower(profanityWords)
badwords <- str_replace_all(badwords, "\\(", "\\\\(")

cleanSample <- Corpus(VectorSource(theSample))

rm(theSample)

## Build a formatted corpus
cleanSample <- tm_map(cleanSample,
                      content_transformer(function(x) 
                        iconv(x, to="UTF-8", sub="byte")))

cleanSample <- tm_map(cleanSample, content_transformer(tolower))
cleanSample <- tm_map(cleanSample, content_transformer(removePunctuation))
cleanSample <- tm_map(cleanSample, content_transformer(removeNumbers))
removeURL <- function(x) gsub("http[[:alnum:]]*", "", x) 
cleanSample <- tm_map(cleanSample, content_transformer(removeURL))
cleanSample <- tm_map(cleanSample, stripWhitespace)
cleanSample <- tm_map(cleanSample, removeWords, stopwords("english"))
cleanSample <- tm_map(cleanSample, stemDocument)

## Save final corpus
saveRDS(cleanSample, file = "finalCorpus.RDS")


#Tokenize unigrams
unigram <-NGramTokenizer(cleanSample, Weka_control(min = 1, max = 1))

#Tokenize bigrams
bigram<- NGramTokenizer(cleanSample, Weka_control(min = 2, max = 2))

#Tokenize trigrams
trigram<- NGramTokenizer(cleanSample, Weka_control(min = 3, max = 3))

#Tokenize quadgrams
quadgram<- NGramTokenizer(cleanSample, Weka_control(min = 4, max = 4))

# Calculate frequency of Unigrams, BiGrams, Trigrams and Quadgrams
unigram_freq <- data.frame(table(unigram))
unigram_ord <- unigram_freq[order(unigram_freq$Freq,decreasing = TRUE),]

bigram_freq <- data.frame(table(bigram))
bigram_ord <- bigram_freq[order(bigram_freq$Freq,decreasing = TRUE),]

trigram_freq <- data.frame(table(trigram))
trigram_ord <- trigram_freq[order(trigram_freq$Freq,decreasing = TRUE),]

quadgram_freq <- data.frame(table(quadgram))
quadgram_ord <- quadgram_freq[order(quadgram_freq$Freq,decreasing = TRUE),]

## Build final datasets (Uni-, Bi- and Tri-grams only) for prediction algorithm
quadgram <- as.data.frame(quadgram_ord)
quadgram_split <- strsplit(as.character(quadgram$quadgram),split=" ")
quadgram <- transform(quadgram,first = sapply(quadgram_split,"[[",1),second = sapply(quadgram_split,"[[",2),third = sapply(quadgram_split,"[[",3), fourth = sapply(quadgram_split,"[[",4))
quadgram <- data.frame(unigram = quadgram$first,bigram = quadgram$second, trigram = quadgram$third, quadgram = quadgram$fourth, freq = quadgram$Freq,stringsAsFactors=FALSE)
write.csv(quadgram[quadgram$freq > 1,],"./final4Data.csv",row.names=F)
quadgram <- read.csv("./final4Data.csv",stringsAsFactors = F)
saveRDS(quadgram,"./final4Data.RData")

trigram <- as.data.frame(trigram_ord)
trigram_split <- strsplit(as.character(trigram$trigram),split=" ")
trigram <- transform(trigram,first = sapply(trigram_split,"[[",1),second = sapply(trigram_split,"[[",2),third = sapply(trigram_split,"[[",3))
trigram <- data.frame(unigram = trigram$first,bigram = trigram$second, trigram = trigram$third, freq = trigram$Freq,stringsAsFactors=FALSE)
write.csv(trigram[trigram$freq > 1,],"./final3Data.csv",row.names=F)
trigram <- read.csv("./final3Data.csv",stringsAsFactors = F)
saveRDS(trigram,"./final3Data.RData")

bigram <- as.data.frame(bigram_ord)
bigram_split <- strsplit(as.character(bigram$bigram),split=" ")
bigram <- transform(bigram,first = sapply(bigram_split,"[[",1),second = sapply(bigram_split,"[[",2))
bigram <- data.frame(unigram = bigram$first,bigram = bigram$second, freq = bigram$Freq,stringsAsFactors=FALSE)
write.csv(bigram[bigram$freq > 1,],"./final2Data.csv",row.names=F)
bigram <- read.csv("./final2Data.csv",stringsAsFactors = F)
saveRDS(bigram,"./final2Data.RData")

