# Dotfiles

The configuration files are managed with [GNU Stow].

Each top-level directory represents a "group" of configs, and you can
"install" (by symlinking) the configs of a group using

```console
$ stow -Sv <group>
```

[GNU Stow]: https://www.gnu.org/software/stow/
