# frozen_string_literal: true

module SilverwebEcom
  class Railtie < Rails::Railtie
    #    initializer "silverweb_portfolio.action_controller" do
    #      ActiveSupport.on_load(:action_controller) do
    #        puts "Extending #{self} with silverweb_portfolio"
    #        # ActionController::Base gets a method that allows controllers to include the new behavior
    #        include SilverwebPortfolio::ControllerExtensions # ActiveSupport::Concern
    #        config.to_prepare do
    #      SiteController.send(:include, SilverwebPortfolio::ControllerExtensions::SiteControllerExtensions)
    #    end
    #      end
    #    end

    # The block you pass to this method will run for every request in
    # development mode, but only once in production.

    initializer 'silverweb_ecom.update_user_notifier' do
      UserNotifier.class_eval do
        
        helper :silverweb_ecom
        include SilverwebEcomHelper
        add_template_helper SilverwebEcomHelper

        
        def inventory_alert(product_detail, host)
          set_up_images
          @hostfull = host
          @host = host
          @user = Settings.inventory_email
          @admin_email = Settings.admin_email || default_params[:from]
          @product_detail = ProductDetail.find(product_detail.id)
          @cc_emai_address = Settings.cc_email_address || ''.dup

          mail(to: @user, cc: @cc_emai_address, subject: "Inventory Warning for #{@product_detail.inventory_key}")
        end

        def shipment_notification(order, user, _message, host)
          set_up_images
          @site_name = Settings.company_url
          @hostfull = host

          setup_email(user)
          subject 'Your shipment has been sent'
          body(order: order, user: user, url_base: 'http://locathost:3000/grants/show')
          content_type 'text/html' # Here's where the magic happens
        end

        def order_notification_as_invoice(order, user, host)
          set_up_images

          @page_title = 'order success'
          @page = Page.find_by_title @page_title.first

          @company_name = Settings.company_name
          @company_address = Settings.company_address
          @company_phone = Settings.company_phone
          @company_fax = Settings.company_fax

          @user = user
          @order = order

          #    @order.order_items.each do |order_item|
          #       attachments.inline["#{order_item.id}.png"] = (File.read(Rails.root.to_s + "/public/" + order_item.product_detail.thumb.to_s) rescue "blank.png")
          #     end

          @order.order_items.each do |order_item|
            image_path = order_item.product_detail.thumb.to_s
            attachments.inline["#{order_item.id}.#{image_path.split('.').last}"] = (begin
                File.read(Rails.root.to_s + '/public/' + image_path)
              rescue StandardError
                'blank.png'
              end)
          end

          @hostfull = host
          @site_slogan = begin
            Settings.site_slogan
          rescue StandardError
            ''.dup
          end
          @site_name = begin
            Settings.site_name
          rescue StandardError
            'Our Site'
          end
          @admin_email = Settings.admin_email || default_params[:from]
          @cc_emai_address = Settings.cc_email_address || @admin_email

          puts("@hostfull: #{@hostfull}")

          mail(from: @admin_email, cc: @cc_emai_address, to: "#{begin
            user.user_attribute.first_name
            rescue StandardError
            ''
            end} #{begin
            user.user_attribute.last_name
            rescue StandardError
            ''
            end}<#{user.name}>", subject: 'Thank you for your order !!')
        end

        def order_notification(order, user, host)
          set_up_images

          @user = user
          @order = order
          @hostfull = host
          @site_slogan = begin
            Settings.site_slogan
          rescue StandardError
            ''.dup
          end
          @site_name = begin
            Settings.site_name
          rescue StandardError
            'Our Site'
          end
          @admin_email = Settings.admin_email || default_params[:from]
          @cc_emai_address = Settings.cc_email_address || @admin_email

          mail(from: @admin_email, cc: @cc_emai_address, to: "#{begin
            user.user_attribute.first_name
            rescue StandardError
            ''
            end} #{begin
            user.user_attribute.last_name
            rescue StandardError
            ''
            end}<#{user.name}>", subject: 'Thank you for your order !!')
        end
      end
    end

    initializer 'silverweb_ecom.update_picture_model' do
      SilverwebCms::Config.add_nav_item(name: 'Products', controller: 'products', action: 'index')
      SilverwebCms::Config.add_nav_item(name: 'My Orders', controller: 'orders', action: 'user_orders')
      SilverwebCms::Config.add_nav_item(name: 'Store Orders', controller: 'orders', action: 'index')
      SilverwebCms::Config.add_nav_item(name: 'Retail', controller: 'retailers', action: 'index')

      SilverwebCms::Config.add_menu_class(['Show Products', 'menu_show_products'])

      # SilverwebCms::Config.add_menu_class(["Show Products with Page","menu_show_products_with_page"])

      # SilverwebCms::Config.add_menu_actions(["Show Portfolio",20])

      Picture.class_eval do
        belongs_to :product, polymorphic: true, optional: true
      end

      User.class_eval do
        has_many :orders

        has_many :coupon_usages
      end

      # Add taggability on this menu
      Menu.class_eval do
        acts_as_taggable_on :category, :department
      end

      ImageUploader.class_eval do
        version :swatch do
          process cropper: [30, 30]
        end

        version :collection_list do
          process resize_to_fill: [90, 140]
        end

        version :product_list, if: :not_pdf? do
            process resize_to_fill: [188, 141]
          end

          version :store_list do
            process resize_to_fill: [77, 125]
          end

          version :store_list_mm do
            process resize_to_fill: [115, 180]
          end

          version :store_list_horizontal do
            process resize_to_limit: [237, 171]
          end

          version :small_h do
            process resize_to_fill: [100, 65]
          end

          version :view do
            process resize_to_fill: [320, 441]
            # process :outliner
          end

          version :view_h do
            process resize_to_fill: [691, 472]
            #  process :outliner
          end

          version :primary do
            process resize_to_fill: [250, 410]
            #  process :resize_to_limit => [270, 410]
            #  process :cropper=>[250,410]
            #  process :outliner
          end

          version :slider do
            process resize_to_fill: [300, 185]
            #  process :outliner
          end
          #
          #        version :artifact_slider do
          #          process :resize_to_fill => [885, 600]
          #        end
          #
          #        version :artifact_custom_slider do
          #          process :resize_to_limit => [600, 615]
          #        end
          #
          #        version :artifact_before do
          #          process :resize_to_limit => [375, 255]
          #        end
          #
          #        version :artifact_list do
          #          process :resize_to_fill => [180, 130]
          #        end
          #
          #
        end
      end

      #    initializer "silverweb_portfolio.update_menu_defs" do
      #      MenusController::MENU_TYPES << ["Portfolio",6]
      #      MenusController::ACTION_TYPES << ["Show Portfolio",20]
      #    end

      config.to_prepare do
        SiteController.send(:include, SilverwebEcom::ControllerExtensions::SiteControllerExtensions)
        MenusController.send(:include, SilverwebEcom::ControllerExtensions::MenusControllerExtensions)
      end

      initializer 'silverweb_ecom.add_user_pref_panes' do
        SilverwebCms::Config.add_user_pref_pane('user_addresses')

        SilverwebCms::Config.add_user_attribute_permitted_fields('shipping_address')
        SilverwebCms::Config.add_user_attribute_permitted_fields('shipping_city')
        SilverwebCms::Config.add_user_attribute_permitted_fields('shipping_state')
        SilverwebCms::Config.add_user_attribute_permitted_fields('shipping_zip_code')
        SilverwebCms::Config.add_user_attribute_permitted_fields('billing_address')
        SilverwebCms::Config.add_user_attribute_permitted_fields('billing_city')
        SilverwebCms::Config.add_user_attribute_permitted_fields('billing_state')
        SilverwebCms::Config.add_user_attribute_permitted_fields('billing_zip_code')
      end
    end
  end
