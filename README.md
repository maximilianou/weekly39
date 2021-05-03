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

---
---
---
### kubernetes k3d

---
- k3d - install as root in /usr/local/bin
```
root@instrument:~# curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
Preparing to install k3d into /usr/local/bin
k3d installed into /usr/local/bin/k3d
Run 'k3d --help' to see what you can do with it.
```
---
- kubectl - install in /usr/local/bin
```
root@instrument:~# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
root@instrument:~# chmod +x kubectl 
root@instrument:~# chown maximilianou:maximilianou kubectl
root@instrument:~# cp kubectl /usr/local/bin
```

---
- k3d - create cluster
```
:~/projects/weekly39$ k3d cluster create one-cluster
INFO[0000] Prep: Network                                
INFO[0000] Created network 'k3d-one-cluster' (416acb2be5f503456ce9487be19a28d031fdea9efbbb9991344c3fa8e8333ae2) 
INFO[0000] Created volume 'k3d-one-cluster-images'      
INFO[0001] Creating node 'k3d-one-cluster-server-0'     
INFO[0004] Pulling image 'docker.io/rancher/k3s:v1.20.6-k3s1' 
INFO[0013] Creating LoadBalancer 'k3d-one-cluster-serverlb' 
INFO[0016] Pulling image 'docker.io/rancher/k3d-proxy:v4.4.3' 
INFO[0022] Starting cluster 'one-cluster'               
INFO[0022] Starting servers...                          
INFO[0022] Starting Node 'k3d-one-cluster-server-0'     
INFO[0027] Starting agents...                           
INFO[0027] Starting helpers...                          
INFO[0027] Starting Node 'k3d-one-cluster-serverlb'     
INFO[0028] (Optional) Trying to get IP of the docker host and inject it into the cluster as 'host.k3d.internal' for easy access 
INFO[0031] Successfully added host record to /etc/hosts in 2/2 nodes and to the CoreDNS ConfigMap 
INFO[0031] Cluster 'one-cluster' created successfully!  
INFO[0031] --kubeconfig-update-default=false --> sets --kubeconfig-switch-context=false 
INFO[0032] You can now use it like this:                
kubectl config use-context k3d-one-cluster
kubectl cluster-info
```

---
- check over docker
```
:~/projects/weekly39$ docker container ls
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                                                                                            NAMES
54fe77609adf   rancher/k3d-proxy:v4.4.3   "/bin/sh -c nginx-pr…"   2 minutes ago   Up 2 minutes   80/tcp, 0.0.0.0:45997->6443/tcp                                                                  k3d-one-cluster-serverlb
e77cfa236553   rancher/k3s:v1.20.6-k3s1   "/bin/k3s server --t…"   2 minutes ago   Up 2 minutes                                                                                                    k3d-one-cluster-server-0
```

---
- kubectl get pods -A
```
:~/projects/weekly39$ kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   local-path-provisioner-5ff76fc89d-kd2zz   1/1     Running     0          4m19s
kube-system   metrics-server-86cbb8457f-t9f2b           1/1     Running     0          4m19s
kube-system   coredns-854c77959c-xgvjg                  1/1     Running     0          4m19s
kube-system   helm-install-traefik-jbsl9                0/1     Completed   0          4m19s
kube-system   svclb-traefik-zp98j                       2/2     Running     0          3m48s
kube-system   traefik-6f9cbd9bd4-gt425                  1/1     Running     0          3m48s

```

---
- kubectl get nodes
```
:~/projects/weekly39$ kubectl get nodes
NAME                       STATUS   ROLES                  AGE   VERSION
k3d-one-cluster-server-0   Ready    control-plane,master   15m   v1.20.6+k3s1
```

---
- k3d cluster create two-cluster
```
:~/projects/weekly39$ k3d cluster create two-cluster --image rancher/k3s:v1.20.6-k3s1
INFO[0000] Prep: Network                                
INFO[0000] Re-using existing network 'k3d-two-cluster' (edf670c1b4a0e2212a049dc7af53337a9e24bcd5bbe17cb3775da33731bfb50a) 
INFO[0000] Created volume 'k3d-two-cluster-images'      
INFO[0001] Creating node 'k3d-two-cluster-server-0'     
INFO[0001] Creating LoadBalancer 'k3d-two-cluster-serverlb' 
INFO[0001] Starting cluster 'two-cluster'               
INFO[0001] Starting servers...                          
INFO[0001] Starting Node 'k3d-two-cluster-server-0'     
INFO[0006] Starting agents...                           
INFO[0006] Starting helpers...                          
INFO[0006] Starting Node 'k3d-two-cluster-serverlb'     
INFO[0007] (Optional) Trying to get IP of the docker host and inject it into the cluster as 'host.k3d.internal' for easy access 
INFO[0010] Successfully added host record to /etc/hosts in 2/2 nodes and to the CoreDNS ConfigMap 
INFO[0010] Cluster 'two-cluster' created successfully!  
INFO[0010] --kubeconfig-update-default=false --> sets --kubeconfig-switch-context=false 
INFO[0011] You can now use it like this:                
kubectl config use-context k3d-two-cluster
kubectl cluster-info
```

---
- docker container ls
```
:~/projects/weekly39$ docker container ls
CONTAINER ID   IMAGE                      COMMAND                  CREATED          STATUS          PORTS                                                                                            NAMES
f7703ecea546   rancher/k3d-proxy:v4.4.3   "/bin/sh -c nginx-pr…"   4 minutes ago    Up 4 minutes    80/tcp, 0.0.0.0:36329->6443/tcp                                                                  k3d-two-cluster-serverlb
ccd6ec0acba6   rancher/k3s:v1.20.6-k3s1   "/bin/k3s server --t…"   4 minutes ago    Up 4 minutes                                                                                                     k3d-two-cluster-server-0
54fe77609adf   rancher/k3d-proxy:v4.4.3   "/bin/sh -c nginx-pr…"   23 minutes ago   Up 23 minutes   80/tcp, 0.0.0.0:45997->6443/tcp                                                                  k3d-one-cluster-serverlb
e77cfa236553   rancher/k3s:v1.20.6-k3s1   "/bin/k3s server --t…"   24 minutes ago   Up 23 minutes                                                                                                    k3d-one-cluster-server-0
```

---
- k3d cluster delete one-cluster
```
:~/projects/weekly39$ k3d cluster delete one-cluster
INFO[0000] Deleting cluster 'one-cluster'               
INFO[0000] Deleted k3d-one-cluster-serverlb             
INFO[0001] Deleted k3d-one-cluster-server-0             
INFO[0001] Deleting cluster network 'k3d-one-cluster'   
INFO[0001] Deleting image volume 'k3d-one-cluster-images' 
INFO[0001] Removing cluster details from default kubeconfig... 
INFO[0001] Removing standalone kubeconfig file (if there is one)... 
INFO[0001] Successfully deleted cluster one-cluster! 
```

---
- k3d cluster delete two-cluster
```
:~/projects/weekly39$ k3d cluster delete two-cluster
INFO[0000] Deleting cluster 'two-cluster'               
INFO[0000] Deleted k3d-two-cluster-serverlb             
INFO[0001] Deleted k3d-two-cluster-server-0             
INFO[0001] Deleting image volume 'k3d-two-cluster-images' 
INFO[0001] Removing cluster details from default kubeconfig... 
INFO[0001] Removing standalone kubeconfig file (if there is one)... 
INFO[0001] Successfully deleted cluster two-cluster! 
```

---
- 
```

```