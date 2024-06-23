#!/bin/bash

set -ouex pipefail

rpm-ostree install \
    make \
    automake \
    gcc \
    gcc-c++ \
    cmake \
    glib \
    glib-devel \
    gtk2 \
    gtk2-devel \
    gtk3 \
    gtk3-devel \
    vala \
    meson \
    libvala \
    libvala-devel \
    dbusmenu-qt \
    libdbusmenu-gtk2 \
    libdbusmenu-gtk3 \
    rust \
    krdp \
    gamemode \
    pamixer \
    playerctl \
    flatpak-builder \
    samba \
    cargo && \
rpm-ostree install \
    steamdeck-kde-presets-desktop  && \
ostree container commit

#Install Tela Circle Icons
cd /tmp && \
git clone https://github.com/vinceliuice/Tela-circle-icon-theme && \
cd Tela-circle-icon-theme && \
./install.sh && \
ostree container commit

#Install Window Title applet for macOS like layouts
cd /usr/share/plasma/plasmoids && \
git clone https://github.com/dhruv8sh/plasma6-window-title-applet org.kde.windowtitle && \
ostree container commit

#Install Plasma Control Hub applet for macOS like control hub
cd /usr/share/plasma/plasmoids && \
git clone https://github.com/zayronxio/Plasma-Control-Hub Plasma.Control.Hub && \
ostree container commit

#Install Toggle Overview Widget
cd /usr/share/plasma/plasmoids && \
git clone https://github.com/HimDek/Overview-Widget-for-Plasma com.himdek.kde.plasma.overview && \
ostree container commit

#Install Uswitch Widget
cd /tmp && \
git clone https://gitlab.com/divinae/uswitch && \
mv /tmp/uswitch/package /usr/share/plasma/plasmoids/com.dv.uswitcher && \
ostree container commit