#!/bin/bash

GITLAB_URL=""
GITLAB_TOKEN=""
PER_PAGE="100" # Max 100

echo "Requesting projects..."

page=1
project_ids=()

while : ; do
	  projects_response=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects?simple=true&per_page=${PER_PAGE}&page=${page}")
    current_ids=($(echo $projects_response | jq '.[].id'))
    if [ -z "$current_ids" ]; then
        break
    fi

    # Merge the fetched project IDs into the main array
    project_ids=("${project_ids[@]}" "${current_ids[@]}")

    # Check if we are on the last page
    next_page=$(curl -s -I --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects?simple=true&per_page=${PER_PAGE}&page=${page}" | grep -Fi X-Next-Page | awk '{print $2}' | tr -d '\r')
    if [ -z "$next_page" ] || [ "$next_page" == "0" ]; then
        break
    else
        ((page++))
    fi
done

echo "Starting mirror syncing..."

for project_id in "${project_ids[@]}"; do
    echo "Checking project with id $project_id"
    
    # Fetch the list of remote mirrors for the project and parse the first mirror's ID
    response=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects/${project_id}/remote_mirrors")
    mirror_id=$(echo $response | jq '.[0].id')
    
    if [ -z "$mirror_id" ] || [ "$mirror_id" == "null" ]; then
        echo " - No mirror found"
        continue
    fi
    
	  echo " - Triggering sync for mirror ID $mirror_id"
    # Trigger sync for the mirror
    sync_response=$(curl -s --request POST --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects/${project_id}/remote_mirrors/${mirror_id}/sync")

    echo " - Sync triggered"
done

echo "Finished mirror syncing"
