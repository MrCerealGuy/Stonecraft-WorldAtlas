#!/bin/bash -e

# Generate from a Stonecraft world an online map
# Copyright (C) 2017  Andreas "MrCerealGuy" Zahnleiter
#
#  This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Made by Andreas 'MrCerealGuy' Zahnleiter
# 2017-01-22: mrcerealguy: initial release

WORLD_PATH="/to/world/path"		# e.g. /usr/games/stonecraft/worlds/world1
WWW_ROOT="/to/www/path"			# e.g. /var/www

# check if WORLD_PATH and WWW_ROOT exist
if [ ! -d "$WORLD_PATH" ]; then
	echo -e "The Stonecraft world path $WORLD_PATH doesn't exist!"
	exit 1
fi

if [ ! -d "$WWW_ROOT" ]; then
	echo -e "The WWW path $WWW_ROOT doesn't exist!"
	exit 1
fi

# check if minetestmapper exists
if [ ! -f "./minetestmapper/minetestmapper" ]; then
	echo -e "minetestmapper not found!"
	exit 1
fi

# check if imagemackig is installed
grep_imagemagick="$(dpkg -s imagemagick | head -1 | grep -o 'imagemagick')" || :

if [ -z "$grep_imagemagick" ]; then
	echo -e "ImageMagick not installed!"
	exit 1
fi

# copy html files to WWW_ROOT
[ ! -d "$WWW_ROOT/css" ] && rsync -r --info=progress2 css $WWW_ROOT/
[ ! -d "$WWW_ROOT/gfx" ] && rsync -r --info=progress2 gfx $WWW_ROOT/
[ ! -d "$WWW_ROOT/js" ] && rsync -r --info=progress2 js $WWW_ROOT/

# generate map
./minetestmapper/minetestmapper --drawalpha --scalecolor '#ffffff' --bgcolor '#000000' --scales 'tlrb' --colors './minetestmapper/colors.txt' -i $WORLD_PATH -o ./map-notinterlaced.png

# generate interlaced image from map
convert -strip -interlace PNG -quality 80 map-notinterlaced.png $WWW_ROOT/map.png

# make thumbnail from map
convert $WWW_ROOT/map.png -thumbnail 1000 $WWW_ROOT/map_small.png

# crop image in 1000x1000 tiles
convert $WWW_ROOT/map.png -crop 1000x1000 -set filename:tile "%[fx:page.x/1000+1]_%[fx:page.y/1000+1]" +repage +adjoin "$WWW_ROOT/map_tile_%[filename:tile].png"

# generate worldatlas.html
rows="$(ls -1tr $WWW_ROOT/map_tile* | tail -1 | grep -Po '([0-9]+)' | head -1)"
lines="$(ls -1tr $WWW_ROOT/map_tile* | tail -1 | grep -Po '([0-9]+)' | tail -1)"

map_html="$(cat map_head.html.in)"
map_html="$map_html <table>"

for (( i=1; i<=$lines; i++ ))
do
	map_html="$map_html <tr>\n"
	#cur_line=$i

	for (( j=1; j<=$rows; j++ ))
	do
		map_html="$map_html <td><a href=\"./map_tile_"$j"_"$i".png\" class=\"fancybox\"> \
		<img class=\"hover\" src=\"./map_tile_"$j"_"$i".png\"></a></td>\n"
	done

	map_html="$map_html </tr>\n"
done

map_html="$map_html </table>"
map_html="$map_html $(cat map_tail.html.in)"

echo -e "$map_html" > $WWW_ROOT/worldatlas.html
echo -e "Generating successfully. Run http://localhost:80/worldatlas.html."
