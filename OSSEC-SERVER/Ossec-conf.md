/var/ossec/bin/agent_control -lc

##Querying information from agent 002

/var/ossec/bin/agent_control -i 023

##

/var/ossec/bin/agent_control -r -u 023


##Agent config

/var/ossec/etc/shared/agent.conf

md5sum /var/ossec/etc/shared/agent.conf













Per poter recuperare gli IoC in formato STIX è possibile [installare il software Cabby](https://cabby.readthedocs.io/en/stable/installation.html)

Di seguito la procedura testata su Ubuntu >=18.04
```
sudo apt install virtualenv
virtualenv cabby
. cabby/bin/activate
```
a questo punto la shell sarà nella forma
```
(cabby) gmellini@18-10:~$
```
e si potrà installare il software via pip
```
pip install cabby
```
Una volta installato cabby si procede alla connessione al servizio STIX/TAXXI erogato sul serverinfosharing.cybersaiyan.it

### Fase di Discovery
La fase iniziale è quella di discovery dei servizii erogati dal server STIX/TAXII infosharing.cybersaiyan.it
Per questo si usa il comando _taxii-discovery_ con gli opportuni parametri (la lista è disponbile all'indirizzo /taxii-discovery-service)
```
taxii-discovery --host infosharing.cybersaiyan.it --path /taxii-discovery-service --https
```
L'ouput del comando riporta i servizi disponili
* DISCOVERY
* COLLECTION_MA