# Insert S3 bucket name
$bucketname = "<bucketname>"
$nextMarker = $null

do
{
    #List all S3 obejct in S3 bucket:
    $objects = Get-S3Object -bucketname $bucketname -Marker $nextMarker
    $nextMarker = $AWSHistory.LastServiceResponse.NextMarker
    foreach( $object in $objects ) 
    {
        #Preform S3 head object request to determine restore status only on glacier objects
        if ($object.StorageClass -eq "GLACIER") 
        {
          $objectrestored = "$bucketname/"+$object.Key
          $restoreState = Get-S3ObjectMetadata -BucketName $bucketname -Key $object.Key
          if($restoreState.RestoreInProgress) {
            # True means the restore is current in progress
            $objectrestored += " currently being restored" 
          } Elseif($restoreState.RestoreExpiration -eq $null) {
            # Restore progress is false and there no expire date, glacier object wasn't restored
            $objectrestored += " has not been restored"
          } else {
            # Object was restored
            $objectrestored += " restored completed. Will expire on "+$restoreState.RestoreExpiration
          }
          Write-Host $objectrestored
        }
    }
} while ($nextMarker)
