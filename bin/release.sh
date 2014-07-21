#!/bin/bash
# apt-get install libssl-dev libxml2-dev libxslt1-dev libreadline-dev nodejs
set -e
set -x
app=${1:?Missing app}
git_dir=${2:-/opt/git}
rel=`date +"%Y%m%d%H%M%S"`
app_dir="/opt/apps/$app"
rel_dir="$app_dir/releases/$rel"
shared_dir="$app_dir/shared"
. $shared_dir/config/env.sh

if [ ! -d "$app_dir" ]; then
	mkdir -p $app_dir/releases
	mkdir -p $app_dir/shared/{log,pids,tmp}
fi

mkdir -p $rel_dir
cd $git_dir/$app.git
git archive master | tar xf - -C $rel_dir

cd $rel_dir
rm -rf log tmp
ln -s $shared_dir/log
ln -s $shared_dir/tmp
ln -s $shared_dir/pids

bundle package
bundle install --deployment --binstubs --without development test
bundle exec rake assets:precompile

if [ -e "$app_dir/current" ]; then
	cd $app_dir/current
	(sudo /sbin/stop $app || :)
	rm $app_dir/current
fi
cd $app_dir
ln -s $rel_dir current
cd current

sudo /sbin/start $app

