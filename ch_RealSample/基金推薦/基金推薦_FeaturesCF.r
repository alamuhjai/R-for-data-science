
#### ���}���Q�Υ�����,�p��U[�S�x]�����ˤ���
set.seed(10)
library(RODBC)
library(tidyverse)
library(recommenderlab)
library(reshape2)
library(stringr)

##################################################################
## Helper function 
##################################################################

PredictFeatureScores <- function(features_tables,
                                 users_binary_data,
                                 modelList,
                                 item_reccomend = 20){
  # ================================================================
  # Predict topNList items for users  
  # ================================================================
  # inputs :
  # --------
  # features_tables : user features tags 
  #                 - class : named matrix 
  # users_binary_data : transaction data of predicted users 
  #                 - class : binaryRatingMatrix
  # modelList : list of features model contain recommender 
  # n : predict top n items
  # ================================================================
  # outputs : 
  # ---------
  # predict score (class: TopNList )
  
  ## check 
  if(any(rownames(features_tables) != rownames(users_binary_data)))
    stop("rowname of [features_tables] and [users_binary_data] must consistent")
  
  
  # Recommender List based on different model (features).
  predictItemList <- 
    lapply(modelList,function(rec)
      predict(rec,users_binary_data,n=item_reccomend)
    )
  
  # 
  
  getUI_ScoreM <- function(recc_model,user_features_matrix,rb){
    ## ================================================================
    ## For a given feacture based model, 
    ##  performing features weighting and score again. 
    ## ================================================================
    ## input :
    ## -------
    ## model: model (class: Recommender)
    ## user_features : features matrix
    ## rb : predicted user transaction data (binaryRatingMatrix) 
    ## ================================================================
    ## output : 
    ## -------
    ## Predicted Scoring Matrix w.r.t recc_model and user_features
    ## ================================================================
    UI_MScore <- matrix(NA,ncol=ncol(rb),nrow=nrow(rb))
    # dimnames(UI_MScore) <- dimnames(rb)
    for (i in 1:length(recc_model@items)){
      UI_MScore[i,recc_model@items[[i]]] <- recc_model@ratings[[i]]
    }
    return(UI_MScore)
  }
  
  ## ���S�x�M�Ȥ��ݩʹw��(matrix rating �s��List )
  UI_ScoreM_List <- 
    lapply(predictItemList,function(rec){
      getUI_ScoreM(rec,features_tables,users_binary_data)
    })
  ## remove NA to 0
  scoreList <- lapply(UI_ScoreM_List,function(scoreMatrix){
    score <- scoreMatrix
    score[which(is.na(scoreMatrix),arr.ind = T)] <-0
    return(score)
  })
  ## �̫�scores���� ##
  
  itemsets <- colnames(users_binary_data)
  scores <- Reduce('+',scoreList) # Matrix with the same dim as users_binary_data
  
  rownames(scores) <- rownames(users_binary_data) ## naming ##
  colnames(scores) <- itemsets
  
  ## browser() ## debuger
  
  ## �靈�R���~�� scores �� -1 
  users <- as(users_binary_data,"matrix")
  scores[which(users == T,arr.ind = T)] <- -1 ## purchased items assign -1
  
  ## ���ͱ��˲M�� ## 
  
  topNListPredict <- list()
  predict_Feature_List <- lapply(1:nrow(users_binary_data),function(i){
    orderIndexs <- order(scores[i,],decreasing = T)[1:item_reccomend] # topN index
    topNListPredict[[i]] <- scores[i,orderIndexs]
  })
  
  names(predict_Feature_List) <- rownames(users_binary_data)
  
  ## ���˲M���নtopNList ##
  
  pred_Feature_TopNList <-
    new("topNList",
        items = lapply(predict_Feature_List,function(x) {
          itemNames <- names(x)
          sapply(itemNames,function(item) which(itemsets==item))
        }),
        ratings = lapply(predict_Feature_List, function(x){
          unname(x)
        }),
        itemLabels = itemsets,
        n = as.integer(item_reccomend)
    )
  return(pred_Feature_TopNList)
}



##################################################################
## ���Ū�X�P��z 
##################################################################
conn <- odbcDriverConnect("Driver=SQL Server;Server=dbm_public;Database=project2017;Uid=sa;Pwd=01060728;")

load('./�ҫ�����/���ʰ��ui���.RData')

## �ޤJHYBRID IBCF/UBCF ,item/users similarity
source('src/RECOM_IBCF_HYBRID.R')
source('src/RECOM_UBCF_HYBRID.r')
load('./�ҫ�����/fundsDistance.RData')
# load('./�ҫ�����/usersDistance.RData')

fund_ids <- r_b_purchase@data@itemInfo$labels ## 2,235
base_ids <- funds$����N�X ## 2,777
both_ids <-  base_ids %in% fund_ids 
both_ids2 <- fund_ids %in% base_ids
gower_mat <- as.matrix(gower_distance)
gower_mat <- gower_mat[both_ids,both_ids]
gower_mat %>% dim() # 2,170


funds_Ids <- r_b_purchase@data@itemInfo$labels ## 2,235 ## ��������ʶR���
funds_base <- sqlQuery(conn,"SELECT ����N�X FROM v_�������_����ݩ�",stringsAsFactors = F) ## MMA �u�W�c����
funds_base <- funds_base$����N�X

fundBoth <- funds_Ids %in% funds_base


# �����L�c�⪺��� #
rb_use <- r_b_purchase[,fundBoth] # 45,350 * 2,170 # ��:2,235 ...�ϥΪ�������...
rb_use <- rb_use[!rowCounts(rb_use)==0,] ## delete no data user , 45,288
# �������ʼ�=1����� #
rb_use <- rb_use[rowCounts(rb_use)>1] ##
rb_use ## 26,622 * 2170

# �Ȥ�201705 CRM data 
user_datasets <- sqlQuery(conn,
                          "select * from Test.dbo.v_Shane_����Ȥ���s_��¦",
                          stringsAsFactors=F)
ids <- rownames(rb_use)
ids_data <- user_datasets$�����Ҧr��
ids_data <- str_trim(ids_data)


# ��������Ȥ�/���q�� ##
rb_use <- rb_use[ids[(ids %in% ids_data)],] ## 26,621 * 2,170 ->26,324





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

# ����S�x(�ꤺ�~/�Ѳ�/�Ũ�) used #
features_used <- user_features_matrix[rownames(rb_use),] 

# �Τ� AUM��T #
load('./�ҫ�����/AUM�x�}.RData')

fund1 %>% as_tibble() %>% 
  filter(`1`==1) 

fund1[is.na(fund1)] <- 0
rownames(rb_use)
# rb_use # 26,621

fund1$�����Ҧr�� <- str_trim(fund1$�����Ҧr��)
fund1 <- 
  fund1 %>% 
  filter(str_trim(�����Ҧr��) %in% rownames(rb_use))
colnames(fund1) <- c('�����Ҧr��',
                     'a.AUM:0��',
                     'b.AUM:0~100�U��',
                     'c.AUM:100~300�U��',
                     'd.AUM:300�U���H�W')

features_used1 <- 
  features_used %>% 
  as.data.frame() %>% 
  rownames_to_column('�����Ҧr��')

features_used <- 
  features_used1 %>% 
  as_tibble() %>% 
  left_join(fund1) 


rownames(features_used) <- features_used$�����Ҧr��
features_used$�����Ҧr�� <- NULL
features_used <- as.matrix(features_used)
head(features_used)
### build model from features ##

dom_id <- names(which(features_used[,1]==1 ))  #12838
bonds_id <- names(which(features_used[,2]==1)) # 17824
stocks_id <- names(which(features_used[,3]==1))# 19114
rb_use[dom_id,]
rb_use[bonds_id,]
rb_use[stocks_id,]



# �ҫ����� ----------------------------------------------------------------
# modelList <- list(f1 = recc_dom,f2=recc_bonds,f3=recc_stocks) 

rb_use <- rb_use[!rowCounts(rb_use)==0,] ## delete no data user , 26,622

eval_sets <- evaluationScheme(data = rb_use,
                              method = "cross",
                              k = 4,
                              # train = 0.9,
                              # k = 1,
                              given = -1)


train_data <- getData(eval_sets,"train") ## ���θ��,��train�إ�model

## Build features based Model ####
number_neighbors = 30


train_features_used = features_used[rownames(train_data),]
# features UBCF #
modelListU <- 
lapply(1:dim(features_used)[2],function(x){
  ids <- names(which(train_features_used[,x] == 1))
  Recommender(train_data[ids,],method='UBCF',
              parameter = list(nn = number_neighbors))
})

# modelList <- list(f1=model1,f2=model2,f3=model3)
# modelListU <- list(f1=model1_u,f2=model2_u,f3=model3_u)
userids <- rownames(rb_use)
test_rownames <- userids[!userids %in% rownames(train_data)]   # 6657



# Evaluate  ---------------------------------------------------------------

# features based IBCF
# eval_pred_list <- lapply(c(3,5,10,15,20),function(x){
#   PredictFeatureScores(features_tables = user_features_matrix[test_rownames,],
#                        modelList = modelList,
#                        users_binary_data = getData(eval_sets,"known"), ## �����ƶ���known part�ӹw��unknown part##
#                        item_reccomend = x)
# })

# features based UBCF
eval_pred_listU <- lapply(c(3,5,10,15,20),function(x){
  PredictFeatureScores(features_tables = user_features_matrix[test_rownames,],
                       modelList = modelListU,
                       users_binary_data = getData(eval_sets,"known"), ## �����ƶ���known part�ӹw��unknown part##
                       item_reccomend = x)
})


# feature based UBCF
eval_acc_listU <-  
  lapply(eval_pred_listU,function(eval_pred){
    calcPredictionAccuracy(
      x = eval_pred,
      data = getData(eval_sets, "unknown"),
      byUser = F,
      given = 10
    )
  })

# acc_features <- sapply(eval_acc_list,'[',c('TPR','FPR'))
acc_featuresU <- sapply(eval_acc_listU,'[',c('TPR','FPR'))
n <- c(3,5,10,15,20)
# acc_features <- rbind(acc_features,n)
# acc_features <- 
#   t(acc_features) %>% 
#   as.tibble() %>% 
#   mutate(algo = "FEATURES_IBCF")
  
acc_featuresU <- 
  t(acc_featuresU) %>% 
  as.tibble() %>% 
  mutate(algo = "FEATURES_UBCF") %>% 
  cbind(n)



#### �P ibcf/ubcf/popular ��� ####
# ibcf recommender
recc_ibcf <- Recommender(train_data,
                         method = "IBCF",
                         parameter = list(method = "Jaccard",k = number_neighbors))


# ubcf recommender
recc_ubcf <- Recommender(train_data,
                         method='UBCF',
                         parameter = list(method = "Jaccard",nn = number_neighbors)
                         )
# popular recommender
recc_pop <- Recommender(train_data,method='Popular')
# hybrid content + IBCF recommender
rec_ibcf_hybrid <- 
  Recommender(train_data,method="IBCF_HYBRID",
              parameter = list(method = "Jaccard",
                               W=0.1,
                               simContent = 1- gower_mat,
                               k = number_neighbors))


# hybrid content UBCF recommender 
# rec_ubcf_hybrid <- 
#   Recommender(train_data,method = "UBCF_HYBRID",
#               parameter = list(method = "Jaccard",W=0.1,simContent = 1-gower_mat_U))


# eval
# ibcf
eval_pred_ibcf <- lapply(n,function(i){
  predict(object = recc_ibcf,
          newdata = getData(eval_sets,"known"),
          n = i,
          type = "topNList")
  })
# hybrid ibcf
eval_pred_ibcf_hybrid <- lapply(n,function(i){
  predict(object = rec_ibcf_hybrid,
          newdata = getData(eval_sets,"known"),
          n = i,
          type = "topNList")
})

# ubcf
eval_pred_ubcf <- lapply(n,function(i){
  predict(object = recc_ubcf,
          newdata = getData(eval_sets,"known"),
          n = i,
          type = "topNList")
})
##### �����V�X��UBCF Weighting (�L�u��ubcf) #####
# hybrid content ubcf

## �L�klapply�@���p��(�]�O����W��)....
# recc_ubcf <- Recommender(train_data,
#                          method='UBCF')
# rec_ubcf_hybrid <- 
#   Recommender(train_data,method = "UBCF_HYBRID",
#               parameter = list(method = "Jaccard",
#                                # nn = 50,
#                                W = 1,
#                                simContent = 1-gower_mat_U))
# 
# # pred_ubcf <- predict(recc_ubcf,newdata = getData(eval_sets,"known"),n=20)  
# pred_ubcf_hybrid <- predict(rec_ubcf_hybrid,
#                             newdata = getData(eval_sets,"known"),
#                             n = 20,
#                             type = "topNList")

# acc_ubcf <- calcPredictionAccuracy(
#   x = pred_ubcf,
#   data = getData(eval_sets,"unknown"),
#   byUser = F,
#   given = 10
# )




# acc_hybrid_ubcf_w05 <- calcPredictionAccuracy(
#   x = pred_ubcf_hybrid,
#   data = getData(eval_sets,"unknown"),
#   byUser = F,
#   given = 10)

################################################
# popular
eval_pred_pop <- lapply(n,function(i){
  predict(object = recc_pop,
          newdata = getData(eval_sets,"known"),
          n = i,
          type = "topNList")
})


### eval accuracy ###
# ibcf 
eval_acc_list_ibcf <- 
  lapply(eval_pred_ibcf,function(eval_pred){
    calcPredictionAccuracy(
      x = eval_pred,
      data = getData(eval_sets,"unknown"),
      byUser = F,
      given = 10
    )
})
# hybrid ibcf
eval_acc_list_ibcf_hybrid <- 
  lapply(eval_pred_ibcf_hybrid,function(eval_pred){
    calcPredictionAccuracy(
      x = eval_pred,
      data = getData(eval_sets,"unknown"),
      byUser = F,
      given = 10
    )
  })

# ubcf
eval_acc_list_ubcf <- 
  lapply(eval_pred_ubcf,function(eval_pred){
    calcPredictionAccuracy(
      x = eval_pred,
      data = getData(eval_sets,"unknown"),
      byUser = F,
      given = 10
    )
  })
# hybrid content ubcf 
# acc_hybrid_ubcf <- calcPredictionAccuracy(
#   x = pred_ubcf_hybrid20,
#   data = getData(eval_sets,"unknown"),
#   byUser = F,
#   given = 10)
# pop
eval_acc_list_pop <- 
  lapply(eval_pred_pop,function(eval_pred){
    calcPredictionAccuracy(
      x = eval_pred,
      data = getData(eval_sets,"unknown"),
      byUser = F,
      given = 10
    )
  })


## combine TPR,FPR .. into one dataframe

acc_pop <- sapply(eval_acc_list_pop,'[',c('TPR','FPR'))
acc_ibcf <- sapply(eval_acc_list_ibcf,'[',c('TPR','FPR'))
acc_ubcf <- sapply(eval_acc_list_ubcf,'[',c('TPR','FPR'))
acc_ibcf_hybrid <- sapply(eval_acc_list_ibcf_hybrid,'[',c('TPR','FPR'))
n <- c(3L,5L,10L,15L,20L)
acc_ibcf <- rbind(acc_ibcf,n)
acc_ubcf <- rbind(acc_ubcf,n)
acc_pop <- rbind(acc_pop,n)
acc_ibcf_hybrid <- rbind(acc_ibcf_hybrid,n)


acc_df_ibcf <- t(acc_ibcf) %>% as.tibble()
acc_df_ubcf <- t(acc_ubcf) %>% as.tibble()
acc_df_pop <- t(acc_pop) %>% as.tibble()
acc_df_ibcf_hybrid <- t(acc_ibcf_hybrid) %>% as.tibble()

acc_df_ibcf_hybrid <- acc_df_ibcf_hybrid %>% mutate(algo = "IBCF_Hybrid")
acc_df_ibcf <- acc_df_ibcf %>% mutate(algo = "IBCF")
acc_df_ubcf <- acc_df_ubcf %>% mutate(algo = "UBCF")
acc_df_pop <- acc_df_pop %>% mutate(algo = "POPULAR")


acc_df_tot <-  acc_featuresU %>% 
  rbind(acc_df_ibcf,acc_df_ubcf,acc_df_pop,acc_df_ibcf_hybrid) 
  
# load(file='./�ҫ�����/ev_result_features.RData')

# ���efeature IBCF, 
# acc_df_tot %>% filter(algo == 'UBCF')
ggplot(acc_df_tot 
       ,aes(x=FPR,y=TPR,color=algo)) + 
  geom_point() + geom_line() +
  annotate("text", x = c(0.0015,0.0023,0.0046,0.0068,0.0092), 
           y = c(0.175,0.21,0.28,0.32,0.35) ,
           label = c('n=3','n=5','n=10','n=15','n=20')) +
  annotate("text", x=0.0085, y=0.2, label= "cv: 4") +
  ggtitle('ROC')

acc_df_temp <- acc_df_tot %>% filter(algo %in% 
                                       c('IBCF','IBCF_Hybrid','POPULAR'))

ggplot(acc_df_temp 
       ,aes(x=FPR,y=TPR,color=algo)) + 
  geom_point() + geom_line() +
  annotate("text", x = c(0.0015,0.0023,0.0046,0.0068,0.0092), 
           y = c(0.11,0.16,0.23,0.27,0.31) ,
           label = c('n=3','n=5','n=10','n=15','n=20')) +
  annotate("text", x=0.0085, y=0.2, label= "cv: 4") +
  ggtitle('ROC')




save(
    eval_acc_listU,
      eval_acc_list_ibcf,
      eval_acc_list_ubcf,
      eval_acc_list_pop,
      acc_df_tot,file = './�ҫ�����/ev_result_featuresU.RData')




# ���˲M��List  ------------------------------------------------------------

## evaluate test sets lists

##  
rb_use[test_rownames,] # test data 
rb_test_known <- getData(eval_sets,"known") #test data known part 
rb_test_unknown <- getData(eval_sets,"unknown") # test data unknown part
##

featuresU_topNList <- 
  PredictFeatureScores(features_tables = user_features_matrix[test_rownames,],
                       modelList = modelListU,
                       users_binary_data = getData(eval_sets,"known"), ## �����ƶ���known part�ӹw��unknown part##
                       item_reccomend = 20)


df_t <- t(data.table::as.data.table(as(featuresU_topNList,"list")))
itemNames <- sapply('���',paste0,c(1:20))[,1]

df_predict <- df_t

colnames(df_predict) <- itemNames
df_predict <- as_tibble(df_predict) %>% 
  mutate(id = test_rownames)

# feature table (dataframe)
df_features <- 
  features_used %>% 
  as.data.frame() %>% 
  rownames_to_column('id')

# predict dataframe for test sets (�w��w����test sets�w��)
df_predict[1:10,] %>% 
  select(1:20,id) %>% 
  left_join(df_features,by = c("id"="id")) %>% 
  write.table("clipboard",sep='\t',row.names = F)

# known part

as(rb_test_known[1:10,],"list")[[8]]

as(rb_test_unknown[1:10,],"list")


### �����˲M��### 

number_neighbors = 30
modelListUAll <- 
  lapply(1:dim(features_used)[2],function(x){
    ids <- names(which(features_used[,x] == 1))
    Recommender(rb_use[ids,],method='UBCF',
                parameter = list(nn = number_neighbors))
  })



## features ���w�����G(�Ӯ�!! > 2hrs,26,324*2170 �H) ##
## (�ݧ�i��k)
featuresU_topNList <- 
  PredictFeatureScores(features_tables = features_used,
                       modelList = modelListUAll,
                       users_binary_data =rb_use,
                       item_reccomend = 20)

featuresU_topNList@items[1:10]

## list to dataframe 
df_predict <- t(data.table::as.data.table(as(featuresU_topNList,"list")))
itemNames <- sapply('���',paste0,c(1:20))[,1]

colnames(df_predict) <- itemNames # colname :���1,���2....
df_predict_ids <- rownames(df_predict) # rowname -> ids

df_predict1 <- df_predict %>% 
  as.data.frame() %>% 
  rownames_to_column('id') %>% 
  left_join(df_features) %>% 
  mutate_at(vars(contains('���')),funs(as.character)) %>% 
  mutate_at(vars(contains('AUM')),funs(as.integer)) %>% 
  mutate_at(vars(contains('��')),funs(as.integer)) %>% 
  rename(a_AUM_0 = `a.AUM:0��`) %>% 
  rename(b_AUM_100 = `b.AUM:0~100�U��`) %>% 
  rename(c_AUM_300 = `c.AUM:100~300�U��`) %>% 
  rename(d_AUM_300 = `d.AUM:300�U���H�W`)
  

## �w�����G(�t�S�xtable) �W��db
df_predict1 %>% head()
str(df_predict1)
sqlSave(conn,
        df_predict1,
        tablename = "�������_�S�x���UBCF_���M��",
        rownames = F)

## �p����˰����(�Ƨ�)
df_predict1  %>%
  select(contains('���'),1) %>% 
  melt(id='id') %>% 
  group_by(value) %>% 
  summarize(count_n = n()) %>% arrange(desc(count_n))
  

###############################################################################
# TEST --------------------------------------------------------------------


### jaccard similarity using sparse matrix 

A = tcrossprod(m2)

jaccard_similarity <- function(m) {
  A <- tcrossprod(m)
  im <- which(A > 0, arr.ind=TRUE, useNames = F)
  b <- rowSums(m)
  Aim <- A[im]
  sparseMatrix(
    i = im[,1],
    j = im[,2],
    x = Aim / (b[im[,1]] + b[im[,2]] - Aim),
    dims = dim(A)
  )
}

jaccard_distance <- function(m) {
  1 - jaccard_similarity(m)
}

