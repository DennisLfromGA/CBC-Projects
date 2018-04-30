#!/bin/bash

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
cp -a ./bin $DIR
echo ""

echo "Sourcing files ..."
if [ "$NODE" = 'localhost' ]; then
  echo ". $DIR/bin/lxc.bashrc"
  . $DIR/bin/lxc.bashrc
else
  cp -v $DIR/bin/.bash* $DIR/bin/.prof* $DIR
  echo ". $DIR/.profile"
  . $DIR/.profile
fi
echo ""

echo "** All done & ready to go **"
echo ""
