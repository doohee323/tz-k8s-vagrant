
cd /Volumes/workspace/etc/tz-k8s-vagrant

vagrant ssh k8s-master

sudo su

kubectl get nodes


kubectl proxy --accept-hosts='^*' &

sudo apt install nginx -y
sudo ufw allow 'Nginx HTTP'
sudo systemctl enable nginx

sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default_bak

cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 8001;
    location / {
        proxy_pass http://127.0.0.1:8001;
    }
}
EOF

sudo service nginx restart




curl http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

curl http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
curl http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services
curl http://127.0.0.1:8080/api/v1/namespaces/kubernetes-dashboard/services



http://10.0.0.10:8001/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy


kubectl run --generator=run-pod/v1 test-np --image=busybox:1.28 --rm -it -- sh
nslookup kubernetes.default
nslookup kubernetes.default.svc.cluster.local

curl -kv http://127.0.0.1:8001/version

curl http://10.0.0.10:8001/api/v1/namespaces/kubernetes-dashboard/services
curl http://10.0.0.10:80/api/v1/namespaces/kubernetes-dashboard/services

curl http://k8s-master:8080/api/v1/namespaces/kubernetes-dashboard/services
curl http://k8s-master:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/


curl https://k8s-master

curl https://k8s-master/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

kubectl proxy --accept-hosts='^*' &

 
kubectl proxy --accept-hosts='^*' &
kubectl -n kube-system port-forward xxxxx 8443

kubectl get all --all-namespaces | grep dashboard

ps -ef | grep 'kubectl proxy'



###### Rancher

docker run -d --restart=unless-stopped \
  -p 9080:80 -p 9443:443 \
  -v /opt/rancher:/var/lib/rancher \
  rancher/rancher:latest --acme-domain k8s-master


curl http://localhost:9080
