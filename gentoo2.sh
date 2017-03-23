#!/bin/bash
#TODO: fstab: /boot must be vfat
set -e
#set -x

# Good ideas:
# >=20GB HDD (for portage tree)
# >=2.5GB RAM (for sync and emerging)

# Steps:
# 1) Boot install media
# 2) Make sure network is up: `network`, `net-setup <interface>`
# 3) Edit variables below
# 4) Run this script

# =============================================================================
# Leaving the following empty or commenting them out means that you will be
# interactively asked for them with the exception of domainname.
# =============================================================================

rusername="zmode"
rusergroups="disk,wheel,audio,cdrom,video,games,cdrw,plugdev,davfs2,netdev,vboxusers"

rhostname="koishi"

rdomainname=""

rtimezone="Europe/Athens"

# Architecture. amd64 or x86.
rarch="amd64"

# Device to install to.
rdev="/dev/sda"

# Portage profile to set.
rgprofile="default/linux/amd64/13.0"

# Partition method. ext4/zfs/lvm
rmode="lvm"
# for lvm:
lvprefix="vgg"
mapper="/dev/$lvprefix"

# EFI support. Must be booted from EFI media to work.
refi="no"

# Must be ftp if you want to verify the stage3.
# Supports the $arch variable. Use single quotes!
rstage3_url='ftp://distfiles.gentoo.org/releases/$arch/autobuilds/current-stage3-$arch/stage3-$arch-*.tar.bz2*'

# /boot and swap sizes in MiB.
rboot_size=128
rswap_size=8192
rswap_size=512 # vbox

# Network configuration
# Use 'AUTO' here to have it replaced with the first network device found

# DHCP example
read -r rnet_cfg <<'EOF'
config_AUTO="dhcp"
EOF
# STATIC example
#read -r rnet_cfg <<'EOF'
#config_AUTO="192.168.2.10/24"
#routes_AUTO="default via 192.168.2.254"
#dns_servers_AUTO="192.168.2.254"
#ifdown_AUTO="NO"
#EOF

# BINPKG
# On the binhost run:
#   useradd -m -r -G portage -s /bin/bash binpkguser
#   passwd binpkguser; <run this script>; passwd -l binpkguser
# rbinhost="binpkguser@192.168.2.3"
# rbinhost_port=37331
# rbinhost="http://192.168.1.201/packages"

# LUKS encryption.
# The keyphrases are asked for interactively at runtime.
rcrypt="no"

# SSD trim
rtrim="no"

# Alternate default config file for genkernel.
# Potentially faster than genkernel's default but you're on your own.
#rdefault_kconfig='${DEFAULT_KERNEL_SOURCE}/arch/x86/configs/x86_64_defconfig'

# Verify stage3? Requires ftp mirror.
rverify_stage3="yes"

rlocale="en_US.UTF-8"

rmake_CFLAGS=$(gcc -v -mtune=native -E /usr/include/stdlib.h 2>&1 | grep "/usr/libexec/gcc/.*cc1" | grep -o -- '--param .*')
rmake_PORTAGE_IONICE_COMMAND="ionice -c 3 -p \${PID}"
rmake_PORTAGE_NICENESS="19"
rmake_FEATURES="buildpkg webrsync-gpg cgroup downgrade-backup unmerge-backup"
rmake_PORTAGE_ELOG_SYSTEM="save"
rmake_PORTAGE_ELOG_CLASSES="warn error info log qa"
#rmake_CPU_FLAGS_X86="$(cpuinfo2cpuflags-x86)"
rmake_MAKEOPTS='-j6 --load-average=6'
rmake_EMERGE_DEFAULT_OPTS='$EMERGE_DEFAULT_OPTS -j16 --load-average=6'
rmake_USE="zsh-complection cjk bash-complection vim-syntax -policykit -consolekit -udisks -gnome -pulseaudio -gnome-keyring"

# Webrsync GPG key
rwebrsync_gpg_key=0x96D8BF6D
rstage3_key=2D182910

rappend="vga=791 suspend_noui"

# Suppress output if command ran correctly
s(){ output=$($* 2>&1) || (echo -e "Failed: $*\n$output" && exit 1) }

# Colored print
e(){ echo -e "\e[1;31m$*\e[0m"; }

outside_chroot(){

    e "======================================================"
    e "Device selected: $rdev"
    e "Sleeping for 5 seconds. Abort partitioning with Ctrl-c"
    e "======================================================"
    sleep 5


    ###########################################################################
    # Partition
    ###########################################################################

    e "Creating partitions"

    boot_start='0%'
    let swap_end=rboot_size+rswap_size
    s parted "$rdev" -s -- mklabel gpt
    s parted "$rdev" -s -- mkpart ESI     fat32                 0%           "$rboot_size"  # /boot
    s parted "$rdev" -s -- set 1 boot on
    rboot="${rdev}1"

    case "$rmode" in
        ext*)
            s parted "$rdev" -s -- mkpart primary linux-swap   "$rboot_size" "$swap_end"    # swap
            s parted "$rdev" -s -- mkpart primary "$rmode"     "$swap_end"   100%           # /

            rswap="${rdev}2"
            rrealswap="$rswap"

            rroot="${rdev}3"
            rrealroot="$rroot"

            if [[ "$rcrypt" == [Yy]* ]]; then
                e "Creating encrypted root."
                # shred "$rroot"
                cryptsetup -y luksFormat "$rroot" -c aes-xts-plain64:sha512 -s 512 --hash whirlpool
                cryptsetup luksOpen --allow-discards "$rroot" root
                rrealroot="/dev/mapper/root"

                e "Creating encrypted swap."
                # shred "$rswap"
                cryptsetup -y luksFormat "$rswap" -c aes-xts-plain64:sha512 -s 512 --hash whirlpool
                cryptsetup luksOpen --allow-discards "$rswap" swap
                rrealswap="/dev/mapper/swap"
            fi
            ;;
        lvm)
            s parted "$rdev" -s -- mkpart primary ext4         "$rboot_size"          100%    # /
            rroot="${rdev}2"

            if [[ "$rcrypt" == [Yy]* ]]; then
                e "Creating encrypted LVM partition."
                # shred "$rroot"
                cryptsetup -y luksFormat "$rroot" -c aes-xts-plain64:sha512 -s 512 --hash whirlpool
                cryptsetup luksOpen --allow-discards "$rroot" encVol
                rdev="/dev/mapper/encVol"
            fi

            # vgchange -a y vgg
            modprobe dm-mod
            if [[ "$rcrypt" == [Yy]* ]]; then
                target="$rdev"
            else
                target="$rroot"
            fi
            s pvcreate -ff -y "$rdev"
            s vgcreate -ff -y "$lvprefix" "$rdev"
            s lvcreate -L "$rswap_size"M -n swap6 "$lvprefix"
            s lvcreate -l 100%FREE -n root6 "$lvprefix"
            # lvcreate -L 20G -n usr  "$lvprefix"   # >=10G
            # lvcreate -L 30G -n home "$lvprefix"   # >=500G
            # lvcreate -L 5G  -n opt  "$lvprefix"   # >=2G
            # lvcreate -L 10G -n var  "$lvprefix"   # >=7G!
            # lvcreate -L 5G  -n tmp  "$lvprefix"   # >=4G
            rrealroot="$mapper/root6"
            rrealswap="$mapper/swap6"
            ;;
    esac

    ###########################################################################
    # Format and Mount
    ###########################################################################

    e "Formatting and mounting partitions"
    case "$rmode" in
    ext*|lvm)
        # / must be mounted first
        s mkfs.ext4 -m 2.0 -q "$rrealroot"
        s mkdir -p /mnt/gentoo
        s mount "$rrealroot" /mnt/gentoo
        ;;&
    # lvm)
    #     for part in usr home opt var tmp; do
    #         mkfs.ext4 "${mapper}/${part}"
    #         # mkdir "/mnt/gentoo/$part"
    #         mount "${mapper}/${part}" "/mnt/gentoo"
    #     done
    #     ;;&
    *)
        # Keep this section last, as we mount inside the previous mounts
        # /boot is always the same
        s mkfs.vfat -s 2 -F 32 "$rboot"
        s mkdir -p /mnt/gentoo/boot
        s mount -o rw "$rboot" /mnt/gentoo/boot
        # s mkfs.ext2 -q "$rboot"
        # s mkdir -p /mnt/gentoo/boot
        # s mount -o rw "$rboot" /mnt/gentoo/boot
        # swap is always the same
        s mkswap "$rrealswap"
        ;;
    esac

    ###########################################################################
    # Extract stage3
    ###########################################################################

    if hash ntpd 2>/dev/null; then
        e "Synchronising time in the background"
        (ntpd -gq || return 0) >/dev/null &
    else
        e "ntpd not found. Not synchronising time"
    fi

    # if [ -n "$rstage3_url" ]; then
    rstage3_url=${rstage3_url//\$arch/$rarch}
    if [[ -z "$rverify_stage3" || "$rverify_stage3" == y* || "$rverify_stage3" == Y* ]]; then
        rm -f /mnt/gentoo/stage3-*
        e "Downloading stage3"; wget -P /mnt/gentoo/ "$rstage3_url"'*' 2> >(awk '/%/ { printf "\r%s", $0 }' 1>&2)
        e " Verifying stage3";
        (
            cd /mnt/gentoo
            s gpg --keyserver pool.sks-keyservers.net --recv-key $rstage3_key
            s gpg --verify stage3-*.DIGESTS.asc
        )
        e " Extracting stage3"; tar xjp -C /mnt/gentoo -f /mnt/gentoo/stage3-*.tar.bz2
        rm -f /mnt/gentoo/stage3-*
    else
        e "Downloading and extracting stage3"
        wget -O - "$rstage3_url" 2> >(awk '/%/ { printf "\r%s", $0 }' 1>&2) | tar xjp -C /mnt/gentoo
        echo
    fi
    # fi

    ###########################################################################
    # Timezone
    ###########################################################################

    # [[ -z "$rtimezone" ]] && pick_tz /mnt/gentoo/usr/share/zoneinfo

    ###########################################################################
    # Mount
    ###########################################################################

    e "Mounting proc, /sys, /dev"
    s mount -t proc none /mnt/gentoo/proc
    s mount --rbind /dev /mnt/gentoo/dev
    s mount --rbind /sys /mnt/gentoo/sys
    e "Copying resolv.conf"
    s cp -L /etc/resolv.conf /mnt/gentoo/etc/
}

conf_append() {
    local file="$1"
    local key="$2"
    local val="$3"
    sed -r -i 's/^ *\# *('"$key"' *=\ *")/\1/' "$file" 2>/dev/null
    if ! sed -r -i.bak 's/^ *'"$key"' *= *"/\0'"$val"' /' "$file" 2>/dev/null || diff "$1" "$1".bak >/dev/null 2>&1; then
        echo "$key=\"$val\"" >> "$file"
    fi
    rm "$1".bak
}

conf_set() {
    local file="$1"
    local key="$2"
    local val="$3"
    sed -r -i 's/^ *\# *('"$key"' *=\ *"?)/\1/' "$file" 2>/dev/null
    if ! sed -r -ibak 's/(^ *'"$key"' *= *"?)([^"]*)("?)?/\1'"$val"'\3/' "$file" 2>/dev/null || ! diff "$1" "$1".bak >/dev/null 2>&1; then
        echo "$key=\"$val\"" >> "$file"
    fi
    rm "$1".bak
}

in_swapon() {
    e "Enabling swap"
    s swapon "$1"
}

in_sync_tree() {
    e "Syncing portage tree"
    s mkdir /etc/portage/repos.conf
    cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
    # sed 's/sync-type = rsync/sync-type = webrsync/' -i /etc/portage/repos.conf/gentoo.conf
    mkdir -p /usr/portage
    emaint sync --auto
}

    # mkdir -p /etc/portage/gpg

    # if [[ -n "$rwebrsync_gpg_key" ]]; then
    #     e "Adding gpg support to webrsync"
    #     mkdir -p /etc/portage/gpg
    #     chmod 500 /etc/portage/gpg
    #     gpg -q --homedir /etc/portage/gpg --keyserver pool.sks-keyservers.net --recv-keys $rwebrsync_gpg_key
    #     e "For gpg support to work you have to accept this key with ultimate trust and then quit"
    #     gpg -q --homedir /etc/portage/gpg --trust-model always --edit-key $rwebrsync_gpg_key trust

    #     echo 'FEATURES="webrsync-gpg"' >> /etc/portage/make.conf
    #     echo 'PORTAGE_GPG_DIR="/etc/portage/gpg"' >> /etc/portage/make.conf

    #     s emaint sync --auto
    # fi

in_locale() {
    e "Generating locale setting to en_US.utf8"
    echo "$1" >> /etc/locale.gen
    s locale-gen
    s eselect locale set "$1"
}

in_profile() {
    e "Sourcing /etc/profile"
    s env-update
    s source /etc/profile
}

    ###########################################################################
    # Binhost
    ###########################################################################

    # if [[ -n "$rbinhost" ]]; then
    #     if [[ "$rbinhost" == ssh* ]]; then
    #         e "Configuring binhost access"
    #         e "Generaging ssh key for root. Blank passphrase."
    #         ssh-keygen -N '' -q -f /root/.ssh/id_rsa
    #         e "Copying key to binhost. You will be asked for its password. Set one now if it doesn't have one!"
    #         ssh-copy-id -p "$rbinhost_port" "$rbinhost"

    #         printf 'PORTAGE_BINHOST="ssh://%s:%s/usr/portage/packages"\n' "$rbinhost" "$rbinhost_port" >> /etc/portage/make.conf
    #     fi
    #     if [[ "$rbinhost" == http* ]]; then
    #         printf 'PORTAGE_BINHOST="%s"\n' "$rbinhost" >> /etc/portage/make.conf
    #     fi
    # fi

in_timezone() {
    e "Setting timezone"
    echo "$1" > /etc/timezone
}

in_hostname() {
    e "Setting hostname"
    echo "hostname=$1" > /etc/conf.d/hostname
}

    # Disabled because we want resume support
    # if [[ "$rcrypt" == [Yy]* ]]; then
    #     e "Modifying crypttab"
    #     printf 'enc-swap %s /dev/urandom cipher=aes-cbc-essiv:sha256,size=128,hash=sha512,swap\n' "/dev/mapper/swap" >> /etc/crypttab
    #     # printf '/dev/mapper/enc-swap swap swap defaults 0 0\n' >> /etc/fstab
    #     sed "s_SWAP_/dev/mapper/swap_" -i /etc/fstab
    # else
    #     sed "s/SWAP/$rswap/" -i /etc/fstab
    # fi

in_fstab() {
    e "Modifying fstab"
    rmode="$1"
    rboot="$2"
    rrealswap="$3"
    rrealroot="$4"

    fstab=/etc/fstab
    case "$rmode" in
    *)
        sed -i \
            -e "s_/dev/BOOT_${rboot}_"  \
            -e "s_/dev/SWAP_${rrealswap}_" \
            -e "s/ext2/vfat/g" \
            "$fstab"
        ;;&
    ext*|lvm)
        sed -i \
            -e "s_/dev/ROOT_${rrealroot}_" \
            -i "s/ext3/ext4/g" \
            "$fstab"
        ;;
    esac
}

in_make_conf() {
    file=/etc/portage/make.conf
    e "Setting up $file"

    while IFS='=' read -r key value ; do
        conf_append "$file" "$key" "$value"
    done <<<"$1"
}

in_gprofile() {
    e "Setting profile"
    s eselect profile set "$1"
}

in_networking() {
    rnet_cfg="$1"

    interface=$(grep -m1 '^config' <<<$rnet_cfg)
    interface="${interface#config_}"
    interface="${interface%=*}"
    if [[ "$interface" == "AUTO" ]]; then
        interface=$(grep -m 1 -Eo 'enp[0-9]*s[0-9]*(f[0-9]*d[0-9]*)?|eth[0-9]*' < <(tail -n +3 /proc/net/dev | cut -d':' -f 1 | sed -e 's/^[[:space:]]*//'))
        rnet_cfg="${rnet_cfg//AUTO/$interface}"
    fi

    if [[ -z "$interface" ]]; then
        e "Failed to find a network interface"
    else
        e "Configuring network for $interface"
        echo "$rnet_cfg" >> /etc/conf.d/net
        (cd /etc/init.d && ln -s net.lo net."$interface")
        s rc-update add net."$interface" default
    fi
}

in_hosts() {
    e "Configuring /etc/hosts"
    rhostname="$1"
    rdomainname="$2"
    if [[ -n "$rdomainname" ]]; then
        sed 's/^127\.0\.0\.1.*$/\0 '"${rhostname}.${rdomainname} ${rhostname}"' localhost/' -i /etc/hosts
        conf_set /etc/conf.d/net dns_domain_lo "$rdomainname"
    else
        sed 's/^127\.0\.0\.1.*$/\0 '"${rhostname}"' localhost/' -i /etc/hosts
    fi
}

in_emerge() {
    e "Emerging needed packages"
    rcrypt="$1"
    rmode="$2"
    refi="$3"
    packages=(
        syslinux gentoo-sources
        gptfdisk parted

        app-portage/eix app-editors/vim
    )
    [[ "$rcrypt" == [Yy]* ]] && echo 'sys-kernel/genkernel cryptsetup' >> /etc/portage/package.use/10-temp
    #[[ "$rcrypt" == [Yy]* ]] && echo 'sys-fs/cryptsetup static' >> /etc/portage/package.use
    [[ "$rmode" == lvm ]] && packages+=(lvm2)
    [[ "$refi" == [Yy]* ]] && packages+=(efibootmgr)
    # echo 'sys-boot/syslinux' >> /etc/portage/package.accept_keywords # >=6

    # if [[ -n "$rbinhost" ]]; then
    #     emerge -g -1 --quiet --quiet-build=y "${packages[@]}"
    # else
    #     emerge -k -1 --quiet --quiet-build=y "${packages[@]}"
    # fi
    emerge --quiet --quiet-build=y "${packages[@]}"

    # mkdir /etc/portage/repos.conf
    # cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
    # while read p; do layman -a $(echo "$p" | grep '*/*::' | cut -f 3 -d':'); done </etc/portage/package.mask

    ###########################################################################
    # Configure new programs
    ###########################################################################

    e "Setting new programs up"
    e " running eix-update"
    s eix-update

    e " configuring genkernel"
    cpu_count=$(grep -c '^processor' /proc/cpuinfo)
    conf_set /etc/genkernel.conf CLEAN no
    conf_set /etc/genkernel.conf INSTALL yes
    conf_set /etc/genkernel.conf MAKEOPTS -j6
    conf_set /etc/genkernel.conf CMD_CALLBACK "emerge @module-rebuild"
    conf_set /etc/genkernel.conf RAMDISKMODULES 0
    [[ "$rcrypt" == [Yy]* ]] &&         conf_set /etc/genkernel.conf LUKS yes
    [[ ! -z "$rdefault_kconfig" ]] &&   conf_set /etc/genkernel.conf DEFAULT_KERNEL_CONFIG "$rdefault_kconfig"

    # genkernel --menuconfig all
    genkernel all

    ###########################################################################
    # Services
    ###########################################################################

    # [[ "$rcrypt" == [Yy]* ]] && e " dmcrypt" && s rc-update add dmcrypt boot
    [[ "$rmode" == zfs ]] && e " zfs" && s rc-update add zfs boot
    [[ "$rmode" == lvm ]] && e " lvm" && s rc-update add lvm boot

}


in_syslinux() {
    e "Installing bootloader"
    rtrim="$1"
    rroot="$2"
    rrealswap="$3"
    rswap="$4"
    refi="$5"
    rdev="$6"
    rcrypt="$7"
    rmode="$8"
    rboot="$9"
    rappend="${10}"

    append="$rappend"
    [[ "$rtrim" == [Yy]* ]] && append="$rappend root_trim=yes"
    if [[ "$rcrypt" == [Yy]* ]]; then
        append="${append} crypt_root=$rroot"
        if [[ "$rmode" != lvm ]]; then
            append="${append} crypt_swap=$rrealswap"
        else
            append="${append} swap=$rrealswap"
        fi
    else
        append="${append} resume=$rswap"
    fi

    # EFI
    if [[ "$refi" == [Yy]* ]]; then
        esp=/boot/efi
        mkdir -p $esp/syslinux
        cp -f /usr/share/syslinux/efi64/{syslinux.efi,ldlinux.e64} $esp/syslinux
        mountpoint -q /sys/firmware/efi/efivars || mount -t efivarfs efivarfs /sys/firmware/efi/efivars
        efibootmgr -c -p 1 -d "$rdev" -l '\EFI\syslinux\syslinux.efi' -L "Syslinux"
    fi

    # BIOS
    s sgdisk "$rdev" --attributes=1:set:2
    cat /usr/share/syslinux/gptmbr.bin > "$rdev"
    mkdir -p /boot/syslinux
    s syslinux --directory syslinux --install "$rboot"

    syslinuxcfg='/boot/syslinux.cfg'

    e "Writing syslinux configuration"
    kernel=$(cd /boot && printf '/%s' kernel-genkernel-*)
    initrd=$(cd /boot && printf '/%s' initramfs-genkernel-*)
    cat <<EOF > "$syslinuxcfg"
DEFAULT gentoo-genkernel
PROMPT 0

LABEL gentoo-genkernel
LINUX ${kernel}
INITRD ${initrd}
EOF

    case "$rmode" in
    ext*)
        printf 'APPEND root=%s %s\n' "$rroot" "$rappend" >> "$syslinuxcfg"
        ;;
    zfs)
        printf 'APPEND root=ZFS=%s dozfs=force %s\n' "$rrealroot" "$rappend" >> "$syslinuxcfg"
        ;;
    lvm)
        printf 'APPEND root=%s dolvm %s\n' "$rrealroot" "$rappend" >> "$syslinuxcfg"
        ;;
    esac
}

in_user() {
    rusername="$1"
    rusergroups="$2"

    e "Adding user"
    useradd -g users "$rusername"
    passwd "$rusername"
    # chsh -s '/bin/zsh' "$rusername"
    useradd -G "$rusergroups" "$rusername"

    e "Please set the root password"
    passwd

    echo "You may now reboot the system."
}

if [[ $# -eq 0 ]]; then
    # [[ -z "$rstage3_url" ]] && (echo 'No stage3 url set'; exit 1)
    # [[ -z "$rnet_cfg" ]] && (echo 'No network configuration'; exit 1)

    # [[ -z "$rarch" ]] && pick_arch
    # [[ -z "$rdev" ]] && pick_dev
    # [[ -z "$rtimezone" ]] && pick_tz /usr/share/zoneinfo  # might fail, we try again at outside_chroot
    # [[ -z "$rhostname" ||  -z "$rtimezone" ]] && pick_other

    # [[ -z "$rmode" ]] && pick_mode
    # [[ "$rarch" -ne amd64 && "$rmode" -eq zfs ]] && (echo "zfs only supported on amd64"; exit 1)

    outside_chroot

    cp -f "$0" /mnt/gentoo/
    chmod +x /mnt/gentoo/"${0##*/}"

    #Enter chroot and call self
    e "Entering chroot!"
    s=/"${0##*/}"
    ch="chroot /mnt/gentoo chroot $s"

    ${ch} swapon "$rrealswap"
    ${ch} sync_tree
    ${ch} locale "$rlocale"
    ${ch} profile
    ${ch} timezone "$rtimezone"
    ${ch} hostname "$rhostname"
    ${ch} fstab "$rmode" "$rboot" "$rrealswap" "$rrealroot"
    ${ch} make_conf "$(env | grep '^rmake_' | sed 's/^rmake_//')"
    ${ch} gprofile "$rgprofile"
    ${ch} networking "$rnet_cfg"
    ${ch} hosts "$rhostname" "$rdomainname"
    ${ch} emerge "$rcrypt" "$rmode" "$refi"
    ${ch} syslinux "$rtrim" "$rroot" "$rrealswap" "$rswap" "$refi" "$rdev" "$rcrypt" "$rmode" "$rboot" "$rappend"
    ${ch} user "$rusername" "$rusergroups"

elif [[ "$1" = "chroot" ]]; then
    shift
    func="in_$1"
    $func "$@"
fi

# useradd -m -g users -G wheel,games,optical,storage,power,floppy,video,audio -s /bin/bash username

# emerge -avtuDN --with-bdeps y --keep-going world && emerge --tree -av @preserved-rebuild && emerge -av --depclean
# if eix -q --installed -e fcron; then
#     e " configuring fcron"
#     "${packages[@]}"
#     s emerge --config sys-process/fcron && s crontab /etc/crontab >/dev/null
# fi

#     e "Enabling services"
#     for daemon in rsyslog ntpd sshd fcron lm_sensors; do
#         if eix -q --installed -e "$daemon"; then
#             e " $daemon"
#             s rc-update add $daemon default
#             # if "$daemon" -eq lm_sensors; then sensors-detect; fi
#         fi
#     done
