#!/bin/bash

help () {
echo "Checks if the unsent mail has changed since the last check"
echo "Usage: $0 [endpoint] [--dry-run]"
}

DRY_RUN=0
ENDPOINT="$1"
if [[ "$ENDPOINT" == "" ]]
then
    echo "CRITICAL: Must pass in an endpoint as the first param!"
    help
    exit 1
fi
shift

while :; do
   if [[ -z $1 ]]; then break; fi
   case "$1" in
      -h|--help)
        help
        exit 0
        ;;
      --dry-run)
        DRY_RUN=1
        shift;
        ;;
      -*)
        echo "Unexpected option $1"
        help
        exit 1
        ;;
      *)
        echo "Unexpected argument $1"
        help
        exit 1
        ;;
  esac
done

THIS_PASS=/tmp/check_unset_email.this.txt
LAST_PASS=/tmp/check_unset_email.last.txt
if [[ $DRY_RUN == 1 ]]
then
  DRY_THIS_PASS=/tmp/check_unset_email.dry.this.txt
  DRY_LAST_PASS=/tmp/check_unset_email.dry.last.txt
  if [[ -f $THIS_PASS ]]; then cp $THIS_PASS $DRY_THIS_PASS; fi
  if [[ -f $LAST_PASS ]]; then cp $LAST_PASS $DRY_LAST_PASS; fi
  THIS_PASS=$DRY_THIS_PASS
  LAST_PASS=$DRY_LAST_PASS
fi

/usr/bin/curl --silent --fail --connect-timeout 2 "$ENDPOINT" > $THIS_PASS
RET=$?
if [[ $RET != 0  ]]; then
  if   [[ $RET == 22 ]]; then echo 'CRITICAL: Server did not return OK';
  elif [[ $RET == 7  ]]; then echo 'CRITICAL: Failed to connect';
  else                        echo "CRITICAL: Unknown curl error '$RET'";
  fi
  exit 2; // Critical Nagios Error
fi

if [[ ! -f $LAST_PASS ]]; then
  MSG="First run after reboot:"
  RET=0
elif ! diff -q $THIS_PASS $LAST_PASS > /dev/null; then
  MSG="WARNING: New Error:"
  RET=1
else
  MSG="Same status:"
  RET=0
fi
cp $THIS_PASS $LAST_PASS

echo "$MSG `cat $THIS_PASS`"
exit $RET
