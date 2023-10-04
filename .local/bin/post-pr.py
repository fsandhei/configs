#! /usr/bin/python3

# Script to generate text that can be used to announce a PR.
# Script uses the GitHub REST API in order to fetch information about the PR.

import argparse
import requests
import subprocess
import sys
import os

class PullRequest:
    def __init__(self, json):
        self.number = json["number"]
        self.title = json["title"]
        self.url = json["html_url"]
        self.poster = json["user"]["login"]

    def __repr__(self):
        return f"{self.url} {self.title}"

def get_args():
    parser = argparse.ArgumentParser(
            description = """Get brief description on PR that can be copy/pasted, using GitHub REST API.

            GitHub token is by default fetched from your .netrc configuration, if any. Otherwise, the token needs

            to be specified with --gh-token.

            """)

    parser.add_argument("--pr-number", help = "PR number", type = int)
    parser.add_argument("--interactive", action = "store_true")
    parser.add_argument("--gh-token", help = "GitHub token")

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
    github_api_prs_url = "https://api.github.com/repos/{}/{}/pulls".format(owner, repo)
    
    headers = {
                "Accept": "application/vnd.github+json",
                "X-GitHub-Api-Version": "2022-11-28"
              }

    if token is not None:
        headers["Authorization"] = "Bearer " + token

    result = requests.get(github_api_prs_url, headers = headers)
    json_doc = result.json()

    prs = []
    for pr_json in json_doc:
        pr = PullRequest(pr_json)
        if pr.poster == "fsandhei":
            prs.append(pr)

    return prs

def main():
    args = get_args()

    remotes = get_git_remotes()
    remote = remotes[0].split()[1]

    domain_stripped = ""

    if "https://github.com/" in remote:
        domain_stripped = remote.replace("https://github.com/", "")
    elif "git@github.com:" in remote:
        domain_stripped = remote.replace("git@github.com:", "")
    else:
        error("Git remote is not from GitHub. This script only works with GitHub remotes")

    owner = ""
    project = ""

    domain_stripped_split = domain_stripped.split("/")

    owner = domain_stripped_split[0]
    repo = domain_stripped_split[1].replace(".git", "")

    print(f"Attempting to fetch PR {args.pr_number} in {owner}/{repo} ...")

    if args.interactive:
        prs = list_prs(owner, repo, args.gh_token)
        print(f"Found {len(prs)}:")

        for (i, pr) in enumerate(prs):
            print(f"   {i}: {pr}")
        sys.exit(0)
    else:
        github_api_pr_url = "https://api.github.com/repos/{}/{}/pulls/{}".format(owner, repo, args.pr_number)

        headers = {
                    "Accept": "application/vnd.github+json",
                    "X-GitHub-Api-Version": "2022-11-28"
                  }

        if args.gh_token is not None:
            headers["Authorization"] = "Bearer " + args.gh_token

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
            error(f"Failed to get information about PR {args.pr_number}: {msg}")

if __name__ == "__main__":
    main()
