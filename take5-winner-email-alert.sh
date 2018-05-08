#!/bin/bash
td=`date +%m%d%y`
gd=`date +%x`
tw=`grep $gd take5-MASTER-DB.txt`
d=`echo $tw | cut -d' ' -f1`
n1=`echo $tw | cut -d' ' -f2`
n2=`echo $tw | cut -d' ' -f3`
n3=`echo $tw | cut -d' ' -f4`
n4=`echo $tw | cut -d' ' -f5`
n5=`echo $tw | cut -d' ' -f6`
for i in `cat take5-numbersPicked.$td`
do
hc=0
echo "Checking [$td]"
echo $i | while read num
do
if [ "$num" -eq "$n1" ]; then
	let hc++
fi
if [ "$num" -eq "$n2" ]; then
	let hc++
fi
if [ "$num" -eq "$n3" ]; then
	let hc++
fi
if [ "$num" -eq "$n4" ]; then
	let hc++
fi
if [ "$num" -eq "$n5" ]; then
	let hc++
fi
echo "hit count=[$hc]"
done
echo "Total hit count=[$hc]"
done
	

