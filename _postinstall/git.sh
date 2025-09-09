#!/usr/bin/env nu
git config --global user.email (input "Enter email: ")
git config --global user.name (input "Enter name: ")
git config --global gpg.format ssh
git config --global commit.gpgSign true
git config --global user.signingkey ~/.ssh/id_ed25519
gh auth login
