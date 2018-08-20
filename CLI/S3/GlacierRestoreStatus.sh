#!bin/bash
#set the bucket name
bucket=bucketname
#set the storage class
class=GLACIER
#loop though the objects and find something
IFS=$(echo -en "\n\b\t")
SAVEIFS=$IFS
for a in $(aws s3api list-object-versions --bucket $bucket --output json --query 'Versions[?StorageClass==`'$class'`].Key'| jq -r .[]);
do
restore=$(aws s3api head-object --bucket $bucket --key $a --query Restore --output text);
if [ $restore == "None" ];
then
echo $a "Has not been Restored"
elif [[ $restore == *true* ]];
then
echo $a "Is being Restored"
else
echo "Object " $a "is Restored for: " $restore
fi
done
