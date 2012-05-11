#!/bin/bash

# downloads files from fileplanet by a span of numeric IDs

# USAGE:
# $ bash download_pages_and_files_from_fileplanet.sh 1 123
# would try to download all files and their download pages
# with the IDs 1 to 123
# Files will be downloaded to ./www.fileplanet.com/NUMERICID/download/

# Random thoughts:
# we can go with http://www.fileplanet.com/NUMERICID/download/
# For the numeric ID we can use both 012345 OR 12345 formats
# We will be using the one without the leading zeros, since that is how Fileplanet links internally.

echo "You will be downloading $1 to $2, you rock!"
echo "Let's go!"

mkdir "$1-$2"
cd $1-$2/

for i in $(seq $1 $2)
do
	echo "Trying to download $i"
	
	# fileplanet returns a "302 Found" for non-existing IDs
	# redirecting to "Location: /error/error.shtml?aspxerrorpath=/autodownload.aspx 
	# we don't want those files, so "--max-redirect=0"
	wget -nv -a pages_$1_$2.log --force-directories --max-redirect=0 http://www.fileplanet.com/${i}/download/
	
	# extract the session download link to the actual file we want
	# the URL is enclosed by single quotes. The second grep will get everything from http until the last '. The rev/cut will remove the trailing '.  
	linktowget=$(grep default-file-download-link www.fileplanet.com/${i}/download/index.html 2>/dev/null | grep -Eo "http.*'" | rev | cut -c 2- | rev)
	
	if [ ! -n "${linktowget}" ]; then
		echo "No download link found."
	else
		echo "Download link found, downloading ${linktowget}"
		# download the file to the same directory as its download page HTML
		wget -nv -a files_$1_$2.log --directory-prefix=www.fileplanet.com/${i}/download/ "${linktowget}"
	fi
	echo "-----"
done

echo "Downloading finished! Yay!"

echo -n "Counting files: "
ls -1 www.fileplanet.com/ | wc -l

echo -n "Getting the size: "
du -hs www.fileplanet.com/

echo "TARring!"
cd ..
tar -cf $1-$2.tar $1-$2/

# just a handy local backup
cp $1-$2/*.log logs/

# This is not recommended to do automatically. The chunk might have been tiny or huge. Better check first.
# echo "Uploading to archive.org!"
# s3cmd --add-header x-archive-auto-make-bucket:1 --add-header "x-archive-meta-description:Files from Fileplanet (www.fileplanet.com), all files from the ID range $1 to $2." put $1-$2.tar s3://FileplanetFiles_$1-$2
# s3cmd put $1-$2/*.log s3://FileplanetFiles_$1-$2/

echo "Done. YAAAY!"
