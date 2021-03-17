#!/usr/bin/env bash

https://www.youtube.com/watch?v=PXjBkVonMQI
https://min.io/
https://www.civo.com/learn/backup-longhorn-volumes-to-a-minio-s3-bucket
https://medium.com/hashicorp-engineering/how-to-backup-a-hashicorp-vault-integrated-storage-cluster-with-minio-33b88399bf63

Access key ID,Secret access key
AKIAW354R7YB4MT3U4NI,Hggvb9TZVir6YmWCXQQrJKDtUqob6OsNy0x1FRDw


{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GrantLonghornBackupstoreAccess0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::tz-longhorn",
                "arn:aws:s3:::tz-longhorn/*"
            ]
        }
    ]
}





https://www.civo.com/learn/backup-longhorn-volumes-to-a-minio-s3-bucket

A_AWS_ENDPOINTS="backup"
A_AWS_ACCESS_KEY_ID="AKIAW354R7YB4MT3U4NI"
A_AWS_SECRET_ACCESS_KEY="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"

A_AWS_ENDPOINTS=`echo -n ${A_AWS_ENDPOINTS} | base64`
A_AWS_ACCESS_KEY_ID=`echo -n ${A_AWS_ACCESS_KEY_ID} | base64`
A_AWS_SECRET_ACCESS_KEY=`echo -n ${A_AWS_SECRET_ACCESS_KEY} | base64`

cat <<EOF >>aws_secret.yml
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret
  namespace: longhorn-system
type: Opaque
data:
  AWS_ACCESS_KEY_ID: A_AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY: A_AWS_SECRET_ACCESS_KEY
  AWS_ENDPOINTS: A_AWS_ENDPOINTS
EOF
sudo sed -i "s|A_AWS_ACCESS_KEY_ID|${A_AWS_ACCESS_KEY_ID}|g" aws_secret.yml
sudo sed -i "s|A_AWS_SECRET_ACCESS_KEY|${A_AWS_SECRET_ACCESS_KEY}|g" aws_secret.yml
sudo sed -i "s|A_AWS_ENDPOINTS|${A_AWS_ENDPOINTS}|g" aws_secret.yml

kubectl delete -f aws_secret.yml
kubectl apply -f aws_secret.yml
kubectl get secrets -n longhorn-system

https://192.168.0.232/k8s/clusters/c-4fjf7/api/v1/namespaces/longhorn-system/services/http:longhorn-frontend:80/proxy/#/setting

Backup Target: s3://tz-longhorn@us-west-1/
Backup Target Credential Secret: aws-secret


InvalidEndpointURL invalid endpoint uri parse \"https://arn:aws:s3:::tz-longhorn/{Bucket}\": invalid port \":tz-longhorn\" after host\n" pkg=s3 time="2021-03-17T04:23:26Z" level=error msg="failed to

AWS Error: RequestError send request failed Get \"https://backup/tz-longhorn?delimiter=%!F(MISSING)&prefix=%!F(MISSING)\": dial tcp: lookup backup on 10.96.0.10:53: server misbehaving\n"


https://github.com/minio/charts

