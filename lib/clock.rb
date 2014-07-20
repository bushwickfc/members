require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

include Clockwork


every(1.day, 'Import fee payments', at: ['00:00']) do
  ImportFees.perform_async
end

every(1.month, 'Set hold and parental leaves in time bank', at: ['00:00']) do
  UpdateHoldsAndLeaves.perform_async
end

