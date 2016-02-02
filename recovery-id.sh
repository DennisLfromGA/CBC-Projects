#!/bin/sh
#
# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This attempts to download current Chrome OS image data for importing
# to a spreadsheet.
#
# We may not need root privileges if we have the right permissions.
#
set -eu

##############################################################################
# Configuration goes here

# Where should we do our work? Use 'WORKDIR=' to make a temporary directory,
# but using a persistent location may let us resume interrupted downloads or
# run again without needing to download a second time.
WORKDIR=${WORKDIR:-/tmp/tmp.crosrec}

# Where do we look for the config file? We can override this for debugging by
# specifying "--config URL" on the command line, but curl and wget may handle
# file URLs differently.
CONFIGURL="${2:-https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf?source=linux_recovery.sh}"

# What version is this script? It must match the 'recovery_tool_version=' value
# in the config file that we'll download.
MYVERSION='0.9.2'

##############################################################################
# Some temporary filenames
debug='debug.log'
tmpfile='tmp.txt'
config='config.txt'
version='version.txt'

# Output file name
recovery_tmp='recovery-id.tmp'
recovery_id='recovery-id.csv'

# Local config file for comparison
local_config="$HOME/Downloads/CBC/tmp.txt"

##############################################################################
# Various warning messages

DEBUG() {
  echo "DEBUG: $@" >>"$debug"
}

prompt() {
  # builtin echo may not grok '-n'. We should always have /bin/echo, right?
  /bin/echo -n "$@"
}

warn() {
  echo "$@" 1>&2
}

fatal() {
  warn "ERROR: $@"
  exit 1
}

ufatal() {
  warn "
ERROR: $@

You may need to run this program as a different user. If that doesn't help, try
using a different computer, or ask a knowledgeable friend for help.

"
  exit 1
}

gfatal() {
  warn "
ERROR: $@

You may need to run this program as a different user. If that doesn't help, it
may be a networking problem or a problem with the images provided by Google.

If all else fails, you could try using a different computer, or ask a
knowledgeable friend for help.

"
  exit 1
}

##############################################################################
# Identify the external utilities that we MUST have available.
#
# I'd like to keep the set of external *NIX commands to an absolute minimum,
# but I have to balance that against producing mysterious errors because the
# shell can't always do everything. Let's make sure that these utilities are
# all in our $PATH, or die with an error.
#
# This also sets the following global variables to select alternative utilities
# when there is more than one equivalent tool available:
#
#   FETCH          = name of utility used to download files from the web
#
require_utils() {
  local extern
  local errors
  local tool
  local tmp

  extern='grep mkdir sed'
  if [ -z "$WORKDIR" ]; then
    extern="$extern mktemp"
  fi
  errors=

  for tool in $extern ; do
    if ! type "$tool" >/dev/null 2>&1 ; then
      warn "ERROR: need \"$tool\""
      errors=yes
    fi
  done

  # We also need to a way to fetch files from the internets. Note that the args
  # are different depending on which utility we find. We'll use two variants,
  # one to fetch fresh every time and one to try again from where we left off.
  FETCH=
  if [ -z "$FETCH" ] && tmp=$(type curl 2>/dev/null) ; then
    FETCH=curl
  fi
  if [ -z "$FETCH" ] && tmp=$(type wget 2>/dev/null) ; then
    FETCH=wget
  fi
  if [ -z "$FETCH" ]; then
    warn "ERROR: need \"curl\" or \"wget\""
    errors=yes
  fi

  if [ -n "$errors" ]; then
    ufatal "Some required utilities are missing."
  fi
}

##############################################################################
# This retrieves a URL and stores it locally. It uses the global variable
# 'FETCH' to determine the utility (and args) to invoke.
# Args:  URL FILENAME [RESUME]
fetch_url() {
  local url
  local filename
  local resume
  local err

  url="$1"
  filename="$2"
  resume="${3:-}"

  DEBUG "FETCH=($FETCH) url=($url) filename=($filename) resume=($resume)"

  if [ "$FETCH" = "curl" ]; then
    if [ -z "$resume" ]; then
      # quietly fetch a new copy each time
      rm -f "$filename"
      curl -L -f -s -S -o "$filename" "$url"
    else
      # continue where we left off, if possible
      curl -L -f -C - -o "$filename" "$url"
      # If you give curl the '-C -' option but the file you want is already
      # complete and the server doesn't report the total size correctly, it
      # will report an error instead of just doing nothing. We'll try to work
      # around that.
      err=$?
      if [ "$err" = "18" ]; then
        warn "Ignoring spurious complaint"
        true
      fi
    fi
  elif [ "$FETCH" = "wget" ]; then
    if [ -z "$resume" ]; then
      # quietly fetch a new copy each time
      rm -f "$filename"
      wget -nv -q -O "$filename" "$url"
    else
      # continue where we left off, if possible
      wget -c -O "$filename" "$url"
    fi
  fi
}

##############################################################################
# Each paragraph in the config file should describe a new image. Let's make
# sure it follows all the rules. This scans the config file and returns success
# if it looks valid. As a side-effect, it lists the line numbers of the start
# and end of each stanza in the global variables 'start_lines' and 'end_lines'
# and saves the total number of images in the global variable 'num_images'.

# NOTE: making assumptions about the order of lines in each stanza!
## name=Samsung Chromebook 2 13"
## version=7077.134.0
## desc=Samsung Ares device
## channel=stable-channel
## hwidmatch=^PI .*
## hwid=PI
## md5=e34fec4c6672fa1389ca7e5fccd852d8
## sha1=da253ad6808858e382927e15218224cb8f8c481b
## zipfilesize=496876989
## file=chromeos_7077.134.0_peach-pi_recovery_stable-channel_pi-mp.bin
## filesize=1556054016
## url=https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos_7077.134.0_peach-pi_recovery_stable-channel_pi-mp.bin.zip

good_config() {
  local name=
  local version=
  local desc=
  local channel=
  local hwidmatch=
  local hwid=
  local md5=
  local sha1=
  local zipfilesize=
  local file=
  local filesize=
  local url=

  local line
  local key
  local val
  local skipping=yes
  local errors=
  local count=0
  local line_num=0
  local fs=','

  # global
  start_lines=
  end_lines=

  echo "Name${fs}Description${fs}Channel${fs}Version${fs}HWID Match${fs}HWID${fs}File${fs}File Size${fs}URL${fs}Zip File Size${fs}MD5${fs}SHA1" > $recovery_tmp

  while read line; do
    line_num=$(( line_num + 1 ))

    # We might have some empty lines before the first stanza. Skip them.
    if [ -n "$skipping" ] && [ -z "$line" ]; then
      continue
    fi

    # Got something...
    if [ -n "$line" ]; then
      key="${line%=*}"
      val="${line#*=}"
      if [ -z "$key" ] || [ -z "$val" ] || [ "$key=$val" != "$line" ]; then
        DEBUG "ignoring $line"
        continue
      fi

      # right, looks good
      if [ -n "$skipping" ]; then
        skipping=
        start_lines="$start_lines $line_num"
      fi

      case $key in
        name)
          if [ -n "$name" ]; then
            DEBUG "duplicate $key"
          fi
          name="$(echo $val | sed 's/"$/-inch/')"
          ;;
        version)
          if [ -n "$version" ]; then
            DEBUG "duplicate $key"
          fi
          version="$val"
          ;;
        desc)
          if [ -n "$desc" ]; then
            DEBUG "duplicate $key"
          fi
          desc="$(echo $val | sed -e 's_,_ /_g' -e 's/\([0-9]\)" /\1-inch /')"
          desc="$(echo $desc | sed "s/\"/'/g")"
          ;;
        channel)
          if [ -n "$channel" ]; then
            DEBUG "duplicate $key"
          fi
          channel="$val"
          ;;
        hwidmatch)
          if [ -n "$hwidmatch" ]; then
            DEBUG "duplicate $key"
          fi
          hwidmatch="$val"
          ;;
        hwid)
          if [ -n "$hwid" ]; then
            DEBUG "duplicate $key"
          fi
          hwid="$val"
          ;;
        md5)
          md5="$val"
          ;;
        sha1)
          sha1="$val"
          ;;
        zipfilesize)
          if [ -n "$zipfilesize" ]; then
            DEBUG "duplicate $key"
          fi
          zipfilesize="$val"
          ;;
        file)
          if [ -n "$file" ]; then
            DEBUG "duplicate $key"
          fi
          file="$val"
          ;;
        filesize)
          if [ -n "$filesize" ]; then
            DEBUG "duplicate $key"
          fi
          filesize="$val"
          ;;
        url)
          url="$val"
          ;;
      esac

    else

      # Between paragraphs. Time to check what we've found so far.
      end_lines="$end_lines $line_num"
      count=$(( count + 1))

      if [ -z "$name" ]; then
        DEBUG "image $count is missing name"
        errors=yes
      fi
      if [ -z "$file" ]; then
        DEBUG "image $count is missing file"
        errors=yes
      fi
      if [ -z "$zipfilesize" ]; then
        DEBUG "image $count is missing zipfilesize"
        errors=yes
      fi
      if [ -z "$filesize" ]; then
        DEBUG "image $count is missing filesize"
        errors=yes
      fi
      if [ -z "$url" ]; then
        DEBUG "image $count is missing url"
        errors=yes
      fi

      ## name=Samsung Chromebook 2 13"
      ## version=7077.134.0
      ## desc=Samsung Ares device
      ## channel=stable-channel
      ## hwidmatch=^PI .*
      ## hwid=PI
      ## md5=e34fec4c6672fa1389ca7e5fccd852d8
      ## sha1=da253ad6808858e382927e15218224cb8f8c481b
      ## zipfilesize=496876989
      ## file=chromeos_7077.134.0_peach-pi_recovery_stable-channel_pi-mp.bin
      ## filesize=1556054016
      ## url=https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos_7077.134.0_peach-pi_recovery_stable-channel_pi-mp.bin.zip

      echo "$name${fs}$desc${fs}$channel${fs}$version${fs}$hwidmatch${fs}${hwid:- }${fs}$file${fs}$filesize${fs}$url${fs}$zipfilesize${fs}$md5${fs}$sha1" >> $recovery_tmp
  
      line_num=0
      # Prepare for next stanza
      name=
      file=
      zipfilesize=
      filesize=
      url=
      md5=
      sha1=
      skipping=yes
      errors=
    fi
  done < "$config"

  DEBUG "$count images found"
  num_images="$count"

  DEBUG "start_lines=($start_lines)"
  DEBUG "end_lines=($end_lines)"

  # return error status
  [ "$count" != "0" ] && [ -z "$errors" ]
# [ "$count" != "0" ] && [ -n "$errors" ]
}

# show the images retrieved if requested
show_images() {
  local show
  local count
  local line
  local num
  local showheader
  local headershown
  local showhwid
  local showregexp
  local regexpshown
  local curname
  local curchannel
  local curregexp
  local space=" "
  local caret="^"

  show=yes
  while true; do
    if [ -n "$show" ]; then
      echo
      echo "This may take a few minutes to print the full list..."

      echo
      if [ "$num_images" -gt 1 ]; then
        echo "There are up to $num_images recovery images to choose from:"
      else
        echo "There is $num_images recovery image to choose from:"
      fi
      echo
      count=0

      # NOTE: making assumptions about the order of lines in each stanza!
      while read line; do
        # Got something...
        if [ -n "$line" ]; then
          # Extract key/value pair
          key=${line%=*}
          val=${line#*=}
          if [ -z "$key" ] || [ -z "$val" ] || \
            [ "$key=$val" != "$line" ]; then
            DEBUG "ignoring $line"
            continue
          fi

          showhwid=
          showregexp=

          case $key in
            name)
              count=$(( count + 1 ))
              headershown=
              curname=${val}
              curregexp=
              regexpshown=
              ;;
            channel)
              curchannel=${val}
              ;;
            hwidmatch)
              curregexp=${val}
              # If there is no prefix specified, show the hwid match.
              showregexp=true
              ;;
          esac

          # Show header at most once per image
          if [ -z "$headershown" ]; then
            if [ -n "$showregexp" ] || [ -n "$showhwid" ]; then
              echo "$count - $curname"
              echo "  channel:  $curchannel"
              headershown=true
            fi
          fi

          if [ -z "$regexpshown" ] && [ -n "$showregexp" ] &&
           [ -n "$curregexp" ]; then
            echo "  pattern:   $curregexp"
            regexpshown=true
          elif [ -n "$showhwid" ]; then
            echo "  model:  $curhwid"
          fi
        fi
      done < "$config"

      echo
      show=
    fi
    false
  done
  echo
}

##############################################################################
# Okay, do something...

# Warn about usage
if [ -n "${1:-}" ] && [ "$1" != "--config" ]; then
  echo "This program takes no arguments. Just run it."
  echo "[ That's not really true. For debugging you can specify "--config URL". ]"
  exit 1
fi

# Make sure we have the tools we need
require_utils

# Need a place to work. We prefer a fixed location so we can try to resume any
# interrupted downloads.
if [ -n "$WORKDIR" ]; then
  if [ ! -d "$WORKDIR" ] && ! mkdir "$WORKDIR" ; then
    warn "Using temporary directory"
    WORKDIR=
  fi
fi
if [ -z "$WORKDIR" ]; then
  WORKDIR=$(mktemp -d)
  # Clean up temporary directory afterwards
  trap "cd; rm -rf ${WORKDIR}" EXIT
fi

cd "$WORKDIR"
warn "Working in $WORKDIR/"
rm -f "$debug"

# Download the config file to see what choices we have.
DISPLAYED_CONFIGURL=`echo $CONFIGURL | sed s/\?.*//`
warn "Downloading config file from $DISPLAYED_CONFIGURL"
fetch_url "$CONFIGURL" "$tmpfile" || \
  gfatal "Unable to download the config file"

# Check to see if the config file has changed.
if diff -q $tmpfile $local_config 2>&1 >/dev/null; then
  echo "The recovery images have not changed."
  echo "No need to proceed with generation of $recovery_id."
  exit 0
else
  echo "The recovery images have changed."
  echo "Continuing with generation of $recovery_id ..."
fi
exit

# Separate the version info from the images
grep '^recovery_tool' "$tmpfile" > "$version"
grep -v '^#' "$tmpfile" | grep -v '^recovery_tool' > "$config"
# Add one empty line to the config file to terminate the last stanza
echo >> "$config"

# Make sure that the config file version matches this script version.
tmp=$(grep '^recovery_tool_linux_version=' "$version") || \
  tmp=$(grep '^recovery_tool_version=' "$version") || \
  gfatal "The config file doesn't contain a version string."
filevers=${tmp#*=}
if [ "$filevers" != "$MYVERSION" ]; then
  tmp=$(grep '^recovery_tool_update=' "$version");
  msg=${tmp#*=}
  warn "This tool is version $MYVERSION." \
    "The config file is for version $filevers."
  fatal ${msg:-Please download a matching version of the tool and try again.}
fi

# Check the config file to be sure it's valid. As a side-effect, this sets the
# global variable 'num_images' with the number of image stanzas read, but
# that's independent of whether the config is valid.
good_config || gfatal "The config file isn't valid."

## add back in if you want to display the images
# prompt "Shall I show the images list now? [y/N] "
# read list
# case $list in
#   [Yy]*)
#     show_images
#     ;;
# esac

## sort recovery id's and save to file
if [ -r $recovery_tmp ]; then
  echo -n "Sorting recovery id's "
  head -n 1  $recovery_tmp        >  $recovery_id
  tail -n +2 $recovery_tmp | sort >> $recovery_id
else
  fatal "Generation of recovery id's has failed!"
fi

if [ -r $HOME/Downloads/$recovery_id ]; then
  mv $HOME/Downloads/$recovery_id /tmp 2>/dev/null
fi

echo "and placing a copy of $recovery_id in ~/Downloads"
cp $recovery_id $HOME/Downloads 2>/dev/null || warn "Copy to ~/Downloads has failed!"

## uncomment to prompt for removal of temp files
#prompt "Shall I remove the temporary files now? [y/N] "
#read tmp
#case $tmp in
#  [Yy]*)
#    cd
#    \rm -rf ${WORKDIR}
#    ;;
#esac

exit 0
