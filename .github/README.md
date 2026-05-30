# Dotfiles

This approach is based off of this [Hacker News Post](https://news.ycombinator.com/item?id=11070797).

## Cloning this repository
In order to clone the repository you have to do the following:
```bash
git clone --separate-git-dir=<git-dir> /path/to/repo/ <dest>
```

`git-clone` will fail if the directory you're cloning to has any of the
existing files from before, so make sure you do it to a clean directory,
preferably a temporary directory, and then copy over the files to the
$HOME directory. Thus, replicating the configuration on a new machine can be done with the following commands:

```bash
repo_path="$HOME/.dotfiles"
git clone --separate-git-dir=$repo_path git@github.com:fsandhei/configs.git $HOME/myconf-tmp
cp $HOME/myconf-tmp $HOME
rm -rf $HOME/myconf-tmp
echo "alias config='/usr/bin/git --git-dir $repo_path --work-tree $HOME'" >> ~/.zshrc
```
