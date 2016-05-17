require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.day, 'Update status cache, for all members not suspended', at: ['11:55']) do
  UpdateMemberStatus.perform_async
end

#every(1.day, 'Import fee payments', at: ['01:00']) do
  #ImportFees.perform_async
#end

# on the first of the month
every(1.day, 'Set hold and parental leaves in time bank', if: lambda{|t| t.day == 1}, at: ['04:00']) do
  UpdateHoldsAndLeaves.perform_async
end

