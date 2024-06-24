#!/bin/bash

repo_path='put repo path here'

case $1 in
	init)
		mkdir -p $repo_path/{conf,incoming}
		cd $repo_path
		echo -n 'Enter Codename [eg. rolling]: '; read codename
		echo -n 'Enter Component [eg. main]: '; read components
		echo -n 'Enter Description: '; read desc
		echo -n 'Enter SignWith: '; read sign
cat <<eof> conf/distributions
Origin: fossfrog
Label: fossfrog
Suite: stable
Codename: $codename
Components: $components
Architectures: amd64 arm64 i386 armhf
Description: $desc
SignWith: $sign
eof
		;;
	gen)
		cd $repo_path
		for pkg in incoming/*
		do
			reprepro -b $repo_path includedeb rolling $pkg
		done

		chmod -R 755 $repo_path
		;;
	clean)
		rm -rvf $repo_path/{db,dists,pool}
		;;
	*)
		echo -e "`basename $0` [option]"
	       	echo -e "\tinit\t\t# Initialize repository"
		echo -e "\tgen\t\t# Add deb packages to repository"
		echo -e "\tclean\t\t# Remove all repository files"
		;;
esac
