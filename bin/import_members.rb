#!/usr/bin/env rails runner
require 'csv'
class MemberCsv
  ADMINS = [
    "Amanda Pitts",
    "Philip Champon",
    "Rachel Garcia-Grossman",
    "Karim Tabbaa",
    "Maggie Herskovits",
    "Christina Robertson",
    "Kira Josefsson",
    "Gwen Schantz",
    "Kristin Caringer",
    "Valerie Di veglio",
    "Leighton Edmondson",
    "Mark Gering",
  ]
  COMMITTEES = %w[
    Outreach
    Sourcing
    Finance
    Communications
    Facilities
    Membership
    Orientations
    Governance
    Technology
  ]
  COMMITTEE_HEADS = [
    "",
    "Rachel Garcia-Grossman",
    "Valerie Di Veglio",
    "Kristin Caringer",
    "Leighton Edmondson",
    "Maggie Herskovits",
    "",
    "Kira Josefsson",
    "Philip Champon",
  ]
  
  def initialize(opts)
    @csv_file = opts[:csv_file] || "tmp/members-0715-nonl.csv"
  end

  def csv
    @csv ||= CSV.read(@csv_file, headers: true)
  end

  def each_with_index
    csv.each_with_index do |member, i|
      @row = member
      yield member, i
    end
  end

  def first_work_shift
    (30..142).select{|i|i%2==0}.each do |i|
      if @row[i].to_i != 0 && (date=Date.strptime(csv.headers[i], "%m/%d/%y") rescue false)
        return date
      end
    end
    nil
  end
  
  def strptime(field)
    date = @row[field]
    if date.nil?
      if field=="Join Date"
        first_work_shift || "0002-02-02"
      else
        "0001-01-01"
      end
    else
      convert_date(date)
    end
  end

  def import_members
    each_with_index do |member,i|
      last_name, first_name = member[0].split(/[,;]\s+/)
      work_date = strptime("JOIN/WF Date (work cycle count start date)").split(/,\s*/)[-1].split('-')[-1]  rescue false
      join_date = (
        (strptime("Join Date") rescue false) || 
        first_work_shift
      )
      if join_date && !work_date
        work_date = join_date
      elsif !join_date && work_date
        join_date = work_date
      end
      fname = (member["First Name"] || first_name.gsub(/[^-_A-za-z].*/, '')).strip.capitalize rescue nil
      lname = (member["Last Name"] || last_name.gsub(/[^-_A-za-z].*/, '')).strip.capitalize rescue nil
      email = (member["Email"].strip.split(/,\s*/)[0] rescue false) || "undefined@bushwickfoodcoop.com"
      phone = (member["Phone"].gsub(/[^\d]/, '') rescue nil)
      phone2= (member["Phone2"].gsub(/[^\d]/, '') rescue nil)
      @member = m = Member.new(
        first_name: fname,
        last_name: lname,
        email: email,
        phone: phone,
        phone2: phone2,
        address: member["Address"],
        address2: member["Address 2"],
        city: member["City"],
        state: member["Region (State)"],
        country: member["Country"],
        zip: member["postal (zip)"],
        contact_preference: member["Contact Preference"] =~ /[Pp]hone/ ? "phone" : "email",
        date_of_birth: (strptime("DOB") rescue nil),
        gender: member["Sex"] =~ /F/i ? "Female" : "Male",
        join_date: join_date,
        work_date: work_date,
        status: member["Member Status"].downcase.strip,
        membership_agreement: member["Membership Agreement"] =~ /y/i ? true : false,
        membership_discount: member["Low Income Verified"] =~ /y/i ? 50.0 : 0.0,
        investment_discount: member["Low Income Verified"] =~ /y/i ? 30.0 : 0.0,
        password: "pickleBFC",
        password_confirmation: "pickleBFC",
      )
      m[:admin] = ADMINS.include?(m.full_name)
      m[:created_at] = m.join_date
      m[:join_date] = nil if m.status == 'interested' || m.status == 'volunteer'
      m.valid? || puts("ERROR MEMBER #{m.full_name} #{m.status}: #{m.errors.full_messages}")
      if m.errors[:status].any?
        m.status = nil
      end
      if m.errors[:email].any?
        m.email = "invalid@bushwickfoodcoop.com"
      end
      m.save!
      puts "MEMBER SAVED #{m.inspect}"
      if i == 0
        @admin = Admin.first
        create_committees
      end
      import_hours
      import_fees
    end
  end

  def create_committees
    COMMITTEES.each do |comm|
      Committee.create!(
        member: @member,
        name: comm
      )
    end

  end

  def s2time_type(hr_string, hours)
    @committee = nil
    str = hr_string.sub(/.*\(([^)]+)/, '\1').split(/,\s*/)[0].strip.downcase
    #puts "STR #{str} // hours #{hours} // #{hr_string}"
    if hours < 0.0
      if str =~ /gift/
        "gift_given"
      else
        "penalty"
      end
    elsif str =~ /gift/
      "gift_received"
    else
      case str
      when /(annual\s+)?(meeting|mtg)/i, /(gen(eral)?\s+)?(meeting|mtg)/i, /summit/i
        "meeting"
      when /orientation/i, /^O$/
        "orientation"
      when /comm(s|unications?)/i
        @committee = Committee.find_by(name: "Communications")
        "committee"
      when /facilities/i, /paint/i
        @committee = Committee.find_by(name: "Facilities")
        "committee"
      when /finance/i
        @committee = Committee.find_by(name: "Finance")
        "committee"
      when /gov(ernance)?/i
        @committee = Committee.find_by(name: "Governance")
        "committee"
      when /membership/i
        @committee = Committee.find_by(name: "Membership")
        "committee"
      when /orientations/i
        @committee = Committee.find_by(name: "Orientations")
        "committee"
      when /outreach/i
        @committee = Committee.find_by(name: "Outreach")
        "committee"
      when /sourcing/i
        @committee = Committee.find_by(name: "Sourcing")
        "committee"
      when /(\bit\b|tech(nology)?)/i
        @committee = Committee.find_by(name: "Technology")
        "committee"
      else
        TimeBank.time_types.include?(str) ? str : "other"
      end
    end
  end

  def convert_date(date)
    return date if date.respond_to?(:day)
    date.match %r{(\d+([./-])\d+([./-])\d+)}
    d = $1
    if d =~ %r{\d+([-/.])\d+([-/.])\d{4}}
      DateTime.strptime(d, "%%m%s%%d%s%%Y" % [$1,$2])
    elsif d =~ %r{\d+([-/.])\d+([-/.])\d{2}}
      DateTime.strptime(d, "%%m%s%%d%s%%y" % [$1,$2])
    else
      puts "ERROR DIFFERENT DATE #{date} // #{d}"
      DateTime.parse(d)
    end
  rescue TypeError, NoMethodError
    nil
  end

  def import_fees
    @row["Dates Paid (amount) mm/dd/yy"].to_s.split(/[,;]\s*/).each do |fee|
      amt, date = fee.split(/\s+/)
      #puts "FEE #{fee} // #{amt} // #{date} // COL #{@row["Dates Paid (amount) mm/dd/yy"]}"
      date = date.match(/(\d+[-\/.]\d+[-\/.]\d+)/)[1] rescue nil
      int_amt = amt[/\d+/].to_f
      if int_amt == 0 || date.nil?
        if @row["Fee Paid to Date"].to_f != 0.0 
          int_amt = @row["Fee Paid to Date"].to_f
          date = @member.join_date
        else
          puts "ERROR SKIPPING FEE #{fee} // #{int_amt} // #{date}"
          next
        end
      end
      f = @member.fees.new(
        amount: int_amt,
        creator_id: @admin.id,
        payment_method: @row["Method of Payment"] =~ /check/i ? "check" : "cash",
        payment_date: convert_date(date),
        created_at: convert_date(date),
        payment_type: "membership"
      )
      if f.valid? 
        f.save!
      else
        puts "ERROR FEE #{@member.full_name} #{f.errors.full_messages} FEE #{f.inspect}"
      end
    end
  end

  def create_time_bank(col, type, date_start, date_finish)
    t=@member.time_banks.new(
      start: date_start,
      created_at: date_start,
      finish: date_finish,
      admin: @admin,
      approved: true,
      time_type: type
    )
    t.committee=@committee if t.time_type=="committee"
    if t.valid? 
      t.save!
    else
      puts "ERROR TIME_BANK: #{@member.full_name} #{t.errors.full_messages} START #{date_start} FINISH #{date_finish} // COL #{col} // TIMEBANK #{t.inspect}"
    end

  end

  def import_hours
    (30..142).select{|i|i%2==0}.each do |i|
      next if csv.headers[i].nil? || @row[i].nil?
      date_start=date_finish=convert_date(csv.headers[i])
      #puts "ROW #{@row[i].split(/\)?,\s*/)}"
      if @row[i][/^hold$/i]
        date_finish += @member.monthly_hours.hours
        create_time_bank(@row[i], "hold", date_start, date_finish)
      else
        hours_split = @row[i].split(/\)?,\s*/)
        hours_split.each do |h|
          hours = h.to_f
          if hours == 0.0
            puts "ERROR SKIPPING TIME_BANK: #{@member.full_name} // COL #{@row[i]} // HOURS #{hours} // h #{h}"
            next
          end
          #puts "HH #{h} // #{hours}"
          date_start=date_finish
          date_finish = (date_start + hours.hours rescue date_start)
          create_time_bank(@row[i], s2time_type(h, hours), date_start, date_finish)
        end
      end
    end
  end

  def fix_committees
    Committee.all.each_with_index do |c, i|
      head = COMMITTEE_HEADS[i].split(/\s+/, 2)
      member = Member.find_by(first_name: (head[0].strip rescue ""), last_name: (head[1].strip rescue ""))
      if head.blank? || member.nil?
        puts "ERROR SKIPPING COMMITTEE #{c.inspect} // #{COMMITTEE_HEADS[i]} // #{head} // #{member.inspect}"
        next
      end
      c.member = member
      if c.save
        puts "COMMITTEE SAVED #{c.inspect}"
        TimeBank.where(committee_id: c.id).update_all(admin_id: member.id)
      else
        puts "ERROR COMMITTEE #{c.inspect} // #{c.errors.full_messages}"
      end
    end

  end

end

m=MemberCsv.new(csv_file: ARGV[0])
m.import_members
m.fix_committees

aid = Admin.first.id
Member.joins(:time_banks).merge(TimeBank.where(time_type:"hold")).group(:member_id).each do |member|
  start = finish = nil
  member.time_banks.where(time_type: "hold").order(:start).each do |t|
    puts "#{t.inspect} // #{start} // #{finish}"
    if start.nil?
      finish = start = t.start
    else
      diff = ((finish - t.start)/60/60/24).to_i
      puts "DIFF #{diff}"
      if diff > -60 && diff <= 0
        finish = t.finish
      else
        member.holds.create(start: start, finish: finish.end_of_month, creator_id: aid)
        finish = start = t.start
      end
    end
  end
  if start
    if start == finish
      finish = finish+1.month 
    else
      finish = finish.end_of_month
    end
    member.holds.create(start: start, finish: finish, creator_id: aid)
  end
end

