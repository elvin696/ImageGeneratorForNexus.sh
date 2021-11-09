#!/usr/bin/env bash
# Author: Habib Guliyev | 13.04.2021
# Global Vars:
Nexus_IP='192.168.116.100'
Nexus_Port='1111'
RepoName='repo1'
ProjectName='test_project'
function Dockerfile(){
cat <<EOF > Dockerfile
FROM openjdk:11.0.3-jdk-slim-stretch
WORKDIR /app
COPY ./fake_compiled_file.jar /app/
ENV TZ Asia/Baku
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAM=1g", "-XX:MaxRAMPercentage=75.0", "-jar", "./fake_compiled_file.jar", "--spring.profiles.active=dev"]
CMD [""]
EOF
}
# Check conditions:
if [ -z "$1" ];then echo -e "Input the images count to generate.\nExample: ./$(basename $0) 5" ; exit 1 ;fi
if [ ! "$(ls|grep -i Dockerfile)" ];then Dockerfile;fi
# Action:
for count in $(seq $1)
do
    Timestamp=$(date '+%H%M%S')
    ImageSize=$(shuf -i 68-85 -n 1)
    Image="$Nexus_IP:$Nexus_Port/java_images/$ProjectName/image-generator:$Timestamp"
    echo "Image Build Count: $count | Image Size: ${ImageSize}MB"
    head -c ${ImageSize}MB </dev/urandom > ./fake_compiled_file.jar
    docker build -t $Image .
    docker push $Image && rm -f ./fake_compiled_file.jar
    docker image ls |grep "image-generator"|awk '{ print $3 }'|xargs docker rmi --force 2>/dev/null
done
