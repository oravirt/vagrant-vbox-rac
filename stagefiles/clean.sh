if [ "$1" == "YES" ]; then
  find /etc -name '*ohasd*' -exec rm {} \;
  find /etc -name '*tfa**' -exec rm {} \;
  rm -fr /u01/app /u01/stage /etc/oracle /etc/oratab /etc/oraInst.loc /tmp/.oracle /var/tmp/.oracle 2>/dev/null
  for x in /dev/sd{c..z}; do
    blkid $x* 2>/dev/null && dd if=/dev/zero of=$x bs=1M count=10
  done
  echo "halting $HOSTNAME"
  halt
else
  echo "This script require YES as argument"
fi
