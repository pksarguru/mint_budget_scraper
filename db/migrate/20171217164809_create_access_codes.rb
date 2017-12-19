class CreateAccessCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :access_codes do |t|
      t.string :body

      t.timestamps
    end
  end
end
