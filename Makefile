step01:
	cd zero && docker-compose up --build
step02:
	cd zero && docker-compose down

step03: 
	snap install helm --classic
step04: 
	helm repo add equinor-charts https://equinor.github.io/helm-charts/charts/
	helm repo update
	helm upgrade --install neo4j-community equinor-charts/neo4j-community
	helm upgrade --install neo4j-community equinor-charts/neo4j-community --set acceptLicenseAgreement=yes --set neo4jPassword=letmein
step05:
	kubectl port-forward neo4j-community-neo4j-community-0 7475:7474
step06:
	kubectl port-forward neo4j-community-neo4j-community-0 7689:7687
step07:
	apt install ansible sshpass

step09:
	mkdir inventory && touch inventory/hosts && echo "[servers]\nlocalhost\n" > inventory/hosts
step10:
	ansible -i ./inventory/hosts servers -m ping --user maximilianou --ask-pass
step11:
	ansible-playbook ./playbooks/apt.yml --user maximilianou --ask-pass --ask-become-pass -i ./inventory/hosts 