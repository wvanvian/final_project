class DataController < ApplicationController
  before_action :required_user_logged_in!
  skip_forgery_protection
  
  require 'csv'
  require 'gruff'

  FILE_EXT = [".csv"]

  def analyze
    pp("HERE ANALYZE")
  end

  def file_validation(ext)
    raise "Not allowed" unless FILE_EXT.include?(ext)
  end

  def upload
  end

  def upload_file  
    if params[:file]
      FileUtils::mkdir_p(Rails.root.join("public/uploads/files"))
        
      ext = File.extname(params[:file].original_filename)
      ext = file_validation(ext)
      filename = params[:file].original_filename
      path = Rails.root.join("public/uploads/files/", filename)
        
      File.open(path, "wb") {|f| f.write(params[:file].read)}
      redirect_to("/visualize?param_name=#{filename}")

    else
      redirect_to("/upload")
    end

  end

  def visualize
    @filename = params[:param_name]
    path = Rails.root.join("public/uploads/files/", @filename)
    csv_data = CSV.parse(File.read("#{path}"), headers: true)
    csv_data.by_col!

    # Extract data from CSV columns
    x_data = csv_data['x'].map(&:to_f)
    y_data = csv_data['y'].map(&:to_f)
    thickness_data = csv_data['thickness'].map(&:to_f)

    below_six_x = Array.new
    below_six_y = Array.new
    six_nine_x = Array.new
    six_nine_y = Array.new
    nine_twelve_x = Array.new
    nine_twelve_y = Array.new
    twelve_fifteen_x = Array.new
    twelve_fifteen_y = Array.new
    fifteen_eighteen_x = Array.new
    fifteen_eighteen_y = Array.new
    eighteen_twentyone_x = Array.new
    eighteen_twentyone_y = Array.new
    twentyone_twentyfour_x = Array.new
    twentyone_twentyfour_y = Array.new
    above_twentyfour_x = Array.new
    above_twentyfour_y = Array.new

    thickness_data.each_index do |i|
      if thickness_data.at(i).to_f >= 24
        above_twentyfour_x.push(x_data.at(i)) 
        above_twentyfour_y.push(y_data.at(i))

      elsif thickness_data.at(i).to_f >= 21
        twentyone_twentyfour_x.push(x_data.at(i)) 
        twentyone_twentyfour_y.push(y_data.at(i))

      elsif thickness_data.at(i).to_f >= 18
        eighteen_twentyone_x.push(x_data.at(i)) 
        eighteen_twentyone_y.push(y_data.at(i))

      elsif thickness_data.at(i).to_f >= 15
        fifteen_eighteen_x.push(x_data.at(i)) 
        fifteen_eighteen_y.push(y_data.at(i))

      elsif thickness_data.at(i).to_f  >= 12
        twelve_fifteen_x.push(x_data.at(i)) 
        twelve_fifteen_y.push(y_data.at(i)) 

      elsif thickness_data.at(i).to_f  >= 9
        nine_twelve_x.push(x_data.at(i)) 
        nine_twelve_y.push(y_data.at(i)) 
        
      elsif thickness_data.at(i).to_f >= 6
        six_nine_x.push(x_data.at(i)) 
        six_nine_y.push(y_data.at(i)) 

      else 
        below_six_x.push(x_data.at(i)) 
        below_six_y.push(y_data.at(i)) 

      end

    end

    # Create a Gruff::Scatter plot
    heatmap = Gruff::Scatter.new(800)

    heatmap.data "< 6in", below_six_x, below_six_y
    heatmap.data '< 9in', six_nine_x, six_nine_y
    heatmap.data '< 12in', nine_twelve_x, nine_twelve_y
    heatmap.data '< 15in', twelve_fifteen_x, twelve_fifteen_y
    heatmap.data '< 18in', fifteen_eighteen_x, fifteen_eighteen_y
    heatmap.data '< 21in', eighteen_twentyone_x, eighteen_twentyone_y
    heatmap.data '< 24in', twentyone_twentyfour_x, twentyone_twentyfour_y
    heatmap.data '>= 24in', above_twentyfour_x, above_twentyfour_y


    heatmap.minimum_x_value = x_data.min - 0.05
    heatmap.maximum_x_value = x_data.max + 0.05
    heatmap.theme = {
      colors: [
        "#007BFF",  # Electric Blue
        "#00C853",  # Emerald Green
        "#7E57C2",  # Royal Purple
        "#FF6B6B",  # Sunset Orange
        "#64FFDA",  # Turquoise
        "#FFD166",  # Lemon Yellow
        "#FF2E63",  # Magenta
        "#00A8E8"   # Deep Sky Blue
      ],
      marker_color: '#aea9a9', # Grey
      font_color: '#F0F0F0',
      font: '9px',
      background_colors: 'black'
    }.freeze
    heatmap.circle_radius = 5
    heatmap.legend_font_size = 9
    heatmap.legend_at_bottom = true
    heatmap.marker_font_size = 9

    heatmap.write('app/assets/stylesheets/thickness.png')

  end

    



end
