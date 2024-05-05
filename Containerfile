ARG BASE_IMAGE
ARG STAGE_NAME
ARG COPY_NVIDIA_FILES
FROM ${BASE_IMAGE}:stable AS ${STAGE_NAME}

COPY system_files/desktop/kinoite /
COPY system_files/desktop/shared /
${COPY_NVIDIA_FILES}
COPY system_files/overrides /

# Setup Repo
RUN curl -Lo /etc/yum.repos.d/tohur-Pwn-fedora-40.repo https://copr.fedorainfracloud.org/coprs/tohur/Pwn/repo/fedora-40/tohur-Pwn-fedora-40.repo && \
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/tohur-Pwn-fedora-40.repo && \
ostree container commit

# Remove uneeded packages
RUN mkdir -p /var/lib/alternatives && \
    rpm-ostree override remove pipewire-pulseaudio --install pulseaudio && \
    ostree container commit && \
    rpm-ostree override remove \
    ptyxis \
    discover-overlay \
    input-remapper \
    kcharselect \
    krfb \
    krfb-libs \
    kmousetool \
    rom-properties-kf6 \
    protontricks \
    steamdeck-kde-presets-desktop \
    qsynth && \
    ostree container commit

# Install new packages
RUN rpm-ostree install \
    konsole \
    rust \
    pamixer \
    playerctl \
    cargo && \
rpm-ostree install \
    steamdeck-kde-presets-desktop  && \
    ostree container commit

# Disable Repo
RUN sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tohur-Pwn-fedora-40.repo && \
ostree container commit

# Remove uneeded files
RUN rm /usr/share/applications/com.gerbilsoft.rom-properties.rp-config.desktop && \
    rm /usr/share/applications/org.gnome.Prompt.desktop && \
    ostree container commit

# Update the initramfs
RUN KERNEL_FLAVOR=fsync /usr/libexec/containerbuild/build-initramfs && \
    ostree container commit