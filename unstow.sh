#!/bin/bash

# Run this script from the root of the repository.
#
# Removes symlinks for dotfiles using GNU stow.


# Check if stow is installed
if ! command -v stow &> /dev/null
then
  echo "Error: GNU stow could not be found."
  exit 1
fi

# Loop over each subdirectory and run stow
for dir in */; do
    # Remove the trailing slash from the directory name
    dir=${dir%/}
    echo "For directory '${dir}':"
    # Run stow for the directory to symlink into home directory
    stow -D "$dir" --target="$HOME" -v
done

echo "Dotfiles have been unstowed."