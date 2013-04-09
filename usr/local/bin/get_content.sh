#!/bin/bash
# Nagios script to get the content of a page

help () {
echo "Get the contents of an HTML page, and return it as the status."
echo "Usage: $0 [--ssl] <hostname> <path>"
}

HOSTNAME=''
PATH=''
SSL=0

while :; do
   if [[ -z $1 ]]; then break; fi
   case "$1" in
      -h|--help)
        help
        exit 0
        ;;
      --ssl)
        SSL=1
        shift;
        ;;
      -*)
        echo "Unexpected option $1"
        help
        exit 1
        ;;
      *)
        if [[ -z $HOSTNAME ]]; then
          HOSTNAME=$1
          shift;
        elif [[ -z $PATH ]]; then
          PATH=$1
          shift;
        else
          echo "Unexpected argument $1"
          help
          exit 1
        fi
        ;;
  esac
done

if [[ -z $PATH ]]; then
  help
  exit 0
fi

if [[ $SSL == 1 ]]; then
  METHOD='https'
else
  METHOD='http'
fi

/usr/bin/curl --fail --connect-timeout 2 "$METHOD://$HOSTNAME$PATH"
RET=$?
if   [[ $RET == 0  ]]; then exit 0;
elif [[ $RET == 22 ]]; then echo 'CRITICAL: Server did not return OK';
elif [[ $RET == 7  ]]; then echo 'CRITICAL: Failed to connect';
else                        echo "WARNING: Unknown curl error '$RET'"; exit 1;
fi

exit 2; // Critical Nagios Error
