ApacheBench tool comes bundled with the standard Apache source distribution for measuring the performance of HTTP web servers.

This especially shows you how many requests per second your Apache is capable of serving by generating a flood of requests to a given URL and returns some easily digestible performance related metrics to the screen. For example, the following command will execute 1000 HTTP GET requests, processing up to 10 requests concurrently, to the specified URL.

```bash
ab -k -n 1000 -c 10 "http://yoursite.com/test"
```
