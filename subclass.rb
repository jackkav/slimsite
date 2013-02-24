require 'sinatra/base'
class App < Sinatra::Base
set :name, "App"
get '/' do
"this is the app"
end
get '/hello' do
"Hello, this is #{settings.name}"
end
end
class Sub < App
set :name, "Sub"
get '/' do
"This is the sub app"
end
end
Sub.run!