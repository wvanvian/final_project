class DataController < ApplicationController
  before_action :required_user_logged_in!
  skip_forgery_protection

  def upload
    pp("HERE UPLOAD")
  end

  def analyze
    pp("HERE ANALYZE")
  end
end
