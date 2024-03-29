FROM debian:testing
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    sudo \
    dbus-x11 \
    gnupg2 \
    procps \
    xfce4 \
    xfce4-goodies \
    xterm \
    tigervnc-standalone-server \
    tigervnc-common \
    wget \
    qtbase5-dev \
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libopengl0 \
    gtk2-engines-pixbuf && \
  update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-arm64 /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN groupadd --gid 7777 dev && \
    useradd --uid 3333 --gid 7777 -m josh && \
    echo josh ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/josh && \
    chmod 0440 /etc/sudoers.d/josh

USER josh

RUN wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

RUN mkdir ~/.vnc && \
    echo 'password' | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd && \
    touch ~/.Xauthority && \
    echo "#!/bin/bash\n\
export XKL_XMODMAP_DISABLE=1\n\
export DISPLAY=:99\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
exec startxfce4\n" | tee ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup && \
    echo " #!/bin/bash\n\
/usr/bin/vncserver -fg -rfbport 5900 -display :99 -depth 24 -geometry 1920x1200 -localhost no -verbose -cleanstale\n" | tee ~/start-vnc && \
    chmod +x ~/start-vnc
