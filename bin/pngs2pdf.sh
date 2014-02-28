#!/usr/bin/env bash

# convert -verbose -density 150 valdivieso-vanitas1-6.pdf -quality 100 -sharpen 0x1.0 out.png

NUMBER_OF_PNGS=$((`find -type f -iname "out-*.png" | wc -l` - 1))
SORTED_PNGS=""

for i in $(seq 0 $NUMBER_OF_PNGS)
do
  SORTED_PNGS="$SORTED_PNGS out-$i.png"
done

convert -verbose -density 150 $SORTED_PNGS -quality 100 out.pdf
