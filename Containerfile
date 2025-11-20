#              .-==++++++++++++++++++++++++++++==============--:.
#           :=+++++++++++++++++++++++++++++++=====================-.
#         -++++++++++++++++++++++++++++++++=========================-:
#       .++++++++++++++++++++++++++++++++=============================-.
#      .++++++++++++#########++++++++++=================================.
#     .+++++++++++++#%%%%%%%#++++++++===================================-
#     =+++++++++++++#%%%%%%%#++++++====================================--:
#     ++++++++++++++#%%%%%%%#=+++=====================================----
#     ++++++++++++++#%%%%%%%#=+=====================================------                        ===========================================================================
#     ++++++++++++++#%%%%%%%#=====================================--------                        | Welcome!                                                                |
#     ++++++++++++++#%%%%%%%#===================================----------                        | This is the file that does most of the magic to create a Horizon image. |
#     ++++++++++++++#%%%%%%%#===+++++++++++++++===============------------                        |                                                                         |
#     ++++++++++++++#%%%%%%%#===#%%%%%%%%%%%%%######**+=-===--------------                        | Special thanks to:                                                      |
#     +++++++++++++=#%%%%%%%#===*%##################%%##+=-=--------------                        | - Tulip Blossom - https://github.com/tulilirockz                        |
#     +++++++++++++=#%%%%%#%#===*%######################%#=---------------                        | - Kyle Gospodnetich - https://github.com/KyleGospo                      |
#     +++++++++++===#%%%%%#%#===*%###############%%########=--------------                        | - And all other people that helped developing Bootcrew images :)        |
#     +++++++++=====#%#%###%#=====================*#######%*--------------                        ===========================================================================
#     +++++++=======#%#####%#============----------*########--------------
#     +++++=========#%#####%#=====================-*########--------------
#     +++===========#%#####%#=================-----*########--------------
#     +=============#%#####%#===============-------*########--------------
#     ==============#%#####%#=============---------*########--------------
#     ==============#%#####%#===========-----------*########--------------
#     ==============#%######*=========-------------*########--------------
#     ==============#%######*=======---------------*########--------------
#     ==============########*-====-----------------*########--------------
#     ==============########*-==-------------------*########--------------
#     -=============########*-=--------------------*########-------------:
#      =============#%#####%#-=--------------------*%#######-------------
#      .============*********----------------------+********------------.
#       .-==========--------------------------------------------------:
#         :-============--------------------------------------------:.
#           .:-=====---------------------------------------------::.
#              .::------------------------------------------:::.


FROM scratch AS ctx

FROM docker.io/archlinux/archlinux:latest

COPY system_files /

ENV DEV_DEPS="base-devel git rust"

ENV DRACUT_NO_XATTR=1

RUN echo "[horizon-pacman]" >> /etc/pacman.conf && \
echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf && \
echo "Server = https://horizonlinux.github.io/pacman/x86_64" >> /etc/pacman.conf && \
pacman -Syu --noconfirm

RUN pacman -Syu --noconfirm --overwrite "*" \
      filesystem-horizon \
      base \
      cups \
      cups-pdf \
      bluez-cups \
      cups-pk-helper \
      cups-browsed \
      dracut \
      linux \
      linux-firmware \
      ostree \
      systemd \
      btrfs-progs \
      e2fsprogs \
      xfsprogs \
      dosfstools \
      skopeo \
      dbus \
      dbus-glib \
      glib2 \
      glibc \
      ostree \
      mkinitcpio \
      shadow \
      sudo \
      open-vm-tools \
      plymouth \
      nano \
      distrobox \
      podman \
      linux-firmware \
	linux-firmware-amdgpu \
	linux-firmware-atheros \
	linux-firmware-broadcom \
	linux-firmware-intel \
	linux-firmware-mediatek \
	linux-firmware-other \
	linux-firmware-radeon \
	linux-firmware-realtek \
      cifs-utils \
	firewalld \
	fuse2 \
	fuse3 \
	fuse-common \
	fwupd  \
	gvfs-smb \
	ifuse \
	libcamera \
	gst-plugin-libcamera \
	libcamera-tools \
	libimobiledevice \
	man-db \
	rclone \
	systemd \
	tuned \
	tuned-ppd \
	unzip \
	vim \
	micro \
	whois \
      ${DEV_DEPS} && \
  pacman -S --clean && \
  rm -rf /var/cache/pacman/pkg/*

RUN echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
echo "Defaults env_reset,pwfeedback" >> /etc/sudoers

# Workaround due to dracut version bump, please remove eventually
# FIXME: remove
RUN echo -e "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /etc/dracut.conf.d/fix-bootc.conf

RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/root \
    git clone https://github.com/bootc-dev/bootc.git /tmp/bootc && \
    cd /tmp/bootc && \
    #rm -rf /tmp/bootc/crates/lib/src/bootc_composefs/state.rs && \
    #curl -o /tmp/bootc/crates/lib/src/bootc_composefs/state.rs https://raw.githubusercontent.com/bootc-dev/bootc/581488cb3c782a208f2fd39518bb19f90e968d73/crates/lib/src/bootc_composefs/state.rs && \
    make bin install-all && \
    sh -c 'export KERNEL_VERSION="$(basename "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)")" && \
    dracut --force --no-hostonly --reproducible --zstd --verbose --kver "$KERNEL_VERSION"  "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"' && \
    pacman -S --clean --noconfirm

RUN pacman -Syyuu --noconfirm \
       system-config-printer \
       glibc-locales \
       aurorae \
       bluedevil \
       breeze \
       breeze-gtk \
       dolphin \
       drkonqi \
       flatpak \
       flatpak-kcm \
       horizon-wallpapers \
       kaccounts-integration \
       kaccounts-providers \
       kactivitymanagerd \
       kde-cli-tools \
       kde-gtk-config \
       kdecoration \
       kdeplasma-addons \
       kglobalacceld \
       kinfocenter \
       kio \
       kio-admin \
       kio-extras \
       kio-fuse \
       kio-gdrive \
       kio-zeroconf \
       audiocd-kio \
       kmenuedit \
       knighttime \
       konsole \
       kpipewire \
       kscreen \
       kscreenlocker \
       ksshaskpass \
       ksystemstats \
       kwallet-pam \
       kwayland \
       kwin \
       kwrite \
       kwrited \
       layer-shell-qt \
       libkscreen \
       libksysguard \
       libplasma \
       milou \
       ocean-sound-theme \
       pipewire \
       pipewire-audio \
       pipewire-pulse \
       plasma-activities \
       plasma-activities-stats \
       plasma-browser-integration \
       plasma-desktop \
       plasma-disks \
       plasma-firewall \
       plasma-integration \
       plasma-nm \
       plasma-pa \
       plasma-systemmonitor \
       plasma-thunderbolt \
       plasma-vault \
       plasma-welcome \
       plasma-workspace \
       plasma-workspace-wallpapers \
       polkit-kde-agent \
       powerdevil \
       print-manager \
       sddm-kcm \
       spectacle \
       systemsettings \
       xdg-desktop-portal-kde \
       wireplumber && \
  pacman -S --clean && \
  rm -rf /var/cache/pacman/pkg/

# Create build user
RUN useradd -m --shell=/bin/bash build && usermod -L build && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER build
WORKDIR /home/build
RUN git clone https://aur.archlinux.org/plasma-setup-git.git /tmp/kiss && \
    cd /tmp/kiss && \ 
    makepkg -sri --noconfirm && \
	git clone https://aur.archlinux.org/bazaar.git /tmp/bazzar && \
    cd /tmp/bazzar && \ 
    makepkg -sri --noconfirm && \
	git clone https://aur.archlinux.org/krunner-bazaar.git /tmp/bazzar-krunner && \
    cd /tmp/bazzar-krunner && \ 
    makepkg -sri --noconfirm
USER root
WORKDIR /

RUN userdel build && mv /etc/sudoers.bak /etc/sudoers && \
    pacman -Rns --noconfirm base-devel rust && \
	  pacman -S --clean

RUN systemd-sysusers

RUN systemctl enable sddm && \
  sed -i '/Current=/c\Current=breeze' /usr/lib/sddm/sddm.conf.d/default.conf && \
  sed -i '/CursorSize=/c\CursorSize=24' /usr/lib/sddm/sddm.conf.d/default.conf && \
  sed -i '/CursorTheme=/c\CursorTheme=breeze_cursors' /usr/lib/sddm/sddm.conf.d/default.conf && \
  systemctl enable NetworkManager && \
  systemctl enable bluetooth && \
# enable sysexts for later released sysexts like ones containg Wine, Steam, and drivers.
  sysremctl enable systemd-sysext && \
  systemctl enable cups && \
  systemctl enable plasma-setup.service
#  systemctl enable plasma-setup.service && \
#  systemctl enable vmtoolsd.service && \
#  systemctl enable vmware-vmblock-fuse.service

# Clean up
RUN rm -rf /var/cache/pacman/pkg/ && \
	rm -rf /tmp/* && \
	rm -rf /usr/share/applications/vim.desktop && \
	rm -rf /usr/share/applications/micro.desktop && \
	rm -rf /usr/share/applications/system-config-printer.desktop && \
	rm -rf /usr/share/applications/cups.desktop && \
	rm -rf /usr/share/applications/lstopo.desktop && \
	rm -rf /usr/share/applications/avahi-discover.desktop && \
	rm -rf /usr/share/applications/bssh.desktop && \
	rm -rf /usr/share/applications/bvnc.desktop && \
	rm -rf /usr/share/applications/qv4l2.desktop && \
	rm -rf /usr/share/applications/qvidcap.desktop

RUN rm -rf /boot /home /root /usr/local /srv && \
    mkdir -p /var/{home,roothome,srv} /sysroot /boot && \
    ln -s /var/home /home && \
    ln -s /var/roothome /root && \
    ln -s /var/srv /srv && \
    ln -s sysroot/ostree /ostree

# Update useradd default to /var/home instead of /home for User Creation
RUN sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd"

# Necessary for `bootc install`
RUN mkdir -p /usr/lib/ostree && \
    printf  "[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n" | \
    tee "/usr/lib/ostree/prepare-root.conf"

RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

RUN bootc container lint
