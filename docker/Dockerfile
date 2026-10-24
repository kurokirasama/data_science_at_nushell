# =============================================================================
# Data Science at Nushell (dsin) — Standalone Container Image
# =============================================================================
FROM datasciencetoolbox/dsatcl2e:latest

ARG NUSHELL_VERSION="0.116.1"
LABEL maintainer="Luis Gómez <lgomez@ubiobio.cl>"
LABEL description="Data Science at Nushell (dsin) — Integrated Nushell, Polars, R, Python, VW, Tapkee, SKLL, ttt, and timg environment"
LABEL org.opencontainers.image.source="https://github.com/kurokirasama/data_science_at_nushell"

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
    usermod -l dsin -d /home/dsin -m dst && \
    groupmod -n dsin dst && \
    chsh -s /usr/local/bin/nu dsin

# 3. Install ttt editor and user configuration (ttt_config.7z)
COPY ttt /usr/local/bin/ttt
COPY ttt_config.7z /tmp/ttt_config.7z
RUN chmod +x /usr/local/bin/ttt && \
    mkdir -p /usr/local/share/nushell/vendor/autoload /home/dsin/.config /home/dsin/.config/nushell/nu_modules /home/dsin/bin /data && \
    7z x /tmp/ttt_config.7z -o/home/dsin/.config/ -y && \
    rm -f /tmp/ttt_config.7z

# 4. Install custom Nushell configuration, course helper module, l command, extra plugins, and pre-populated /data (ch03..ch09)
COPY config.nu /home/dsin/.config/nushell/config.nu
COPY env.nu /home/dsin/.config/nushell/env.nu
COPY dsin_tools.nu /home/dsin/.config/nushell/nu_modules/dsin_tools.nu
COPY custom_l.nu /usr/local/share/nushell/vendor/autoload/custom_l.nu
COPY custom_l.nu /home/dsin/.config/nushell/nu_modules/custom_l.nu
COPY data/ /data/
COPY plugins/* /usr/local/bin/
RUN cp /data/ch08/pbc /usr/local/bin/pbc && \
    chmod +x /usr/local/bin/pbc /usr/local/bin/ttt /usr/local/bin/timg /usr/local/bin/nu_plugin_* && \
    chown -R dsin:dsin /home/dsin /data

# 5. Register all Nushell plugins for user dsin
USER dsin
WORKDIR /home/dsin
RUN for p in polars formats gstat inc query file plot port_extension; do \
      /usr/local/bin/nu -c "plugin add /usr/local/bin/nu_plugin_${p}"; \
    done

ENV HOSTNAME="dsin"
ENV HOME="/home/dsin"
ENV SHELL="/usr/local/bin/nu"
ENV PARALLEL_SHELL="/bin/bash"
ENV EDITOR="ttt"
ENV VISUAL="ttt"
ENV PATH="/home/dsin/bin:/usr/local/bin:/usr/bin/dsutils:/home/dsin/.local/bin:/usr/games:/usr/sbin:/usr/bin:/sbin:/bin"
ENV LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*.txt=00;33:"

ENTRYPOINT ["/usr/local/bin/nu"]
