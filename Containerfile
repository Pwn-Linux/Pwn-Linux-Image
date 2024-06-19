ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG BASE_IMAGE_FLAVOR="${BASE_IMAGE_FLAVOR:-main}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-fsync}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$BASE_IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

FROM ghcr.io/ublue-os/bazzite:stable AS pwnlinux

ARG IMAGE_NAME="${IMAGE_NAME:-pwnlinux}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-pwn-linux}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-fsync}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

COPY system_files/desktop/kinoite /
COPY system_files/desktop/shared /
COPY system_files/overrides /

# Setup Repo
RUN curl -Lo /etc/yum.repos.d/tohur-Pwn-fedora-40.repo https://copr.fedorainfracloud.org/coprs/tohur/Pwn/repo/fedora-40/tohur-Pwn-fedora-40.repo && \
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/tohur-Pwn-fedora-40.repo && \
curl -Lo /etc/yum.repos.d/mullvad.repo https://repository.mullvad.net/rpm/stable/mullvad.repo && \
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/mullvad.repo && \
ostree container commit

# Remove uneeded packages
RUN mkdir -p /var/lib/alternatives && \
    rpm-ostree override remove \
    ptyxis \
    discover-overlay \
    input-remapper \
    kdebugsettings \
    kcharselect \
    krfb \
    krfb-libs \
    kmousetool \
    lutris \
    steam \
    fcitx5-mozc \
    fcitx5 \
    fcitx5-data \
    fcitx5-qt5 \
    rom-properties-kf6 \
    protontricks \
    steamdeck-kde-presets-desktop \
    qsynth && \
    ostree container commit

# Install new packages
RUN rpm-ostree install \
    rust \
    konsole \
    gamemode \
    pamixer \
    playerctl \
    flatpak-builder \
    samba \
    cargo && \
rpm-ostree install \
    steamdeck-kde-presets-desktop  && \
    ostree container commit

#Install Tela Circle Icon theme
RUN cd /tmp && \
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme && \
    cd Tela-circle-icon-theme && \
    ./install.sh && \
    ostree container commit

# Disable Repo
RUN sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tohur-Pwn-fedora-40.repo && \
ostree container commit

# Remove uneeded files
RUN rm /usr/share/applications/com.gerbilsoft.rom-properties.rp-config.desktop && \
    rm /usr/share/applications/org.gnome.Prompt.desktop && \
    rm /usr/share/applications/bazzite-documentation.desktop && \
    rm /usr/share/applications/bazzite-landing.desktop && \
    ostree container commit

# Update the initramfs
RUN KERNEL_FLAVOR=fsync /usr/libexec/containerbuild/build-initramfs && \
    /usr/libexec/containerbuild/image-info && \
    ostree container commit

# Finalize the build
RUN sed -i 's/Fedora Linux/Pwn Linux/g' /usr/lib/os-release && \
    sed -i 's/Bazzite/KDE Plasma/g' /usr/lib/os-release && \
    sed -i 's:/var/home:/home:' /etc/passwd && \
    sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
    touch /usr/bin/steam && \
    echo '#!/bin/bash' >> /usr/bin/steam && \
    echo 'flatpak run com.valvesoftware.Steam $@' >> /usr/bin/steam && \
    chmod +x /usr/bin/steam && \
    chmod +x /usr/libexec/pwn-linux-initial-setup && \
    chmod +x /usr/libexec/pwn-linux-user-setup && \
    systemctl enable pwn-linux-initial-setup.service && \
    systemctl --global enable pwn-linux-user-setup.service && \
    mv /usr/share/sddm /usr/share/pwn-linux/sddm && \
    ln -s /var/sddm /usr/share/sddm && \
    ostree container commit

FROM ghcr.io/ublue-os/bazzite-nvidia:stable AS pwnlinux-nvidia

ARG IMAGE_NAME="${IMAGE_NAME:-pwnlinux-nvidia}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-pwn-linux}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-nvidia}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-fsync}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"

COPY system_files/desktop/kinoite /
COPY system_files/desktop/shared /
COPY system_files/nvidia/kinoite /
COPY system_files/overrides /

# Setup Repo
RUN curl -Lo /etc/yum.repos.d/tohur-Pwn-fedora-40.repo https://copr.fedorainfracloud.org/coprs/tohur/Pwn/repo/fedora-40/tohur-Pwn-fedora-40.repo && \
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/tohur-Pwn-fedora-40.repo && \
curl -Lo /etc/yum.repos.d/mullvad.repo https://repository.mullvad.net/rpm/stable/mullvad.repo && \
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/mullvad.repo && \
ostree container commit

# Remove uneeded packages
RUN mkdir -p /var/lib/alternatives && \
    rpm-ostree override remove \
    ptyxis \
    discover-overlay \
    input-remapper \
    kdebugsettings \
    kcharselect \
    krfb \
    krfb-libs \
    kmousetool \
    lutris \
    steam \
    fcitx5-mozc \
    fcitx5 \
    fcitx5-data \
    fcitx5-qt5 \
    rom-properties-kf6 \
    protontricks \
    steamdeck-kde-presets-desktop \
    qsynth && \
    ostree container commit

# Install new packages
RUN rpm-ostree install \
    rust \
    konsole \
    gamemode \
    flatpak-builder \
    pamixer \
    playerctl \
    samba \
    cargo && \
rpm-ostree install \
    steamdeck-kde-presets-desktop  && \
    ostree container commit

#Install Tela Circle Icon theme
RUN cd /tmp && \
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme && \
    cd Tela-circle-icon-theme && \
    ./install.sh && \
    ostree container commit

# Disable Repo
RUN sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tohur-Pwn-fedora-40.repo && \
ostree container commit

# Remove uneeded files
RUN rm /usr/share/applications/com.gerbilsoft.rom-properties.rp-config.desktop && \
    rm /usr/share/applications/org.gnome.Prompt.desktop && \
    rm /usr/share/applications/bazzite-documentation.desktop && \
    rm /usr/share/applications/bazzite-landing.desktop && \
    ostree container commit

# Update the initramfs
RUN KERNEL_FLAVOR=fsync /usr/libexec/containerbuild/build-initramfs && \
    /usr/libexec/containerbuild/image-info && \
    ostree container commit

# Finalize the build
RUN sed -i 's/Fedora Linux/Pwn Linux/g' /usr/lib/os-release && \
    sed -i 's/Bazzite/KDE Plasma/g' /usr/lib/os-release && \
    sed -i 's:/var/home:/home:' /etc/passwd && \
    sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
    touch /usr/bin/steam && \
    echo '#!/bin/bash' >> /usr/bin/steam && \
    echo 'flatpak run com.valvesoftware.Steam $@' >> /usr/bin/steam && \
    chmod +x /usr/bin/steam && \
    chmod +x /usr/libexec/pwn-linux-initial-setup && \
    chmod +x /usr/libexec/pwn-linux-user-setup && \
    systemctl enable pwn-linux-initial-setup.service && \
    systemctl --global enable pwn-linux-user-setup.service && \
    mv /usr/share/sddm /usr/share/pwn-linux/sddm && \
    ln -s /var/sddm /usr/share/sddm && \
    ostree container commit