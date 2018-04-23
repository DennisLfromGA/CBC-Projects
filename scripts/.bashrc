#set -x
#/etc/skel/.bashrc

# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


###########################################################################
## START ## Following lines copied from (standard) *nix .bashrc ## START ##
###########################################################################

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

HISTTIMEFORMAT='%D.%T  $ '

shopt -s cdspell

# If id command returns zero, you have root access.
if [ $(id -u) -eq 0 ];
then # you are root, set red colour prompt for superuser
   #PS1="\\[$(tput setaf 1)\\]\\u@\\h:\\w #\\[$(tput sgr0)\\]"
    PS1='${debian_chroot:+($debian_chroot)}\[$(tput setaf 1)\]\u@\h\[\e[00m\]:\d@\@\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ '
fi

# Prepend user bin to PATH if exists
[ -d $HOME/bin ] && PATH="$HOME/bin:$PATH"

PATH=`echo $PATH | tr ':' '\n' | sort | uniq | tr '\n' ':'`
CDPATH=.:~:~/Downloads:/etc:/var
export PATH CDPATH
export TERM=xterm-color

# Alias definitions.
# You may want to put all your additions into a separate file like
# $MYSTUFF/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# Function definitions.
# You may want to put all your additions into a separate file like
# $MYSTUFF/.bash_functions, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
[ -f ~/.bash_funcs ] && . ~/.bash_funcs

###########################################################################
##  END  ## Following lines copied from (standard) *nix .bashrc ##  END  ##
###########################################################################
cd
