# docker run -p 80:80 -p 9080:9080 -v tor-bridge2-keys:/var/lib/tor/keys -d --restart always --name tor-bridge2 benwaddell/tor-bridge2

# ubuntu base image
FROM ubuntu

# ports used by tor
EXPOSE 80 9080

# install tor repo dependencies
RUN apt-get update \
&& apt-get install apt-transport-https wget gpg -y \
&& wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc \
| gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null \
&& echo 'deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org jammy main' \
>> /etc/apt/sources.list.d/tor.list \
&& echo 'deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org jammy main' \
>> /etc/apt/sources.list.d/tor.list

# install tor and obfs4proxy
RUN apt-get update \
&& apt-get install tor deb.torproject.org-keyring obfs4proxy nyx -y

# copy config file
COPY --chown=debian-tor:debian-tor torrc /etc/tor/

# change to debian-tor
USER debian-tor

# set permissions on docker volume
RUN mkdir -p /var/lib/tor/keys \
&& chmod 2700 /var/lib/tor/keys

# run startup script
ENTRYPOINT tor
