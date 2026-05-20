# ZSHRC for Francis Potter for MacOS or Linux

# YMMV - Some settings might only apply if you install all the same tools


# Easy-to-type shortcuts

alias dr="dyngle run"
alias ll="ls -al"
alias xx="exit"
alias finddir="find . -type d -name "
alias ee="edit"


# Direct Dyngle commands

ggp() { dyngle run git-commit-push-all-dot }
ggk() { dyngle run git-commit-ai }
jj() { dyngle run journalize-local }
jt() { dyngle run journalize-this }

# Next item in my queue
nn() {
  dyngle run busy-next
  zsh
  busy done
}

# ---- journal ----

# Use a text file as a journal

journalize() {
    DATE=$(date +"%Y%m%d")
    if ! grep -q "^#\+ \+${DATE}\$" "$1"; then
        echo -e "\n# $DATE\n" >> "$1"
    fi
    edit "$1" -f end-of-buffer
}


# ---- Encrypted backup via AWS S3 ----

backup() {
  source $HOME/secrets
  FILE=$(basename $1).tar.gz
  tar -caf $FILE $1
  openssl enc -aes-256-cbc -salt -pbkdf2 -in $FILE -out $FILE.aes256 -k "$BACKUP_AES256_KEY"
  aws s3 cp $FILE.aes256 s3://$BACKUP_BUCKET/
  rm $FILE $FILE.aes256
  echo "Backup complete"
}

restore() {
  source $HOME/secrets
  FILE=$(basename $1).tar.gz
  aws s3 cp s3://$BACKUP_BUCKET/$FILE.aes256 ./
  openssl enc -d -aes-256-cbc -salt -pbkdf2 -in $FILE.aes256 -out $FILE -k "$BACKUP_AES256_KEY"
  mkdir -p restored
  tar -xzf $FILE -C restored/
  rm $FILE $FILE.aes256
  echo "Restore complete"
}


# Edit a file in a Git repo, keeping it synced with a simple commit message

gedit() {
  DIR="$(dirname "$(readlink -f "$1")")"
  git -C $DIR pull || return
  edit $1
  git -C $DIR add $1
  git -C $DIR commit -am '.'
  git -C $DIR push
}


# Edit this file and start using it right away

alias z="gedit $ZDOTDIR/.zshrc; source $ZDOTDIR/.zshrc"



# Misc shortcuts


# Browse a URL
browse() {
  open -a 'Google Chrome' "$1"
}

# List files deeply
lll() {
  ls -1d ./**/$1
}

# Rename deeply
rnm() {
  ls -1d ./**/$1
  echo -n "Change to $2? [ok] "
  read
  rename "s/$1/$2/" ./**/$1
  ls -1d ./**/$2
}


# Terminal customization based on personal MacOS iTerm settings

bindkey -e

# Option-arrow
bindkey '\e[1;9A' up-line-or-history
bindkey '\e[1;9B' down-line-or-history
bindkey '\e[1;3C' forward-word
bindkey '\e[1;3D' backward-word

# Command-arrow
bindkey '\e[1;5A' up-line-or-history
bindkey '\e[1;5B' down-line-or-history
bindkey '\e[1;5C' end-of-line
bindkey '\e[1;5D' beginning-of-line

# Shift-arrow
bindkey '\e[1;2A' up-line-or-history
bindkey '\e[1;2B' down-line-or-history
bindkey '\e[1;2C' forward-char
bindkey '\e[1;2D' backward-char

# Shift-option-arrow
bindkey '\e[1;10A' up-line-or-history
bindkey '\e[1;10B' down-line-or-history
bindkey '\e[1;10C' forward-word
bindkey '\e[1;10D' backward-word

# Command-option-arrow
bindkey '\e[1;6A' up-line-or-history
bindkey '\e[1;6B' down-line-or-history
bindkey '\e[1;6C' end-of-line
bindkey '\e[1;6D' beginning-of-line

# Complete aliases with <tab>
# https://superuser.com/a/1514591

autoload -Uz compinit && compinit;
bindkey "^Xa" _expand_alias
zstyle ':completion:*' completer _expand_alias _complete _ignored
zstyle ':completion:*' regular true


# Prompt magic adapted from code found at <https://gist.github.com/1712320>.

setopt prompt_subst
autoload -U colors && colors

# Git functionality
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
GIT_PROMPT_PREFIX="["
GIT_PROMPT_SUFFIX="]"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"

parse_git_branch() {
  (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

parse_git_state() {
  local GIT_STATE=""
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi
  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi
  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi
  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi
  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi
  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi
}

git_prompt_string() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX\n"
}

shell_level() {
  printf '$%.0s' {1..$SHLVL}
}

if command -v python3 >/dev/null 2>&1; then
  py3_prompt() {
    python3 -c "import os;e=os.getenv('VIRTUAL_ENV');print('('+e.split('/')[-2]+') ' if e else '')"
  }
fi

short_cwd() {
    parent="$(dirname "${PWD#$HOME}")"
    if [[ "$PWD" == "$HOME"* ]]; then
        if [ -z "${PWD#$HOME}" ]; then
            echo "~"
        elif [ "$parent" = "/" ]; then
            echo "~/$(basename "${PWD#$HOME}")"
        else
            echo "~/.../$(basename "$(dirname "${PWD#$HOME}")")/$(basename "${PWD#$HOME}")"
        fi
    else
        echo $PWD
    fi
}

# OS and machine name
if [ -f ~/.preferred-hostname ]; then
    PROMPT_BASE="$(cat ~/.preferred-hostname)"
else
    PROMPT_BASE="${$(hostname):0:10} ${$(uname -s):0:6}"
fi

# Put Python info, Git info, and our smart PWD into the prompt
export PS1=$'%{$fg[green]%}${PROMPT_BASE} ($(whoami))%{$reset_color%} $(git_prompt_string) %{$fg[cyan]%}$(py3_prompt)%{$reset_color%}\n%{$fg[green]%}$(short_cwd) $(shell_level)%{$reset_color%} '


# Make it easy to change the title

title() {
   echo -ne "\033]0;$*\007"
}

# Change title with SSH

ssh() {
   /usr/bin/ssh "$@"
   title "Z shell"
}

# This seems a little lame
title "Z shell"


# Support pipx applications

export PATH="$PATH:$HOME/.local/bin"


# Support Rust/Cargo

if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Support Go
if [ -d "/usr/local/go/bin" ]; then
    export PATH=$PATH:/usr/local/go/bin
fi

# Where is Python?

whereispython() {
  python3 -c "import pathlib;print(pathlib.Path(pathlib.__file__).parent)"
}


# Set time zone

export TZ="America/Vancouver"


# Run shell inside podman with the local directory loaded at /app

pod-sh() {
  podman run -it --entrypoint /bin/sh -v "$(pwd):/app" $1
}

pod-bash() {
  podman run -it -v "$(pwd):/app" $1 /bin/bash
}


# Run mdbook for easy previews

pod-mdbook() {
  podman run -it -v "$(pwd):/app" -p 3000:3000 registry.gitlab.com/procicd/lib/mdbook:4 mdbook serve app -n 0.0.0.0
}


# Include OS-specific settings

if [[ "$(uname -s)" == "Darwin" ]] && [ -s "$ZDOTDIR/.macos" ]; then
  source $ZDOTDIR/.macos
elif [[ "$(uname -s)" == "Linux" ]] && [ -s "$ZDOTDIR/.linux" ]; then
  source $ZDOTDIR/.linux
fi


# Include anything that's local to this machine (i.e. outside the zshrc repo)

if [ -f "$HOME/.zlocal" ]; then
  source $HOME/.zlocal
fi

# Source secrets if present
# Supports both KEY=value (exported automatically) and export KEY=value formats

if [ -f "$HOME/.secrets" ]; then
  first=$(grep -v '^\s*#' "$HOME/.secrets" | grep -v '^\s*$' | head -1)
  if [[ "$first" == export\ * ]]; then
    source "$HOME/.secrets"
  else
    set -a; source "$HOME/.secrets"; set +a
  fi
fi

alias z2="edit $HOME/.zlocal ; source $HOME/.zlocal"


# Keep everything clean

unset HISTFILE SAVEHIST


# https://gitlab.com/wizlib/swytchit

if [[ -n $SWYTCHITRC ]]; then source $SWYTCHITRC; fi
