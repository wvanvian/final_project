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
    x_data = csv_data['x_bin'].map(&:to_f)
    y_data = csv_data['y_bin'].map(&:to_f)
    thickness_data = csv_data['thickness'].map(&:to_f)

    below_six_x = Array.new
    below_six_y = Array.new
    six_nine_x = Array.new
    six_nine_y = Array.new
    nine_twelve_x = Array.new
    nine_twelve_y = Array.new
    twelve_fifteen_x = Array.new
    twelve_fifteen_y = Array.new
    above_fifteen_x = Array.new
    above_fifteen_y = Array.new


    pp('-------------------------------------')
    thickness_data.each_index do |i|
      pp(thickness_data.at(i).to_f < 15, i)
      if thickness_data.at(i).to_f >= 15
        above_fifteen_x.push(x_data.at(i)) 
        above_fifteen_y.push(y_data.at(i))

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
    heatmap.title = 'Heatmap'

    #g = Gruff::Scatter.new(800)
    heatmap.data "< 6in", below_six_x, below_six_y
    heatmap.data '>= 6in & < 9in', six_nine_x, six_nine_y
    heatmap.data '>= 9in & < 12in', nine_twelve_x, nine_twelve_y
    heatmap.data '>= 12in & < 15in', twelve_fifteen_x, twelve_fifteen_y
    heatmap.data '>= 15in', above_fifteen_x, above_fifteen_y

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
      font_color: 'white',
      background_colors: 'black'
    }.freeze
    heatmap.write('scatter.png')






  end

    



end
