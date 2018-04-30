# .bash_profile - Ensure .profile is run.
###################################################
## To retrieve this file enter:                  ## 
## curl -L# http://snip.li/vuYg -o .bash_profile ##
###################################################

# Load .profile, containing login, non-bash related initializations.
if [ -f ~/.profile ]; then
    source ~/.profile
fi
