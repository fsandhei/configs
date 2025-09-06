#! /usr/bin/python3

# Script to generate text that can be used to announce a PR.
# Script uses the GitHub REST API in order to fetch information about the PR.

import argparse
import textwrap
import requests
from requests import Request
import subprocess
import sys
import os
import json

GITHUB_REST_API_BASIC_HEADER = {
                                 "Accept": "application/vnd.github+json",
                                 "X-GitHub-Api-Version": "2022-11-28"
                             }

class PullRequest:
    def __init__(self):
        self.number = None
        self.title = None
        self.url = None
        self.poster = None

    def parse_response_from_json_github(self, json):
        self.number = json["number"]
        self.title = json["title"]
        self.url = json["html_url"]
        self.poster = json["user"]["login"]

    def __repr__(self):
        return f"{self.title} (#{self.number})"

def get_args():
    parser = argparse.ArgumentParser(
            description =
            textwrap.dedent("""
            Get brief description on PR that can be copy/pasted, using GitHub REST API.

            GitHub token is by default fetched from your .netrc configuration, if any. Otherwise, the token needs

            to be specified with --gh-token.

            """),
            formatter_class = argparse.RawTextHelpFormatter)

    parser.add_argument("--pr-number", help = "PR number", type = int)
    parser.add_argument("--gh-token", help = "GitHub token")
    parser.add_argument("--list", action = "store_true", default = False, dest = "list_prs", help = "List pull requests owned by me")

    return parser.parse_args();

def error(msg, error_code = 1):
    print(msg)
    sys.exit(error_code)

def get_git_remotes():
    remotes_process = subprocess.run(["git", "remote", "-v"], capture_output = True)

    if remotes_process.returncode == 0:
        remotes = remotes_process.stdout.decode("utf-8")
        remotes = remotes.split('\n')
        return remotes
    else:
        error("Failed to get git remotes. cwd = {}".format(os.getcwd()), remotes_process.returncode);

def list_prs(owner, repo, token):
    user = get_user(token)
    github_api_prs_url = "https://api.github.com/repos/{}/{}/pulls".format(owner, repo)
    
    headers = GITHUB_REST_API_BASIC_HEADER

    if token is not None:
        headers.update({"Authorization": "Bearer " + token})

    result = requests.get(github_api_prs_url, headers = headers)
    json_doc = result.json()

    prs = []
    for pr_json in json_doc:
        pr = PullRequest()
        pr.parse_response_from_json_github(pr_json)
        if pr.poster == user:
            prs.append(pr)

    return prs

def try_announce_github(owner, repo, pr_number, token: str | None = None):
    github_api_pr_url = "https://api.github.com/repos/{}/{}/pulls/{}".format(owner, repo, pr_number)

    headers = GITHUB_REST_API_BASIC_HEADER

    if token is not None:
        headers.update({"Authorization": "Bearer " + token})

    result = requests.get(github_api_pr_url, headers = headers)
    json_doc = result.json()

    if result.status_code == requests.codes.ok:

        url = json_doc["html_url"]
        title = json_doc["title"]
        adds = json_doc["additions"]
        dels = json_doc["deletions"]

        print(f"""Announce PR with message:

                {url} {title} [+{adds}/-{dels}]
              """)
    else:
        msg = json_doc["message"]
        err_msg = f"Failed to get information about PR #{pr_number}: {msg}"
        raise RuntimeError(err_msg)

class Repository:
    def __init__(self):
        self.owner = None
        self.project = None
        self.domain = None

    def get_info_from_remote(self, remote):
        if "https://github.com" in remote:
            domain_stripped = remote.replace("https://github.com/", "")
            domain = "github"
        elif "git@github.com:" in remote:
            domain_stripped = remote.replace("git@github.com:", "")
            domain = "github"
        else:
            error("Git remote is not from any known domain.")

        match domain:
            case "github":
                domain_stripped_split = domain_stripped.split("/")
                self.owner = domain_stripped_split[0]
                self.project = domain_stripped_split[1].replace(".git", "")
            case _:
                raise RuntimeError("Could not figure out domain!")
        self.domain = domain

def get_user(token: str | None = None):
    headers = GITHUB_REST_API_BASIC_HEADER
    if token is not None:
        headers.update({"Authorization": "Bearer " + token})

    user_api_url = "https://api.github.com/user"

    result = requests.get(user_api_url, headers = headers)
    json_doc = result.json()

    if result.status_code == requests.codes.ok:
        user = json_doc["login"]
        return user
    else:
        msg = json_doc["message"]
        raise RuntimeError(f"Failed to get user information: {msg}")

def main():
    try:
        args = get_args()

        remotes = get_git_remotes()
        remote = remotes[0].split()[1]

        repo = Repository()
        repo.get_info_from_remote(remote)

        owner = repo.owner
        project = repo.project

        if args.list_prs:
            prs = list_prs(owner, project, args.gh_token)
            num_prs = len(prs)

            if num_prs != 0:
                print(f"Found {len(prs)}:")

                for (i, pr) in enumerate(prs):
                    num_i_pr = i + 1
                    print(f"   {num_i_pr}: {pr}")
            sys.exit(0)
        else:
            print(f"Attempting to fetch PR {args.pr_number} in {owner}/{project} ...")

            if repo.domain == "github":
                try_announce_github(owner, project, args.pr_number, args.gh_token)
            else:
                raise RuntimeError(f"unhandled repository domain {repo.domain}")
        return 0
    except Exception as e:
        print(e)
        return -1

if __name__ == "__main__":
    sys.exit(main())
