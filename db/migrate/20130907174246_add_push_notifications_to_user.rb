class AddPushNotificationsToUser < ActiveRecord::Migration
  def change
    add_column :users, :push_notifications, :boolean
  end
end
