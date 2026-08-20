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

ARIA2P_MARKER="$XDG_STATE_HOME/aria2p-install-done"
if ! command -v aria2p >/dev/null 2>&1 && [ ! -f "$ARIA2P_MARKER" ]; then
  mkdir -p "$(dirname "$ARIA2P_MARKER")"
  pip install "aria2p[tui]" --break-system-packages --user || true
  touch "$ARIA2P_MARKER"
fi

ARIA2_CONF="$HOME/.config/aria2/aria2.conf"
ARIA2_SECRET_MARKER="$XDG_STATE_HOME/aria2-secret-done"
if [ -f "$ARIA2_CONF" ] && [ ! -f "$ARIA2_SECRET_MARKER" ]; then
  mkdir -p "$(dirname "$ARIA2_SECRET_MARKER")"
  SECRET="$(head -c 16 /dev/urandom | md5sum | cut -c1-16)"
  sed -i '/^rpc-secret=/d' "$ARIA2_CONF"
  echo "rpc-secret=${SECRET}" >> "$ARIA2_CONF"
  sudo -n sv restart aria2c-user >/dev/null 2>&1
  touch "$ARIA2_SECRET_MARKER"
fi

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

alias aria2ptop='aria2p --secret "$(grep "^rpc-secret=" "$HOME/.config/aria2/aria2.conf" | cut -d= -f2)" top'

alias sdwl='dbus-run-session ~/.config/scripts/startdwl'

alias cat='bat'

alias grep='rg --color=auto'
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
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

alias stream='mpv av://v4l2:/dev/video4 --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'

set -o vi

bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'

bind -x '"\C-f": _fzf_file_no_hidden'

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
