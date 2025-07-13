
# Brief Overview
The sound.ipynb file is a dataset that has several vocal biometrics and several metrics for a vocal note, per person. They were both controls and PD cases in the dataset. The data was preprocessed and several machine learning algorithms were trained to see which one better performs well on unseen data and which one would be kept for deployment via fe

# Summary of Models and Feature selection
I aimed for models good at doing binary classification (0 for "Healthy" and 1 for "PD patients"). I'm also linking what features (aimed for 6) were important based on the several feature selection I did

LogisticRegression: Accuracy: 82%
                    Recall: 76%
                    Precision: 78%
                    Feature selection method: SelectKBest: []

RandomForestClassifier: Accuracy: 86%
                        Precision: 83%
                        Recall: 80%
                        Feature selection methood : feature_importances_ attribute: [
                            tqwt_TKEO_std_dec_12, std_7th_delta, std_8th_delta, std_9th_delta_delta, tqwt_TKE0_mean_dec_12, 
                        ]

Support Vector Machine: Accuracy: 86%
                        Precision: 86%
                        Recall: 77%
                        Feature selection method : permutation importance [
                            'b4', 
                            'tqwt_meanValue_dec_21',
                             'tqwt_TKEO_std_dec_11',
                           'tqwt_entropy_shannon_dec_29', 
                           'tqwt_kurtosisValue_dec_26',
                         'tqwt_kurtosisValue_dec_27']   --> This deviates a lot from other features

XGBoost: Accuracy: 81%
         Recall : 81%
         Precision: 82%
         Feature selection method: feature_importances_ attribute: [std_9th_delta_delta, std_8th_delta
         tqwt_entropy_log_dec_20
         tqwt_entropy_shannon_dec_36
         tqwt_TKEO_std_dec_12    
         app_entropy_shannon_1_coef]

                    
# Relevance for deployment phase
I will extract the important voice inputs during vocal transmission during the deployment to fit into the model (The paper indicates how to measure each feature)


