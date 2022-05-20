# Copyright 2020 - 2022 The Litegapps Project
# customize.sh 
# latest update 22-02-2021
# By wahyu6070

chmod 755 $MODPATH/bin/functions
#litegapps functions
. $MODPATH/bin/functions

LIST=$MODPATH/list/aosp
[ "$TYPEINSTALL" ] || TYPEINSTALL=magisk

#path
if [ -f /system_root/system/build.prop ]; then
	SYSTEM=/system_root/system 
elif [ -f /system_root/build.prop ]; then
	SYSTEM=/system_root
elif [ -f /system/system/build.prop ]; then
	SYSTEM=/system/system
else
	SYSTEM=/system
fi

if [ ! -L $SYSTEM/vendor ]; then
	VENDOR=$SYSTEM/vendor
else
	VENDOR=/vendor
fi

# /product dir (android 10+)
if [ ! -L $SYSTEM/product ]; then
	PRODUCT=$SYSTEM/product
else
	PRODUCT=/product
fi

# /system_ext dir (android 11+)
if [ ! -L $SYSTEM/system_ext ]; then
	SYSTEM_EXT=$SYSTEM/system_ext
else
	SYSTEM_EXT=/system_ext
fi

litegapps_info


READ_FILE(){
	local INPUT=$1
	
	test ! -d $INPUT && print "<$INPUT> is not directory"
	
	for PY in $(find $INPUT -type f); do
		for YU in $(cat $PY); do
			echo "$YU"
		done
	done
	}


PARTITIONS="
$SYSTEM
$PRODUCT
$SYSTEM_EXT
"

TYPEINSTALL=kopi


## app and priv-app debloat
if [ $TYPEINSTALL = magisk ]; then
	printlog "- Debloating Systemless"
	#app
	for B1 in app priv-app; do
		for B2 in $(READ_FILE $LIST/app); do
			if [ -d $SYSTEM/$B1/$B2 ]; then
				printlog "- Debloating Dir $SYSTEM/$B1/$B2"
				cdir $MODPATH/system/$B1/$B2/.replace
			fi
			if [ -d $PRODUCT/$B1/$B2 ]; then
				printlog "- Debloating Dir $PRODUCT/$B1/$B2"
				cdir $MODPATH/system/product/$B1/$B2/.replace
			fi
			if [ -d $SYSTEM_EXT/$B1/$B2 ]; then
				printlog "- Debloating Dir $SYSTEM_EXT/$B1/$B2"
				cdir $MODPATH/system/system_ext/$B1/$B2/.replace
			fi
		done
	done
	
else
	for A1 in $PARTITIONS; do
		for A2 in app priv-app; do
			for A3 in $(READ_FILE $LIST/app); do
				if [ -d $A1/$A2/$A3 ]; then
					printlog "- Removing Dir $A1/$A2/$A3"
					del $A1/$A2/$A3
				fi
			done
		done
	done
fi

#
# etc,framework,lib and overlay debloat
#

if [ $TYPEINSTALL = magisk ]; then
	#overlay
	for B1 in overlay; do
		for B2 in $(READ_FILE $LIST/overlay); do
			if [ -d $SYSTEM/$B1 ]; then
				cd $SYSTEM/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $SYSTEM/$B1/$B3 ]; then
						printlog "- Debloating Dir $SYSTEM/$B1/$B3"
						$MODPATH/system/$B1/$B3/.replace
					elif [ -f $SYSTEM/$B1/$B3 ]; then
						printlog "- Debloating File $SYSTEM/$B1/$B3"
						cdir $(dirname $MODPATH/system/$B1/$B3)
						touch $MODPATH/system/$B1/$B3
					fi
				done
			fi
			if [ -d $PRODUCT/$B1 ]; then
				cd $PRODUCT/$B1
				for B3 in $(find * -name $B2); do
				
					if [ -d $PRODUCT/$B1/$B3 ]; then
						printlog "- Debloating Dir $PRODUCT/$B1/$B3"
						$MODPATH/system/product/$B1/$B3/.replace
					elif [ -f $PRODUCT/$B1/$B3 ]; then
						printlog "- Debloating File $PRODUCT/$B1/$B3"
						cdir $(dirname $MODPATH/system/product/$B1/$B3)
						touch $MODPATH/system/product/$B1/$B3
					fi
				
				done
			fi
			if [ -d $SYSTEM_EXT/$B1 ]; then
				cd $SYSTEM_EXT/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $SYSTEM_EXT/$B1/$B3 ]; then
						printlog "- Debloating Dir $SYSTEM_EXT/$B1/$B3"
						$MODPATH/system/system_ext/$B1/$B2/.replace
					elif [ -f $SYSTEM_EXT/$B1/$B3 ]; then
						printlog "- Debloating File $SYSTEM_EXT/$B1/$B3"
						cdir $(dirname $MODPATH/system/system_ext/$B1/$B3)
						touch $MODPATH/system/system_ext/$B1/$B3
					fi
				done
			fi
		done
	done
	#etc
	for B1 in etc; do
		for B2 in $(READ_FILE $LIST/etc); do
			if [ -d $SYSTEM/$B1 ]; then
				cd $SYSTEM/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $SYSTEM/$B1/$B3 ]; then
						printlog "- Debloating Dir $SYSTEM/$B1/$B3"
						$MODPATH/system/$B1/$B3/.replace
					elif [ -f $SYSTEM/$B1/$B3 ]; then
						printlog "- Debloating File $SYSTEM/$B1/$B3"
						cdir $(dirname $MODPATH/system/$B1/$B3)
						touch $MODPATH/system/$B1/$B3
					fi
				done
			fi
			if [ -d $PRODUCT/$B1 ]; then
				cd $PRODUCT/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $PRODUCT/$B1/$B3 ]; then
						printlog "- Debloating Dir $PRODUCT/$B1/$B3"
						$MODPATH/system/product/$B1/$B3/.replace
					elif [ -f $PRODUCT/$B1/$B3 ]; then
						printlog "- Debloating File $PRODUCT/$B1/$B3"
						cdir $(dirname $MODPATH/system/product/$B1/$B3)
						touch $MODPATH/system/product/$B1/$B3
					fi
				
				done
			fi
			if [ -d $SYSTEM_EXT/$B1 ]; then
				cd $SYSTEM_EXT/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $SYSTEM_EXT/$B1/$B3 ]; then
						printlog "- Debloating Dir $SYSTEM_EXT/$B1/$B3"
						$MODPATH/system/system_ext/$B1/$B2/.replace
					elif [ -f $SYSTEM_EXT/$B1/$B3 ]; then
						printlog "- Debloating File $SYSTEM_EXT/$B1/$B3"
						cdir $(dirname $MODPATH/system/system_ext/$B1/$B3)
						touch $MODPATH/system/system_ext/$B1/$B3
					fi
				done
			fi
		done
	done
	
	#framework
	for B1 in framework; do
		for B2 in $(READ_FILE $LIST/framework); do
			if [ -d $SYSTEM/$B1 ]; then
				cd $SYSTEM/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $SYSTEM/$B1/$B3 ]; then
						printlog "- Debloating Dir $SYSTEM/$B1/$B3"
						$MODPATH/system/$B1/$B3/.replace
					elif [ -f $SYSTEM/$B1/$B3 ]; then
						printlog "- Debloating File $SYSTEM/$B1/$B3"
						cdir $(dirname $MODPATH/system/$B1/$B3)
						touch $MODPATH/system/$B1/$B3
					fi
				done
			fi
			if [ -d $PRODUCT/$B1 ]; then
				cd $PRODUCT/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $PRODUCT/$B1/$B3 ]; then
						printlog "- Debloating Dir $PRODUCT/$B1/$B3"
						$MODPATH/system/product/$B1/$B3/.replace
					elif [ -f $PRODUCT/$B1/$B3 ]; then
						printlog "- Debloating File $PRODUCT/$B1/$B3"
						cdir $(dirname $MODPATH/system/product/$B1/$B3)
						touch $MODPATH/system/product/$B1/$B3
					fi
				
				done
			fi
			if [ -d $SYSTEM_EXT/$B1 ]; then
				cd $SYSTEM_EXT/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $SYSTEM_EXT/$B1/$B3 ]; then
						printlog "- Debloating Dir $SYSTEM_EXT/$B1/$B3"
						$MODPATH/system/system_ext/$B1/$B2/.replace
					elif [ -f $SYSTEM_EXT/$B1/$B3 ]; then
						printlog "- Debloating File $SYSTEM_EXT/$B1/$B3"
						cdir $(dirname $MODPATH/system/system_ext/$B1/$B3)
						touch $MODPATH/system/system_ext/$B1/$B3
					fi
				done
			fi
		done
	done

	#lib
	for B1 in lib lib64; do
		for B2 in $(READ_FILE $LIST/lib); do
			if [ -d $SYSTEM/$B1 ]; then
				cd $SYSTEM/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $SYSTEM/$B1/$B3 ]; then
						printlog "- Debloating Dir $SYSTEM/$B1/$B3"
						$MODPATH/system/$B1/$B3/.replace
					elif [ -f $SYSTEM/$B1/$B3 ]; then
						printlog "- Debloating File $SYSTEM/$B1/$B3"
						cdir $(dirname $MODPATH/system/$B1/$B3)
						touch $MODPATH/system/$B1/$B3
					fi
				done
			fi
			if [ -d $PRODUCT/$B1 ]; then
				cd $PRODUCT/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $PRODUCT/$B1/$B3 ]; then
						printlog "- Debloating Dir $PRODUCT/$B1/$B3"
						$MODPATH/system/product/$B1/$B3/.replace
					elif [ -f $PRODUCT/$B1/$B3 ]; then
						printlog "- Debloating File $PRODUCT/$B1/$B3"
						cdir $(dirname $MODPATH/system/product/$B1/$B3)
						touch $MODPATH/system/product/$B1/$B3
					fi
				
				done
			fi
			if [ -d $SYSTEM_EXT/$B1 ]; then
				cd $SYSTEM_EXT/$B1
				for B3 in $(find * -name $B2); do
					if [ -d $SYSTEM_EXT/$B1/$B3 ]; then
						printlog "- Debloating Dir $SYSTEM_EXT/$B1/$B3"
						$MODPATH/system/system_ext/$B1/$B2/.replace
					elif [ -f $SYSTEM_EXT/$B1/$B3 ]; then
						printlog "- Debloating File $SYSTEM_EXT/$B1/$B3"
						cdir $(dirname $MODPATH/system/system_ext/$B1/$B3)
						touch $MODPATH/system/system_ext/$B1/$B3
					fi
				done
			fi
		done
	done
else
	#overlay
	for A1 in $PARTITIONS; do
		for A2 in overlay; do
			for A3 in $(READ_FILE $LIST/overlay); do
				cd $A1/$A2
				for A4 in $(find * -name $A3); do
					if [ -d $A1/$A2/$A4 ]; then
						print "- Removing Dir $A1/$A2/$A4"
						print "- Removing Dir $A1/$A2/$A4"
						del $A1/$A2/$A4
					elif [ -f $A1/$A2/$A4 ]; then
						print "- Removing File $A1/$A2/$A4"
						del $A1/$A2/$A4
					fi
				done
			done
		done
	done

	#etc
	for A1 in $PARTITIONS; do
		for A2 in etc; do
			for A3 in $(READ_FILE $LIST/etc); do
				cd $A1/$A2
				for A4 in $(find * -name $A3); do
					if [ -d $A1/$A2/$A4 ]; then
						print "- Removing Dir $A1/$A2/$A4"
						del $A1/$A2/$A4
					elif [ -f $A1/$A2/$A4 ]; then
						print "- Removing File $A1/$A2/$A4"
						del $A1/$A2/$A4
					fi
				done
			done
		done
	done

	#framework
	for A1 in $PARTITIONS; do
		for A2 in framework; do
			for A3 in $(READ_FILE $LIST/framework); do
				cd $A1/$A2
				for A4 in $(find * -name $A3); do
					if [ -d $A1/$A2/$A4 ]; then
						print "- Removing Dir $A1/$A2/$A4"
						del $A1/$A2/$A4
					elif [ -f $A1/$A2/$A4 ]; then
						print "- Removing File $A1/$A2/$A4"
						del $A1/$A2/$A4
					fi
				done
			done
		done
	done

	#lib
	for A1 in $PARTITIONS; do
		for A2 in lib lib64; do
			for A3 in $(READ_FILE $LIST/lib); do
				cd $A1/$A2
				for A4 in $(find * -name $A3); do
					if [ -d $A1/$A2/$A4 ]; then
						print "- Removing Dir $A1/$A2/$A4"
						del $A1/$A2/$A4
					elif [ -f $A1/$A2/$A4 ]; then
						print "- Removing File $A1/$A2/$A4"
						del $A1/$A2/$A4
					fi
				done
			done
		done
	done
fi

print " "