
#### ���}���Q�Υ�����,�p��U[�S�x]�����ˤ���

library(RODBC)
library(tidyverse)
library(recommenderlab)
library(reshape2)

##################################################################
## Helper function 
##################################################################

PredictFeatureScores <- function(features_tables,
                                 users_binary_data,
                                 modelList,
                                 n = 20){
  # inputs :
  # --------
  # features_tables : user features tags (class:named matrix -- userid, items)
  # users_binary_data : transaction data of predicted users (class: binaryRatingMatrix)
  # modelList : list of features model contain recommender 
  # n : predict top n items
  # ===================================================================
  # outputs : scores
  # ------------
  # 
  
  
  getUI_ScoreM <- function(pred_IBCF,user_features_matrix,rb){
    ## ================================================================
    ## input :
    ## -------
    ## pred_IBCF: IBCF model (class: Recommender)
    ## user_features : features matrix ,
    ## rb : predicted user transaction data (binaryRatingMatrix) 
    ## ================================================================
    ## output : 
    ## -------
    ## Predicted Scoring Matrix w.r.t pred_IBCF model and user_features
    ## ================================================================
    UI_MScore <- matrix(NA,ncol=ncol(rb),nrow=nrow(rb))
    dimnames(UI_MScore) <- dimnames(rb)
    for (i in 1:length(pred_IBCF@items)){
      UI_MScore[i,pred_IBCF@items[[i]]] <- pred_IBCF@ratings[[i]]
    }
    return(UI_MScore)
  }
  
}



# UI_IBCF_score_rating <- function(rb,rb_use){
#   #==========================================# �����D��!!!!! ######
#   ## input  
#   # rb : rating binary wrt features 
#   # rb_use : total rating binary used for transaction data
#   # output: u-i�S�x���Ưx�} 
#   #==========================================
#   reccIBCF <- Recommender(rb,'IBCF',parameter=list(normalize_sim_matrix=F))
#   
#   pred_IBCF <- reccIBCF@predict(model = reccIBCF@model,
#                                 newdata = rb_use,
#                                 n = 20,
#                                 type = "topNList")
#   UI_MatrixScore <- matrix(NA,ncol=ncol(rb_use),nrow=nrow(rb_use))
#   dimnames(UI_MatrixScore) <- dimnames(rb_use)
#   
#   for (i in 1:length(pred_IBCF@items)){
#     UI_MatrixScore[i,pred_IBCF@items[[i]] ] <- pred_IBCF@ratings[[i]]
#   }
#   UI_Features_Scores <- as(UI_MatrixScore,"realRatingMatrix")
#   return(UI_Features_Scores)
# }




# 1. �ꤺ�Ѳ������  -------------------------------------------------------------

##################################################################
## 1-1 ���Ū�X�P��z 
##################################################################
conn <- odbcDriverConnect("Driver=SQL Server;Server=dbm_public;Database=project2017;Uid=sa;Pwd=01060728;")

load('./�ҫ�����/���ʰ��ui���.RData')
# load('./�ҫ�����/fundsDistance.RData') ## gower distance ... funds sim
# r_b_purchase

funds_Ids <- r_b_purchase@data@itemInfo$labels ## 2,235 ## ��������ʶR���
funds_base <- sqlQuery(conn,"SELECT ����N�X FROM v_�������_����ݩ�",stringsAsFactors = F) ## MMA �u�W�c����
funds_base <- funds_base$����N�X

fundBoth <- funds_Ids %in% funds_base

funds_clus1 <- sqlQuery(conn,"SELECT * FROM v_�������_����ݩ� WHERE CLUSTER=1",stringsAsFactors=F)
funds_clus1 <- funds_clus1 %>% as_tibble()
funds1 <- funds_clus1$����N�X

# �����L�c�⪺��� #
rb_use <- r_b_purchase[,fundBoth] # 45,350 * 2,170 # ��:2,235 ...�ϥΪ�������...

###
indexID_dom <- which(colnames(rb_use) %in% funds1)

rb_use[,indexID_dom] ## 462�ꤺ�Ѳ��� (�������)

UI_dgCmatrix_dom <- as(rb_use,"dgCMatrix")
UI_dgCmatrix_dom[,-indexID_dom] <- 0 ## �D�ꤺ�Ѳ���=0

# image(UI_dgCmatrix_dom) ##45,350 * 2,170
rb_dom <- as(UI_dgCmatrix_dom,"realRatingMatrix")
rb_dom <- binarize(rb_dom,minRating=0.1)
rb_dom ## binary rating matrix 

## delete no data users ...
rb_dom <- rb_dom[rowCounts(rb_dom)!=0,]
rb_dom # 17,370 * 2,170

##### split data/train data???  ##############

##### reccomender feature 1   ###### 
recc_dom <- Recommender(data = rb_dom,
                          method = "IBCF",
                          parameter = list(method = "Jaccard"))

dataPredict1 <- predict(recc_dom,rb_use[1:10,])
##################################################################
## 1-2 IBCF ���ˤ���
##################################################################
# UI_IBCF_score_dom <- UI_IBCF_score_rating(rb_dom,rb_use) ## �ꤺ����� rating 

# 2. ��~�Ũ髬 ----------------------------------------------------------------


##################################################################
## 2-1 ���Ū�X�P��z 
##################################################################

funds_clus2 <- sqlQuery(conn,"SELECT * FROM v_�������_����ݩ� WHERE CLUSTER=2",stringsAsFactors=F)
funds_clus2 <- funds_clus2 %>% as_tibble()
funds2 <- funds_clus2$����N�X # 1031

indexID_foreign_bonds <- which(colnames(rb_use) %in% funds2)

rb_use[,indexID_foreign_bonds] ## 785 ��~�Ũ髬 (�������)

UI_dgCmatrix_foreign_bonds <- as(rb_use,"dgCMatrix")
UI_dgCmatrix_foreign_bonds[,-indexID_foreign_bonds] <- 0 ## �D��~�Ũ髬=0

# image(UI_dgCmatrix_dom) ##45,350 * 2,170
rb_bonds <- as(UI_dgCmatrix_foreign_bonds,"realRatingMatrix")
rb_bonds <- binarize(rb_bonds,minRating=0.1)
rb_bonds ## binary rating matrix 


rm(UI_dgCmatrix_foreign_bonds,UI_dgCmatrix_dom)
###### recommender feature 2 --- bonds #####
recc_bonds <- Recommender(data = rb_bonds,
                          method = "IBCF",
                          parameter = list(method = "Jaccard"))

dataPredict2 <- predict(recc_bonds,rb_use[1:10,])

##################################################################
## 2-2 IBCF ���ˤ���
##################################################################

# UI_IBCF_score_bonds <- UI_IBCF_score_rating(rb_bonds,rb_use) ## ��~�Ũ髬 rating 

# 3. ��~�Ѳ��� ----------------------------------------------------------------

##################################################################
## 3-1 ���Ū�X�P��z 
##################################################################

funds_clus3 <- sqlQuery(conn,"SELECT * FROM v_�������_����ݩ� WHERE CLUSTER=3",stringsAsFactors=F)
funds_clus3 <- funds_clus3 %>% as_tibble()
funds3 <- funds_clus3$����N�X # 1200

indexID_foreign_stocks <- which(colnames(rb_use) %in% funds3)

rb_use[,indexID_foreign_stocks] ## 923 ��~�Ѳ��� (�������)

UI_dgCmatrix_foreign_stocks <- as(rb_use,"dgCMatrix")
UI_dgCmatrix_foreign_stocks[,-indexID_foreign_stocks] <- 0 ## �D��~�Ѳ���=0

# image(UI_dgCmatrix_dom) ##45,350 * 2,170
rb_stocks <- as(UI_dgCmatrix_foreign_stocks,"realRatingMatrix")

rb_stocks <- binarize(rb_stocks,minRating=0.1)
rb_stocks ## binary rating matrix

###### recommender feature 3####
recc_stocks <- Recommender(data = rb_stocks,
                           method = "IBCF",
                           parameter = list(method = "Jaccard"))

dataPredict3 <- predict(recc_stocks,rb_use[1:10,])

rm(UI_dgCmatrix_foreign_stocks)
##################################################################
## 3-2 IBCF ���ˤ���
##################################################################
# UI_IBCF_score_stocks <- UI_IBCF_score_rating(rb_stocks,rb_use)


rm(UI_dgCmatrix_foreign_stocks,UI_dgCmatrix_foreign_bonds,UI_dgCmatrix_dom)
gc()

# image(UI_IBCF_score_bonds[1:10,1:100])


# �аO�Τ�S�x ------------------------------------------------------------------

SQL_trans <- " select b.cluster,a.�����Ҧr��,�������W�� from v_�������_���ʩ��� a
	  left join v_�������_����ݩ� b on left(a.�������W��,3) = b.����N�X
  where [���ʵn���~] >= 2015 "

user_purchase_details <- sqlQuery(conn,SQL_trans,stringsAsFactors = F)
user_purchase_details <- user_purchase_details %>% mutate_each(funs(factor),cluster) 
str(user_purchase_details)
user_purchase_details %>% head()

user_features <- 
  user_purchase_details %>% 
  mutate(fundId=substr(�������W��,1,3)) %>%
  group_by(�����Ҧr��,fundId,cluster) %>% 
  count() %>% 
  ungroup() %>% 
  arrange(desc(n)) 
  # dcast(�����Ҧr��~fundId,value.var="n")
user_features1 <- 
  user_features %>% 
  dcast(�����Ҧr��~cluster,fun.aggregate=sum,value.var='n') %>% 
  mutate(�ꤺ�Ѳ��� = ifelse(`1`!=0,1,0),
              ��~�Ũ髬 = ifelse(`2`!=0,1,0),
              ��~�Ѳ��� = ifelse(`3`!=0,1,0))

user_features1 %>% head(10)  ## ��� user_features1$�����Ҧr�� == rownames(r_b_purchase)
user_features1 %>% dim() # 45350

users_df <- data_frame(userid = rownames(rb_use))
user_features_matrix <- 
  user_features1 %>% 
  select(�����Ҧr��,�ꤺ�Ѳ���,��~�Ũ髬,��~�Ѳ���) %>% 
  left_join(users_df,by=c("�����Ҧr��" = "userid")) %>% 
  select(-�����Ҧr��) %>% 
  as.matrix()
rownames(user_features_matrix) <- user_features1$�����Ҧr��


# ���� SCORE ----------------------------------------------------------------

user_features_matrix %>% head()



## test 
m <- matrix(rnorm(100),ncol=5)
f <- matrix(sample(c(0,1),20,replace=T))
m
f

ans <- t(sapply(1:length(f1),function(i) m[i,]*f[i]))
ans2 <- t(sapply(1:length(f2),function(i) m[i,]*f2[i]))

sapply()


col1<-c(NA,1,2,3)
col2<-c(1,2,3,NA)
col3<-c(NA,NA,2,3)

rowSums(cbind(col1,col2,col3), na.rm=TRUE)
cbind(col1,col2,col3)





order(MScore_total[1,],na.last=NA,decreasing = T)



order(MScore2[1,],na.last=NA,decreasing = T)


MScore1[1,1264]

colnames(UI_MScore) <- colnames(rb_use)
rownames(UI_MScore) <- rownames(rb_use[1:10,])

dataPredict1@ratings


UI_MatrixScore <- matrix(NA,ncol=ncol(rb_use),nrow=nrow(rb_use))
dimnames(UI_MatrixScore) <- dimnames(rb_use)

for (i in 1:length(pred_IBCF@items)){
  UI_MatrixScore[i,pred_IBCF@items[[i]] ] <- pred_IBCF@ratings[[i]]
}
UI_Features_Scores <- as(UI_MatrixScore,"realRatingMatrix")






U1 <- as(UI_IBCF_score_dom,"dgCMatrix") # 45350*2170
U2 <- as(UI_IBCF_score_bonds,"dgCMatrix")
U3 <- as(UI_IBCF_score_stocks,"dgCMatrix")
image(U3)

u <- as(newdata,"dgCMatrix")

score_m <- U1 + U2 + U3

t(score_m) %*% x 
x %>% dim()

U1

x %>% dim()
image(score_m)

U <- as(UI_IBCF_score_stocks,"dgCMatrix")
x <- as(user_features_matrix,"dgCMatrix")
# rownames(U[1:10,]) == names(x[1:10])


U %>% dim()
u %>% dim()
x %>% dim()

apply(U,1,sum,na.rm=T)

score_m <- t(U) %*% x

score_m

matrix(x,ncol=1) 

image(as(U,'realRatingMatrix'))




# TEST --------------------------------------------------------------------


reccIBCF_dom <- Recommender(rb_dom,'IBCF',parameter = 
                              list(normalize_sim_matrix = F))

image(reccIBCF_dom@model$sim[indexID_dom,indexID_dom]) ## �ꤺ����ۦ���
image(reccIBCF_dom@model$sim) ## ��������ۦ���
# reccIBCF_dom@model
pred_dom_IBCF <- reccIBCF_dom@predict(model = reccIBCF_dom@model,
                                      newdata = rb_use,n=20,type="topNList")

# pred_dom_IBCF@items[1:10]
# pred_dom_IBCF@ratings[1:10]

## �إ�u-i�S�x���Ưx�} ###

UI_MatrixScore_dom <- matrix(NA,ncol=ncol(rb_use),nrow=nrow(rb_use))
dimnames(UI_MatrixScore_dom) <- dimnames(rb_use)
# pred_dom_IBCF@items[[1]]


for(i in 1:length(pred_dom_IBCF@items)){
  UI_MatrixScore_dom[i,pred_dom_IBCF@items[[i]]] <- pred_dom_IBCF@ratings[[i]]
} 


UI_score_dom <- as(UI_MatrixScore_dom,"realRatingMatrix")
UI_score_dom
# UI_score_dom@data@Dimnames
# 
# image(UI_score_dom[rownames(rb_dom),][1:100,1:50])

rm(UI_MatrixScore_dom,pred_dom_IBCF)

## =============================================================
##  total score 
## =============================================================

user_features_1to10 <- user_features_matrix[1:10,]
rb_use[1:10,]
UI_MScore <- matrix(NA,ncol=ncol(rb_use),nrow=10)  


getUI_ScoreM <- function(pred_IBCF,user_features_matrix,rb){
  ## ================================================================
  ## input :
  ## -------
  ## pred_IBCF: IBCF model (class: Recommender)
  ## user_features : features matrix ,
  ## rb : predicted user transaction data (binaryRatingMatrix) 
  ## ================================================================
  ## output : 
  ## -------
  ## Predicted Scoring Matrix w.r.t pred_IBCF model and user_features
  ## ================================================================
  UI_MScore <- matrix(NA,ncol=ncol(rb),nrow=nrow(rb))
  dimnames(UI_MScore) <- dimnames(rb)
  for (i in 1:length(pred_IBCF@items)){
    UI_MScore[i,pred_IBCF@items[[i]]] <- pred_IBCF@ratings[[i]]
  }
  return(UI_MScore)
}




m <- matrix(1:10,ncol=2)
m


## 
recommenderList <- list('recommender_dom'=recc_dom,
                 'recommender_bonds'=recc_bonds,
                 'recommender_stocks'=recc_stocks)

# ��󤣦P�S�x������ List
predictList <- 
lapply(recommenderList,function(rec)
  predict(rec,rb_use[1:10,],n=20)
  )
# (rownames(user_features_1to10) == rownames(rb_use[1:9,]))

## ���ꤺ�Ѳ���(feature1)�M�Ȥ��ݩʹw�����G(return Matrix rating)
getUI_ScoreM(predictList$recommender_dom,user_features_1to10,rb_use[1:10,]) #

## ���S�x�M�Ȥ��ݩʹw��(matrix rating �s��List )
UI_ScoreM_List <- 
lapply(predictList,function(rec){
  getUI_ScoreM(rec,user_features_1to10,rb_use[1:10])
})


## 
scoreList <- lapply(UI_ScoreM,function(scoreMatrix){
  score <- scoreMatrix
  score[which(is.na(scoreMatrix),arr.ind = T)] <-0
  return(score)
})


score_ans <- Reduce('+',scoreList)
rownames(score_ans) <- rownames(scoreList$recommender_dom) ## naming ##

## remove purchesed items for a user
rowCounts(rb_use[1,])
user1 <- as(rb_use[1,],"matrix")
which(user1 == T) ## ���R�� -- index:140
colnames(user1)[140]
rb_use[1,'310'] ## names : ����N�X --310 
## �靈�R���~�� score_ans �� -1 
rowCounts(rb_use[1:10,])
users <- as(rb_use[1:10,],"matrix")
score_ans[which(users == T,arr.ind = T)] <- -1 ## purchased items assign -1

colnames(user1)[c(5,1942)]
# for user 7 056270720 #
# ('120','T34' -- purchased--
# ,'J99' ,'T35' ,'78F','L91' ,'PD0','Z07','BL6') --- recommend ---
which(users == T,arr.ind = T)
## topN items and rating 
topNIndexs1 <- order(score_ans[1,],decreasing = T)[1:10]
score_ans[1,topNIndexs1]
rownames(score_ans)
topNListPredict <- list()
# topNListPredict[[1]] <- 1:10
# topNListPredict[[2]] <- 2:10
namesVec <- rownames(score_ans)
predict_List <- lapply(1:10,function(i){
  orderIndexs <- order(score_ans[i,],decreasing = T)[1:10] # topN index
  topNListPredict[[i]] <- score_ans[i,orderIndexs]
})
names(predict_List) <- namesVec
predict_List ## 

######## �p��s�� TopList Class ?? #########
lapply(predict_List,function(x) unames(x))

itemsets <- colnames(rb_use)
names(predict_List$`033591090`) %in% itemsets 
predict1_items <- names(predict_List$`033591090`)
itemsets[which(itemsets %in% predict1_items)]
predict1_items
## names ������ index 
sapply(predict1_items,function(x) which(itemsets==x)) # name->fundid, val->fundindex

# itemsets == names(predict_List$`033591090`) 
predFeaturesTest<-
new("topNList",
    items = lapply(predict_List,function(x) {
      itemNames <- names(x)
      sapply(itemNames,function(item) which(itemsets==item))
      }),
    ratings = lapply(predict_List, function(x){
     unname(x)
    }),
    n = 10
    )

##===================================================
predFeaturesTest@n

unname(predict_List$`033591090`)

items= lapply(predict_List,function(x) {
  itemNames <-names(x)
  sapply(itemNames,function(item) which(itemsets==item))
})
items