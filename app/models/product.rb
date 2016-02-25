class Product < ActiveRecord::Base
  has_many :product_details, dependent: :destroy
  belongs_to :supplier
  has_many :pictures,  -> { order(position: :asc) },  dependent: :destroy, as: :resource
  has_one :order_item
  has_many :related, dependent: :destroy, class_name: "ProductRelatedProduct", foreign_key: "product_id"
  
   acts_as_taggable_on :category, :department
   
  
    scope :by_search_term, lambda {|q|  
    where("product_active=true and (product_name LIKE ? or product_description LIKE ? or sheet_name LIKE ? or search_terms LIKE ?)", "%#{q}%", "%#{q}%", "%#{q}%","%#{q}%").order("product_ranking DESC").order("created_at DESC")
    }
    
  validates_uniqueness_of :supplier_product_id, allow_nil: true, message: "Supplier Product ID must be unique!!"

   def self.find_or_create(attributes)
    Product.where(attributes).first || Product.create(attributes)
  end
  
  def self.key_field
    return "supplier_product_id"
  end
  
  
  
  def price
    if discount_available then
      return msrp.to_f - ((discount.to_f/100) * msrp.to_f)
    else
      return msrp
    end
  end
  
  def primary_image 
    self.pictures.where(title: "Primary").first
  end
  
  def product_list_image
        self.pictures.where(title: "Product List").first
  end
  
  def slider_image
        self.pictures.where(title: "Slider").first 
  end
  
  
  def next_in_collection 
    product_list = Product.tagged_with([self.category[0].name], on: :category).order(:position)
    product_list.index(self)
    if product_list.last == self then
      return product_list.first

      else
        return product_list[product_list.index(self) + 1 ]
    end
  end
  
  def previous_in_collection
    product_list = Product.tagged_with([self.category[0].name], on: :category).order(:position)
    product_list.index(self)
    if product_list.first == self then
      return product_list.last
      else
        return product_list[product_list.index(self) - 1 ]
    end
  end
end
