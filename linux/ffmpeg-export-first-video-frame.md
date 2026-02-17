```bash
ffmpeg -i ~/Downloads/home-banner-full.mp4 -vf "select=eq(n\,0)" -vframes 1 ~/Downloads/out.png
```
