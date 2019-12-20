# Create the initial location for the packages
mkdir ~/packages/

# Update apt and install pip
sudo apt-get update
sudo apt install python3-pip

# Install the virtial environment module and source the environment
pip3 install virtualenv
python3 -m virtualenv packages/venv
source packages/venv/bin/activate

# Install the pypiserver in the environment
pip install pypiserver

# Install apache and a password library
sudo apt install apache2
pip install passlib

sudo apt install libapache2-mod-wsgi
sudo a2enmod wsgi

echo "
import os
import pypiserver
PACKAGES = '/home/ubuntu/packages'
HTPASSWD = '/home/ubuntu/packages/htpasswd.txt'
application = pypiserver.app(root=PACKAGES, redirect_to_fallback=True, password_file=HTPASSWD)" >> ~/packages/pypiserver.wsgi

sudo echo "
<VirtualHost *:80>
WSGIPassAuthorization On
WSGIScriptAlias / /home/ubuntu/packages/pypiserver.wsgi
WSGIDaemonProcess pypiserver python-path=/home/ubuntu/packages:/home/ubuntu/packages/venv/lib/python3.6/site-packages
    LogLevel info
    <Directory /home/ubuntu/packages/>
        AllowOverride AuthConfig
        WSGIProcessGroup pypiserver
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>
</VirtualHost>
" >> wsgi.conf
sudo mv wsgi.conf /etc/apache2/sites-available/pypiserver.conf

sudo chown -R www-data:www-data packages/

sudo a2dissite 000-default.conf
sudo a2ensite pypiserver.conf

sudo service apache2 restart