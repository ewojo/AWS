 #!bin/bash
 
#set the bucket name
bucket=BUCKETNAME
 
#set the storage class
class=GLACIER
 
#loop though the objects and find something
IFS=$(echo -en "\n\b\t")
SAVEIFS=$IFS
for a in $(aws s3api  list-object-versions --bucket $bucket  --output json --query 'Versions[?StorageClass==`'$class'`].Key'| jq -r .[]);
        do
        # Run a head object api call to get the restore status of the Glacier object
        restore=$(aws s3api head-object --bucket $bucket --key $a --query Restore --output text);
 
        # If there is no ongoing restore, and expiry date, then the object is not restored, and not in restoration progress
        if [ $restore == "None" ];
        then
                #echo $a "Has not been Restored"
                echo $a
        fi
done
