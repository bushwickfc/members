#!/usr/bin/env rails runner 
require 'csv'

headers = [
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
  :status,
  :membership_agreement,
  :total_hours,
  :balance,
  :fee_status,
  :fee_paid_to_date,
  :fee_dates,
]
new_csv = headers.to_csv

Member.all.includes(:fees, :time_banks).order(:last_name, :first_name).each do |m|
  i=0
  new_csv << headers.reduce([]) do |memo,header|
    if i <= 10
      memo << m.attributes[header.to_s]
    else
      memo << case header
      when :total_hours then m.time_banks.hours_worked
      when :balance then m.time_banks.balance
      when :fee_status then m.fees.membership_paid?
      when :fee_paid_to_date then m.fees.membership_payment_total
      when :fee_dates then m.fees.membership_payment.collect(&:payment_date).join(', ')
      end
    end
    i+=1
    memo
  end.to_csv
end

puts new_csv
