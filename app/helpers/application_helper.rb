module ApplicationHelper
  def is_controller?(*names)
    names.include?(params[:controller])
  end

  def active_class(*names)
    is_controller?(*names) ? "active" : ""
  end

  def member_name(obj, attr=:member)
    obj.send(attr).send(:full_name)
  rescue NoMethodError
    obj.send("#{attr}_id")
  end

  def committee_name(obj, attr=:committee)
    obj.send(attr).send(:name)
  rescue NoMethodError
    obj.send("#{attr}_id")
  end

  def fee_table_tr_class(fee)
    if !fee.member.fees.membership_paid? 
      if !fee.member.fees.membership_payment_overdue?
        "fee-risk"
      else
        "fee-overdue"
      end
    else
      "fee-paid"
    end
  end

  def as_money(mny)
    "$%0.2f" % mny
  end

  def search_link(obj, field)
    value = obj.send(field)
    unless value.nil?
      if value === true
        search_value = 1
      elsif value === false
        search_value = 0
        value = "false"
      else
        search_value = value
      end
      query = URI.encode("search[%s]=%s" % [field, search_value])
      query.gsub!(/@/, '%40')
      req = URI.parse(request.url)
      if req.query
        req.query += "&#{query}"
      else
        req.query = query
      end
      link_to value, req.to_s
    end
  end

  def print_crumbs
    uri = URI.parse(request.url)
    return [] unless uri.query
    queries = uri.query.split('&').reject{|u|u[-1]=='='}
    queries.map do |q|
      tu = uri.clone
      tu.query = (queries-[q]).join('&')
      link_to "⟨ #{URI.unescape(q)}", tu.to_s
    end
  end

  def csv_link
    uri = URI.parse(request.url)
    if uri.path[/\.[a-z]+$/]
      uri.path = uri.path.sub(/\.[a-z]+$/, '.csv')
    elsif uri.path == '/'
      uri.path = '/' + params[:controller] + '.csv'
    else
      uri.path += '.csv'
    end
    uri.to_s
  end

  def furlough_show(member, furlough, opts=Hash.new)
    case furlough.type
    when "Hold" then member_hold_url(member, furlough, opts)
    when "Parental" then member_parental_url(member, furlough, opts)
    end
  end

  def furlough_edit(member, furlough, opts=Hash.new)
    case furlough.type
    when "Hold" then edit_member_hold_url(member, furlough, opts)
    when "Parental" then edit_member_parental_url(member, furlough, opts)
    end
  end

end
