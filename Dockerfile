FROM debian:8.5

#
# Redis Dockerfile
#
# https://github.com/dockerfile/redis
#

#install basic
RUN \
	    sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
	    apt-get update && \
	    apt-get -y upgrade && \
	    apt-get install -y build-essential && \
	    apt-get install -y software-properties-common && \
	    apt-get install -y byobu curl git htop man unzip vim wget gcc make && \
	    rm -rf /var/lib/apt/lists/*

# Install Redis.
RUN \
cd /tmp && \
wget http://download.redis.io/releases/redis-3.0.7.tar.gz && \
tar xvzf redis-3.0.7.tar.gz && \
cd redis-3.0.7 && \
make && \
make install && \
cp -f src/redis-sentinel /usr/local/bin && \
mkdir -p /etc/redis && \
cp -f *.conf /etc/redis && \
rm -rf /tmp/redis-3.0.7* && \
sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf && \
sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf && \
sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf && \
sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["redis-server", "/etc/redis/redis.conf"]

# Expose ports.
EXPOSE 6379
