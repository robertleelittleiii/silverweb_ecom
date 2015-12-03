class ProductRelatedProduct < ActiveRecord::Base
  belongs_to :product
  has_one :related_product, class_name: "Product",
                          foreign_key: "id",
                          primary_key: "related_product_id"
                        
  def self.reorder(id,position)
    puts(id, position)
    ActiveRecord::Base.connection.execute ("UPDATE `product_related_products` SET `position` = '"+position.to_s+"' WHERE `product_related_products`.`id` ="+id.to_s+" LIMIT 1 ;")
  end
end
