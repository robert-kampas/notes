```bash
yt-dlp -f "bestvideo[ext=mp4]+bestaudio/best[ext=mp4]/best" \
  --js-runtimes node \
  --embed-thumbnail \
  --embed-metadata \
  --embed-chapters \
  --parse-metadata "description:(?s)(?P<meta_comment>.+)" \
  --xattrs \
  --embed-subs \
  --sub-langs "en.*" \
  --concurrent-fragments 4 \
  --merge-output-format mkv \
  --extractor-args "youtube:player_client=default" \
  --no-warnings \
  "https://www.youtube.com/watch?v=abc123"
```

Alias definition (bash) in `~/.bashrc`:

```bash
alias ytdl='yt-dlp -f "bestvideo[ext=mp4]+bestaudio/best[ext=mp4]/best" \
  --js-runtimes node \
  --embed-thumbnail \
  --embed-metadata \
  --embed-chapters \
  --parse-metadata "description:(?s)(?P<meta_comment>.+)" \
  --xattrs \
  --embed-subs \
  --sub-langs "en.*" \
  --concurrent-fragments 4 \
  --merge-output-format mkv \
  --extractor-args "youtube:player_client=default" \
  --no-warnings'
```

Reload and use:

```bash
source ~/.bashrc
ytdl "https://www.youtube.com/watch?v=abc123"
```
