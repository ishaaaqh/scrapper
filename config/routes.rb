Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'scraper#home'
  get '/scraper' => 'scraper#scraper'
  get '/get_7days_data' => 'scraper#get_7days_data'
  get '/get_30days_data' => 'scraper#get_30days_data'
  get '/state' => 'scraper#state'
end

