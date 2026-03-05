Connect as root user.

```bash
sudo mysql -u root
```

Reset root user password (legacy).

```mysql
USE mysql;
UPDATE user SET authentication_string=PASSWORD("rootpass") WHERE User='root';
FLUSH PRIVILEGES;
```

Verify user table and force _mysql_native_password_ plugin (legacy).

```mysql
SELECT Host,User,authentication_string,plugin FROM mysql.user;
UPDATE user SET plugin='mysql_native_password' WHERE User='root';
FLUSH PRIVILEGES;
```
