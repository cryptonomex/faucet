#!/usr/bin/env bash
# below is needed to run ruby and nginx, comment things out if you don't need any of them
echo_msg "installing ruby and it's dependencies"
sudo apt-get install -yfV -qq libgdbm-dev libncurses5-dev bison libffi-dev curl gawk libyaml-dev libsqlite3-dev sqlite3 libmysqlclient-dev
sudo apt-get install -yfV -qq libcurl4-openssl-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev libffi-dev python-software-properties

# install mysql manually:
# sudo apt-get -q -y install mysql-server
# mysql -u root -e "create database graphene_prod"

export USER_NAME="ubuntu"
export USER_HOME="/home/$USER_NAME"
export DEFAULT_RUBY="2.2.3"

git clone https://github.com/sstephenson/rbenv.git $USER_HOME/.rbenv
git clone https://github.com/sstephenson/ruby-build.git $USER_HOME/.rbenv/plugins/ruby-build

echo '' >> $USER_HOME/.bashrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $USER_HOME/.bashrc
echo 'eval "$(rbenv init -)"'               >> $USER_HOME/.bashrc
echo 'export RAILS_ENV=production'          >> $USER_HOME/.bashrc
echo 'gem: --no-document'                   >> $USER_HOME/.gemrc
$USER_HOME/.rbenv/bin/rbenv install -s $DEFAULT_RUBY
$USER_HOME/.rbenv/bin/rbenv global $DEFAULT_RUBY
mkdir $USER_HOME/.rbenv/plugins
git clone git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo

echo_msg "installing passenger and nginx"
$USER_HOME/.rbenv/bin/rbenv exec gem install bundler rails passenger
$USER_HOME/.rbenv/bin/rbenv sudo passenger-install-nginx-module --auto > /dev/null

sudo ln -s /opt/nginx/ /usr/local/nginx
sudo ln -s /opt/nginx/conf/ /etc/nginx

sudo wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo update-rc.d -f nginx defaults

#sudo mkdir -p /www/graphene
sudo mkdir -p /www/logs
sudo chown -R ubuntu:users /www

sudo mkdir -p /etc/ssl/certs
sudo mkdir -p /etc/ssl/private

echo_msg "done"
