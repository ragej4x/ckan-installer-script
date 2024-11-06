@echo off

if exist "config/development.ini" (
    echo skipping

) else (

    mkdir config

    ckan generate config config/development.ini

    
)

ckan db init config/development.ini
ckan run config config/development.ini


pause