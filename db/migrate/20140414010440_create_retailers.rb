class CreateRetailers < ActiveRecord::Migration
  def self.up
    if not ActiveRecord::Base.connection.table_exists? 'retailers' then
      create_table :retailers do |t|
        t.string :company_name
        t.string :company_street_1
        t.string :company_street_2
        t.string :company_city
        t.string :company_state
        t.string :company_zip
        t.string :company_phone
        t.string :company_website
        t.string :company_hours_1
        t.string :company_hours_2
        t.string :company_hours_3
        t.float :latitude
        t.float :longitude
        t.timestamps
      end
    end
  end

  def self.down
    if  ActiveRecord::Base.connection.table_exists? 'retailers' then
      drop_table :retailers
    end
  end
end
