#!/bin/bash
read -p "input the commit msg:" msg #gesture
echo "$msg"
hugo
git add .
git commit -m "$msg"
git push
echo "over"