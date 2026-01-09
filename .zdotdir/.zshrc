# ZSHRC for FPotter for MacOS or Linux


# We're replacing a lot of shortcut-type scripts with dyngle commands

alias dr="dyngle run"

# Git commit with meaningless message and push
ggp() { dyngle run git-commit-push-all-dot }

# Next item in my queue
nn() {
  dyngle run busy-next
  zsh
  busy done
}

# ---- emacs ----

edit() { emacs "$@" }
ee ()  { emacs $@ }
export EDITOR=emacs


# ---- journal ----

# Use a text file as a journal

journalize() {
    DATE=$(date +"%Y%m%d")
    if ! grep -q "^#\+ \+${DATE}\$" "$1"; then
        echo -e "\n# $DATE\n" >> "$1"
    fi
    edit "$1" -f end-of-buffer
}

# Edit the home journal

jj() {
    journalize "$HOME/journal/$(date +%Y)/$(date +%Y%m)-journal.md"
}

# Edit the local journal for a project (probably in Git)

jl() {
    journalize "NOTEBOOK.md"
}


# ---- contacts ----

# Maintain a YAML file with contact information

# CONTACTS="$HOME/.contacts"

# cc() { gedit $CONTACTS }


# Contact by context

# cq() {
#    cat $CONTACTS | yq "with_entries(select(.value.context[] == \"$1\"))"
# }


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


# ---- glab shortcuts for GitLab ----

# Increment version using VerNum and GitLab CI

vernumrun() {
    glab ci run --variables VERSION_INCREMENT:$1
}

vernumpush() {
    git push -o ci.variable="VERSION_INCREMENT=$1"
}


# ---- Git shortcuts ----

# Git commit with meaningless message
gg() {
    echo "git commit -am '.'"
    git commit -am '.'
}

# Git commit with kwark message
ggk() {
    MESSAGE="$(git diff --staged | kwark commit)"
    echo $MESSAGE
    git commit -am "$MESSAGE"
}

# Delete unused branches
git-clean-branches() {
    git fetch --prune
    git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -n 1 git branch -D
}



# Check sanitization of a directory for e.g. a client name
sanitize() {
  for arg in "$@"; do
    grep -irl --exclude-dir .git $arg .
  done
}

# Sync a whole directory with Git, hoping for the best
gsync() {
  DIR="${1}"
  git -C $DIR pull -X ours || return
  git -C $DIR add -A
  git -C $DIR commit -am '.'
  git -C $DIR push
}

# Edit a file in a Git repo, keeping it synced with a simple commit message
gedit() {
  DIR="${1%/*}"
  git -C $DIR pull || return
  edit $1
  git -C $DIR add $1
  git -C $DIR commit -am '.'
  git -C $DIR push
}

# --- Misc shortcuts ----

alias ll="ls -al"
alias xx="exit"

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


# ---- Edit this file and start using it right away ----

alias z="gedit $ZDOTDIR/.zshrc; source $ZDOTDIR/.zshrc"


# --- Terminal customization ----

# Based on personal MacOS iTerm settings

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


# ---- Prompt magic ----

# Adapted from code found at <https://gist.github.com/1712320>.
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


# ---- Terminal window title ----

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


# ---- MacOS specific ----

# Set up our environment for Homebrew on MacOS

if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# Support pipx applications
export PATH="$PATH:$HOME/.local/bin"

# And little scriptlettes I might whip up
export PATH="$PATH:$HOME/.local/quick"

# Support Rust/Cargo
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi


# ---- Developer workflow using glab cli ----

# Loop through my issues
glabiloop() {
  username=$(glab api user | jq -r '.username')
  issues_json=$(glab api projects/:id/issues'?'assignee_username="$username"'&'per_page=100)
  iids=($(jq -r '.[]|.iid' <<< "$issues_json"))
  for iid in "${iids[@]}"; do
    title=$(jq -r ".[]|select(.iid==${iid})|.title" <<< $issues_json)
    echo "$iid" "$title"
    ISSUE=$iid zsh
    if (( $? != 0 )); then
      break
    fi
done
}

# Loop through my issues
glabbusystatus() {
  DATE=$1
  username=$(glab api user | jq -r '.username')
  issues_json=$(glab api projects/:id/issues'?'assignee_username="$username"'&'per_page=100)
  iids=($(jq -r '.[]|.iid' <<< "$issues_json"))
  echo "## Completed since $DATE"
  for iid in "${iids[@]}"; do
    title=$(jq -r ".[]|select(.iid==${iid})|.title" <<< $issues_json)
    echo "$title (Issue #${iid})"
    busy view --unique -s done -t '- {base}' client+$CLIENT val:i$iid donemin:$DATE
    echo
  done
  echo
  echo "## In progress"
  for iid in "${iids[@]}"; do
    title=$(jq -r ".[]|select(.iid==${iid})|.title" <<< $issues_json)
    echo "$title (Issue #${iid})"
    busy view --unique -t '- {base}' client+$CLIENT val:i$iid
    echo
  done
}


# Labels for this project
glablabels() {
  glab api 'projects/:id/labels?include_ancestor_groups=false' | jq -r '.[]|.name'
}

# Just issue title
glabititle() {
  glab issue view $1 --output json | jq -r ".title"
}


# Find issues by glab criteria, outputting the iid and full title
glabilist() {
  glab issue list $@ --output json | jq -r ".[] | \"\(.iid|tostring)\t\(.title)\""
}


# Find issues by any string in the title
glabifind() {
  glab issue list --output json | jq -r ".[] | select(.title | test(\"$1\"; \"i\")) | \"\(.iid|tostring)\t\(.title)\""
}

# Combine glab with busy - update description for the current issue
glabiupbusy() {
  glab issue update $(busy get gitlab) --description -
}


glabi2wip() {
  glab api "projects/:id/issues/$1" | jq -r '.description' > WIP.md
}

glabwip2i() {
  glab issue update $1 --description "$(cat WIP.md)"
}


brname() {
  python3 -c "import re;print(re.sub(r'[^a-zA-Z0-9]+', '-','$1'.lower()))"
}

# Open CI editor in browser

glciedit () {
  open "https://${PWD#${HOME}/}/-/ci/editor?branch_name=$(git branch --show-current)"
}

# Run CI

glstatus () {
  echo | glab ci status --branch $(git log -1 --pretty=format:%H)
}

gltrace () {
  while true
    do glab ci trace --branch $(git log -1 --pretty=format:%H) || return
  done
}

glrun() {
  glab ci run || return
  gltrace
}

glmerge() {
  glab mr merge -sy &&
  if [ -s ".target-branch" ]; then
    TARGET=$(cat .target-branch)
  else
    TARGET="main"
  fi
  sleep 2
  git checkout $TARGET &&
  git pull &&
  sleep 2 &&
  gltrace
}


# Push changes and stat CI

glpush() {
  git status
  MESSAGE="$1"
  echo "\033[0;32m$MESSAGE\033[0m"
  echo -n "Perform git add, commit, and push? [OK]: "
  read
  git add -A
  git commit -m "$MESSAGE"
  git push
  sleep 5
  gltrace
}

# ... Repeating previous commit msg

upush() {
  glpush "$(git log -1 --pretty=%B)"
}

# ... or using Busy

bpush() {
  glpush "$(busy base $1)"
}


# Find a directory
alias finddir="find . -type d -name "


# Where is Python?

whereispython() {
  python3 -c "import pathlib;print(pathlib.Path(pathlib.__file__).parent)"
}

# Set up chruby to select Ruby versions

#CHRUBY_DIR=$(dirname $(which chruby-exec))/../share/chruby
#if [ "$CHRUBY_DIR" ] && [ -d $CHRUBY_DIR ]; then
#  source $CHRUBY_DIR/chruby.sh
#  source $CHRUBY_DIR/auto.sh
#fi


# Set time zone

export TZ="America/Vancouver"


# Docker commands that include the current project

dkr-sh() {
  docker run -it --entrypoint /bin/sh -v "$(pwd):/app" $1
}

dkr-bash() {
  docker run -it -v "$(pwd):/app" $1 /bin/bash
}

dkr-tools() {
  OP_ITEM_AWS="AWS sandbox (GitLab)"
  AWS_ACCESS_KEY_ID=$(op item get "$OP_ITEM_AWS" --vault Private --fields label="aws-access-key-id")
  AWS_SECRET_ACCESS_KEY=$(op item get "$OP_ITEM_AWS" --vault Private --fields label="aws-secret-access-key")
  if [ $# -eq 0 ]; then
    AWS_DEFAULT_REGION="us-west-2"
  else
    AWS_DEFAULT_REGION="$1"
  fi
  docker run -it -v "$(pwd):/app" \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    registry.gitlab.com/fpotter/ops/tools:latest /bin/bash
}

dkr-mdbook() {
  docker run -it -v "$(pwd):/app" -p 3000:3000 registry.gitlab.com/procicd/lib/mdbook:4 mdbook serve app -n 0.0.0.0
}

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
alias z2="emacs $HOME/.zlocal ; source $HOME/.zlocal"

# Keep everything clean
unset HISTFILE SAVEHIST

# https://gitlab.com/wizlib/swytchit
if [[ -n $SWYTCHITRC ]]; then source $SWYTCHITRC; fi

