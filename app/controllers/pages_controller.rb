class PagesController < ApplicationController
  before_filter :authenticate_user!, except: :welcome
  def app    
  end
  
  def welcome
  end
end
