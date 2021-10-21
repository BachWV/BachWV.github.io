#!/bin/bash
read -p "input the commit meg:" ges #gesture


#circling
hugo
git add .
git commit -m $ges
git push
echo "over"
