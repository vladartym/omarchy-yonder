# Yonder for the Omarchy bar

[Yonder](https://yonder.so) lets you talk to your Claude Code agents by voice, on the computer or from the phone.
This plugin puts Yonder in the Omarchy bar.

- The bar shows the agents that run (`3`), wait on you (`?1`) or have new results (`✓2`).
- The icon is red during a call.
- Left click starts or ends a call. Right click opens Yonder. Middle click shows the QR code that pairs a phone.

## Install

The plugin needs Yonder on this computer. Install Yonder first:

```sh
curl -fsSL https://download.yonder.so/install.sh | bash
```

Then add the plugin:

```sh
omarchy plugin add https://github.com/vladartym/omarchy-yonder --enable
```

## Remove

```sh
omarchy plugin remove so.yonder.bar
```

To remove Yonder too, run `yonder uninstall`.

## How it works

The plugin is one QML file, `BarWidget.qml`. Every 3 seconds it runs `~/.local/bin/yonder status`, which reads the
state from the Yonder bridge on `127.0.0.1:7787`. A click runs `yonder call`, `yonder open` or `yonder pair`. The
plugin runs no shell, opens no network connection and downloads nothing.

## Dependencies

- The Yonder app for Linux, from the install command above. Its own terms apply to it.
- `xdg-terminal-exec`, which Omarchy installs, for the pairing terminal.

## License

MIT. See [LICENSE](LICENSE). The license covers this plugin only, not the Yonder app.
