#!/bin/bash

touch logGroupnames.txt
touch filterloggroupnames.txt

aws logs describe-log-groups --log-group-name-prefix /aws/lambda/logname | jq -r '.logGroups[].logGroupName' > logGroupnames.txt

filename="logGroupnames.txt"
ufile="filterloggroupnames.txt"

for element in $(<"$filename"); do
    if [[ "$element" == "/aws/lambda/logname-x"* || "$element" == "/aws/lambda/logname-y"* ]]; then
        if [[ "$element" == *"zstage" ]]; then
          echo "$element" >> "$ufile"
        fi
    fi
done

for element in $(<"$ufile"); do
        sfnames=$( aws logs describe-subscription-filters --log-group-name "$element" | jq -r '.subscriptionFilters[].filterName')
    aws logs delete-subscription-filter --log-group-name "$element" --filter-name "$sfnames"
done

rm -rf "$filename"
rm -rf "$ufile"
