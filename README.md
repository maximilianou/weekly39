# weekly39
Learning GRANDStack, Typescript, GraphQL, Apollo, React, Neo4j.

---
- zero/api/.env
```
# Use this file to set environment variables with credentials and configuration options
# This file is provided as an example and should be replaced with your own values
# You probably don't want to check this into version control!

NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=letmein

# Uncomment this line to specify a specific Neo4j database (v4.x+ only)
NEO4J_DATABASE=neo4j

GRAPHQL_SERVER_HOST=0.0.0.0
GRAPHQL_SERVER_PORT=4001
GRAPHQL_SERVER_PATH=/graphql

```

---
- zero/neo4j/Dockerfile
```js
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
```

---
- zero/docker-compose.yml
```yml
version: '3'

services:
  neo4j:
    build: ./neo4j
    ports:
      - 7474:7474
      - 7687:7687
    environment:
      - NEO4J_dbms_security_procedures_unrestricted=apoc.*
      - NEO4J_apoc_import_file_enabled=true
      - NEO4J_apoc_export_file_enabled=true
      - NEO4J_dbms_shell_enabled=true

  api:
    build: ./api
    ports:
      - 4001:4001
    environment:
      - NEO4J_URI=bolt://neo4j:7687
      - NEO4J_USER=neo4j
      - NEO4J_PASSWORD=letmein
      - GRAPHQL_LISTEN_PORT=4001
      - GRAPHQL_URI=http://api:4001/graphql

    links:
      - neo4j
    depends_on:
      - neo4j

  ui:
    build: ./web-react-ts
    ports:
      - 3000:3000
    environment:
      - CI=true
      - REACT_APP_GRAPHQL_URI=http://0.0.0.0:4001/graphql
      - PROXY=http://api:4001/graphql
    links:
      - api
    depends_on:
      - api
```