#!/bin/bash

repo_path='put repo path here'

case $1 in
	init)
		mkdir -p $repo_path/{conf,incoming}
		cd $repo_path
		echo -n 'Enter Codename: '; read codename
		echo -n 'Enter Component: '; read component
		echo -n 'Enter Arch: '; read arch
		echo -n 'Enter Description: '; read desc
		echo -n 'Enter SignWith: '; read sign
cat <<eof> conf/distributions
Codename: $codename
Components: $component
Architectures: $arch
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

