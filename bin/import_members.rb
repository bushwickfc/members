require 'csv'
class MemberCsv
  ADMINS = [
    "Amanda Pitts",
    "Philip Champon"
  ]
  
  def initialize(opts)
    @csv_file = opts[:csv_file] || "tmp/members.csv"
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
    (31..141).each do |i|
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
    elsif date =~ %r{\d+([-/.])\d+([-/.])\d{4}}
      Date.strptime(date, "%%m%s%%d%s%%Y" % [$1,$2])
    elsif date =~ %r{\d+([-/.])\d+([-/.])\d{2}}
      Date.strptime(date, "%%m%s%%d%s%%y" % [$1,$2])
    else
      Date.parse(date)
    end
  end

  def import_members
    Member.transaction do
      each_with_index do |member,i|
        last_name, first_name = member[0].split(/,\s+/)
        @member = m = Member.new(
          first_name: member["First Name"] || first_name.gsub(/[^-_A-za-z].*/, ''),
          last_name: member["Last Name"] || last_name.gsub(/[^-_A-za-z].*/, ''),
          email: (member["Email"].strip rescue false) || "undefined@bushwickfoodcoop.com",
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
        m.save
        @admin = Admin.first if i==0
        create_committees if m.full_name == "Amanda Pitts"
      end
    end
  end

  def create_committees
    %w[Distro Outreach Sourcing Communications Orientations Governance].each do |comm|
      Committee.create(
        member: @member,
        name: comm
      )
    end

  end

  def committees
    @committees ||= Committee.scoped
  end

  def s2time_type
    @committee = nil
    case h.sub(/.*\(\([^)]+)\)/, '\1').split(/,\s*/)[0]
    when /(annual\s+)?(meeting|mtg)/i, /(gen(eral)?\s+)?(meeting|mtg)/i, /summit/i
      "meeting"
    when /orientation/i, /O/i
      "orientation"
    when /comm(s|unications?)/i
      @committee = @committees.find_by(name: "Communications").first
      "committee"
    else
      "other"
    end
  end

  def import_hours
    (31..141).each do |i|
      if @row[i].to_i > 0 
        date_start=date_finish=DateTime.strptime(csv.headers[i], "%m/%d/%y")
        hours = @row[i].split(/,\s*/)
        hours.each do |h|
          hours = h.to_f
          work_type = h.sub(/.*\(\([^)]+)\)/, '\1').split(/,\s*/)[0]
          date_start=date_finish
          date_finish = date+hours.hours
          t=@member.time_banks.new(
            start: date_start,
            finish: date_finish,
            admin: @admin,
            approved: true,
            time_type: s2time_type(h)
          )
          t.committee=@committee if t.time_type=="committee"
          if t.valid? 
            t.save
          else
            puts "ERROR: #{@member.full_name} #{t.errors.full_messages}"
          end
        end
      end
    end
  end

end

m=MemberCsv.new(csv_file: ARGV[0])
m.import_members
