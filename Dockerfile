FROM debian:8.5

# how to
#docker build -t janek109/cs .
#docker run --name cs -d -p 6379:6379 -p 3306:3306 janek109/cs

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

# Define default command.
CMD ["redis-server", "/etc/redis/redis.conf"]

# get correct packages
RUN \
cd /tmp && \
export DEBIAN_FRONTEND=noninteractive && \
wget http://repo.mysql.com/mysql-apt-config_0.1.5-1debian7_all.deb && \
dpkg -i mysql-apt-config_0.1.5-1debian7_all.deb

# set default replay
RUN \
echo mysql-server-5.6 mysql-server/root_password password root | debconf-set-selections && \
echo mysql-server-5.6 mysql-server/root_password_again password root | debconf-set-selections

# Install MySQL.
RUN \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -f -y mysql-server-5.6 && \
rm -rf /var/lib/apt/lists/* && \
sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf && \
echo "mysqld_safe &" > /tmp/config && \
echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
echo "mysql -e 'SET PASSWORD FOR \"root\"@\"localhost\" = PASSWORD(\"root\"); SET PASSWORD FOR \"root\"@\"127.0.0.1\" = PASSWORD(\"root\"); SET PASSWORD FOR \"root\"@\"%\" = PASSWORD(\"root\"); SET PASSWORD FOR \"root\"@\"::1\" = PASSWORD(\"root\"); SET PASSWORD FOR \"root\"@\"%\" = PASSWORD(\"root\");'" >> /tmp/config && \
bash /tmp/config && \
rm -f /tmp/config

# clean
RUN \
cd /tmp && \
rm ./mysql-apt-config_0.1.5-1debian7_all.deb

# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql"]

# Define mountable directories.
VOLUME ["/data"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["mysqld_safe"]

# Expose ports.
EXPOSE 6379
EXPOSE 3306
