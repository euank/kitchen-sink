### NixOS ami build example

Prerequisites:

Have a flake enabled nix (i.e. any recent nix release now).

Install coldsnap: https://github.com/awslabs/coldsnap

OR

Install nixos-ami-upload: https://github.com/euank/nixos-ami-upload

Have working AWS credentials

Usage:

```
$ nix build '.#ami'
# wait a while

$ AWS_REGION=us-west-2 coldsnap upload --wait ./result/nixos-amazon-image-22.05pre130979.gfedcba-x86_64-linux.img

export SNAPSHOT_ID=$idFromColdsnap

$ aws ec2 register-image \
  --name "NixOS-22.04pre-custom" \
  --region "us-west-2" \
  --architecture "x86_64" \
  --block-device-mappings "DeviceName=/dev/xvda,Ebs={SnapshotId=$SNAPSHOT_ID,VolumeSize=30,DeleteOnTermination=true,VolumeType=gp3}"

$ aws ec2 copy-image \
  --region "us-east-2" \
  --source-region us-west-2 \
  --source-image-id $imageIDFromAbove \
  --name "NixOS-22.04pre-custom"

# OR

$ nixos-ami-upload --regions us-west-2,us-east-2 ./result/
```

### caveat emptor

I did not actually run the above instructions to create this, but I've done
something like the above in the past, and something very close to the above
does work.
