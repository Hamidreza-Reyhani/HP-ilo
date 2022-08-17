#!/bin/bash -x
AdminPass="$1"
User="$2"
date=$(date "+%Y-%m-%d")
display_usage() { 
echo -e "\nUsage: ./$(basename $0) AdminPass FullPrivilageUser\n"
echo "AdminPass must be a list file with this format : IP       FullControlUserName     FullControlUserPassword "
}

CHPassword() {
  echo Opration for $(echo $IloIp|awk '{print $1}' )  Password Change ...
  string=$(cat "$AdminPass"  |grep $IloIp) 
  Url=$(echo $string|awk '{print $1}')
  FullControlUserName=$(echo $string|awk '{print $2}')
  Password=$(echo $string|awk '{print $3}')
  echo Checking User Validation ...
  ilorest select ManagerAccount. --url="$Url" --user "$FullControlUserName" --password "$Password"  > /dev/null 2>&1
  ExistUser=$(ilorest list Oem/Hpe 2>&-  | grep  "LoginName="|grep "$User")
  if [ ! -z  "$ExistUser" ];
  then
  echo Genarating Password ...
  NewPassword=$(cat /dev/urandom | tr -dc '1234567689!@#$%}{][ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' | head -c16; echo "")
  echo Changing $User  Password ...
  ilorest iloaccounts changepass "$User" "$NewPassword" --url="$Url" --user "$FullControlUserName" --password "$Password" > /dev/null 2>&1
  if [  "$?" -eq 0 ]
  then
  echo $Url  "$User" Password  Updated  Successfully!
  echo "$(echo $IloIp|  awk '{print $1}' )      $User   $NewPassword ">> "$User"-"$date"
  else
  echo $Url Can not Change user:"$User"  Password Please check Input or Network Connection!!
  ilorest logout
  exit 1
  fi
  else
  echo In $Url The User:"$User" not existing!!
   ilorest logout > /dev/null 2>&1
  fi
  ilorest logout > /dev/null 2>&1
}


########################
########MAIN###########
########################

if [  $# -ne 2 ]
        then
                display_usage
                exit 1
fi

if [[ ( $# == "--help") ||  $# == "-h" ]]
then
                display_usage
                exit 0
fi






cat  "$AdminPass" | awk '{print $1}' | while read IloIp
do
CHPassword 
done
