#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config;
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;

cat > /tmp/launch-template-user-data.log << EOF
ECS_CLUSTER [${cluster_name}]

This is a AWS Launch Template for Backend
echo $(date +"%Y%m%d")
EOF