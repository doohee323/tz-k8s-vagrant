import mlflow
import os
import mlflow.tracking
import requests


# main.py
def main():
    # notebook 내용 정리
    print("Hello from converted notebook")
    # 모델 학습, 저장 등 실질 작업 수행

    # In[4]:

    session = requests.Session()
    session.headers.update({
        "Authorization": os.getenv("MLFLOW_AUTH_HEADER")
    })
    mlflow.tracking._tracking_service.utils._get_http_session = lambda: session

    mlflow.set_tracking_uri(os.getenv("MLFLOW_TRACKING_URI"))
    # mlflow.set_tracking_uri("https://mlflow.new-nation.church")

    # In[5]:

    mlflow.set_experiment("Check localhost connection2")

    with mlflow.start_run():
        mlflow.log_metric("test", 1)
        mlflow.log_metric("Krish", 2)

    # In[6]:

    with mlflow.start_run():
        mlflow.log_metric("test1", 1)
        mlflow.log_metric("Krish1", 2)

    # In[7]:

    with mlflow.start_run():
        mlflow.log_metric("test2", 1)
        mlflow.log_metric("Krish2", 2)

    # In[ ]:


if __name__ == "__main__":
    main()



