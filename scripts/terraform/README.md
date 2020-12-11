# tz-k8s-vagrant

## 0. Prep
```
	-. set aws configuration
	cf. This env. works only in us-west-1.
	vi tz-aws-terraform/resource/aws/config
        [default]
        region = us-west-1
        output = json
	vi tz-aws-terraform/resource/aws/credentials
        [default]
        aws_access_key_id = xxx
        aws_secret_access_key = xxx

	-. set docker credentials
    vi tz-aws-terraform/resource/dockerhub
        docker_id = doohee323
        docker_passwd = xxxxx
```

## 1. make ec2 instances with trafform
```
	cd tz-k8s-vagrant
	vagrant up  # as vagrant user

	It does these steps
	1) make a working vm in vagrant
		scripts/terraform/install.sh
		install terraform etc

	2) make tz-aws env.
		scripts/terraform/build_all.sh
		- make aws credentials
		- make a ssh key
		- make instances in aws
```

## * destroy aws resources
```
	vagrant ssh
    sudo su
    cd /vagrant/scripts/terraform
    bash remove_all.sh
```

cf. https://github.com/weibeld/terraform-aws-terraform