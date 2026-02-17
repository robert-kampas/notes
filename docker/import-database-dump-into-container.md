```bash
docker exec -i mlginkwordpress_db_1 mysql -u root -proot ink < /Users/robert.kampas/Downloads/db.sql
```

```bash
docker run --rm -i --link mullenlowegroupcom2017docker_db2_1:db mariadb:10 mysql -uroot -proot -hdb mullenlo_loweandp < database.sql
```
