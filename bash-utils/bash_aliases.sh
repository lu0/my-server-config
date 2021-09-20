# ----------- Server specifics ----------------------------------------------------------------------

alias s='systemctl'
alias j="journalctl -xe"

alias fuser="fuser -n tcp -k"
alias kill-nginx="systemctl stop nginx"
alias reload-nginx="systemctl reload nginx"

# Aliases I use a lot ---------------------------------------------------------------
alias cp="cp -riv"      # verbose
alias mkdir="mkdir -pv" # parent, verbose
alias rm="rm -i"

alias dusingle="sudo du -sh"            # size of directory
alias duall="sudo du -hd 1 . | sort -h" # size of subdirectories (1st level)
alias dfall="sudo df -h 1 .  | sort -h" # available space

alias dps='docker ps -a --no-trunc --format "table{{.Names}}\t{{.CreatedAt}}\t{{.Ports}}\t{{.Command}}"'

#
# Git aliases and functions I use ---------------------------------------------------------------------
#   https://github.com/lu0
#

function is-git-repo() {
    git rev-parse --is-inside-work-tree > /dev/null 2>&1
}

# STATUS
alias gstatus="git fetch && git status"
alias gstatus-sub="git submodule foreach 'git status'"


# PIECE-WISE OPERATIONS
alias gapatch="git add --patch"
alias gcopatch="git checkout --patch"
alias grepatch="git reset --patch"


# DIFFS
alias gdiff="git diff --color"
alias gtree="git diff-tree -p"  # diff of a commit. Usage: gtree COMMITHASH
alias gstaged="git diff --no-ext-diff --staged"

function gdiff-reorder() {
  # git diff between 2 files ignoring order of lines.
  # Usage: gdiff-reorder <path/to/file1> <path/to/file2>
  trap '' INT
  sort $1 >tmp-a
  sort $2 >tmp-b
  gdiff --no-index tmp-a tmp-b
  /bin/rm tmp-a tmp-b
}

# RELAXED MERGE
alias gmerge="git merge --no-commit --no-ff" # gmerge BRANCH_NAME

# LOGS
# Manual https://mirrors.edge.kernel.org/pub/software/scm/git/docs/git-log.html

# Default: Short commit hash + full dates + author + branch commit message.
alias glog="git log --graph --pretty=format:'%C(yellow)%h %C(red)%aD %C(cyan)%an%C(green)%d %Creset%s'"

# Same as default but with relative dates
alias glogr="git log --graph --pretty=format:'%C(yellow)%h %C(red)%ar %C(cyan)%an%C(green)%d %Creset%s'"

# Show logs of all branches
alias gloga="git log --graph --all --pretty=format:'%C(yellow)%h %C(red)%aD %C(cyan)%an%C(green)%d %Creset%s'"

# logs of a file/directory. Usage: gfollow /path/of/file
alias gfollow="git log --follow --graph --pretty=format:'%C(yellow)%h %C(red)%aD %C(cyan)%an%C(green)%d %Creset%s' -- "

# Find commit whose diff contains regex
function glog-find() {
  git log --pickaxe-regex -p --color-words -S"$*" # $* regex or string to find
}

# USER SPECIFIED IN THE CURRENT DIRECTORY
alias guser="git config user.name; git config user.email"

# COMMIT
alias gcommit="git commit -m"                   # Usage: gcommit "message"

# Amend last commit without changing its message
alias gamend="git commit --amend --no-edit"     # Usage: gamend

# FILES
# List tracked files. Usage: glist-tracked /path/to/subdir
alias glist-tracked="git ls-tree -r --abbrev=8 --name-only $(is-git-repo && git branch --show-current)"

# List untracked files. Usage: glist-untracked /path/to/subdir
alias glist-untracked="git ls-files --others --exclude-standard"

# Ignore all untracked files
alias gignoreall="git ls-files --others --exclude-standard >> .gitignore"

# Interactive deletion of untracked files
alias gclean-untracked="git clean -i"

# Interactive deletion of ignored files
alias gclean-ignored="git clean --exclude=.gitignore -xdi"

# Ignore and revert ignorance of tracked files (temporary)
# https://stackoverflow.com/a/23259612
alias gignore="git update-index --assume-unchanged"   # Usage: gignore path/to/file
alias gignored="git ls-files -v | grep ^[a-z]"        # list temporarily ignored files
alias gtrack="git update-index --no-assume-unchanged" # Usage: gtrack path/to/file

# SHOW/CHANGE TREATMENT OF SCRIPTS
# Track (true) or ignore (false) file mode changes
alias gmode="git config core.fileMode"

# STASHES
alias gslist="git stash list"

# Save a stash: gspush <name of stash>
function gspush() {
  git stash push -m "$*" -p # $* name of stash
}

# Apply a saved stash: gsapply <name of stash>
function gsapply() {
  git stash apply $(git stash list | grep "$*" | cut -d: -f1) # $* name of stash
}

# Show diff of a stash: gsshow <name of stash>
function gsshow() {
  git stash show -p $(git stash list | grep "$*" | cut -d: -f1) # $* name of stash
}

alias mail-setup="${GIT_DIR_MAIL}/setup.sh"
alias _mail-mx='echo -e "MX:\t\tmail.${HOSTNAME}"'
alias _mail-blank='echo -e "TXT blank:\tv=spf1 mx a:mail.${HOSTNAME} -all"'
alias _mail-dmarc='echo -e "TXT _dmarc:\tv=DMARC1; p=reject; rua=mailto:dmarc@${HOSTNAME}; fo=1"'
alias _mail-dkim="sudo cat ${HOME}/mail-server/config/opendkim/keys/${HOSTNAME}/mail.txt"

function mail-dns-show() {
    _mail-mx
    _mail-blank
    _mail-dmarc
    echo -e "\nTXT DKIM:"
    _mail-dkim
}