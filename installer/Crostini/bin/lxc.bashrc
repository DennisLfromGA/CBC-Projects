#/etc/skel/.bashrc

# lxc.bashrc - Setup environment, paths, etc.
#################################################
## To retrieve this file enter:                ## 
## curl -L# http://snip.li/y318t -o lxc.bashrc ##
#################################################

# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


###########################################################################
## START ## Following lines copied from (standard) *nix .bashrc ## START ##
###########################################################################

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth

HISTTIMEFORMAT='%D.%T  $ '

# If id command returns zero, you have root access.
if [ $(id -u) -eq 0 ];
then # you are root, set red colour prompt for superuser
   #PS1="\\[$(tput setaf 1)\\]\\u@\\h:\\w #\\[$(tput sgr0)\\]"
    PS1='${debian_chroot:+($debian_chroot)}\[$(tput setaf 1)\]\u@\h\[\e[00m\]:\d@\@\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ '
fi

MYSTUFF='/mnt/stateful/lxd_conf/bin'
if [ ! -d $MYSTUFF ]; then
  echo "Sorry, no files found in $MYSTUFF ..."
  exit 1
fi

# Prepend lxd bin to PATH if exists
[ -d $MYSTUFF ] && PATH="$MYSTUFF:$PATH"

PATH=`echo $PATH | tr ':' '\n' | sort | uniq | tr '\n' ':'`
CDPATH=.:~:$(dirname $MYSTUFF):/etc:/var
export PATH CDPATH
export TERM=xterm-color

# Alias definitions.
# You may want to put all your additions into a separate file like
# $MYSTUFF/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
[ -f $MYSTUFF/.lxc.bash_aliases ] && . $MYSTUFF/.lxc.bash_aliases

# Alias definitions for Cr-48
[ -f $MYSTUFF/.lxc.termina_aliases ] && . $MYSTUFF/.lxc.termina_aliases

# Function definitions.
# You may want to put all your additions into a separate file like
# $MYSTUFF/.bash_functions, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
[ -f $MYSTUFF/.lxc.bash_funcs ] && . $MYSTUFF/.lxc.bash_funcs

###########################################################################
##  END  ## Following lines copied from (standard) *nix .bashrc ##  END  ##
###########################################################################
cd
