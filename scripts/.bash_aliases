#######################################################################
## To retrieve enter: curl -L http://bit.ly/2qRX9NR -o .bash_aliases ##
#######################################################################

### Alias definitions for chromeos
### See /usr/share/doc/bash-doc/examples in the bash-doc package.

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
### if user is not root,
##+ pass all superuser commands via sudo
if [ $(id -u) -ne 0 ];
then
   alias fdisk='sudo fdisk'
   alias du='sudo du'
   alias find='sudo find'
   alias is=initstats
   alias vis='sudo vi'
   alias vss='sudo vs'
fi

###
### some history lessons
 alias r='fc -s'
 alias rf='history | grep -i'
 alias h='history'
 alias his='history'
 alias hsp='history | less'
 alias j='jobs -l'
 
###
### some editing helpers
 alias baf='. ~/.bash_funcs'
 alias bas='. ~/.bash_aliases'
 alias brc='. ~/.bashrc'
 alias bpf='. ~/.bash_profile'
#alias gvim="gvim $@ &> /dev/null"
 alias vi=vim
 alias iv='vi'
 alias va='vi ~/.bash_aliases    && source ~/.bash_aliases'
 alias vb='vi ~/.bashrc          && source ~/.bashrc'
 alias vf='vi ~/.bash_funcs      && source ~/.bash_funcs'
 alias vl='vi ~/.bash_logout     && source ~/.bash_logout'
#alias vg='gvim'
 alias vp='vi ~/.bash_profile    && source ~/.bash_profile'

###
### some more handy-dandies
 alias al=alias
 alias alf='alias | grep -Hi'
 alias bb=busybox
 alias bbhelp='nl /usr/local/bin/busybox-links-HELP.txt | less'
 alias c='clear'
 alias cls='tput clear'
#alias d='c; name'
 alias d='c; sf; echo; name'
#alias d='c; mf; name; updates; vmlist; playon status'
 alias dif='diff -Biw'
 alias dm='screenfetch -nN -d term,shell,wm,de|sed "s/^ //"'
 alias fh='free -hot'
#alias fx='mint-fortunex'
 alias jar='java -Xmx256M -jar'
 alias md='mkdir -p'
#alias mf='mint-fortune'
#alias mfx='mint-fortunex'
 alias mnt='mount|grep -e ^/dev/root -e /sd -e /mmcblk -e ^/dev/fuse | sort'
#alias mnt='mount|grep -e ^/dev/root -e /sd -e /mmcblk -e ^/dev/fuse | sort | column -t'
 alias ri='rm -i'
 alias rmdir='rmdir -v --ignore-fail-on-non-empty'
 alias rd='rmdir'
#alias rd='rm -rfd'
#alias pman='PAGER= man -a'
 alias png='ping -Aa -c5 -w10'
#alias sc='saycow'
 alias sc='screencast'
 alias sf='screenfetch -E'
 alias sls='screen -ls;ps -ef|grep -i -e pts -e "screen "|grep -iv grep|sort -k +6' # list screens
 alias sr='screen -a -R' # initiate screen session
 alias sx='screen -X quit' # end screen session
#alias srch='gnome-search-tool'
 alias tlab='tar --test-label -af'
 alias wget='wget --retry-connrefused --no-check-certificate -T 60'
 alias whence='type -p'
 alias wh='which'
 alias wi='whereis'

###
### some SSH shortcuts
 alias XPi='xinit -- :1 &'
 alias xpi=XPi
 alias RPi='ssh pi lxsession'
 alias rpi=RPi

###
### some 'git' shortcuts
 alias gadd='git ls-files -m|xargs --verbose -i git add "{}"'
 alias gls='git ls-files'
 alias glsm='git ls-files -m'
 alias gs='git status'
 alias pop='git stash pop'
 alias stash='git stash'
