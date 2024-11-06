@echo off

::

echo Checking for Python 3.9.13...

if exist "python-3.9.13-amd64.exe" (
    echo Python installer found. Skipping download.

) else (

    echo Python installer not found. Downloading Python 3.9.13...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe' -OutFile 'python-3.9.13-amd64.exe'"
    
    if not exist "python-3.9.13-amd64.exe" (
        echo ERROR: Failed to download Python 3.9.13. Please check the internet connection.
        pause
        exit /b
    )
    echo Starting Python installation...
    start /wait python-3.9.13-amd64.exe /quiet InstallAllUsers=1 PrependPath=1
)






set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"


echo Creating CKAN environment folder...
mkdir ckan_env
cd ckan_env


echo Creating Virtual Environment...
python -m venv ckan_venv
call ckan_venv\Scripts\activate.bat

echo Installing CKAN and dependencies...

if not exist "ckan" (

    echo CKAN source not found. Cloning CKAN from GitHub...
    git clone https://github.com/ckan/ckan.git
    cd ckan

) else (
    cd ckan
)
pip install -r requirements.txt
python setup.py install
pip install python-magic-bin
mkdir config
ckan generate config config/development.ini

echo Checking for PostgreSQL 13.x installer...
if exist "postgresql-13.16-2-windows-x64.exe" (

    echo PostgreSQL installer found. Skipping download.

) else (
    echo PostgreSQL installer not found. Downloading PostgreSQL 13.x...

    powershell -Command "Invoke-WebRequest -Uri 'https://get.enterprisedb.com/postgresql/postgresql-13.16-2-windows-x64.exe' -OutFile 'postgresql-13.16-2-windows-x64.exe'"
    
    if not exist "postgresql-13.16-2-windows-x64.exe" (
        echo ERROR: Failed to download PostgreSQL installer. Please check the internet connection.
        pause
        exit /b
    )
    echo Starting PostgreSQL installation...
    start /wait postgresql-13.16-2-windows-x64.exe --mode unattended --superpassword "mypassword" --datadir "C:\PostgreSQL\data" --unattendedmodeui none
)

echo Setting PostgreSQL environment variables...
set PATH=%PATH%;C:\Program Files\PostgreSQL\13\bin

echo Creating PostgreSQL database and user for CKAN...
set PGPASSWORD=mypassword
:: database config mo lng po sa needs mo
psql -U postgres -h localhost -c "CREATE DATABASE ckan;"
psql -U postgres -h localhost -c "CREATE USER ckanuser WITH PASSWORD 'ckanpassword';"
psql -U postgres -h localhost -c "ALTER ROLE ckanuser SET client_encoding TO 'utf8';"
psql -U postgres -h localhost -c "ALTER ROLE ckanuser SET default_transaction_isolation TO 'read committed';"
psql -U postgres -h localhost -c "ALTER ROLE ckanuser SET timezone TO 'UTC';"
psql -U postgres -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE ckan TO ckanuser;"

echo Checking for Solr 7.7.3 installer...

if exist "solr-7.7.3.zip" (
    echo Solr installer found. Skipping download.
) else (

    echo Solr installer not found. Downloading Solr 7.7.3...
    powershell -Command "Invoke-WebRequest -Uri 'https://archive.apache.org/dist/lucene/solr/7.7.3/solr-7.7.3.zip' -OutFile 'solr-7.7.3.zip'"
    if not exist "solr-7.7.3.zip" (
        echo ERROR: Failed to download Solr. Please check the internet connection.
        pause
        exit /b
    )
)



echo Extracting Solr...
mkdir C:\solr-7.7.3
tar -xf solr-7.7.3.zip -C C:\solr-7.7.3



echo Creating Solr core for CKAN...
solr create_core -c ckan

echo Configuring CKAN...
cd C:\ckan_env\ckan
echo sqlalchemy.url = postgresql://ckanuser:ckanpassword@localhost/ckan > C:\ckan_env\ckan\config\development.ini
echo ckan.site_url = http://localhost:5000 >> C:\ckan_env\ckan\config\development.ini
echo solr.url = http://localhost:8983/solr/ckan >> C:\ckan_env\ckan\config\development.ini

echo Initializing CKAN database...
python -m ckan.auth.init --config=C:\ckan_env\ckan\config\development.ini

echo Starting CKAN server...
python -m ckan.serve --config=C:\ckan_env\ckan\config\development.ini

echo CKAN installation complete! You can access CKAN at http://localhost:5000
pause
