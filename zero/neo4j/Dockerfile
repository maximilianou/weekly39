FROM neo4j:latest

ENV NEO4J_AUTH=neo4j/letmein \
    APOC_VERSION=4.1.0.0 \
    GRAPHQL_VERSION=4.0

##ENV  NEO4J_apoc_export_file_enabled=true 
##ENV  NEO4J_apoc_import_file_enabled=true 
##ENV  NEO4J_apoc_import_file_use__neo4j__config=true 
##ENV  NEO4JLABS_PLUGINS=["apoc"]
#RUN apt -y update && apt -y upgrade && apt -y install curl
#
#ENV APOC_URI https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/${APOC_VERSION}/apoc-${APOC_VERSION}-all.jar
#RUN sh -c 'cd /var/lib/neo4j/plugins && curl -L -O "${APOC_URI}"'
#
#ENV GRAPHQL_URI https://github.com/neo4j-graphql/neo4j-graphql/releases/download/${GRAPHQL_VERSION}/neo4j-graphql-${GRAPHQL_VERSION}.jar
#RUN sh -c 'cd /var/lib/neo4j/plugins && curl -L -O "${GRAPHQL_URI}"'

EXPOSE 7474 7473 7687

CMD ["neo4j"]
