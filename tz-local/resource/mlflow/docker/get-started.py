import mlflow


# In[4]:


mlflow.set_tracking_uri("https://mlflow.drillquiz.com")


# In[5]:


mlflow.set_experiment("Check localhost connection2")

with mlflow.start_run():
    mlflow.log_metric("test",1)
    mlflow.log_metric("Krish",2)


# In[6]:


with mlflow.start_run():
    mlflow.log_metric("test1",1)
    mlflow.log_metric("Krish1",2)


# In[7]:


with mlflow.start_run():
    mlflow.log_metric("test2",1)
    mlflow.log_metric("Krish2",2)


# In[ ]:

