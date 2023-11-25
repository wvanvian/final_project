class DataController < ApplicationController
  before_action :required_user_logged_in!
  skip_forgery_protection
  
  require 'csv'
  require 'gruff'

  FILE_EXT = [".csv"]

  def analyze
  end

  def analyze_file
    pp(params[:dropdown1])
    pp(params[:dropdown2])

    filename_one = params[:dropdown1]
    filename_two = params[:dropdown1]
    path_one = Rails.root.join("public/uploads/files/", filename_one)
    path_two = Rails.root.join("public/uploads/files/", filename_two)
    csv_data_one = CSV.parse(File.read("#{path_one}"), headers: true)
    csv_data_two = CSV.parse(File.read("#{path_two}"), headers: true)
    csv_data_one.by_col!
    csv_data_two.by_col!

    # Extract data from CSV columns
    thickness_data_one = csv_data_one['thickness'].map(&:to_f)
    thickness_data_two = csv_data_one['thickness'].map(&:to_f)

    get_boxplot(thickness_data_one, thickness_data_two, filename_one, filename_two)
    redirect_to("/analyze")

  end

  def mean(array)
    array.sum.to_f / array.size
  end
  
  def variance(array)
    m = mean(array)
    sum = array.reduce(0) { |acc, i| acc + (i - m) ** 2 }
    sum / (array.size - 1)
  end
  
  def welchs_t_test(sample1, sample2)
    mean1 = mean(sample1)
    mean2 = mean(sample2)
    variance1 = variance(sample1)
    variance2 = variance(sample2)
    n1 = sample1.size
    n2 = sample2.size
  
    t = (mean1 - mean2) / Math.sqrt((variance1 / n1) + (variance2 / n2))
  
    # Degrees of freedom
    df = ((variance1 / n1) + (variance2 / n2))**2 / (((variance1 / n1)**2 / (n1 - 1)) + ((variance2 / n2)**2 / (n2 - 1)))
  
    return t, df
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
    filename = params[:param_name]
    path = Rails.root.join("public/uploads/files/", filename)
    csv_data = CSV.parse(File.read("#{path}"), headers: true)
    csv_data.by_col!

    # Extract data from CSV columns
    x_data = csv_data['x'].map(&:to_f)
    y_data = csv_data['y'].map(&:to_f)
    thickness_data = csv_data['thickness'].map(&:to_f)
    amplitude_data = csv_data['amplitude'].map(&:to_f)
    
    amplitude_max = amplitude_data.max
    x_min = x_data.min
    x_max = x_data.max

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

    low_x = Array.new
    low_y = Array.new
    high_x = Array.new
    high_y = Array.new

    thickness_data.each_index do |i|
      if thickness_data.at(i) >= 24
        above_twentyfour_x.push(x_data.at(i)) 
        above_twentyfour_y.push(y_data.at(i))

      elsif thickness_data.at(i) >= 21
        twentyone_twentyfour_x.push(x_data.at(i)) 
        twentyone_twentyfour_y.push(y_data.at(i))

      elsif thickness_data.at(i) >= 18
        eighteen_twentyone_x.push(x_data.at(i)) 
        eighteen_twentyone_y.push(y_data.at(i))

      elsif thickness_data.at(i) >= 15
        fifteen_eighteen_x.push(x_data.at(i)) 
        fifteen_eighteen_y.push(y_data.at(i))

      elsif thickness_data.at(i) >= 12
        twelve_fifteen_x.push(x_data.at(i)) 
        twelve_fifteen_y.push(y_data.at(i)) 

      elsif thickness_data.at(i) >= 9
        nine_twelve_x.push(x_data.at(i)) 
        nine_twelve_y.push(y_data.at(i)) 
        
      elsif thickness_data.at(i) >= 6
        six_nine_x.push(x_data.at(i)) 
        six_nine_y.push(y_data.at(i)) 

      else 
        below_six_x.push(x_data.at(i)) 
        below_six_y.push(y_data.at(i)) 

      end

      if amplitude_data.at(i) < amplitude_max * 0.5
        low_x.push(x_data.at(i))
        low_y.push(y_data.at(i))
      else
        high_x.push(x_data.at(i))
        high_y.push(y_data.at(i))
      end

    end

    get_thickness_heatmap(below_six_x, below_six_y, six_nine_x, six_nine_y, nine_twelve_x, nine_twelve_y, twelve_fifteen_x, twelve_fifteen_y, fifteen_eighteen_x, fifteen_eighteen_y, eighteen_twentyone_x, eighteen_twentyone_y, twentyone_twentyfour_x, twentyone_twentyfour_y, above_twentyfour_x, above_twentyfour_y, x_min, x_max)
    get_amplitude_heatmap(high_x, high_y, low_x, low_y, x_max, x_min, amplitude_max.to_i)


  end


  def get_boxplot(thickness_data_one, thickness_data_two, filename_one, filename_two)
    box_plot = Gruff::Box.new
    box_plot.data "#{filename_one}", thickness_data_one
    box_plot.data "#{filename_two}", thickness_data_two

    max_one = thickness_data_one.max
    max_two = thickness_data_two.max

    box_plot.theme = {
      colors: [
        "#FF2E63",  # Magenta
        "#FFD166",  # Lemon Yellow
      ],
      marker_color: 'black',
      font_color: '#F0F0F0',
      font: '9px',
      background_colors: 'black'
    }.freeze
    box_plot.legend_font_size = 9
    box_plot.legend_at_bottom = true
    box_plot.marker_font_size = 9
    box_plot.maximum_value = max_one > max_two ? max_one : max_two
    box_plot.minimum_value = 0

    # Perform Welch's t-test
    t_statistic, degrees_of_freedom = welchs_t_test(thickness_data_one, thickness_data_two)
    box_plot.title = "Box Plot Comparison of Two Samples with #{degrees_of_freedom} Degrees of Freedom and a t-Statistic of #{t_statistic}"
    box_plot.title_font_size=15

    box_plot.write("app/assets/stylesheets/box_plot.png")
  end

  def get_thickness_heatmap(below_six_x, below_six_y, six_nine_x, six_nine_y, nine_twelve_x, nine_twelve_y, twelve_fifteen_x, twelve_fifteen_y, fifteen_eighteen_x, fifteen_eighteen_y, eighteen_twentyone_x, eighteen_twentyone_y, twentyone_twentyfour_x, twentyone_twentyfour_y, above_twentyfour_x, above_twentyfour_y, x_min, x_max)
    # Create a Gruff::Scatter plot
    thickness_heatmap = Gruff::Scatter.new(800)

    thickness_heatmap.data "< 6 in", below_six_x, below_six_y
    thickness_heatmap.data '< 9 in', six_nine_x, six_nine_y
    thickness_heatmap.data '< 12 in', nine_twelve_x, nine_twelve_y
    thickness_heatmap.data '< 15 in', twelve_fifteen_x, twelve_fifteen_y
    thickness_heatmap.data '< 18 in', fifteen_eighteen_x, fifteen_eighteen_y
    thickness_heatmap.data '< 21 in', eighteen_twentyone_x, eighteen_twentyone_y
    thickness_heatmap.data '< 24 in', twentyone_twentyfour_x, twentyone_twentyfour_y
    thickness_heatmap.data '>= 24 in', above_twentyfour_x, above_twentyfour_y


    thickness_heatmap.minimum_x_value = x_min - 0.05
    thickness_heatmap.maximum_x_value = x_max + 0.05
    thickness_heatmap.theme = {
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
      marker_color: 'black',
      font_color: '#F0F0F0',
      font: '9px',
      background_colors: 'black'
    }.freeze
    thickness_heatmap.circle_radius = 5
    thickness_heatmap.legend_font_size = 9
    thickness_heatmap.legend_at_bottom = true
    thickness_heatmap.marker_font_size = 9

    thickness_heatmap.write('app/assets/stylesheets/thickness.png')
  end


  def get_amplitude_heatmap(high_x, high_y, low_x, low_y, x_max, x_min, amplitude_max)
    amplitude_heatmap = Gruff::Scatter.new(800)

    amplitude_heatmap.data "< #{amplitude_max / 2} mV", high_x, high_y
    amplitude_heatmap.data ">= #{amplitude_max / 2} mV", low_x, low_y

    amplitude_heatmap.minimum_x_value = x_min - 0.05
    amplitude_heatmap.maximum_x_value = x_max + 0.05
    amplitude_heatmap.theme = {
      colors: [
        "#FF0000",  # Red
        "#C0C0C0"   # Gray
      ],
      marker_color: 'black', 
      font_color: '#F0F0F0',
      font: '9px',
      background_colors: 'black'
    }.freeze
    amplitude_heatmap.circle_radius = 5
    amplitude_heatmap.legend_font_size = 9
    amplitude_heatmap.legend_at_bottom = true
    amplitude_heatmap.marker_font_size = 9

    amplitude_heatmap.write('app/assets/stylesheets/amplitude.png')
  end

    



end
