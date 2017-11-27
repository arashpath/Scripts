#!/bin/bash
# Script to backup DB and Application in FOSTAC Svr
  app='fostac' 
# app='fosrest'
# app='fotest'

app=$1
tar -czvf /opt/BKPs/$app-webapps_`date +%H%M%S_%d%b%y`.tgz /opt/APPS/$app-tom?/webapps/
pg_dump -cC $app | gzip > /opt/BKPs/$app-db_`date +%H%M%S_%d%b%y`.sql.gz
