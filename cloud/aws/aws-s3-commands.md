Check bucket ACL:

```bash
aws s3api get-bucket-acl --bucket ipg-wireless-network-terms-of-use
```

Check bucket policy:

```bash
aws s3api get-bucket-policy --bucket ipg-wireless-network-terms-of-use
```

Check public access block settings:

```bash
aws s3api get-public-access-block --bucket ipg-wireless-network-terms-of-use
```

Check bucket website configuration:

```bash
aws s3api get-bucket-website --bucket ipg-wireless-network-terms-of-use
```

List objects (test if listing is public):

```bash
aws s3 ls s3://ipg-wireless-network-terms-of-use/ --no-sign-request
```

Get tree of all the files inside a bucket:

```bash
aws s3 ls kudos-awards --profile s3-downloader --recursive >> ~/Downloads/files.txt
```

Get object info:

```bash
aws s3api head-object --bucket horizonstagings3 --key PR1801api-aecorndrinks.diageoplatform.com
```

Check object permission and access:

```bash
aws s3api get-object-acl --bucket 215-mccann-images --key 1477572195/index.html --profile=s3tester
```

Check bucket ownership controls:

```bash
aws s3api get-bucket-ownership-controls --bucket ipg-wireless-network-terms-of-use
```

List all items in a bucket:

```bash
aws s3 ls s3://fcb-edm --no-sign-request
aws s3 ls s3://fcb-edm --recursive --human-readable
```

Downloads a file from a bucket:

```bash
aws s3api get-object --bucket fcb-edm --key PhoneBackup/2mz8E7.php ./OUTPUT --no-sign-request
```

```bash
aws s3 cp s3://cdn.mlghyperholidays.com ~/Downloads/cdn --recursive
```

```bash
aws s3 sync s3://mlg-sql-backups ~/Downloads/mlg-sql-backups_2022-04-01
```
