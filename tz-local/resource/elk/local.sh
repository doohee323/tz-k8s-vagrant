#!/usr/bin/env bash

brew install python
brew info python

#sudo /usr/local/Cellar/python@3.9/3.9.1/bin/easy_install-3.9 virtualenv
#virtualenv venv --python=python3.9
virtualenv venv
source venv/bin/activate
python --version

pip3 install scrapy
pip3 install selenium
#pip3 freeze > requirements.txt
pip3 install --upgrade -r requirements.txt

#scrapy startproject youtube
#scrapy genspider -t crawl stack_crawler www.test.co.kr
#scrapy genspider stack_crawler www.test.co.kr

cd youtube
scrapy crawl youtube -a watch_ids=ioNng23DkIM -o any_name.csv

brew cask install chromedriver

#pip install pytest

exit 0

# make docker image
cd tz-k8s-vagrant/projects/tz-py-crawler
#vi Dockerfile
#CMD [ "python", "/code/youtube/youtube/server.py" ]
#docker login -u="$USERNAME" -p="$PASSWD"
#docker rmi tz-py-crawler
#docker build -t tz-py-crawler .
#docker image ls
#docker tag tz-py-crawler:latest doohee323/tz-py-crawler:latest
#docker push doohee323/tz-py-crawler:latest

docker run -d -v `pwd`/youtube:/code/youtube -p 8000:8000 tz-py-crawler
docker run -v `pwd`/youtube:/code/youtube -p 8000:8000 -v `pwd`/mnt:/mnt tz-py-crawler
#docker ps
#docker exec -it pod/tz-py-crawler-7cd7c49755-w79hw /bin/bash
#/usr/bin/python3 /code/youtube/youtube/cli.py -l /mnt/list.txt

curl -d "watch_ids=ioNng23DkIM,MlE-HP1U5DM" -X POST http://localhost:8000/crawl
curl -X GET http://localhost:8000/crawl?watch_ids=ioNng23DkIM,MlE-HP1U5DM

#docker image ls
#docker container run -it --rm --name=debug2 -v `pwd`/youtube:/code/youtube -p 8000:8000 cd0dad6e335a /bin/sh
docker run --rm -it --name=debug2 -v `pwd`/youtube:/code/youtube -p 8000:8000 366853331b20  /bin/sh

#python /code/youtube/youtube/server.py &
#cat /code/youtube/youtube/ioNng23DkIM.csv
