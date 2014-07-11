require 'csv' # adds a .to_csv method to Array instances

class Array 
  alias old_to_csv to_csv #keep reference to original to_csv method

  def to_csv(options = Hash.new)
    # override only if first element actually has as_csv method
    return old_to_csv(options) unless self.first.respond_to? :as_csv
    # use keys from first row as header columns
    out = first.as_csv.keys.to_csv(options)
    self.each { |r| out << r.as_csv.values.to_csv(options) }
    out
  end
end

class ActiveRecord::Base
  def to_csv(options = Hash.new)
    out = attributes.keys.to_csv(options)
    out << attributes.values.to_csv(options)
  end

  def as_csv
    attributes
  end
end

ActionController::Renderers.add :csv do |csv, options|
  o = options.reject{|k,v| [:prefixes, :template, :layout].include?(k) }
  csv = csv.respond_to?(:to_csv) ? csv.to_csv(o) : csv
  self.content_type ||= Mime::CSV
  self.response_body = csv
end
