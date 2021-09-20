# /etc/inputrc - global inputrc for libreadline
# See readline(3readline) and `info rluserman' for more information.

# See current kb: stty -a
# Monitor keybindings: sed -n l

# Be 8 bit clean.
set input-meta on
set output-meta on

# To allow the use of 8bit-characters like the german umlauts, uncomment
# the line below. However this makes the meta key not work as a meta key,
# which is annoying to those which don't need to type in 8-bit characters.

# set convert-meta off

# try to enable the application keypad when it is called.  Some systems
# need this to enable the arrow keys.
# set enable-keypad on

# see /usr/share/doc/bash/inputrc.arrows for other codes of arrow keys

# do not bell on tab-completion
# set bell-style none
# set bell-style visible

# some defaults / modifications for the emacs mode
$if mode=emacs

# allow the use of the Home/End keys
"\e[1~": beginning-of-line
"\e[4~": end-of-line

# allow the use of the Delete/Insert keys
"\e[3~": delete-char
"\e[2~": overwrite-mode

# mappings for "page up" and "page down" to step to the beginning/end
# of the history
"\e[5~": beginning-of-history
"\e[6~": end-of-history

# mappings for Ctrl-left-arrow and Ctrl-right-arrow for word moving
"\e[1;5C": forward-word
"\e[1;5D": backward-word
"\e[5C": forward-word
"\e[5D": backward-word
"\e\e[C": forward-word
"\e\e[D": backward-word

$if term=rxvt
"\e[7~": beginning-of-line
"\e[8~": end-of-line
"\eOc": forward-word
"\eOd": backward-word
$endif

# Key bindings, up/down arrow searches through history
"\e[A": history-search-backward
"\e[B": history-search-forward
"\eOA": history-search-backward
"\eOB": history-search-forward

# Ctrl-Delete to delete next word
"\e[3;5~": kill-word

# Ctrl+k to delete whole line
"\C-K": kill-whole-line
"\C-D": kill-whole-line

# Ctrl-down and Ctrl-up to down/uppercase the next word
"\e[1;5A": upcase-word --
"\e[1;5B": downcase-word

# Ctrl+Backspace to delete previous word
"\C-H": backward-kill-word

# Incremental undo
"\C-z": undo

# Ctrl-shift-down and Ctrl-shift-up to scroll on terminal
