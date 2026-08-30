PS1='\[\e[1;92m\][\u@\h \W]\$\[\e[0m\] '

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR="nvim"
export VISUAL="nvim"

if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

export GPG_TTY=$(tty)

export PATH="$HOME/.local/bin:$HOME/.config/scripts:$PATH"

case $- in
  *i*) ;;
  *) return ;;
esac

if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  FIRST_BOOT_MARKER="$XDG_STATE_HOME/resolvconf-first-boot-done"
  if [ ! -f "$FIRST_BOOT_MARKER" ]; then
    sudo -n resolvconf -u >/dev/null 2>&1
    mkdir -p "$(dirname "$FIRST_BOOT_MARKER")"
    touch "$FIRST_BOOT_MARKER"
  fi
  exec dbus-run-session ~/.config/scripts/startdwl
fi

export HISTFILE="$XDG_STATE_HOME/bash/history"
mkdir -p "$(dirname "$HISTFILE")"
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
shopt -s cmdhist
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"

shopt -s autocd 2>/dev/null
shopt -s checkwinsize
shopt -s globstar 2>/dev/null

eval "$(zoxide init bash)"

if [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
  source /usr/share/fzf/key-bindings.bash
  source /usr/share/fzf/completion.bash
fi

export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=sharp
  --prompt="  "
  --pointer="  "
  --preview-window=right,65%,wrap,border-sharp
'
export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") || return
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$result${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$((READLINE_POINT + ${#result}))
}

alias sdwl='dbus-run-session ~/.config/scripts/startdwl'

alias cat='bat'

alias diff='diff --color=auto'
alias df='df -h'

alias rm='trash-put'

alias open='xdg-open'
alias openwith='mimeopen -a'

alias drag='dragon-drag-and-drop'

lf() {
  tmp=$(mktemp)
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

alias vim='nvim'

alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'

set -o vi

bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'

bind -x '"\C-f": _fzf_file_no_hidden'

wifi() {
  local dev network pass

  dev=$(iwctl device list 2>/dev/null \
    | sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | grep -Ev '^[[:space:]]*$' \
    | grep -Ev '^-+$' \
    | grep -Ev '^[[:space:]]*Devices[[:space:]]*$' \
    | grep -Ev '^[[:space:]]*Name[[:space:]]+Address' \
    | awk '{print $1; exit}')

  if [ -z "$dev" ]; then
    echo "No wireless device found" >&2
    return 1
  fi

  iwctl station "$dev" scan >/dev/null 2>&1
  sleep 2

  network=$(iwctl station "$dev" get-networks 2>/dev/null \
    | sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g' \
    | grep -Ev '^[[:space:]]*$' \
    | grep -Ev '^-+$' \
    | grep -Ev '^[[:space:]]*Available networks[[:space:]]*$' \
    | grep -Ev '^[[:space:]]*Network name[[:space:]]+Security' \
    | awk '{
        n = NF
        if (n < 3) next
        ssid = ""
        for (i = 1; i <= n - 2; i++) ssid = ssid (i > 1 ? " " : "") $i
        print ssid
      }' \
    | fzf --prompt=" Wi-Fi> ")

  [ -z "$network" ] && return 0

  read -rsp "Password for $network (blank if open): " pass
  echo

  if [ -n "$pass" ]; then
    iwctl --passphrase "$pass" station "$dev" connect "$network"
  else
    iwctl station "$dev" connect "$network"
  fi
}

bt() {
  local action choice mac

  bluetoothctl power on >/dev/null 2>&1

  action=$(printf 'Connect\nDisconnect\nToggle Power\n' | fzf --prompt=" Bluetooth> ")
  [ -z "$action" ] && return 0

  case "$action" in
    Connect)
      echo "Scanning for 5 seconds..."
      timeout 6 bluetoothctl scan on
      choice=$(bluetoothctl devices 2>/dev/null \
        | sed -E 's/^Device //' \
        | fzf --prompt="Connect> ")
      [ -z "$choice" ] && return 0
      mac=$(awk '{print $1}' <<< "$choice")
      bluetoothctl connect "$mac"
      ;;
    Disconnect)
      choice=$(bluetoothctl devices Connected 2>/dev/null | sed -E 's/^Device //')
      [ -z "$choice" ] && choice=$(bluetoothctl devices 2>/dev/null | sed -E 's/^Device //')
      choice=$(printf '%s\n' "$choice" | fzf --prompt="Disconnect> ")
      [ -z "$choice" ] && return 0
      mac=$(awk '{print $1}' <<< "$choice")
      bluetoothctl disconnect "$mac"
      ;;
    "Toggle Power")
      if [ "$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/{print $2; exit}')" = "yes" ]; then
        bluetoothctl power off
      else
        bluetoothctl power on
      fi
      ;;
  esac
}

bind -x '"\C-xw": wifi'
bind -x '"\C-xb": bt'

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

BLE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/blesh"

_ble_install() {
  local src
  src="$(mktemp -d)"
  git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git "$src" \
    && make -C "$src" install PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/.." \
    || return 1
  rm -rf "$src"
}

[[ -d "$BLE_HOME" ]] || _ble_install
[[ -f "$BLE_HOME/ble.sh" ]] && source "$BLE_HOME/ble.sh" --noattach

function blerc/vim-load-hook {
  ble-bind -m vi_imap -f 'C-m' accept-line
  ble-bind -m vi_imap -f 'RET' accept-line
  ble-bind -m vi_nmap -f 'C-m' accept-line
  ble-bind -m vi_nmap -f 'RET' accept-line
}
blehook/eval-after-load keymap_vi blerc/vim-load-hook

ble-update() {
  local src
  src="$(mktemp -d)"
  git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git "$src" \
    && make -C "$src" install PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/.."
  rm -rf "$src"
}

[[ ${BLE_VERSION-} ]] && ble-attach
