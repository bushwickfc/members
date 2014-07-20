#!/bin/bash
set -e
set -x
DATE=${1:?Missing Date}
SHORT=${2:-no}
base=$(dirname "$0")
tmp="$base/../tmp"
csv="$tmp/members-$DATE-nonl.csv"

rake db:drop db:create db:migrate
$base/import_members.rb  $csv 2>&1 |tee $tmp/members-$DATE-nonl.log 

if [ $SHORT != "yes" ]; then
  $base/extract_from_csv.rb $csv > $tmp/verify-members-${DATE}.csv
  $base/export_members.rb > $tmp/verify-db-${DATE}.csv 
  vi $tmp/verify-*${DATE}*.csv
  open $tmp/verify-*${DATE}*.csv
fi
