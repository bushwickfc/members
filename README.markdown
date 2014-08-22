# README

A membership and status application for Bushwick Food Co-Op members. Used to
track fee payments, hours, etc. Uses sidekiq to run some jobs...

Foreman will spawn unicorn, a clockwork process, and sidekiq to process jobs.

## Requirements

* Ruby 2.1.2
* apt-get install libssl-dev libxml2-dev libxslt1-dev libreadline-dev nodejs mysql-server nginx redis-server
  * `cp -R config/etc /`
* `useradd -d /opt/apps -r -m apps`
* `cp bin/release.sh /opt/apps`
* `useradd -d /opt/git -r -m -s /usr/bin/git-shell git`
* `sudo -u git -c 'cd /opt/git; mkdir bfc-members; cd bfc-members; git init --bare'`
  * add the machine as a remote to your repo
  * push master to the repo
* create ~apps/bfc-members/shared/config/env.sh
```
export SECRET_KEY_BASE=
export LANG="en_US.UTF-8"
export RACK_ENV="prodcution"
export RAILS_ENV="prodcution"
export DATABASE_URL=
export REDISTOGO_URL="redis://localhost:6379/10"
```
* `sudo -u apps 'cd ~apps; ./release bfc-members`

## Development

* On OS X install [brew](http://brew.sh/)
* `brew install mysql`
 * follow the on screen instructions, for running the server
* `git clone git@github.com:bushwickfc/bfc-members`
* `cd bfc-members`
* **DO NOT USE db:setup**
* `rake db:create db:migrate`
* To seed data, you can use a db dump or seeds
 * `rake db:seed`
 * `gzip -dc db.sql.gz | mysql -D bfc-members_development`
* REPL `rails c`
* Local web server `rails s`
* Run tests `rake test`

## Deployment

* `git remote add ov git@db.ov.bushwickfoodcoop.org:bfc-members.git`
* `git push ov master:master`
* `ssh db.ov.bushwickfoodcoop.org`
  * `su - apps`
    * `./release.sh bfc-members`
    * `cd bfc-members/current; rake db:migrate`
  * `restart bfc-members`

