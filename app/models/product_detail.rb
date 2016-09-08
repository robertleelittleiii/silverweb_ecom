class ProductDetail < ActiveRecord::Base
  belongs_to :product

  #has_one :order_item
  validates_uniqueness_of :inventory_key, allow_nil: true, message: "Inventory Key must be Unique!!"

  def self.find_or_create(attributes)
    ProductDetail.where(attributes).first || ProductDetail.create(attributes)
  end
  
  def self.key_field
    return "inventory_key"
  end
  
  def swatch
    if (!!Settings.force_system_swatches)
      SystemImages.all.where(title: self.color).first.image_url.to_s
    else
      begin 
        self.product.pictures.where(title: self.color).first.image_url(:swatch).to_s 
      rescue 
        begin
          SystemImages.all.where(title: self.color).first.image_url.to_s
        rescue 
           ActionController::Base.helpers.asset_path("blank.png")
#        "blank.png"
        end
      end
    end

  end
  
  def thumb
    #self.product.pictures.where(:title=>self.color, :active_flag=>true).first.image_url(:thumb).to_s rescue "/images/site/blank.png"

    begin 
      self.product.pictures.where(title: self.color).first.image_url(:thumb).to_s 
    rescue 
      #begin
      #  self.product.pictures.first.image_url(:thumb).to_s
      #rescue 
      begin
        SystemImages.all.where(title: self.color).first.image_url(:thumb).to_s
      rescue 
                ActionController::Base.helpers.asset_path("blank.png")

      #  "/images/site/blank.png"
      end
      # end
    end

  end

  def colorpattern
    
  end
  
  def medium
    self.product.pictures.where(title: self.color).first.image_url(:medium).to_s rescue "/images/site/blank.png"

  end
  
  def small
    #  self.product.pictures.where(:title=>self.color).first.image_url(:small).to_s rescue "/images/site/blank.png"
    begin 
      self.product.pictures.where(title: self.color).first.image_url(:small).to_s 
    rescue 
      begin
        SystemImages.all.where(title: self.color).first.image_url(:small).to_s
      rescue 
        ActionController::Base.helpers.asset_path("blank.png")
        # "/images/blank.png"
      end
    end
  end
  
  def reduce_inventory (sold_count, host) 
    self.units_in_stock = self.units_in_stock - sold_count
    self.save

    if self.units_in_stock.to_i < (self.product.reorder_level.to_i + 1) then
      UserNotifier.inventory_alert(self, host).deliver
    end
  end
end
