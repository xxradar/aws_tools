## Setting up

### Create a `terraform.tfvars`
```
access_key = "xxxxxxx"
secret_key = "xxxxxxx"
```


### Create gpg keys
```
#Generate a key (no passphrase)
gpg --gen-key


#Verify the key is added
gpg --list-secret-key --keyid-format LONG


#Export the the public key
gpg --export xxxx >labuserkey.pub
```

### Generate the users
```
./getpass.sh <#number> <name_prefix> <domain>
```
