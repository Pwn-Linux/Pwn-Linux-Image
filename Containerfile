FROM ghcr.io/ublue-os/bazzite:stable AS facillinux

COPY build.sh /tmp/build.sh

RUN mkdir -p /var/lib/alternatives && \
    rpm-ostree override remove pipewire-pulseaudio --install pulseaudio && \
    ostree container commit && \
    rpm-ostree override remove \
    ptyxis \
    kde-connect-libs \
    kdeconnectd \
    kde-connect \
    kcharselect \
    krfb \
    krfb-libs \
    kmousetool \
    qsynth && \
    ostree container commit && \
    rpm-ostree install \
    konsole \
    rust \
    pamixer \
    cargo && \
    ostree container commit
