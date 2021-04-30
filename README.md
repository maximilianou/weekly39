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

---
- zero/package.json
```json
{
  "devDependencies": {
    "concurrently": "^5.2.0",
    "dotenv": "^8.2.0",
    "eslint": "^7.19.0",
    "eslint-config-prettier": "^6.11.0",
    "eslint-plugin-prettier": "^3.1.3",
    "eslint-plugin-react": "^7.20.0",
    "execa": "^4.0.2",
    "grandstack": "^0.0.1",
    "husky": ">=4",
    "lint-staged": ">=10",
    "prettier": "^2.0.5",
    "prettier-eslint-cli": "^5.0.0"
  },
  "scripts": {
    "seedDb": "node scripts/seed.js",
    "start": "node scripts/start-dev.js",
    "build": "node scripts/build.js",
    "format": "find . -name \"*.js\" | grep -v node_modules | grep -v build | xargs prettier --write",
    "format:log": "find . -name \"*.js\" | grep -v node_modules | grep -v build | xargs prettier",
    "inferschema:write": "node scripts/inferSchema.js"
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.js": [
      "prettier --write",
      "eslint --fix"
    ]
  }
}
```
---
- zero/api/package.json
```json
{
  "name": "grand-stack-starter-api",
  "version": "0.0.1",
  "description": "API app for GRANDstack",
  "main": "src/index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start:dev": "./node_modules/.bin/nodemon --watch src --ext js,graphql --exec babel-node  src/index.js",
    "build": "babel src --out-dir build && shx cp .env build 2>/dev/null || : && shx cp src/schema.graphql build",
    "now-build": "babel src --out-dir build && shx cp src/schema.graphql build",
    "start": "npm run build && node build/index.js",
    "seedDb": "./node_modules/.bin/babel-node src/seed/seed-db.js"
  },
  "author": "William Lyon",
  "license": "MIT",
  "dependencies": {
    "@apollo/client": "^3.2.5",
    "@neo4j/graphql": "^1.0.0-beta.2",
    "apollo-server": "^2.19.2",
    "apollo-server-lambda": "^2.19.0",
    "csv-parse": "^4.10.1",
    "dotenv": "^7.0.0",
    "graphql": "^15.5.0",
    "neo4j-driver": "^4.2.2",
    "node-fetch": "^2.6.0",
    "react": "^16.13.1"
  },
  "devDependencies": {
    "@babel/cli": "^7.8.4",
    "@babel/core": "^7.9.0",
    "@babel/node": "^7.8.7",
    "@babel/plugin-proposal-class-properties": "^7.8.3",
    "@babel/plugin-transform-runtime": "^7.9.0",
    "@babel/preset-env": "^7.9.0",
    "@babel/preset-react": "^7.9.4",
    "@babel/preset-typescript": "^7.9.0",
    "@babel/runtime-corejs3": "^7.9.2",
    "babel-plugin-auto-import": "^1.0.5",
    "babel-plugin-module-resolver": "^4.0.0",
    "cross-env": "^7.0.2",
    "nodemon": "^1.19.1",
    "shx": "^0.3.2"
  }
}

```

---
- zero/web-react-ts/package.json
```json
{
  "name": "web-react-ts",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@apollo/client": "^3.1.2",
    "@material-ui/core": "^4.11.0",
    "@material-ui/icons": "^4.9.1",
    "moment": "^2.29.1",
    "react": "^16.13.1",
    "react-dom": "^16.13.1",
    "react-router-dom": "^5.2.0",
    "react-scripts": "^4.0.3",
    "recharts": "^1.8.5"
  },
  "devDependencies": {
    "@testing-library/jest-dom": "^4.2.4",
    "@testing-library/react": "^9.3.2",
    "@testing-library/user-event": "^7.1.2",
    "@types/jest": "^24.0.0",
    "@types/node": "^12.0.0",
    "@types/react": "^16.9.0",
    "@types/react-dom": "^16.9.0",
    "@types/react-router-dom": "^5.1.5",
    "@types/recharts": "^1.8.14",
    "typescript": "~3.7.2"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": "react-app"
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
```

