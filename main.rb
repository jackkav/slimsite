require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require 'v8'
require 'coffee-script'
require 'sinatra/flash'
require './song.rb'
require './sinatra/auth'

configure :development do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end
configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'])
end
configure do
	enable :sessions
	set :username, 'jack'
	set :password, 'jack'
	set :session_secret, 'try to make this long and hard to guess'
end
configure do
	set :port, 1337
end

get('/styles.css'){ scss :styles }
get('/javascripts/application.js'){ coffee :application }

helpers do
	def css(*stylesheets)
	stylesheets.map do |stylesheet|
		"<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
		end.join
	end

	def current?(path='/')
		(request.path==path || request.path==path+'/') ? "current" : nil
	end
end

before do
	set_title
end

def set_title
	@title ||= "Songs By Sinatra"
end

get '/' do
	slim :home
end

get '/about' do
	@title = "All About This Website"
	slim :about
end

get '/contact' do
	slim :contact
end

post '/contact' do
	flash[:notice] = "Thank you for your message. We'll be in touch soon."
	redirect to('/')
end



not_found do
	slim :not_found
end