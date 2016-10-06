
require 'rake'

namespace :image_processing do
  desc "Update Image versions."
  task :update_versions, [:start_image, :image_count,:version] => :environment do |task, params|
    puts("Update Image Versions ==> Started: @#{Time.now}")
    puts("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    puts(":start_image is #{params[:start_image]}")
    puts(":version is #{params[:version]}")

    @pictures = Picture.all
    update_counter = 1
    @pictures.each do |picture|
      if picture.id > params[:start_image].to_i then
          if params[:version].blank? then
            picture.image.recreate_versions!
          else
            picture.image.recreate_versions!(params[:version].to_sym)
          end
        # sleep 0.25 
        file_name = picture.image.file.nil? ? "unknown" : picture.image.file.filename

        puts("Items Updated: #{update_counter}  ID:#{picture.id} - #{file_name} image version updated.")
        
        update_counter = update_counter+1
        
        break if update_counter >= params[:image_count].to_i
        
      else
        puts("ID:#{picture.id} - #{picture.image.file.filename rescue "<file not found>"} already processed.")
        end
      end
        
    puts("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
    puts("Update Image Versions Complete. Ended @#{Time.now}")  
  end
end