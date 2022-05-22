# Copyright 2020 - 2022 The Litegapps Project
# customize.sh 
# latest update 22-05-2022
# By wahyu6070

chmod 755 $MODPATH/bin/functions
#litegapps functions
. $MODPATH/bin/functions

LITEGAPPS=/data/media/0/Android/litegapps
log=$LITEGAPPS/litegapps_remover.log
files=$MODPATH/files
tmp=$MODPATH/tmp
LIST=$MODPATH/list/aosp
[ "$TYPEINSTALL" ] || TYPEINSTALL=magisk


cdir $(diname $log)

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


[ ! -f $SYSTEM/build.prop ] && report_bug "System build.prop not found"

#developer mode
if [ -f /sdcard/Android/litegapps/mode_developer ]; then
	DEV_MODE=ON
else
	DEV_MODE=OFF
fi

SDKTARGET=$(getp ro.build.version.sdk $SYSTEM/build.prop)
findarch=$(getp ro.product.cpu.abi $SYSTEM/build.prop | cut -d '-' -f -1)
case $findarch in
arm64) ARCH=arm64 ;;
armeabi) ARCH=arm ;;
x86) ARCH=x86 ;;
x86_64) ARCH=x86_64 ;;
*) report_bug " <$findarch> Your Architecture Not Support" ;;
esac

#mode installation
[ $TYPEINSTALL ] || TYPEINSTALL=magisk_module
case $TYPEINSTALL in
kopi)
	sedlog "- Type install KOPI module"
;;
magisk)
	sedlog "- Type install KOPI installer convert to magisk module"
;;
*)
	sedlog "- Type install MAGISK module"
;;
esac

# Test /data rw partition
case $TYPEINSTALL in
magisk | magisk_module)
	DIR_TEST=/data/adb/test8989
	cdir $DIR_TEST
	touch $DIR_TEST/io
	if [ -f $DIR_TEST/io ]; then
		del $DIR_TEST
	else
		report_bug "/data partition is encrypt or read only"
	fi
;;
esac


#bin
bin=$MODPATH/bin/$ARCH

chmod -R 755 $bin

#checking format file
if [ -f $files/files.tar.xz ]; then
	format_file=xz
elif [ -f $files/files.tar.7z ]; then
	format_file=7za
elif [ -f $files/files.tar.br ]; then
	format_file=brotli
elif [ -f $files/files.tar.gz ]; then
	format_file=gzip
elif [ -f $files/files.tar.zst ]; then
	format_file=zstd
elif [ -f $files/files.tar.zip ]; then
	format_file=zip
else
	report_bug "Files format not found or format not support"
	listlog $files
fi
sedlog "Format file : $format_file"


#checking executable
for W in $format_file tar zip; do
	test ! -f $bin/$W && report_bug "Please add executable <$W> in <$bin/$W>"
done

#extracting file format
printlog "- Extracting Files"
case $format_file in
xz)
	$bin/xz -d $files/files.tar.xz || report_bug "Failed extract <files.tar.xz>"
;;
7za)
	$bin/7za e -y $files/files.tar.7z >/dev/null || report_bug "Failed extract <files.tar.7z>"
	;;
gunzip)
	$bin/gzip -d $files/files.tar.gz || report_bug "Failed extract <files.tar.gz>"
	;;
brotli)
	$bin/brotli -dj $files/files.tar.br || report_bug "Failed extract <files.tar.br>"
	;;
zstd)
	$bin/zstd -df --rm $files/files.tar.zst || report_bug "Failed extract <files.tar.zst>"
	;;
zip)
	unzip -o $files/files.tar.zip -d $files >/dev/null || report_bug "Failed extract <files.tar.zip>"
;;
*)
	report_bug "File format not support"
	listlog $files ;;
esac

#extract tar files
printlog "- Extracting Archive"
if [ -f $files/files.tar ]; then
	cdir $MODPATH/modules
	$bin/tar -xf $files/files.tar -C $MODPATH/modules
else
	report_bug "File <files.tar> not found !!!"
fi


#cheking sdk files
if [ ! -d $MODPATH/modules/$ARCH/$SDKTARGET ]; then
	printlog "! Apps files not support in your android version [SKIP]"
fi


PARTITIONS="
$SYSTEM
$PRODUCT
$SYSTEM_EXT
"


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

#module
printlog "- Installing Modules"
for TY in $(ls -1 $MODPATH/modules/$ARCH/$API); do
	printlog "- Installing $(cat $MODPATH/modules/$ARCH/$API/$TY/name)"
	cp -rdf $MODPATH/modules/$ARCH/$API/$TY/system/* $MODPATH/system/
done

#Permissions
find $MODPATH/system -type d 2>/dev/null | while read setperm_dir; do
	ch_con $setperm_dir
	chmod 755 $setperm_dir
done

printlog "- Set Permissions"
find $MODPATH/system -type f 2>/dev/null | while read setperm_file; do
	ch_con $setperm_file
	chmod 644 $setperm_file
done

if [ -d $MODPATH/system/product/overlay ]; then
	for FG in $(ls -1 $MODPATH/system/product/overlay); do
		chcon -h u:object_r:vendor_overlay_file:s0 $MODPATH/system/product/overlay/$FG
		chmod 644 $MODPATH/system/product/overlay/$FG
	done

fi

case $TYPEINSTALL in
magisk | magisk_module)
	[ "$MAGISKUP" ] || MAGISKUP=$MODPATH
	printlog "- Cleaning Cache"
	TMP_LIST="
	$tmp
	$MAGISKUP/modules
	$MAGISKUP/bin
	$MAGISKUP/list
	$MAGISKUP/files
	"
	for Y4 in $TMP_LIST; do
		del $Y4
	done
;;
esac
print " "
