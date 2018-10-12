# frozen_string_literal: true

class Retailer < ActiveRecord::Base
  geocoded_by :address
  before_update :geocode

  def address
    [company_street_1, company_street_2, company_city, company_state, company_zip].compact.join(', ')
   end
end
