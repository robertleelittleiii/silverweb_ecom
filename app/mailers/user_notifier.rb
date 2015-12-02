class UserNotifier < ActionMailer::Base
  default :from=>"admin@littleconsultingnj.com"

  
  def signup_notification(user, siteurl)
    @hostfull=siteurl
    setup_email(user)
    subject 'Please activate your new account'
    body(:user=>user, :hostfull=>@hostfull)
    content_type "text/html"   #Here's where the magic happens

    #@body  = siteurl.gsub(%r{</?[^>]+?>}, '')+"activate/#{user.activation_code}"
  end
  
  def inventory_alert(product_detail, host)
    @hostfull=host
    #  attachments.inline['logo-100.png'] = File.read('assets/images/site/logo-100.png')
     
    @host = host
    @user = Settings.inventory_email
    @admin_email = Settings.admin_email || self.default_params[:from]
    @product_detail = ProductDetail.find(product_detail.id)
    
    mail(:to=>@user, :subject=>"Inventory Warning for #{@product_detail.inventory_key}")
    
  end
  
  

  def signup_notification(user, host)
   # attachments.inline['logo-100.png'] = File.read('assets/images/site/logo-100.png')

    @user=user
    @hostfull=host
    @admin_email = Settings.admin_email || self.default_params[:from]
    @site_name = Settings.company_url
    mail(:from=>@admin_email,:to => "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", :subject => "Welcome to Our Store!!")
  end
 
  
  def reset_notification(user, host)
    
   # attachments.inline['logo-100.png'] = File.read('assets/images/site/logo-100.png')
    puts("Self: #{self.default_params[:from]}")
    @user=user
    @hostfull=host
    @site_name = Settings.company_url
    @admin_email = Settings.admin_email || self.default_params[:from]
        
    mail(:from=>@admin_email,:to => "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", :subject => "Reset your password")
  end
 
  
  def signup_notification2(user, siteurl)
    @hostfull=siteurl
    @site_name = Settings.company_url
    setup_email(user)
    subject 'Please activate your new account'
    body(:user=>user, :hostfull=>@hostfull)
    content_type "text/html"   #Here's where the magic happens

    #@body  = siteurl.gsub(%r{</?[^>]+?>}, '')+"activate/#{user.activation_code}"
  end

  def activation(user)
    setup_email(user)
    @site_name = Settings.company_url
    @subject    += 'Your account has been activated!'
    @body  = "#{@site_name}"
    @site_name = Settings.company_url
  end

  def reset_notification2(user, siteurl)
    @hostfull=siteurl
    @site_name = Settings.company_url
    setup_email(user)
    subject 'Link to reset your password'
    #    @body  = siteurl.gsub(%r{</?[^>]+?>}, '')+"reset/#{user.password_reset_code}"
    body(:user=>user, :hostfull=>@hostfull)
    content_type "text/html"   #Here's where the magic happens

  end
  
  def lostwithemail(user, host)
  #  attachments.inline['logo-100.png'] = File.read('assets/images/site/logo-100.png')

    @user=user
    @hostfull=host
    @site_name = Settings.company_url
    @admin_email = Settings.admin_email || self.default_params[:from]

    mail(:from=>@admin_email,:to => "#{user.user_attribute.first_name} #{user.user_attribute.last_name}<#{user.name}>", :subject => "Activation for squirtinibikini.com!!")
  end
  
  def shipment_notification(order, user, message, host)
    @site_name = Settings.company_url
    @hostfull=host
  
    setup_email(user)
    subject 'Your shipment has been sent'
    body(:order=>order, :user => user, :url_base => 'http://locathost:3000/grants/show')
    content_type "text/html"   #Here's where the magic happens
  end

  def order_notification_as_invoice(order,user,host)
   
    #  attachments.inline['logo.png'] = File.read(('public/'+Settings.logo_path rescue "public/images/empty_s.jpg"))
   # attachments.inline['logo-100.png'] = File.read('assets/images/site/logo-100.png')

    @page_title = "order success"
    @page = Page.find_all_by_title (@page_title).first
    
    @company_name = Settings.company_name
    @company_address = Settings.company_address
    @company_phone = Settings.company_phone
    @company_fax = Settings.company_fax
    
    
    @user=user
    @order=order
    
    @order.order_items.each do |order_item|
      attachments.inline["#{order_item.id}.png"] = File.read("public" + order_item.product_detail.thumb.to_s)
    end
    
    
    
    @hostfull=host
    @site_slogan = Settings.site_slogan rescue ""
    @site_name = Settings.site_name rescue "Our Site"
    @admin_email = Settings.admin_email || self.default_params[:from]
 
    mail(:from=>@admin_email, :cc=> @admin_email,:to => "#{user.user_attribute.first_name rescue ""} #{user.user_attribute.last_name rescue ""}<#{user.name}>", :subject => "Thank you for your order !!")
 
  end
  
 def order_notification(order, user, host)

    #  attachments.inline['logo.png'] = File.read(('public/'+Settings.logo_path rescue "public/images/empty_s.jpg"))
   # attachments.inline['logo-100.png'] = File.read('assets/images/site/logo-100.png')

    @user=user
    @order=order
    @hostfull=host
    @site_slogan = Settings.site_slogan rescue ""
    @site_name = Settings.site_name rescue "Our Site"
    @admin_email = Settings.admin_email || self.default_params[:from]
 
    mail(:from=>@admin_email, :cc=> @admin_email,:to => "#{user.user_attribute.first_name rescue ""} #{user.user_attribute.last_name rescue ""}<#{user.name}>", :subject => "Thank you for your order !!")
  end


  #def winner_notification(user, message, host)
  #  @hostfull=host
  #  self.setup_email(user)
  #  subject 'Congratulations!! You are a winner.'
  #  body (:user=>user)
  #  content_type "text/html"
  #  
  #end


  
  protected

  def setup_email(user)
    @recipients  = "#{user.name}"
    @from        = "admin@squirtinibikini.com"
    @subject     = "[mysite]"
    @sent_on     = Time.now
    @body = user.name
  end
end