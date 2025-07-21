#!/usr/bin/env bash

source /root/.bashrc
function prop { key="${2}=" file="/root/.k8s/${1}" rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); [[ -z "$rslt" ]] && key="${2} = " && rslt=$(grep "${3:-}" "$file" -A 10 | grep "$key" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'); rslt=$(echo "$rslt" | tr -d '\n' | tr -d '\r'); echo "$rslt"; }
#bash /vagrant/tz-local/resource/mlflow/install.sh
cd /vagrant/tz-local/resource/mlflow

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

export k8s_project=$(prop 'project' 'project')
export admin_password=$(prop 'project' 'admin_password')
NS=devops-dev

#0. research with jupiter notebook
# get-started.ipynb

#1. Python 코드 준비
#pip install nbconvert
#cd papermill
jupyter-nbconvert --to script get-started.ipynb
cp get-started.py main.py
# add if __name__ == "__main__":

#2. Dockerfile 작성
#3. Docker Image 빌드 및 Push
cd docker
docker build -t doohee323/ml_job_dag:latest .
docker push doohee323/ml_job_dag:latest

#4. Airflow DAG에서 만들기 (KubernetesPodOperator)
# ml_job_dag.py

#5. Airflow gitsync 로 배포
#git clone https://github.com/doohee323/tz-airflow-dags.git
cp -Rf ml_job_dag.py tz-airflow-dags/airflow-dags/ml_job_dag.py
cd tz-airflow-dags
git add airflow-dags/ml_job_dag.py
git commit -m 'ml_job_dag'
git push

#6. 확인
#URL: https://airflow-admin.new-nation.church/

#7 Trigger
#실행: doohee323/ml_job_dag:latest


