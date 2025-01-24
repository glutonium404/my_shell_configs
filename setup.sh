#!/usr/bin/bash

echo "==========================="
echo "updating and upgrading pkgs"
echo "==========================="
sudo apt update
sudo apt upgrade

echo "==============="
echo "installing pkgs"
echo "==============="
sudo apt install tmux gh git neovim make gcc ripgrep unzip xclip curl fzf

echo "============="
echo "setting up gh"
echo "============="
gh auth login
gh repo list

echo "=============="
echo "setting up git"
echo "=============="
git config --global user.email "tahzib404@gmail.com"
git config --global user.name "glutonium69"

echo "======================"
echo "setting nvm, node, npm"
echo "======================"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source .bashrc
nvm install node

echo "========================="
echo "cloning shell custom repo"
echo "========================="
git clone https://github.com/glutonium69/my_shell_configs "$HOME/.shell_custom_config"

echo "====================="
echo "cloning neovim config"
echo "====================="
git clone --branch edit-1 --single-branch https://github.com/glutonium69/kickstart.nvim "$XDG_CONFIG_HOME/nvim"

echo "===================================="
echo "enabling custom shell configs setups"
echo "===================================="
ln -s "$HOME/.shell_custom_config/.tmux.conf" "$HOME/.tmux.conf"
echo '' >> "$HOME/.bashrc"
echo 'source "$HOME/.shell_custom_config/.custom.sh"' >> "$HOME/.bashrc"

echo "================================================"
echo "setting up tmux plugin manager and other plugins"
echo "================================================"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
chmod +x ./.tmux/plugins/tpm/bin/install_plugins
./.tmux/plugins/tpm/bin/install_plugins

echo "==============="
echo "setting up nvim"
echo "==============="
rm -rf "$HOME/.local/share/nvim"
