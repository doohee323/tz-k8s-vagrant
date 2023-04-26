#!/usr/bin/env bash

function prop {
	grep "${2}" "/home/ubuntu/.aws/${1}" | head -n 1 | cut -d '=' -f2 | sed 's/ //g'
}
k8s_project=$(prop 'project' 'project')

bash /home/ubuntu/tz-local/resource/docker-repo/install.sh
bash /home/ubuntu/tz-local/resource/ingress_nginx/install.sh

bash /home/ubuntu/tz-local/resource/consul/install.sh
bash /home/ubuntu/tz-local/resource/vault/helm/install.sh
bash /home/ubuntu/tz-local/resource/vault/data/vault_user.sh
#bash /home/ubuntu/tz-local/resource/vault/vault-injection/install.sh
#bash /home/ubuntu/tz-local/resource/vault/vault-injection/update.sh
bash /home/ubuntu/tz-local/resource/vault/external-secrets/install.sh

bash /home/ubuntu/tz-local/resource/argocd/helm/install.sh
bash /home/ubuntu/tz-local/resource/jenkins/helm/install.sh

exit 0

bash /home/ubuntu/tz-local/resource/vault/external-secrets/install.sh
