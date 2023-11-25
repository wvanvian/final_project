class DataController < ApplicationController
  before_action :required_user_logged_in!
  skip_forgery_protection
  require 'csv'

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
    @dataTable = CSV.parse(File.read("#{path}"), headers: true)
    @dataTable.by_col!


    #row,record,x_localized,y_localized,x_bin,y_bin,impactor,frequency,thickness,expected_thickness,amplitude,noise_amplitude,noise_ratio,voltage_max,
    #thickness_frequency_amplitude,p_wave_integral,transducers_clipped,transducers_amp_max,exp_decay,time_delay,contact_time,starting_frequency,ending_frequency,
    #frequency_range,calculated_cpp,ie_defects,pre_impact_resonance_frequency,pre_impact_resonance_frequency_amplitude,frequencies,mean_amplitudes,impactor_mass,
    #sensor_ids,noise,clipped,debond,thickness_diff,defect,ie_defect

    g = Gruff::Line.new
    g.title = "A Line Graph"
    g.data 'Fries', [20, 23, 19, 8]
    g.data 'Hamburgers', [50, 19, 99, 29]
    g.write("line.png")

    require 'gruff'


    data = [
      [1, 1, 5],
      [1, 2, 7],
      [2, 1, 4],
      [2, 2, 6]
    ]

    # Separate the data into x, y, and value arrays
    x_data_points = data.map { |point| point[0] }
    y_data_points = data.map { |point| point[1] }
    values = data.map { |point| point[2] }

    # Create a Gruff::Scatter plot
    heatmap = Gruff::Scatter.new
    heatmap.title = 'Heatmap'

    #g = Gruff::Scatter.new(800)
    heatmap.data :apples, [1,2,3,4], [4,3,2,1]
    heatmap.data 'oranges', [5,7,8], [4,1,7]
    heatmap.theme = {
      colors: [
        '#a9dada', # blue
        '#aedaa9', # green
        '#daaea9', # peach
        '#dadaa9', # yellow
        '#a9a9da', # dk purple
        '#daaeda', # purple
        '#dadada' # grey
      ],
      marker_color: '#aea9a9', # Grey
      font_color: 'black',
      background_colors: 'white'
    }.freeze
    heatmap.write('scatter.png')


    csv_data = @dataTable

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


    pp('-------------------------------------')
    thickness_data.each_index do |i|
      pp(thickness_data.at(i).to_f < 15, i)
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
    pp(y_data)
    pp('------------------------------------')

    # Create a Gruff::Scatter plot
    heatmap = Gruff::Scatter.new
    heatmap.title = 'Impact Echo Thickness'
    heatmap.minimum_x_value = x_data.min - 0.05
    heatmap.maximum_x_value = x_data.max + 0.05

    #g = Gruff::Scatter.new(800)
    heatmap.data "< 6in", below_six_x, below_six_y
    heatmap.data '>= 6in & < 9in', six_nine_x, six_nine_y
    heatmap.data '>= 9in & < 12in', nine_twelve_x, nine_twelve_y
    heatmap.data '>= 12in & < 15in', twelve_fifteen_x, twelve_fifteen_y
    heatmap.data '>= 15in & < 18in', fifteen_eighteen_x, fifteen_eighteen_y
    heatmap.data '>= 18in & < 21in', eighteen_twentyone_x, eighteen_twentyone_y
    heatmap.data '>= 21in & < 24in', twentyone_twentyfour_x, twentyone_twentyfour_y
    heatmap.data '>= 24in', above_twentyfour_x, above_twentyfour_y

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
      #marker_font_size: '20px',
      font_color: 'white',
      background_colors: 'white'
    }.freeze

    #heatmap.data('Data Series').marker_scale = 2.0
    heatmap.circle_radius = 5
    heatmap.legend_font_size = 9
    heatmap.legend_at_bottom = true
    heatmap.write('scatter1.png')

    pp(x_data.max)
    pp(y_data.max)






  end

    



end
