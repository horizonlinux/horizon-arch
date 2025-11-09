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
       gdm \
       glibc-locales \
       gnome-backgrounds \
       gnome-color-manager \
       gnome-control-center \
       gnome-disk-utility \
       gnome-initial-setup \
       gnome-keyring \
       gnome-menus \
       gnome-session \
       gnome-settings-daemon \
       gnome-shell \
       gnome-user-share \
       grilo-plugins \
       gvfs \
       gvfs-afc \
       gvfs-dnssd \
       gvfs-goa \
       gvfs-google \
       gvfs-gphoto2 \
       gvfs-mtp \
       gvfs-nfs \
       gvfs-onedrive \
       gvfs-smb \
       gvfs-wsdd\
       malcontent \
       nautilus \
       networkmanager \
       orca \
       ptyxis \
       rygel \
       tecla \
       xdg-desktop-portal-gnome \
       xdg-user-dirs-gtk && \
  pacman -S --clean && \
  rm -rf /var/cache/pacman/pkg/* && \
  systemctl enable NetworkManager && \
  systemctl enable gdm

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
