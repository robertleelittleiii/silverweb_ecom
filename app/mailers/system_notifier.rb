# frozen_string_literal: true

class SystemNotifier < ActionMailer::Base
  default from: 'admin@littleconsultingnj.com'
  helper :mail
  helper :silverweb_ecom
  
  include SilverwebEcomHelper
  add_template_helper SilverwebEcomHelper
  
  def display_page_body(page_name)
    page = begin
      Page.where(title: page_name).first
    rescue StandardError
      ''
    end

    begin
      return page.body.html_safe
    rescue StandardError
      "Page '#{page_name}' not found.   Please create it in pages."
    end
  end
    
  def purchase_fail_notification(order, user, host)
    @hostfull = host
    # attachments.inline['logo-100.png'] = File.read('public/images/site/logo-100.png')

    @user = user
    @order = order
    @hostfull = host
    @admin_email = Settings.admin_email || default_params[:from]
    @host = host

    mail(from: @admin_email, to: @admin_email, subject: 'Order: Gateway error notification. !!')
  end
end
