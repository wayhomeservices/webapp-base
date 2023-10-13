# webapp-base-image
Base Image for Web App Server with Ruby, Node, and dependencies


# Build & Deploy Guide

```
docker login
docker build -t wayhomeservices/webapp-base .
docker push wayhomeservices/webapp-base
```

Above commands can be made into a GHA but this doesn't get enough use to warrant such niceties.
