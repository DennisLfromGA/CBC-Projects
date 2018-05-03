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
elif [ "$NODE" != 'localhost' ]; then
  if [ -d $HOME -a -w $HOME ]; then
    DIR="$HOME"
    echo "in Container ..."
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
cp -a ./bin $DIR
echo ""

echo "Sourcing files ..."
if [ "$NODE" = 'localhost' ]; then
  rm $DIR/bin/name
  echo ". $DIR/bin/lxc.bashrc"
  eval . $DIR/bin/lxc.bashrc
else
  cp -v $DIR/bin/.bash* $DIR/bin/.prof* $DIR
  echo ". $DIR/.profile"
  eval . $DIR/.profile
fi
echo ""

echo "** All done & ready to go **"
echo ""
