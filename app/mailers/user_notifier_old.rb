# frozen_string_literal: true

class UserNotifierOld < ActionMailer::Base
  default from: 'admin@littleconsultingnj.com'
  helper :silverweb_ecom
  
  def signup_notification(user, siteurl)
    set_up_images
    @hostfull = siteurl
    setup_email(user)
    subject 'Please activate your new account'
    body(user: user, hostfull: @hostfull)
    content_type 'text/html'   # Here's where the magic happens
  end

  def inventory_alert(product_detail, host)
    set_up_images
    @hostfull = host
    @host = host
    @user = Settings.inventory_email
    @admin_email = Settings.admin_email || default_params[:from]
    @product_detail = ProductDetail.find(product_detail.id)

    mail(to: @user, subject: "Inventory Warning for #{@product_detail.inventory_key}")
  end

  def signup_notification(user, host)
    set_up_images

    @user = user
    @hostfull = host
    @admin_email = Settings.admin_email || default_params[:from]
    @site_name = Settings.company_url
    mail(from: @admin_email, to: "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", subject: 'Welcome to Our Store!!')
  end

  def reset_notification(user, host)
    set_up_images
    puts("Self: #{default_params[:from]}")
    @user = user
    @hostfull = host
    @site_name = Settings.company_url
    @admin_email = Settings.admin_email || default_params[:from]
    mail(from: @admin_email, to: "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", subject: 'Reset your password')
  end

  def signup_notification2(user, siteurl)
    set_up_images
    @hostfull = siteurl
    @site_name = Settings.company_url
    setup_email(user)
    subject 'Please activate your new account'
    body(user: user, hostfull: @hostfull)
    content_type 'text/html'   # Here's where the magic happens
  end

  def activation(user)
    set_up_images
    setup_email(user)
    @site_name = Settings.company_url
    @subject += 'Your account has been activated!'
    @body = @site_name.to_s
    @site_name = Settings.company_url
  end

  def reset_notification2(user, siteurl)
    set_up_images
    @hostfull = siteurl
    @site_name = Settings.company_url
    setup_email(user)
    subject 'Link to reset your password'
    body(user: user, hostfull: @hostfull)
    content_type 'text/html'   # Here's where the magic happens
  end

  def lostwithemail(user, host)
    set_up_images
    @user = user
    @hostfull = host
    @site_name = Settings.company_url
    @admin_email = Settings.admin_email || default_params[:from]

    mail(from: @admin_email, to: "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", subject: 'Activation for squirtinibikini.com!!')
  end

  def shipment_notification(order, user, _message, host)
    set_up_images
    @site_name = Settings.company_url
    @hostfull = host

    setup_email(user)
    subject 'Your shipment has been sent'
    body(order: order, user: user, url_base: 'http://locathost:3000/grants/show')
    content_type 'text/html'   # Here's where the magic happens
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

    @order.order_items.each do |order_item|
      image_path = order_item.product_detail.thumb.to_s
      attachments.inline["#{order_item.id}.#{image_path.split('.').last}"] = File.read(Rails.root.to_s + '/public/' + image_path)
    end
    puts(attachments.inspect)

    @hostfull = host
    @site_slogan = begin
                     Settings.site_slogan
                   rescue StandardError
                     ''
                   end
    @site_name = begin
                   Settings.site_name
                 rescue StandardError
                   'Our Site'
                 end
    @admin_email = Settings.admin_email || default_params[:from]

    puts("@hostfull: #{@hostfull}")

    mail(from: @admin_email, cc: @admin_email, to: "#{begin
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
                   ''
                 end
    @site_name = begin
                 Settings.site_name
               rescue StandardError
                 'Our Site'
               end
    @admin_email = Settings.admin_email || default_params[:from]

    mail(from: @admin_email, cc: @admin_email, to: "#{begin
                                                           user.user_attribute.first_name
                                                         rescue StandardError
                                                           ''
                                                         end} #{begin
                                                                                                       user.user_attribute.last_name
                                                                                                     rescue StandardError
                                                                                                       ''
                                                                                                     end}<#{user.name}>", subject: 'Thank you for your order !!')
   end

  protected

  def set_up_images
    attachments.inline['logo-100.png'] = File.read(Rails.root.to_s + '/app/assets/images/site/logo-100.png')
  end

  def setup_email(user)
    @recipients  = user.name.to_s
    @from        = 'admin@squirtinibikini.com'
    @subject     = '[mysite]'
    @sent_on     = Time.now
    @body = user.name
  end
end
