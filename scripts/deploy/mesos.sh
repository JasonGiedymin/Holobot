http POST http://10.10.10.10:8080/v1/apps/start \
id=multidis instances=2 mem=512 cpus=1 \
executor=/var/lib/mesos/executors/docker \
cmd='nickstenning/java7'

http GET http://localhost:8080/v1/endpoints

sudo docker run -i -t nickstenning/java7 java -version

sudo docker ps -a