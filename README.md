# webapp-base-image
Base Image for Web App Server with Ruby, Node, and dependencies

The base image is **`ruby:3-slim`** (smaller attack surface than the full Ruby image). `ca-certificates`, `curl`, and `gnupg` are installed for APT repositories. **Node.js** comes from the [NodeSource](https://github.com/nodesource/distributions) `node_22.x` repo (current LTS with timely security updates); **npm** is upgraded to the latest **npm 11** line. **Yarn** is installed with Corepack as **Yarn 1.22.22** (classic), matching what the former Yarn APT package typically provided.

ImageMagick is installed from **Debian packages** (`imagemagick`, `libmagickwand-dev`) so multi-arch images build reliably: compiling ImageMagick or codecs from source under `docker buildx` often fails when one platform is built via QEMU (e.g. **linux/amd64** on Apple Silicon) because `gcc`/autoconf do not tolerate emulation well.

Images are published for **linux/amd64** and **linux/arm64** (Apple Silicon, AWS Graviton, and other ARM64 hosts run natively instead of via emulation).

## Local build (single architecture)

On your machine, `docker build` targets your host architecture automatically (including Apple Silicon):

```sh
docker build -t wayhomeservices/webapp-base .
```

### Apple Silicon (or any ARM64 host)

If `docker run` warns that the image platform is **linux/amd64** while your host is **arm64**, Docker chose the wrong manifest entry or you have an older single-arch image cached. Prefer native ARM:

```sh
docker pull --platform linux/arm64 wayhomeservices/webapp-base
docker run --platform linux/arm64 -it wayhomeservices/webapp-base /bin/bash
```

`--platform linux/arm64` selects the ARM variant from the multi-arch index; without it, some setups still resolve to amd64 and run slower under emulation.

## Publish multi-architecture image to Docker Hub

A single tag on Docker Hub should be a [multi-platform manifest](https://docs.docker.com/build/building/multi-platform/) so pulls work on both Intel/AMD and ARM64. Log in, then either run:

```sh
docker login
./scripts/build-multiarch.sh
```

Or equivalently:

```sh
docker login
docker buildx create --name multiarch --driver docker-container --bootstrap 2>/dev/null || true
docker buildx use multiarch
docker buildx build --platform linux/amd64,linux/arm64 -t wayhomeservices/webapp-base:latest --push .
```

Optional environment variables for the script: `IMAGE`, `TAG`, `PLATFORMS` (comma-separated list).

Above commands can be made into a GHA but this doesn't get enough use to warrant such niceties.
