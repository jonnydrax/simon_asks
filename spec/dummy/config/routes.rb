Rails.application.routes.draw do

  mount SimonAsks::Engine => "/qa"

  mount SimonAsks::Engine => "/simon_asks"
end
