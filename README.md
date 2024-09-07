# dotfiles

## Setup

1 - Create a new SSH key:

```sh
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

2 - Add the SSH key to your GitHub account:

```sh
pbcopy < ~/.ssh/id_rsa.pub
```

2 - Install Homebrew:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3 - Install Xcode command line tools:

```sh
xcode-select --install
```

**Note:** If you edit the `brew/Brewfile` to install Xcode before adding the `thoughtbot/formulae/rcm` brew package, you can ignore this step.

4 - Clone the repo:

```sh
git clone https://github.com/rafaelcruzazevedo/dotfiles.git
```

5 - Run `./install`.

6 - After the install restart your system as some macOS setup may only happen after restart.  
Some additional setup will happen after you restart your shell.


## Features and customisation

- Brew is used to install macOS packages, as such, you can find and edit the `brew/Brewfile` to fit your needs. 
- MacOS defaults can be edited at `macos/defaults`.
- Dotfiles are at `packages` and are managed via [rcm](https://github.com/thoughtbot/rcm). 
- iTerm2 preferences are at `library/iterm`.
- Zsh plugins are managed with [zinit](https://github.com/zdharma-continuum/zinit). Edit the `packages/zshrc` file to add/remove plugins. 
- For `git` aliases and utils, check the `packages/gitconfig` and `packages/git-utils`. 