# The LiteGapps Project
# permissions.sh
# latest update 04-04-2022


if [ $TYPEINSTALL = "magisk" ]; then
chcon -hR u:object_r:system_file:s0 $MAGISKUP/system
find $MAGISKUP/system -type f | while read anjay; do
	dir6070=$(dirname $anjay)
	chcon -hR u:object_r:system_file:s0 $anjay
	chmod 644 $anjay
	chcon -hR u:object_r:system_file:s0 $dir6070
	chmod 755 $dir6070
done

if [ -d $MAGISKUP/system/product/overlay ]; then
	for FG in $(ls -1 $MAGISKUP/system/product/overlay); do
		chcon -h u:object_r:vendor_overlay_file:s0 $MAGISKUP/system/product/overlay/$FG
		chmod 644 $MAGISKUP/system/product/overlay/$FG
	done
fi

fi

