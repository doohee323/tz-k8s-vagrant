# install airflow

source /root/.bashrc
#bash /vagrant/tz-local/resource/airflow/run.sh
cd /vagrant/tz-local/resource/airflow

#set -x
shopt -s expand_aliases
alias k='kubectl --kubeconfig ~/.kube/config'

k8s_project=$(prop 'project' 'project')
k8s_domain=$(prop 'project' 'domain')
admin_password=$(prop 'project' 'admin_password')
NS=airflow

#kubectl delete ns ${NS}
kubectl create ns ${NS}
helm repo add apache-airflow https://airflow.apache.org
#helm show values apache-airflow/airflow > values.yaml
helm uninstall airflow -n ${NS}
#kubectl cp values.yaml devops-dev/bastion:/vagrant/tz-local/resource/airflow
#--reuse-values
helm upgrade --install airflow apache-airflow/airflow -n ${NS} -f values.yaml

#echo Fernet Key: $(kubectl get secret --namespace airflow airflow-fernet-key -o jsonpath="{.data.fernet-key}" | base64 --decode)

cp -Rf airflow-ingress.yaml airflow-ingress.yaml_bak
sed -ie "s/k8s_project/${k8s_project}/g" airflow-ingress.yaml_bak
sed -ie "s/k8s_domain/${k8s_domain}/g" airflow-ingress.yaml_bak
#kubectl delete -f airflow-ingress.yaml_bak -n airflow
kubectl apply -f airflow-ingress.yaml_bak -n airflow

admin / admin


