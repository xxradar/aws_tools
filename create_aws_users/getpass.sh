#!/bin/bash

nbuser=$1
index=0
indexbis=0
name=$2
domain=$3
list="["

while [ $index -lt $nbuser ]
do
    newuser=$name$index@$3

    if [ $index == "0" ]
    then
        list=$list"\""$newuser"\""
    else
	    list=$list",\""$newuser"\""
    fi

    index=$((index+1))
done

list=$list"]"

echo   $list
echo "-----"
echo -e "variable \"students_user_names\" { \n\t type=list \n\t default=$list \n}" > variables.tf
sudo terraform init
sudo terraform apply
#sudo terraform destroy

while [ $indexbis -lt $nbuser ]
do
    echo $name$indexbis@$3 = >> final.txt
    sudo terraform output -json | python3 -c "import sys, json; print(json.load(sys.stdin)['new_iam_user_password']['value'][0][$indexbis])" | base64 --decode >> pass-$indexbis.txt
    gpg  --decrypt pass-$indexbis.txt >> final.txt
    echo -e "\n" >> final.txt
    indexbis=$((indexbis+1))
done

aws sts get-caller-identity
 rm -f pass-*
  rm -f variables.tf

