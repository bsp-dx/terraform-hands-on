#!/bin/bash

cat > /tmp/ec2-user-data.log << EOF
Hello ${name}!

This is a AWS Launch Template User Data Script
echo $(date +"%Y%m%d")
EOF