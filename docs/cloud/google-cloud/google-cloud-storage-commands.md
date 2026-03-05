Login to CLI:

```bash
gcloud auth login
```

Set project:

```bash
gcloud config set project personal-291808
```

List all files in storage:

```bash
gsutil ls -r gs://cloud_open/**
```

Download all files:

```bash
gsutil -m cp -R gs://cloud_open/* .
```
