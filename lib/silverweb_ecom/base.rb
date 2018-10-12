# frozen_string_literal: true

module SilverwebEcom
  module Config
    @PRODUCT_LIST_LAYOUTS = nil

    def self.PRODUCT_LIST_LAYOUTS
      @PRODUCT_LIST_LAYOUTS
    end

    def self.load_product_list_layouts
      @PRODUCT_LIST_LAYOUTS = [['Default', '']]
    end

    def self.add_product_list_layouts(product_list_layout_item)
      @PRODUCT_LIST_LAYOUTS << product_list_layout_item
    end
  end
end

SilverwebEcom::Config.load_product_list_layouts
