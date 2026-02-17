```bash
mysqldump --column-statistics=0 -h mlg-main-cluster.cluster-0000000.eu-west-1.rds.amazonaws.com -u wp_mlg_group -p mullenlo_loweandp > db_backup.sql --ssl-mode=DISABLED
```
