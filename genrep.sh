#!/bin/bash

repo_path='put repo path here'
cd $repo_path

case $1 in
	init)
		mkdir conf incoming
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
		for pkg in incoming/*
		do
			reprepro -b $repo_path includedeb rolling $pkg
		done

		chmod -R 755 $repo_path
		;;
	clean)
		rm -rvf db dists pool
		;;
esac

