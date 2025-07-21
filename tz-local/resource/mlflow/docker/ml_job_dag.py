from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from datetime import datetime

with DAG(
    dag_id="ml_job_dag",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:

    run_ml_task = KubernetesPodOperator(
        task_id="run_ml_task",
        name="ml_task",
        namespace="airflow",        # Airflow가 배포된 namespace
        image="doohee323/ml_job_dag:latest",
        image_pull_policy="Always",
        is_delete_operator_pod=True,
        get_logs=True,
    )
