#!/bin/bash
# To be run by cron once per day at 11:45... 
ml="/dj2/tony/lottery/take5-MASTER-DB.txt"
dt=`date '+%0m/%0d/%Y'`
for i in `wget -q -O - 'http://nylottery.ny.gov/wps/portal/?WCM_CONTEXT=/wps/wcm/connect/nysl+content+library/nysl+internet+site/home/your+lottery/drawing+results/drawingresults_take5' | grep -A40  drawingresults_take5| grep mm_separator | cut -d'<' -f1`
do
t=`echo -n "$i"`
t1="$t1 $t"
done
echo "$dt$t1" >> $ml
