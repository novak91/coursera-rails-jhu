class TodoItem < ActiveRecord::Base
  def self.count_completed
    TodoItem.where(completed: true).count
  end
end