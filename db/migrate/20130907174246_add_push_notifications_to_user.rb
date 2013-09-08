class AddPushNotificationsToUser < ActiveRecord::Migration
  def change
    add_column :users, :push_notifications, :boolean
    add_column :users, :device_token, :string
  end
end
