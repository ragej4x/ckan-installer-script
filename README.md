# ckan-installer-script


ckan config's === ignore


sqlalchemy.url = postgresql://ckanuser:ckanpassword@localhost/ckan

ckan.site_url = http://localhost:5000

solr.url = http://localhost:8983/solr/ckan



=====================================================================================
install python 3.9

step 1 run the installer.bat as an admin

step 2 start the PostgreSQL and start the server Password is (mypassword)

step 3 ckan run



wait nyo lng po to kasi installing na mismo ung PostgreSQL
and auto configuring na din to sa database no need imano mano
next installing is Solr 7.7.3 medj matagal po tlga mag install kasi need offline lahat
soo ginawa ko sa script idownlaod na lahat and automated na ma install

installation duration estimated 10min or 15
double check ko lng nirun ko ulit ung installation

punta kayo sa ckan_env/ckan/config/development.ini

palitan nyo ung sqlalchemy neto
sqlalchemy.url = postgresql://ckanuser:ckanpassword@localhost/ckan




