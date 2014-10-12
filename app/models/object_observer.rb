class ObjectObserver < ActiveRecord::Observer
  observe :member

  def after_save(record)
    return unless record.changes[:status]
    record.events.create(data: record.changes[:status][0])
  end
end
