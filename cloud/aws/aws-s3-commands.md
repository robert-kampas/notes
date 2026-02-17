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
