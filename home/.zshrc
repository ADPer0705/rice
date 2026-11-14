# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	sudo
	dnf
	docker
	python
	fzf-tab
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-completions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ─────────────────────────────────────────
#  Starship prompt
# ─────────────────────────────────────────
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ─────────────────────────────────────────
#  Zsh options
# ─────────────────────────────────────────
setopt autocd               # cd by typing directory name
setopt interactivecomments  # allow # comments in interactive shell
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history        # share history across terminal sessions

# ─────────────────────────────────────────
#  History
# ─────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ─────────────────────────────────────────
#  Completion
# ─────────────────────────────────────────
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# fzf-tab settings
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:*' fzf-min-height 10

# ─────────────────────────────────────────
#  Autosuggestions
# ─────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#666'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^ ' autosuggest-accept   # Ctrl+Space accepts suggestion

# ─────────────────────────────────────────
#  Syntax highlighting
# ─────────────────────────────────────────
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,underline'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[path]='bold'
ZSH_HIGHLIGHT_STYLES[comment]='fg=245'

# ─────────────────────────────────────────
#  PATH
# ─────────────────────────────────────────
export PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"         # nvim
export PATH="$HOME/.local/bin:$PATH"                    # user binaries
export PATH="$HOME/intellij/bin:$PATH"                  # IntelliJ IDEA
export PATH="/usr/local/texlive/2024/bin/x86_64-linux:$PATH"  # TexLive
export PATH="$HOME/.lmstudio/bin:$PATH"                 # LM Studio CLI

# Flatpak
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS}"

# ─────────────────────────────────────────
#  NVM — Node Version Manager
# ─────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ─────────────────────────────────────────
#  uv — Python package manager
# ─────────────────────────────────────────
command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion zsh)"
command -v uvx >/dev/null 2>&1 && eval "$(uvx --generate-shell-completion zsh)"

# ─────────────────────────────────────────
#  OpenClaw completions
# ─────────────────────────────────────────
[[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && \
  source "$HOME/.openclaw/completions/openclaw.zsh"

# ─────────────────────────────────────────
#  Navigation aliases
# ─────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias docs='cd ~/Documents'
alias down='cd ~/Downloads'

# ─────────────────────────────────────────
#  ls / tree aliases
# ─────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='tree -a -C -L 1'
alias l1='tree -C -L 1'
alias cls='clear && tree -C -L 1'
alias .='xdg-open .'

# ─────────────────────────────────────────
#  Color aliases
# ─────────────────────────────────────────
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias cat='bat --style=plain --paging=never'   # bat: syntax-highlighted cat

# ─────────────────────────────────────────
#  System aliases
# ─────────────────────────────────────────
alias reboot='sudo systemctl reboot'
alias shutdown='sudo systemctl poweroff'
alias poweroff='sudo systemctl poweroff'
alias lock='loginctl lock-session'
alias please='sudo $(fc -ln -1)'
alias weather='curl wttr.in'
alias history='history 0'

# ─────────────────────────────────────────
#  Clipboard — Wayland (wl-clipboard replaces xclip)
# ─────────────────────────────────────────
alias clip='wl-copy'
alias paste='wl-paste'

# ─────────────────────────────────────────
#  Language aliases
# ─────────────────────────────────────────
alias python='python3'
alias pip='pip3'

# ─────────────────────────────────────────
#  App aliases
# ─────────────────────────────────────────
alias notion='nohup google-chrome \
  --profile-directory="Default" \
  --app=https://www.notion.so > /dev/null 2>&1 & disown'

alias excalidraw='nohup google-chrome \
  --app=https://excalidraw.com \
  --profile-directory=Default > /dev/null 2>&1 & disown'

alias chatgpt='nohup google-chrome \
  --app=https://chat.openai.com/ \
  --profile-directory=Default > /dev/null 2>&1 & disown'

alias perplexity='nohup google-chrome \
  --app=https://www.perplexity.ai/ \
  --profile-directory=Default > /dev/null 2>&1 & disown'

alias telegram='nohup telegram-desktop > /dev/null 2>&1 & disown'

# ─────────────────────────────────────────
#  Developer tools
# ─────────────────────────────────────────
alias vim='nvim'
alias v='nvim'

# Distrobox
alias kali='distrobox enter kali --root'

# qemu VM ssh
alias parrot='TERM=xterm-256color ssh parrot'

# john the ripper
export PATH="$PATH:$HOME/john/run"

# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# virtualization
export LIBVIRT_DEFAULT_URI=qemu:///system
export VAGRANT_DEFAULT_PROVIDER=libvirt

# markdown to pdf 
md2pdf() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: md2pdf <file.md>"
        return 1
    fi

    local input="$1"
    local output="${input%.md}.pdf"

    pandoc "$input" \
        --defaults="$HOME/.local/share/pandoc/pdf.yaml" \
        -o "$output"

    if [[ $? -eq 0 ]]; then
        echo "Created: $output"
    else
        echo "PDF generation failed"
        return 1
    fi
}

# npm global installs set to ~/.npm-global 
export PATH=~/.npm-global/bin:$PATH

# fuzzy finder for terminal
[[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# CUDA Toolkit
export CUDA_HOME=/usr/local/cuda
export PATH="$CUDA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# sempropos
command -v sem >/dev/null 2>&1 && eval "$(sem init zsh)"

# Go path
export PATH=$PATH:$(go env GOPATH)/bin

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# ─────────────────────────────────────────────
#  Machine-local overrides and secrets (untracked)
# ─────────────────────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
