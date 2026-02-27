#!/bin/bash
#####################################################################
### Run these commands on a clean installation of Ubuntu 24.04 WSL ###
#####################################################################

# Exit on any major error
set -e

# Go to home directory
cd ~
# Make temp directory for source builds
mkdir -p ~/temp

echo "========================================="
echo " Updating System & Base Packages"
echo "========================================="
sudo apt update
sudo apt -y upgrade

# Core utilities
# Note: 7zip replaces p7zip-full in Ubuntu 24.04
sudo apt -y install 7zip ncdu tmate cmake curl wget git build-essential pkg-config

# Node, Go, and C# (Kept for YouCompleteMe/LSP servers)
# Note: mono-complete is massive. If you don't write C#, you can remove it.
sudo apt -y install mono-complete golang-go nodejs openjdk-17-jdk openjdk-17-jre npm

# Python system dependencies (for matplotlib GUI/rendering)
sudo apt -y install python3-dev python3-tk python3-gi-cairo python3-venv

echo "========================================="
echo " Setting up Python via 'uv'"
echo "========================================="
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Ensure uv is available in current session
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# Ubuntu 24.04 blocks global python installs. We will create a primary virtualenv
# for your general workflow and auto-activate it in ~/.bashrc
UV_VENV_DIR="$HOME/.wsl_default_env"
if [ ! -d "$UV_VENV_DIR" ]; then
    uv venv "$UV_VENV_DIR"
fi

# Install Python Libraries into the default venv
echo "Installing Python Libraries..."
uv pip install --python "$UV_VENV_DIR" -U \
    matplotlib \
    scipy \
    scikit-learn \
    pydot \
    cvxpy \
    tqdm \
    Cython

# Install Python CLI Tools 
# 'uv tool install' isolates binaries so they don't conflict, putting them in ~/.local/bin
echo "Installing Python CLI Tools..."
uv tool install pygments
# Replaced youtube-dl with yt-dlp (youtube-dl is essentially dead)
uv tool install yt-dlp 


echo "========================================="
echo " Building SVT-AV1-PSY & FFmpeg"
echo "========================================="
# Install dependencies for FFmpeg and encoders
sudo apt -y install autoconf automake libtool meson ninja-build texinfo yasm nasm \
    libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libsdl2-dev \
    libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
    libxcb-xfixes0-dev zlib1g-dev libx264-dev libx265-dev libnuma-dev \
    libvpx-dev libfdk-aac-dev libopus-dev libaom-dev

# 1. Build SVT-AV1-PSY
cd ~/temp
if [ ! -d "svt-av1-psy" ]; then
    git clone https://github.com/gianni-rosato/svt-av1-psy.git
    cd svt-av1-psy/Build
    cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
    make -j$(nproc)
    sudo make install
fi

# 2. Build FFmpeg with the good stuff
cd ~/temp
if [ ! -d "ffmpeg" ]; then
    git clone https://git.ffmpeg.org/ffmpeg.git
    cd ffmpeg
    ./configure \
      --pkg-config-flags="--static" \
      --extra-libs="-lpthread -lm" \
      --enable-gpl \
      --enable-nonfree \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-libaom \
      --enable-libsvtav1
    make -j$(nproc)
    sudo make install
fi


echo "========================================="
echo " Building Vim from Source (Huge Features)"
echo "========================================="
# Remove any apt vim installations
sudo apt -y purge vim vim-tiny vim-common vim-gtk3

# Install Vim build dependencies (X11 libraries needed for clipboard support)
sudo apt -y install libncurses5-dev libgtk2.0-dev libatk1.0-dev libcairo2-dev \
    libx11-dev libxpm-dev libxt-dev ruby-dev lua5.3 liblua5.3-dev libperl-dev

cd ~/temp
if [ ! -d "vim" ]; then
    git clone https://github.com/vim/vim.git
    cd vim
    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp=yes \
                --enable-python3interp=yes \
                --enable-perlinterp=yes \
                --enable-luainterp=yes \
                --enable-gui=gtk3 \
                --enable-cscope \
                --prefix=/usr/local \
                --with-x
    make -j$(nproc)
    sudo make install
fi


echo "========================================="
echo " Installing LaTeX (Tectonic)"
echo "========================================="
# Ubuntu 24.04 does not have Tectonic in the default apt repos.
# We will download the official pre-compiled binary instead.
mkdir -p ~/.local/bin
cd ~/temp
curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net | sh
mv tectonic ~/.local/bin/

# Fallback traditional LaTeX (Warning: texlive-full is massive, ~6-7 GB). 
# Uncomment the line below if Tectonic doesn't support a specific legacy package you need:
# sudo apt -y install texlive-full


echo "========================================="
echo " Fetching & Running Custom Configs"
echo "========================================="
cd ~
ln -s ~/myconfigs/.mybashrc ~/
ln -s ~/myconfigs/.inputrc ~/
ln -s ~/myconfigs/.pythonrc ~/
ln -s ~/myconfigs/.gitconfig ~/

# Get .bashrc to source .mybashrc if it isn't already
if grep -Fxq "source ~/.mybashrc" ~/.bashrc
then
echo ".bashrc already sourcing .mybashrc"
else
cat <<EOT >> ~/.bashrc

# Run all the custom configs in .mybashrc
source ~/.mybashrc

EOT
fi

cd ~
if [ ! -d "~/.vim" ]; then
    git clone https://github.com/chausies/.vim.git ~/.vim
fi
if [ -f ~/.vim/RUN_THIS.sh ]; then
    sh ~/.vim/RUN_THIS.sh
fi

echo "========================================="
echo " DONE! Please restart your terminal."
echo "========================================="
