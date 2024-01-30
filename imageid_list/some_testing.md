```
export LOOKUP="Name=name,Values=*FortiGate*AWSONDEMAND*7.*"
aws ec2 describe-images --filters $LOOKUP | jq -r --arg region "$(echo -n $region)"  '.Images[] | $region + ", " + .ImageId + ", " + .Name'
aws ec2 describe-images --filters $LOOKUP | jq -r --arg region "$(echo -n $region)"  '.Images[] | $region + ", " + .ImageId + ", " + .Description'
```

```
export LOOKUP="Name=name,Values=*FortiGate*AWSONDEMAND*"
aws ec2 describe-images --filters $LOOKUP | jq -r --arg region "$(echo -n $region)"  '.Images[] | $region  + " " + .ImageId + " " + .Description' >tst.lst
cat tst.lst | sed 's/ /, /g' | sed 's/[()]//g' >final.lst
```
```
#!/bin/bash

# Read each line from the file
while IFS=,  read -r region ami_id type build version ga; do
	echo $region $ami_id $type $build $version $ga
done < final.lst
```
