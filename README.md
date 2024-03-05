# gitlab-mirror-sync
This project contains a shell script designed to automate the synchronization of available repositories in GitLab.

## Prerequisites
- `GITLAB_URL`: the GitLab url of the instance
- `GITLAB_TOKEN`: the user's GitLab generated access token

Install packages:
```shell
sudo apt install curl jq
```

## How to run

Make file executable:
```shell
chmod a+x script.sh
```

Execute:
```shell
./script.sh
```
