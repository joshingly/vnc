FROM debian:stable
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    dbus-x11 \
    gnupg2 \
    procps \
    xfce4 \
    xfce4-goodies \
    xterm \
    tigervnc-standalone-server \
    tigervnc-common \
    gtk2-engines-pixbuf && \
  update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper

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
/usr/bin/vncserver -fg -rfbport 5900 -display :99 -depth 24 -geometry 1024x600 -localhost no -verbose -cleanstale\n" | tee ~/start-vnc && \
    chmod +x ~/start-vnc

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-arm64 /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
