while [ true ]
do
   sshpass -p 'orga6620' scp -r -P 2222 ./* root@127.0.0.1:/root/tp1/validate_mips32
   sleep 4
   echo 'OK'
done
