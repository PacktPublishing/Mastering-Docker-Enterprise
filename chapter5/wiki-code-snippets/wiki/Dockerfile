# /wiki-app/wiki/Dockerfile - install confluence and tomcat
FROM java:7-jdk

RUN apt update && apt install -y netcat
ADD wiki-jar/atlassian-confluence-5.4.3-deployment.tar.gz /opt/j2ee/domains/mydomain.com/wiki/webapps/atlassian-confluence/deployment/
COPY wiki-conf/confluence-init.properties /opt/j2ee/domains/mydomain.com/wiki/webapps/atlassian-confluence/deployment/exploded_war/WEB-INF/classes/confluence-init.properties

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV JAVA_OPTS -Xms1536m -Xmx1536m -Dinstance.id=wiki.mydomain.com -Djava.awt.headless=true -XX:MaxPermSize=384m

ADD wiki-jar/apache-tomcat-6.0.35.tar.gz /usr/local/
RUN mv /usr/local/apache-tomcat-6.0.35 /usr/local/tomcat
COPY wiki-conf/ROOT.xml /usr/local/tomcat/conf/Catalina/localhost/
COPY wiki-conf/server.xml /usr/local/tomcat/conf/
COPY entrypoint.sh /usr/local/tomcat/

CMD ./usr/local/tomcat/entrypoint.sh