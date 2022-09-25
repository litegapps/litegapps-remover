# Litegapps Remover Core Script
#
# Copyright 2022 The LiteGapps Project
#

base="`dirname $(readlink -f "$0")`"
chmod -R 755 $base/bin
. $base/bin/core-functions
#actived bash function colos
bash_color
#
case $(uname -m) in
aarch32 | armv7l) ARCH=arm
;;
aarch64 | armv8l) ARCH=arm64
;;
i386 | i486 |i586 | i686) ARCH=x86
;;
*x86_64*) ARCH=x86_64
;;
*) ERROR "Architecure not support <$(uname -m)>"
;;
esac

export tmp=$base/tmp
export bin=$base/bin/$ARCH
export log=$base/log/make.log
export loglive=$base/log/make_live.log
export out=$base/output


PROP_VERSION=`get_config version`
PROP_VERSIONCODE=`get_config version.code`
PROP_BUILDER=`get_config name.builder`
PROP_SET_TIME=`get_config set.time.stamp`
PROP_SET_DATE=`get_config date.time`
PROP_COMPRESSION=`get_config compression`
PROP_COMPRESSION_LEVEL=`get_config compression.level`
PROP_ARCH=`get_config arch | sed "s/,/ /g"`
PROP_SDK=`get_config api | sed "s/,/ /g"`


case "$(get_config litegapps_apk_compress_level)" in
0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9)
litegapps_apk_compress_level=`get_config litegapps_apk_compress_level`
;;
*)
litegapps_apk_compress_level=0
;;
esac

#process tmp
for P_TMP in $base/log $tmp; do
	[ -d $P_TMP ] && del $P_TMP && cdir $P_TMP || cdir $P_TMP
done


MAKE(){
	for W_ARCH in $PROP_ARCH; do
	echo z
	#binary copy architecture type
	BIN_ARCH=$W_ARCH
	 for W_SDK in $PROP_SDK; do
		clear
		echo p
		printmid "Building LiteGapps Remover"
		printlog " "
		printlog "Version : $PROP_VERSION (${PROP_VERSIONCODE})"
		printlog "Builder : $PROP_BUILDER"
		printlog "Compressions : $PROP_COMPRESSION"
		printlog "Compressions Level : $PROP_COMPRESSION_LEVEL"
		printlog "Architecture : $W_ARCH"
		printlog "SDK : $W_SDK"
		printlog "Android Target : $(get_android_version $W_SDK)"
		printlog " "
		[ -d $tmp ] && del $tmp && cdir $tmp || cdir $tmp
		#copying gapps
		if [ -d $base/files/modules/$W_ARCH/$W_SDK ]; then
			test ! -d $tmp/$W_ARCH/$W_SDK && cdir $tmp/$W_ARCH/$W_SDK
			cp -af $base/files/modules/$W_ARCH/$W_SDK/* $tmp/$W_ARCH/$W_SDK/
		else
			printlog "[ERROR] <$base/files/modules/$W_ARCH/$W_SDK> not found"
			sleep 3s
			continue
		fi
		
		make_tar_arch
		make_archive
		for WFL in MAGISK RECOVERY AUTO; do
		printlog "- Build flashable [$WFL]"
		cdir $tmp/$WFL
		copy_binary_flashable $BIN_ARCH $tmp/$WFL/bin/$BIN_ARCH
			# copy core/utils/magisk or kopi installer
			for W in functions; do
				if [ -f $base/utils/$W ]; then
					cp -pf $base/utils/$W $tmp/$WFL/bin/
				else
					ERROR "utils <$base/utils/$W> not found"
				fi
			done
			
			# Customize.sh
			if [ -f $base/utils/customize.sh ]; then
				cp -pf $base/utils/customize.sh $tmp/$WFL/
			else
				ERROR "Customize.sh <$base/utils/customize.sh> not found"
			fi
			# LICENSE
			if [ -f $base/utils/LICENSE ]; then
				cp -pf $base/utils/LICENSE $tmp/$WFL/
			else
				ERROR "LICENSE <$base/core/utils/LICENSE> not found"
			fi
			# copy utils files
			for W in README.md; do
				if [ -f $base/utils/$W ]; then
				cp $base/utils/$W $tmp/$WFL/
				else
				ERROR "magisk files <$base/utils/$W> not found"
				fi
			done
		case $WFL in
			MAGISK)
				cp -af $base/utils/magisk/* $tmp/$WFL/
			;;
			RECOVERY)
				cp -af $base/utils/kopi/* $tmp/$WFL/
				#kopi mode install kopi (recovery)
				SED "$(getp typeinstall $tmp/$WFL/module.prop)" "kopi" $tmp/$WFL/module.prop
			;;
			AUTO)
				cp -af $base/utils/kopi/* $tmp/$WFL/
			;;
		esac
		# copy file.tar.(type archive) in tmp
		for WD in $(ls -1 $tmp); do
			if [ -f $tmp/$WD  ]; then
				test ! -d $tmp/$WFL/files && cdir $tmp/$WFL/files
				cp -pf $tmp/$WD $tmp/$WFL/files/
			fi
		done
		
		#cp list
		test ! -d $tmp/$WFL/list && mkdir -p $tmp/$WFL/list
		cp -af $base/list/* $tmp/$WFL/list/
			
		local MODULE_PROP=$tmp/$WFL/module.prop
		local MODULE_DESC=`get_config desc`
		local MODULE_UPDATE=https://raw.githubusercontent.com/litegapps/updater/main/core/litegapps_remover/${W_ARCH}/${W_SDK}/$WFL/update.json
		
		SED "$(getp name $MODULE_PROP)" "LiteGapps Remover $W_ARCH $(get_android_version $W_SDK) $PROP_STATUS" $MODULE_PROP
		SED "$(getp id $MODULE_PROP)" "litegapps_remover" $MODULE_PROP
		SED "$(getp author $MODULE_PROP)" "$PROP_BUILDER" $MODULE_PROP
		SED "$(getp version $MODULE_PROP)" "v${PROP_VERSION}" $MODULE_PROP
		SED "$(getp versionCode $MODULE_PROP)" "$PROP_VERSIONCODE" $MODULE_PROP
		SED "$(getp date $MODULE_PROP)" "$(date +%d-%m-%Y)" $MODULE_PROP
		SED "$(getp description $MODULE_PROP)" "$MODULE_DESC" $MODULE_PROP
		sed -i 's,'"$(getp updateJson $MODULE_PROP)"','"${MODULE_UPDATE}"',g' $MODULE_PROP
		
		#set time stamp
		set_time_stamp $tmp/$WFL
			
		local NAME_ZIP="[$WFL]LiteGapps_Remover_${W_ARCH}_$(get_android_version $W_SDK)_v${PROP_VERSION}.zip"
		local OUT_ZIP=$out/litegapps_remover/$W_ARCH/$W_SDK/v$PROP_VERSION/$NAME_ZIP
		make_zip $tmp/$WFL $OUT_ZIP
		done
	 done
	done
	}
rm -rf $tmp

case "$1" in
make)
MAKE
;;
restore)
echo
;;
clean)
echo
;;
*)
print " usage : bash make.sh <menu>"
print " "
print " menu :"
print " make            make litegapps remover"
print " restore         restoring files"
print " clean           clean file and directtory"
print " "
;;
esac


