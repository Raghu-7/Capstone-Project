Word Prediction Application
========================================================
author: Santosh Pawar
date: Feb 03,2018
autosize: true

Develop the App model
========================================================

- App involves creating an algorithm for predicting the next word using one or more words as text input

- A large corpus of blog, news and twitter data is created and loaded 

- N-grams are extracted from the corpus and used to build a predictive model 


Algorithm for App
========================================================

- Dataset is cleaned by removing weblinks, twitter handles, punctuations, numbers, symbols, extra whitespaces etc

- Matrices from unigram to quadgram are extracted using RWeka 

- N-gram model with stupid back-off strategy is used


Shiny App interface
========================================================

- A text input box is provided for user to type a word/phrase

- Based on input words the application predicts the next word reactively

- Predicts using the longest, most frequent, matching N-gram


App and resources
========================================================

- Application can be viewed at: https://santipawar.shinyapps.io/ShinyApp

- Github link for Capstone project files: https://github.com/santipawar/Capstone-Project

- Project presentation can be found at: http://rpubs.com/santipawar/capstone-presentation
