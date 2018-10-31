# frozen_string_literal: true

class SystemNotifier < ActionMailer::Base
  default from: 'admin@littleconsultingnj.com'
  helper :mail
  helper :silverweb_ecom_helper
  
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
