#!/bin/bash

repo_path='.'

case $1 in
	init)
		mkdir -p $repo_path/{conf,incoming}
		echo -n 'Enter Codename [eg. rolling]: '; read codename
		echo -n 'Enter Component [eg. main]: '; read components
		echo -n 'Enter Description: '; read desc
		echo -n 'Enter SignWith: '; read sign
cat <<eof> $repo_path/conf/distributions
Origin: fossfrog
Label: fossfrog
Suite: fossfrog
Codename: $codename
Components: $components
Architectures: amd64 arm64 i386 armhf
Description: $desc
SignWith: $sign
eof
		;;
	gen)
		for pkg in $repo_path/incoming/*
		do
			reprepro -b $repo_path --outdir $repo_path/output includedeb rolling $pkg
		done

		chmod -R 755 $repo_path/output/dists $repo_path/output/pool
		;;
	clean)
		rm -rvf $repo_path/{db,dists,pool,output/dists,output/pool}
		;;
	*)
		echo -e "`basename $0` [option]"
	       	echo -e "\tinit\t\t# Initialize repository"
		echo -e "\tgen\t\t# Add deb packages to repository"
		echo -e "\tclean\t\t# Remove all repository files"
		;;
esac
