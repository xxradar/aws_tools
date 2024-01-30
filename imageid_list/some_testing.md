```
export LOOKUP="Name=name,Values=*FortiGate*AWSONDEMAND*7.*"
aws ec2 describe-images --filters $LOOKUP | jq -r --arg region "$(echo -n $region)"  '.Images[] | $region + ", " + .ImageId + ", " + .Name'
aws ec2 describe-images --filters $LOOKUP | jq -r --arg region "$(echo -n $region)"  '.Images[] | $region + ", " + .ImageId + ", " + .Description'

```
