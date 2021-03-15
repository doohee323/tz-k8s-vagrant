# install Rancher on MacOS

## install docker desktop
```
    #https://rancher.com/blog/2018/2018-05-18-how-to-run-rancher-2-0-on-your-desktop/
    
    Docker-for-Desktop > settings > kubernetes enabled 
    
    # install rancher in kubernetes on Desktop
    bash tz-rancher/scripts/macos/install.sh
```

## install rancher in kubernetes on Desktop
```
    bash tz-rancher/scripts/macos/install.sh

    on macos
    sudo vi /etc/hosts
    192.168.0.186  rancher.localdev   # 192.168.0.186 -> macos ip
```

## get a join script
```
open https://192.168.0.232

# from Import Cluster page
# 1. create a cluster
#    Add Cluster > Other Cluster > Cluster Name: tz-k8s-vagrant
# 2. import cluster
# https://192.168.0.232/g/clusters/add/launch/import?importProvider=other

```

## import a cluster 
```
# on all nodes of the k8s cluster
sudo vi /etc/hosts
192.168.0.152  rancher.localdev         # rancher server ip

cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1 #cloudflare DNS
nameserver 8.8.8.8 #Google DNS
EOF

# on a master node

curl --insecure -sfL https://192.168.0.232/v3/import/bqbz8cfhg897lt95nhlq2pqfltbczztdjlzkgnpmqhxsnwr5wntj6x_c-4fjf7.yaml | kubectl apply -f -
or
wget https://192.168.0.232/v3/import/bqbz8cfhg897lt95nhlq2pqfltbczztdjlzkgnpmqhxsnwr5wntj6x_c-4fjf7.yaml --no-check-certificate
kubectl apply -f bqbz8cfhg897lt95nhlq2pqfltbczztdjlzkgnpmqhxsnwr5wntj6x_c-4fjf7.yaml --kubeconfig=kube_config_cluster.yml

curl --insecure -sfL https://192.168.0.232/v3/import/bqbz8cfhg897lt95nhlq2pqfltbczztdjlzkgnpmqhxsnwr5wntj6x_c-4fjf7.yaml | kubectl apply -f -


kubectl get all -n cattle-system

# fix domain and ip
kubectl -n cattle-system patch  deployment.apps/cattle-cluster-agent --patch '{
    "spec": {
        "template": {
            "spec": {
                "hostAliases": [
                    {
                      "hostnames":
                      [
                        "rancher.localdev"
                      ],
                      "ip": "192.168.0.152"
                    }
                ]
            }
        }
    }
}'

kubectl -n cattle-system patch  daemonsets cattle-node-agent --patch '{
 "spec": {
     "template": {
         "spec": {
             "hostAliases": [
                 {
                    "hostnames":
                      [
                        "rancher.localdev"
                      ],
                    "ip": "192.168.0.152"
                 }
             ]
         }
     }
 }
}'

```
