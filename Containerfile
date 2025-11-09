FROM scratch AS ctx

FROM docker.io/archlinux/archlinux:latest

COPY system_files /

ENV DEV_DEPS="base-devel git rust"

ENV DRACUT_NO_XATTR=1
RUN pacman -Sy --noconfirm \
      base \
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
      ostree \
      shadow \
      sudo \
      open-vm-tools \
      ${DEV_DEPS} && \
  pacman -S --clean && \
  rm -rf /var/cache/pacman/pkg/*

# Workaround due to dracut version bump, please remove eventually
# FIXME: remove
RUN echo -e "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /etc/dracut.conf.d/fix-bootc.conf

RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/root \
    git clone https://github.com/bootc-dev/bootc.git /tmp/bootc && \
    cd /tmp/bootc && \
    make bin install-all install-initramfs-dracut && \
    sh -c 'export KERNEL_VERSION="$(basename "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)")" && \
    dracut --force --no-hostonly --reproducible --zstd --verbose --kver "$KERNEL_VERSION"  "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"' && \
    pacman -Rns --noconfirm base-devel git rust && \
    pacman -S --clean --noconfirm

RUN pacman -Syyuu --noconfirm \
       aurorae \
       bluedevil \
       breeze \
       breeze-gtk \
       drkonqi \
       flatpak-kcm \
       kactivitymanagerd \
       kde-cli-tools \
       kde-gtk-config \
       kdecoration \
       kdeplasma-addons \
       kglobalacceld \
       kinfocenter \
       kmenuedit \
       knighttime \
       kpipewire \
       kscreen \
       kscreenlocker \
       ksshaskpass \
       ksystemstats \
       kwallet-pam \
       kwayland \
       kwin \
       kwrited \
       layer-shell-qt \
       libkscreen \
       libksysguard \
       libplasma \
       milou \
       ocean-sound-theme \
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
       xdg-desktop-portal-kde && \
  pacman -S --clean && \
  rm -rf /var/cache/pacman/pkg/* && \
  systemctl enable NetworkManager && \
  systemctl enable sddm

RUN systemd-sysusers

RUN echo "[horizon-pacman]" >> /etc/pacman.conf && \
echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf && \
echo "Server = https://horizonlinux.github.io/pacman/x86_64" >> /etc/pacman.conf && \
  pacman -Syyuu --noconfirm plasma-setup-git && \
  pacman -S --clean && \
  rm -rf /var/cache/pacman/pkg/* && \
  systemctl enable plasma-setup

# Setup a temporary root passwd (changeme) for dev purposes
RUN usermod -p "$(echo "changeme" | mkpasswd -s)" root

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

RUN bootc container lint
