class Admin < Member
  #TODO: ensure only admins can become Admin

  default_scope { where(admin: true) }
end
