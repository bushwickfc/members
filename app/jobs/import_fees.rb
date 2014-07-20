class ImportFees
  include Sidekiq::Worker
  sidekiq_options queue: :fees, retry: true, backtrace: true, failures: true 

  def initialize
    super
    configure_pos
  end

  def perform

  end

  def configure_pos
    config_name = "pos_#{Rails.env}".to_sym
    conf = ActiveRecord::Base.configurations[config_name]
    ActiveRecord::Base.establish_connection(conf)
  end
end
