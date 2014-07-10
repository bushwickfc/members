module ApplicationHelper
  def is_controller?(*names)
    names.include?(params[:controller])
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

end
