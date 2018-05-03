# .lxc.bash_aliases - Aliases for common commands in termina
#######################################################
## To retrieve this file enter:                      ## 
## curl -L# http://snip.li/aubh -o .lxc.bash_aliases ##
#######################################################

### Alias definitions for Crostini
### See /usr/share/doc/bash-doc/examples in the bash-doc package.


###
### Grab a fresh copy of the ready2go script & run it
 alias getready2go="curl -Ls http://snip.li/qyfns -o /tmp/Crostini-extractor.sh && sh /tmp/Crostini-extractor.sh"

###
### enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
   test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
   alias ls='ls --color=auto -h'
   alias dir='ls --color=auto --format=vertical -h'
   alias egrep='egrep --color=auto'
   alias grep='grep --color=auto'
   alias fgrep='fgrep --color=auto'
   alias vdir='ls --color=auto --format=long -h'
fi

###
### some ls aliases
 alias l='ls -CFh'
 alias la='ls -AFh'
 alias ll='ls -hlF'
 alias lla='ls -hlAF'
 alias lld='ls -hlAF|grep ^d'
 alias llf='ls -hlAF|grep -v ^d'
 alias laa='ls -hAF --ignore=*'
 alias llaa='ls -hlAF --ignore=*'
 alias llar='ls -hlAFR'
 alias llr='ls -hlFR'
 alias ltr='ls -hltrF'
 alias ltra='ls -hltrAF'
 alias latr='ls -hltrAF'

###
### some history lessons
 alias r='fc -s'
 alias rf='history | grep -i'
 alias h='history'
 alias his='history'
 alias hsp='history | less'
 alias j='jobs -l'
 
###
### some more handy-dandies
 alias al=alias
 alias alf='alias | grep -Hi'
#alias bb=busybox
#alias bbhelp='nl /usr/local/bin/busybox-links-HELP.txt | less'
 alias c='clear'
 alias cD='cd $LXD_CONF'
 alias cls='tput clear'
#alias d='c; name'
 alias d='c; sf; echo'
#alias d='c; sf; echo; name'
#alias d='c; mf; name; updates; vmlist; playon status'
 alias dif='diff -Biw'
 alias dm='screenfetch -nN -d term,shell,wm,de|sed "s/^ //"'
 alias fh='free -hot'
 alias md='mkdir -p'
#alias mnt='mount|grep -e ^/dev/root -e /sd -e /mmcblk -e ^/dev/fuse | sort'
#alias mnt='mount|grep -e ^/dev/root -e /sd -e /mmcblk -e ^/dev/fuse | sort | column -t'
 alias ri='rm -i'
#alias rmdir='rmdir -v --ignore-fail-on-non-empty'
 alias rd='rmdir'
#alias rd='rm -rfd'
#alias pman='PAGER= man -a'
 alias png='ping -Aa -c5 -w10'
#alias sc='saycow'
 alias sf='screenfetch -E'
#alias sls='screen -ls;ps -ef|grep -i -e pts -e "screen "|grep -iv grep|sort -k +6' # list screens
#alias sr='screen -a -R' # initiate screen session
#alias sx='screen -X quit' # end screen session
 alias tlab='tar --test-label -af'
#alias wget='wget --retry-connrefused --no-check-certificate -T 60'
 alias whence='type -p'
 alias wh='which'
 alias wi='whereis'
