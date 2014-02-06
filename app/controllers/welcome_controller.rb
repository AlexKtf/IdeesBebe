class WelcomeController < ApplicationController
  skip_authorization_check


  def index
  end

  def forbidden
    render file: 'public/422.html', status: :forbidden
  end
end
