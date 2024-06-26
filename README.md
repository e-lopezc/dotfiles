# My dotfiles

This directory contains the dotfiles for my system

## Requirements

Make sure you have installed the following packages in the system:

### Git

```
pacman -S git
```

### Stow

```
pacman -S stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```
$ git clone git@github.com/e-lopezc/dotfiles.git
$ cd dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```
