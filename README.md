# Spotify Soloist Nix flake

This flake packages Spotify's x86_64 Linux release of [Soloist](https://developer.spotify.com/documentation/soloist/tutorials/getting-started). It pins the archive hash and patches the binary for NixOS.

Build and check the package:

```sh
nix build 'path:/home/vt/soloist#soloist'
./result/bin/soloist --version
```

To use it, generate a Soloist API key in the [Spotify developer dashboard](https://developer.spotify.com/documentation/soloist/tutorials/getting-started#generate-an-api-key). A Premium account, working PipeWire or PulseAudio output, and a Spotify app on the same local network are required. Keep the key in a private local file or secret manager. For example, after placing it in `$HOME/.config/soloist/api-key` with mode `0600`:

```sh
read -r SOLOIST_API_KEY < "$HOME/.config/soloist/api-key"
nix run 'path:/home/vt/soloist' -- --device-name "Soloist" --api-key "$SOLOIST_API_KEY"
unset SOLOIST_API_KEY
```

The API key is passed as a command-line argument because Soloist requires `--api-key`; it can be visible in process listings while Soloist runs.

Spotify uses a stable archive URL. When Spotify publishes a new build, update the version and hash in `package.nix` together. An expired build exits with status 10.
