# install airflow

source /root/.bashrc
#bash /vagrant/sl-local/resource/airflow/run.sh
cd /vagrant/sl-local/resource/airflow

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

k8s_project=$(prop 'project' 'project')
k8s_domain=$(prop 'project' 'domain')
admin_password=$(prop 'project' 'admin_password')
NS=airflow

kubectl create ns ${NS}
helm repo add apache-airflow https://airflow.apache.org
helm upgrade --install airflow apache-airflow/airflow --namespace airflow --create-namespace

k8s_project='k8s-main-s'
k8s_domain='argear.io'
cp -Rf airflow-ingress.yaml airflow-ingress.yaml_bak
sed -ie "s/k8s_project/${k8s_project}/g" airflow-ingress.yaml_bak
sed -ie "s/k8s_domain/${k8s_domain}/g" airflow-ingress.yaml_bak
#kubectl delete -f airflow-ingress.yaml_bak -n airflow
kubectl apply -f airflow-ingress.yaml_bak -n airflow

admin / admin


