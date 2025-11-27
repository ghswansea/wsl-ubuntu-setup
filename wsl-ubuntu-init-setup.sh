#!/bin/bash
set -e

echo "🖥️  Starting full WSL setup..."

# --------------------------------------------------
# 1️⃣ Update Ubuntu
# --------------------------------------------------
echo "Updating Ubuntu..."
sudo apt update
sudo apt upgrade -y

# --------------------------------------------------
# 2️⃣ Install essential tools
# --------------------------------------------------
echo "Installing development essentials..."
sudo apt install -y \
  build-essential git curl wget zsh tmux htop tree unzip zip \
  software-properties-common ca-certificates lsb-release gnupg

echo "Installing Python..."
sudo apt install -y python3 python3-pip python3-venv

echo "Installing Node.js..."
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
else
  echo "Node.js already installed."
fi

# --------------------------------------------------
# 3️⃣ Install Oh My Zsh (unattended)
# --------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh already installed."
fi

# --------------------------------------------------
# 4️⃣ Set Zsh as default shell
# --------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Setting Zsh as default shell..."
  chsh -s "$(which zsh)"
fi

# --------------------------------------------------
# 5️⃣ Configure Oh My Zsh
# --------------------------------------------------
ZSHRC="$HOME/.zshrc"

echo "Configuring .zshrc..."

# Set theme to agnoster safely
if grep -q '^ZSH_THEME=' "$ZSHRC"; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$ZSHRC"
else
  echo 'ZSH_THEME="agnoster"' >> "$ZSHRC"
fi

# Set plugins list safely (overwrite whole plugins line)
if grep -q '^plugins=' "$ZSHRC"; then
  sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
fi

# Install zsh-autosuggestions
AUTO_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$AUTO_DIR" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTO_DIR"
fi

# Install zsh-syntax-highlighting
HILITE_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$HILITE_DIR" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HILITE_DIR"
fi

# Ensure plugin sources are added at end of zshrc
grep -q "zsh-autosuggestions.zsh" "$ZSHRC" || \
  echo "source $AUTO_DIR/zsh-autosuggestions.zsh" >> "$ZSHRC"

grep -q "zsh-syntax-highlighting.zsh" "$ZSHRC" || \
  echo "source $HILITE_DIR/zsh-syntax-highlighting.zsh" >> "$ZSHRC"

# --------------------------------------------------
# 6️⃣ Add helpful aliases
# --------------------------------------------------
echo "Adding aliases..."
for alias in \
  "ll='ls -alF'" \
  "la='ls -A'" \
  "l='ls -CF'" \
  "gs='git status'" \
  "gc='git commit'" \
  "gp='git push'"
do
  key=$(echo "$alias" | cut -d= -f1)
  grep -q "alias $key" "$ZSHRC" || echo "alias $alias" >> "$ZSHRC"
done

# --------------------------------------------------
# 7️⃣ Clean up
# --------------------------------------------------
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean

echo "🎉 Full WSL setup completed! Restart WSL to start using Zsh."