############################################################
### Run these commands on a clean installation of ubuntu ###
############################################################


# go to home directory
cd ~

# Update repositories and upgrade installed packages
sudo apt-get update
sudo apt-get upgrade

# Install useful packages
sudo apt-get install cmake # useful for makefiles. Needed to install YouCompleteMe

# install python2.7 and pip
sudo apt-get install python-dev python-tk python-pip
# Update pip
sudo -H pip install --upgrade pip
# Install important python packages
sudo -H pip install matplotlib scipy
# Install other python packages
sudo -H pip install cvxpy progressbar2 youtube-dl


# Install LaTeX stuff (like pdflatex command)
sudo apt-get install texlive

# Get custom configs
cd ~
git clone https://github.com/chausies/configs.git
sh ~/configs/RUN_THIS.sh

# Setup vim things
# Remove old vim and install version with everything
sudo apt-get remove --purge vim
sudo apt-get install vim-gtk-py2
# MAKE SURE THAT `vim --version` has `+python` in it, else vim wasn't
# removed fully. You may need to run things like 
# `sudo apt-get remove OTHER_VIM_DISTRO`

cd ~/
git clone https://github.com/chausies/.vim.git
sh ~/.vim/RUN_THIS.sh