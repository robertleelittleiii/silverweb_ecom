# frozen_string_literal: true

class SystemImages
  def self.all
    Picture.where(resource_type: 'System').order(:position)
  end

  def self.swatches
    Picture.where(resource_type: 'Swatch')
  end

  def self.count
    Picture.where(resource_type: 'System').count
  end

  def self.[](var_name)
    image = Picture.where(title: var_name, resource_type: 'System')

    if image.blank?
      return nil
    else
      return image
    end
  end

  def self.find_by_title(title)
    Picture.where(title: title)
  end

  def self.new(var_name, image)
    #  new_image = Picture.where(:title=>var_name, :resource_type=>"System")

    # if new_image.blank? then
    new_image = Picture.new(image: image)
    new_image.resource_type = 'System'
    new_image.title = var_name
    new_image.position = 999
    new_image.save

    new_image

    #  end
    # new_image
  end

  # get or set a variable with the variable as the called method
  def self.method_missing(method, *args)
    if respond_to?(method)
      super
    else
      method_name = method.to_s

      # set a value for a variable
      if /=$/.match?(method_name)
        var_name = method_name.delete('=')
        value = args.first
        self[var_name] = value

        # retrieve a value
      else
        self[method_name]

      end
    end
  end
end
