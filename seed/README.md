# mailcow-seed (CapRover-friendly)

This builds a tiny "seed" image that contains **mailcow's** `data/conf/nginx` and `data/web` so you can copy them into CapRover volumes on first boot (and avoid running `generate_config.sh` inside CapRover).

## Build locally

```bash
docker build \
  --build-arg MAILCOW_REPO=https://git.xo.nl/marcel/mailcow-dockerized.git \
  --build-arg MAILCOW_REF=e8d9315d4a \
  -t mailcow-seed:local .
```

## Run (example)

```bash
docker run --rm \
  -e MAILCOW_HOSTNAME=mail.example.com \
  -v $PWD/vol-nginx-conf:/target/conf-nginx \
  -v $PWD/vol-web:/target/web \
  -v $PWD/vol-ssl:/target/ssl \
  mailcow-seed:local
```

## Notes

- By default, it **won’t overwrite** existing files (safe seeding).
- Set `SEED_FORCE=1` to fully resync and overwrite (dangerous, but sometimes necessary).
