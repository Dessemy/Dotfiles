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
  --border=none
  --prompt="  "
  --pointer="  "
  --preview-window=right,65%,wrap,border-none
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

_read_secret() {
  local var=$1 prompt=$2
  if [[ ${BLE_VERSION-} ]]; then
    ble/util/read "$var" -rsp "$prompt"
  else
    read -rsp "$prompt" "$var"
  fi
}

wifi() {
  local dev networks network pass

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
  sleep 3

  networks=$(iwctl station "$dev" get-networks 2>/dev/null \
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
      }')

  if [ -z "$networks" ]; then
    echo "No networks found"
    return 0
  fi

  network=$(printf '%s\n' "$networks" | fzf --prompt=" Wi-Fi> ")
  [ -z "$network" ] && return 0

  _read_secret pass "Password for $network (blank if open): "
  echo

  if [ -n "$pass" ]; then
    iwctl --passphrase "$pass" station "$dev" connect "$network"
  else
    iwctl station "$dev" connect "$network"
  fi
}

bt() {
  local devices choice mac name

  _bt_strip() {
    sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g;s/\r//g;s/^[[:space:]]+//'
  }

  _bt_is_connected() {
    bluetoothctl info "$1" 2>/dev/null | grep -q "Connected: yes"
  }

  _bt_add_device() {
    local mac=$1 name=$2
    [[ ${seen[$mac]+x} ]] && return
    seen[$mac]=1
    if _bt_is_connected "$mac"; then
      buf+="* $mac $name"$'\n'
    else
      buf+="$mac $name"$'\n'
    fi
  }

  _bt_parse_scan() {
    local clean=$1 _mac _name
    if [[ "$clean" =~ \[NEW\][[:space:]]Device[[:space:]]+([0-9A-Fa-f:]{17})[[:space:]]+(.*)$ ]]; then
      _mac="${BASH_REMATCH[1]}"
      _name="${BASH_REMATCH[2]}"
    elif [[ "$clean" =~ \[NEW\][[:space:]]Device[[:space:]]+([0-9A-Fa-f:]{17})$ ]]; then
      _mac="${BASH_REMATCH[1]}"
      _name=$(bluetoothctl info "$_mac" 2>/dev/null | awk -F': ' '/^[[:space:]]+Name:/{print $2; exit}')
      _name=${_name:-Unknown}
    else
      return 1
    fi
    _bt_add_device "$_mac" "$_name"
  }

  collect_devices() {
    declare -A seen
    local line clean buf=""

    bluetoothctl power on >/dev/null 2>&1
    bluetoothctl scan off >/dev/null 2>&1

    while read -r mac name; do
      [ -z "$mac" ] && continue
      _bt_add_device "$mac" "$name"
    done < <(bluetoothctl devices Paired 2>/dev/null | sed -E 's/^Device //')

    while IFS= read -r line; do
      clean=$(_bt_strip <<< "$line")
      _bt_parse_scan "$clean" || true
    done < <(bluetoothctl --timeout 8 scan on 2>&1)

    bluetoothctl scan off >/dev/null 2>&1
    printf '%s' "$buf"
  }

  _bt_mac_to_card() {
    echo "bluez_card.${1//:/_}"
  }

  _bt_setup_audio() {
    local mac=$1 card sink profile i=0 timeout=15

    card=$(_bt_mac_to_card "$mac")

    while [ "$i" -lt "$timeout" ]; do
      pactl list cards short 2>/dev/null | grep -qF "$card" && break
      sleep 1
      i=$((i + 1))
    done

    if ! pactl list cards short 2>/dev/null | grep -qF "$card"; then
      echo "Audio card not ready — try reconnecting" >&2
      return 1
    fi

    for profile in a2dp-sink a2dp-sink-sbc a2dp-sink-sbc_xq; do
      pactl set-card-profile "$card" "$profile" 2>/dev/null && break
    done

    i=0
    while [ "$i" -lt "$timeout" ]; do
      sink=$(pactl list sinks short 2>/dev/null \
        | awk -v m="${mac//:/_}" '$2 ~ "bluez_output." m {print $2; exit}')
      [ -n "$sink" ] && break
      sleep 1
      i=$((i + 1))
    done

    if [ -z "$sink" ]; then
      echo "Bluetooth audio sink not found" >&2
      return 1
    fi

    pactl set-default-sink "$sink"
    local desc
    desc=$(pactl list sinks 2>/dev/null | awk -v s="$sink" '
      $0 ~ "Name: " s { found=1 }
      found && /^[[:space:]]+Description:/ { print $2; exit }
    ')
    echo "Audio output: ${desc:-$sink}"
  }

  pair_connect() {
    local mac=$1 i=0 timeout=45

    bluetoothctl power on >/dev/null 2>&1
    bluetoothctl pairable on >/dev/null 2>&1

    if ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
      echo "Pairing with $mac..."

      (
        echo "default-agent"
        echo "scan on"
        sleep 5
        echo "pair $mac"
        sleep "$timeout"
        echo "scan off"
      ) | bluetoothctl --agent NoInputNoOutput

      while [ "$i" -lt "$timeout" ]; do
        bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes" && break
        sleep 1
        i=$((i + 1))
      done

      if ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
        bluetoothctl scan off >/dev/null 2>&1
        echo "Failed to pair with $mac — keep it in pairing mode and try again" >&2
        return 1
      fi
    fi

    bluetoothctl trust "$mac" >/dev/null 2>&1

    if ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
      i=0
      while [ "$i" -lt 3 ]; do
        bluetoothctl connect "$mac" 2>/dev/null && break
        sleep 2
        i=$((i + 1))
      done
    fi

    bluetoothctl scan off >/dev/null 2>&1

    if ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
      echo "Failed to connect to $mac" >&2
      return 1
    fi

    _bt_setup_audio "$mac"
  }

  echo "Scanning..."
  devices=$(collect_devices)
  if [ -z "$devices" ]; then
    echo "No devices found"
    return 0
  fi

  choice=$(printf '%s' "$devices" | fzf --prompt=" Bluetooth> ")
  [ -z "$choice" ] && return 0

  if [ "${choice:0:2}" = '* ' ]; then
    mac=$(awk '{print $2}' <<< "$choice")
  else
    mac=$(awk '{print $1}' <<< "$choice")
  fi

  if _bt_is_connected "$mac"; then
    bluetoothctl disconnect "$mac" >/dev/null 2>&1
    echo "Disconnected"
  else
    pair_connect "$mac"
  fi
}

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

  ble-bind -m emacs   -c M-i wifi
  ble-bind -m vi_imap -c M-i wifi
  ble-bind -m vi_nmap -c M-i wifi
  ble-bind -m emacs   -c M-p bt
  ble-bind -m vi_imap -c M-p bt
  ble-bind -m vi_nmap -c M-p bt
  ble-bind -m emacs   -c M-o _fzf_file_no_hidden
  ble-bind -m vi_imap -c M-o _fzf_file_no_hidden
  ble-bind -m vi_nmap -c M-o _fzf_file_no_hidden
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
