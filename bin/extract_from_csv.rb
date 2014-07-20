#!/usr/bin/env ruby
require 'csv'
file = ARGV[0] || "tmp/members-0715-nonl.csv"
headers = [
  "Last Name",
  "First Name",
  "Join Date",
  "JOIN/WF Date (work cycle count start date)",
  "Email",
  "Phone",
  #"Phone2",
  #"Address",
  #"Address2",
  #"City",
  #"Region (State)",
  #"Country",
  #"postal (zip)",
  "Contact Preference",
  "DOB",
  "Sex",
  "Member Status",
  "Membership Agreement",
  "Total hours ever worked",
  "Hours owed/banked",
  "FEE STATUS (PAID, CURRENT, DUE, OWING, SUSPENDED)",
  "Fee Paid to Date",
  "Dates Paid (amount) mm/dd/yy",
]
csv = CSV.read(file, headers: true).sort_by{|r| r.values_at(0) }
new_csv = [
  :last_name, 
  :first_name, 
  :join_date,
  :work_date,
  :email,
  :phone,
  #:phone2,
  #:address, 
  #:address2, 
  #:city,
  #:state,
  #:country,
  #:zip,
  :contact_preference,
  :date_of_birth,
  :gender,
  :status,
  :membership_agreement,
  :total_hours,
  :balance,
  :fee_status,
  :fee_paid_to_date,
  :fee_dates,
].to_csv
csv.each do |row|
  new_csv << headers.reduce([]) do |memo,header|
    memo << row[header]
  end.to_csv
end
puts new_csv
