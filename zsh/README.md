# ZSH

## Setup

1. Launch ZSH:
```
zsh
```

2. Clone zprezto repository:
```
git clone --recursive https://github.com/scnewma/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
```

3. Create a new Zsh configuration by copying the Zsh configuration files provided:
```
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
```

4. Set Zsh as your default shell:
```
chsh -s /bin/zsh
```
