#!/bin/sh

# installer.sh - Installation script for both termina & container
#####################################################
## To retrieve this file enter:                    ##
## curl -L# http://snip.li/i56h4   -o installer.sh ##
#####################################################

PREFIX='Crostini'

echo -n "Running Installer "

NODE=$(uname -n)
CONF='/mnt/stateful/lxd_conf'

if [ "$NODE" = 'localhost' ]; then
  if [ -d $CONF -a -w "$CONF" ]; then
    DIR="$CONF"
    echo "in VM ..."
  else
    echo "- not in a VM - Exiting ..."
    exit 1
  fi
elif grep -q lxd /etc/resolv.conf;  then
  if [ -d $HOME -a -w $HOME ]; then
    DIR="$HOME"
    echo "in Container ..."
  else
    echo "- not in a Container - Exiting ..."
    exit 1
  fi
else
  echo
  echo "Can't find VM or Container folders - ABORTING!"
  exit 1
fi
echo ""

echo "Unbundling files in $DIR"
for each in ./bin/*; do
  if [ -s "$each" ]; then
    chmod +x $each
  fi
done
mkdir -p $DIR/bak                       2>/dev/null
cp $DIR/.bash*     $DIR/.prof* $DIR/bak 2>/dev/null
cp -a ./bin $DIR
echo ""

echo "** Just about done, now we're ready to setup. **"
echo ""

echo -n "To 'source' your files please enter:  "
if [ "$NODE" = 'localhost' ]; then
  rm $DIR/bin/name 2>/dev/null
# . $DIR/bin/lxc.bashrc ||\
  echo "source $DIR/bin/lxc.bashrc"
else
  cp $DIR/bin/.bash* $DIR/bin/.prof* $DIR 2>/dev/null
# . $DIR/.profile ||\
  echo "source $DIR/.profile"
fi
echo ""
