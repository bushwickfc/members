require 'csv'
class MemberCsv
  ADMINS = [
    "Amanda  Pitts",
    "Philip  Champon"
  ]
  
  def initialize(opts)
    @csv_file = opts[:csv_file] || "tmp/members-no-nl.csv"
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
      if @row[i].to_i > 0 && (date=Date.strptime(csv.headers[i], "%m/%d/%y") rescue false)
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
        last_name, first_name = member[0].split(/,\s+/)
        @member = m = Member.new(
          first_name: member["First Name"] || first_name.gsub(/[^-_A-za-z].*/, ''),
          last_name: member["Last Name"] || last_name.gsub(/[^-_A-za-z].*/, ''),
          email: (member["Email"].strip.split(/,\s*/)[0] rescue false) || "undefined@bushwickfoodcoop.com",
          phone: member["Phone"],
          phone2: member["Phone2"],
          address: member["Address"],
          address2: member["Address 2"],
          city: member["City"],
          state: member["Region (State)"],
          country: member["Country"],
          zip: member["postal (zip)"],
          contact_preference: member["Contact Preference"] =~ /[Pp]hone/ ? "phone" : "email",
          date_of_birth: (strptime("DOB") rescue '0003-03-03'),
          gender: member["Sex"] =~ /F/i ? "Female" : "Male",
          join_date: ((strptime("Join Date") rescue false) || first_work_shift),
          status: member["Member Status"].downcase.strip,
          membership_agreement: member["Membership Agreement"] =~ /y/i ? true : false,
          membership_discount: member["Low Income Verified"] =~ /y/i ? 50.0 : 0.0,
          investment_discount: member["Low Income Verified"] =~ /y/i ? 30.0 : 0.0,
        )
        m.admin = true if i==0 || ADMINS.include?(m.full_name)
        m.valid?
        if m.errors[:status].any?
          puts "#{m.full_name} #{m.status}: #{m.errors[:status]}"
          m.status = nil
        end
        if m.errors[:email].any?
          puts "#{m.full_name} #{m.email}: #{m.errors[:email]}"
          m.email = "invalid@bushwickfoodcoop.com"
        end
        m.save!
        if i == 0
          @admin = Admin.first
          create_committees
        end
        import_hours
        import_fees
      end
  end

  def create_committees
    %w[Outreach Sourcing Finance Communications Facilities Membership Orientations Governance Technology].each do |comm|
      Committee.create!(
        member: @member,
        name: comm
      )
    end

  end

  def s2time_type(h)
    @committee = nil
    str = h.sub(/.*\(([^)]+)/, '\1').split(/,\s*/)[0].strip.downcase
    hours = h.to_f
    #puts "STR #{str} // hours #{hours} // #{h}"
    if hours < 0
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
      when /tech(nology)?/i
        @committee = Committee.find_by(name: "Technology")
        "committee"
      else
        TimeBank.time_types.include?(str) ? str : "other"
      end
    end
  end

  def convert_date(date)
    date.match %r{(\d+([./-])\d+([./-])\d+)}
    d = $1
    if d =~ %r{\d+([-/.])\d+([-/.])\d{4}}
      DateTime.strptime(d, "%%m%s%%d%s%%Y" % [$1,$2])
    elsif d =~ %r{\d+([-/.])\d+([-/.])\d{2}}
      DateTime.strptime(d, "%%m%s%%d%s%%y" % [$1,$2])
    else
      DateTime.parse(d)
    end
  end

  def import_fees
    @row["Dates Paid (amount) mm/dd/yy"].to_s.split(/,\s*/).each do |fee|
      amt, date = fee.split(/\s+/)
      #puts "FEE #{fee} // #{amt} // #{date} // COL #{@row["Dates Paid (amount) mm/dd/yy"]}"
      date = date.match(/(\d+[-\/.]\d+[-\/.]\d+)/)[1] rescue nil
      next unless amt =~ /^\(\d+\)$/ && !date.nil?
      f = @member.fees.new(
        amount: amt[1..-1].to_f,
        receiver_id: @admin.id,
        payment_method: @row["Method of Payment"] =~ /check/i ? "check" : "cash",
        payment_date: convert_date(date),
        payment_type: "membership"
      )
      if f.valid? 
        f.save!
      else
        puts "ERROR: #{@member.full_name} #{t.errors.full_messages} FEE #{f.inspect}"
      end
    end
  end

  def import_hours
    (30..142).select{|i|i%2==0}.each do |i|
      if @row[i].to_i > 0 
        next unless csv.headers[i]
        date_start=date_finish=convert_date(csv.headers[i])
        #puts "ROW #{@row[i].split(/\)?,\s*/)}"
        hours = @row[i].split(/\)?,\s*/)
        hours.each do |h|
          hours = h.to_f
          date_start=date_finish
          date_finish = date_start + hours.hours
          t=@member.time_banks.new(
            start: date_start,
            finish: date_finish,
            admin: @admin,
            approved: true,
            time_type: s2time_type(h)
          )
          t.committee=@committee if t.time_type=="committee"
          if t.valid? 
            t.save!
          else
            puts "ERROR: #{@member.full_name} #{t.errors.full_messages} START #{date_start} FINISH #{date_finish} HOURS #{hours} // COL #{@row[i]} // TIMEBANK #{t.inspect}"
          end
        end
      end
    end
  end

end

m=MemberCsv.new(csv_file: ARGV[0])
m.import_members
