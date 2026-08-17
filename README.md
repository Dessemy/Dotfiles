# My personal setup for Artix Linux running **dwl**. Includes a one-shot install script.

## Install

Boot the Artix Runit live ISO, then:

```bash
git clone https://github.com/Dessemy/Dotfiles && cd Dotfiles && sudo bash setup
```

This wipes the target disk.

## VPN

Drop your ProtonVPN WireGuard config in place, then toggle it with `scripts/vpn`:

```bash
sudo cp ~/Downloads/VPN-*.conf /etc/wireguard/vpn.conf
sudo chmod 600 /etc/wireguard/vpn.conf
```

## Qute binds

| Key | Action |
|---|---|
| `Space .` / `Alt+x` | open command bar |
| `Space b` / `Space h` | bookmarks / history |
| `Space gh/gl/gc/gg` | open GitHub / GitLab / Codeberg / private Gitea |
| `t` / `x` | new tab / close tab |
| `yf` | yank a link via hints |
| `,m` | send hinted link to **mpv** |
| `,d` | send hinted link to **aria2** for download |
| `,D` | same as `,d` but rapid-fire |
| `Ctrl+P/N` | up/down in completion, normal & insert mode |

Passthrough mode also gets its own set: `Ctrl+T` new tab, `Ctrl+W` close tab, `Ctrl+R` reload, `Ctrl+F` find, `Shift+Esc` to leave passthrough.

`Ctrl+X` / `Ctrl+A` (URL increment/decrement) are unbound.
