#
# Defines transfer alias and provides easy command line file and folder sharing.
#
# Authors:
#   Remco Verhoef <remco@dutchcoders.io>
#
#   github.com/DennisLfromGA (added logging)
#
##################################################
## To retrieve enter one of the below:          ## 
## curl -L http://bit.ly/2FefaKH -o transfer.sh ##
## wget -q http://bit.ly/2FefaKH -O transfer.sh ##
##################################################



APPLICATION="${0##*/}"
RIGHTNOW="$(date)"
EXPIRES="$(date -d "+14 days")"
TERMINA='/mnt/stateful/lxd_conf'

if [ -w "$HOME" ]; then
  LOGLOC=$HOME
elif [ -w "$TERMINA" ]; then
  LOGLOC="$TERMINA"
elif [ -w "$(pwd)" ]; then
  LOGLOC=$(pwd)
else
  echo "LOG LOCATION NOT WRITABLE"
fi

transfer() { 
    # check for curl
    curl --version 2>&1 > /dev/null
    if [ $? -ne 0 ]; then
      echo "Could not find curl."
      return 1
    fi

    # check arguments
    if [ $# -ne 1 ]; 
    then 
        echo -e "Wrong arguments specified. Usage:\ntransfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    fi

    # get temporary filename, output is written to this file so show progress can be showed
    tmpfile="$( mktemp -t transferXXX )"
    
    # upload stdin or file
    file="$1"

    if tty -s; 
    then 
        basefile="$( basename "$file" | sed -e 's/[^a-zA-Z0-9._-]/-/g' )"

        if [ ! -e $file ];
        then
            echo "File $file doesn't exists."
            return 1
        fi
        
        if [ -d $file ];
        then
            # zip directory and transfer
            zipfile="$( mktemp -t transferXXX.zip )"
            cd "$(dirname "$file")" && zip -r -q - "$(basename "$file")" >> "$zipfile"
            curl --progress-bar --upload-file "$zipfile" "https://transfer.sh/$basefile.zip" >> "$tmpfile"
            rm -f $zipfile
        else
            # transfer file
            curl --upload-file "$file" "https://transfer.sh/$basefile" >> "$tmpfile"
        fi
    else 
        # transfer pipe
        curl --progress-bar --upload-file "-" "https://transfer.sh/$file" >> "$tmpfile"
    fi
   
    # cat output link
    cat "$tmpfile"
    echo

   # log file link
    echo -e "$(cat "$tmpfile")	- uploaded $RIGHTNOW	- expires $EXPIRES" >> $LOGLOC/$APPLICATION.log
    echo "See $LOGLOC/$APPLICATION.log for all transfers."
   
    # cleanup
    rm -f "$tmpfile"
}

transfer "$@"
