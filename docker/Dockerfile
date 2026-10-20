# =============================================================================
# Data Science at Nushell (dsin) — Standalone Container Image
# =============================================================================
FROM datasciencetoolbox/dsatcl2e:latest

ARG NUSHELL_VERSION="0.116.1"
LABEL maintainer="Luis Gómez <lgomez@ubiobio.cl>"
LABEL description="Data Science at Nushell (dsin) — Integrated Nushell, Polars, R, Python, VW, Tapkee, SKLL, ttt, and timg environment"

USER root

# 1. Fix upstream Issue #150: Switch EOL Ubuntu 21.04 (hirsute) APT sources to old-releases.ubuntu.com
#    and install core CLI + build dependencies for timg (from install_01_ubuntu_24.04.sh)
RUN sed -i -E 's/(archive|security)\.ubuntu\.com/old-releases.ubuntu.com/g' /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      cmake \
      curl \
      g++ \
      git \
      jq \
      libavcodec-dev \
      libavdevice-dev \
      libavformat-dev \
      libcairo-dev \
      libdeflate-dev \
      libexif-dev \
      libgraphicsmagick++-dev \
      libgraphicsmagick-dev \
      libopenslide-dev \
      libpoppler-glib-dev \
      librsvg2-dev \
      libsixel-dev \
      libswscale-dev \
      libturbojpeg-dev \
      p7zip-full \
      pkg-config \
      sqlite3 \
      tree \
      unzip \
      xmlstarlet && \
    git clone --depth 1 https://github.com/hzeller/timg.git /tmp/timg && \
    mkdir -p /tmp/timg/build && \
    cd /tmp/timg/build && \
    cmake ../ -DWITH_OPENSLIDE_SUPPORT=On && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/timg /var/lib/apt/lists/*

# 2. Install static Nushell (nu) and nu_plugin_polars (musl build for universal GLIBC compatibility)
RUN mkdir -p /tmp/nu-install && \
    curl -fsSL "https://github.com/nushell/nushell/releases/download/${NUSHELL_VERSION}/nu-${NUSHELL_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
      -o /tmp/nu-install/nu.tar.gz && \
    tar -xzf /tmp/nu-install/nu.tar.gz -C /tmp/nu-install --strip-components=1 && \
    cp /tmp/nu-install/nu /usr/local/bin/nu && \
    cp /tmp/nu-install/nu_plugin_* /usr/local/bin/ && \
    chmod +x /usr/local/bin/nu /usr/local/bin/nu_plugin_* && \
    rm -rf /tmp/nu-install && \
    grep -qxF '/usr/local/bin/nu' /etc/shells || echo '/usr/local/bin/nu' >> /etc/shells && \
    chsh -s /usr/local/bin/nu dst

# 3. Install ttt editor and user configuration (ttt_config.7z)
COPY ttt /usr/local/bin/ttt
COPY ttt_config.7z /tmp/ttt_config.7z
RUN chmod +x /usr/local/bin/ttt && \
    mkdir -p /home/dst/.config /home/dst/.config/nushell/nu_modules /home/dst/bin /data && \
    7z x /tmp/ttt_config.7z -o/home/dst/.config/ -y && \
    rm -f /tmp/ttt_config.7z

# 4. Install custom Nushell configuration, course helper module, and pre-populated /data (ch02..ch08)
COPY config.nu /home/dst/.config/nushell/config.nu
COPY dsin_tools.nu /home/dst/.config/nushell/nu_modules/dsin_tools.nu
COPY data/ /data/
RUN echo '$env.PATH = ($env.PATH | split row (char esep) | prepend ["/home/dst/bin", "/usr/local/bin", "/usr/bin/dsutils", "/home/dst/.local/bin", "/usr/games"] | uniq); $env.PARALLEL_SHELL = "/bin/bash"' > /home/dst/.config/nushell/env.nu && \
    cp /data/ch07/pbc /usr/local/bin/pbc && \
    chmod +x /usr/local/bin/pbc /usr/local/bin/ttt /usr/local/bin/timg && \
    chown -R dst:dst /home/dst /data

# 5. Register nu_plugin_polars for user dst
USER dst
WORKDIR /data
RUN /usr/local/bin/nu -c "plugin add /usr/local/bin/nu_plugin_polars"

ENV HOSTNAME="dsin"
ENV SHELL="/usr/local/bin/nu"
ENV PARALLEL_SHELL="/bin/bash"
ENV EDITOR="ttt"
ENV VISUAL="ttt"
ENV PATH="/home/dst/bin:/usr/local/bin:/usr/bin/dsutils:/home/dst/.local/bin:/usr/games:/usr/sbin:/usr/bin:/sbin:/bin"

ENTRYPOINT ["/usr/local/bin/nu"]
