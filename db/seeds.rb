# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def generate_time_bank(member, admin)
  months = member.membership_in(:months)
  bank = (1..months).inject([]) do |m,a|
    was = Time.current - a.months
    m << {start: was, finish: was+4.hours, time_type: "greeter", admin_id: admin.id, approved: true}
  end
end

Fee.destroy_all
Committee.destroy_all
TimeBank.destroy_all
Member.destroy_all

Member.create!([
  {first_name: "John", middle_name: "Current", last_name: "Jay", email: "jj@yahoo.com", status: "active", join_date: Date.current-1.year, admin: true, date_of_birth: "1980-01-01"},
  {first_name: "Jane", middle_name: "Current", last_name: "Doe", email: "jd@gmail.com", status: "active", join_date: Date.current-1.year, admin: false, date_of_birth: "1980-02-02"},
])

john=Member.first
john.fees.create!([
  {amount: 50, creator_id: john.id, payment_type: "membership", payment_method: "cash", payment_date: Date.current-1.year},
  {amount: 25, creator_id: john.id, payment_type: "investment", payment_method: "cash", payment_date: Date.current},
])
john.committees.create!(
  {name: "Test"}
)
john.time_banks.create!(generate_time_bank(john, john))

jane=Member.second
jane.fees.create!([
  {amount: 50, creator_id: john.id, payment_type: "membership", payment_method: "cash", payment_date: Date.current-1.year},
])
jane.committees.create!(
  {name: "Test2"}
)
jane.time_banks.create!(generate_time_bank(jane, john))

