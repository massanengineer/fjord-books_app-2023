class ChangeToTitleNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :reports, :title, false
  end
end
