FROM maven:latest
COPY ./spring-petclinic/target/*.jar .
EXPOSE 8080
CMD java -jar *.jar