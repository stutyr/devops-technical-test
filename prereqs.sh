# This file contains the commands to install the various components used by this deployment
#these commands are for a mac

#Homebrew settings assume a clean install, if previous versions installed then use 'brew upgrade ' rather than 'brew install'

brew update && brew install azure-cli
brew install terraform
brew install kubernetes-helm


# Docker Desktop or simialr is required to run the docker build command

