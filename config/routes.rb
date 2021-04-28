Rails.application.routes.draw do
  
  scope 'api' do
  	resources :charge
  end

end