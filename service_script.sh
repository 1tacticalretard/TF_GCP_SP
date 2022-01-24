#!/bin/bash

cd /home/zheniakushnir7/spring-petclinic
mvn clean install -DskipTests
java -jar target/*.jar