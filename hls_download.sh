#!/bin/bash

mydir='pwd'

function download ()
{
	local url=$1;
	local basepath=$2;
	local path=${url%/*};
	local fname=$(basename $url);
	local filename=${fname%%\?*};
	local suffix=${filename##*.};
	
	local dir="${path##*$basepath}";	
	
	echo "debug0: path is $path"
	echo "debug1: scheme is ${url%%://*}"
	echo "debug2: basepath is $basepath"
	echo "debug3: fname is $fname"
	echo "debug4: filename is $filename"
	echo "debug5: suffix is $suffix"
	
	if [[ "${url%%://*}" == "http" ]]
	then
		path=${url%/*};
	else
		if [[ "$path" == "$fname" ]] 
		then
			echo "using basepath $basepath";
			path=$basepath;
			url=$basepath/$fname;
			dir=".";
		else
			if [[ "${path:0:1}" == "/" ]]
			then
				url=${basepath%%/*}$path/$fname;
				path=${basepath%%/*}$path;
				dir="."; #dont want to complete this case...
			else
				url=$path/$fname;
				dir=$path;
			fi
		fi
	fi
	
	echo "debug6: path is $path"
	echo "debug7: dir is $dir"
	
	if [[ "$dir" == "" ]]
	then
		dir=".";
	else
		dir=${dir%/*};
		mkdir -p $dir;
	fi
	
	echo "downloading $url to $dir";
	if [ -f $dir/$filename ]
	then
		echo "file exists, skip downloading..."
	else
		wget -O $dir/$filename $url;
		
		if [ $? -ne 0 ]
		then
			echo "failed to download $url";
			return $?
		fi
	fi
	
	if [[ "$suffix" == "m3u8" ]]
	then
		echo "processing $dir/$filename..."
		cat $dir/$filename | sed -e '/#/d' -e '/^$/d' | while read line
		do 
		{
			if [ -n "$line" ]
			then
				surl=$(echo "$line" | tr -d '\n')
				download $surl $path;
				if [ $? -ne 0 ]
				then exit 1;
				fi
			fi
		}
		done
	fi
}

mainurl=$1
download $1 ${mainurl%/*};
