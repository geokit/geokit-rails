Rails.application.routes.draw do
  get "/", to: "location_aware#index"
  get "/cookietest", to: "location_aware#cookietest"
  get "/sessiontest", to: "location_aware#sessiontest"
  get "/failtest", to: "location_aware#failtest"
end
