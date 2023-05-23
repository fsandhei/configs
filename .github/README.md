## Cloning this repository
In order to clone the repository you have to do the following:
```bash
git clone --separate-git-dir=<git-dir> /path/to/repo/ <dest>
```

`git-clone` will fail if the directory you're cloning to has any of the
existing files from before, so make sure you do it to a clean directory,
preferably a temporary directory, and then copy over the files to the
$HOME directory.
