#!/bin/sh
# Pass the forum directory name as argument, eg "planetquake".
# Until ~April 2012 the URLs were http://forumplanet.gamespy.com/planetquake/ , later they were http://forums.gamespy.com/planetquake/
# No idea how it was in the past.

################
# some forums like http://forumplanet.gamespy.com/planetfrontlines/ have conflicts:
# forums on them will have their posts in a different "folder" than the index. Example:
# http://forumplanet.gamespy.com/frontlines_in_the_news/b67210/p1 -> http://forumplanet.gamespy.com/frontline_discussion/b67210/20695604/p1/?0
# I have another files where I listed those.
################

forum=$1

echo "===== Mirroring http://forums.gamespy.com/${forum}/ ====="

mkdir ${forum}
cd ${forum}

time wget -a ${forum}.log -nv --adjust-extension --convert-links --page-requisites -np -X PrivateMessages -X Static --user-agent "Hi, I am preserving these forums for archivist/nostalgia reasons. If there is a problem, please contact spirit at quaddicted com. Thanks" http://forums.gamespy.com/${forum}/

for url in $(grep BoardRowA forums.gamespy.com/${forum}/index.html | sed 's/.*http/http/g' | sed 's/".*//g')
do
	echo "=== Mirroring ${url} and all links on it (all threads of all pages) ==="
	time wget -a ${forum}.log -nv --adjust-extension --convert-links --page-requisites -m -np -X PrivateMessages -X Static --user-agent "Hi, I am preserving these forums for archivist/nostalgia reasons. If there is a problem, please contact spirit at quaddicted com. Thanks" ${url}

done

echo "done mirroring, now 7zipping..."
cd ..
time 7z a ${forum}_$(date +%Y%m%d).7z ${forum} 2>&1 > /dev/null
