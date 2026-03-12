```bash
yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/b" \
  --js-runtimes node \
  --embed-thumbnail --embed-metadata --embed-chapters \
  --parse-metadata "description:(?s)(?P<meta_comment>.+)" \
  --xattrs \
  --embed-subs --sub-langs "en.*" \
  --concurrent-fragments 4 \
  --merge-output-format mkv \
  --extractor-args "youtube:player_client=default" \
  --cookies-from-browser chrome \
  --no-warnings'
```

Make it an alias.

```bash
alias ytbp='yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/b" \
  --js-runtimes node \
  --embed-thumbnail --embed-metadata --embed-chapters \
  --parse-metadata "description:(?s)(?P<meta_comment>.+)" \
  --xattrs \
  --embed-subs --sub-langs "en.*" \
  --concurrent-fragments 4 \
  --merge-output-format mkv \
  --extractor-args "youtube:player_client=default" \
  --cookies-from-browser chrome \
  --no-warnings'
```
