```bash
apache2 -v
echo "deb http://deb.debian.org/debian buster main" > /etc/apt/sources.list
apt-get update
apt-get install --assume-yes --only-upgrade apache2
apache2 -v
```