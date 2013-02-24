$: << '.'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require 'v8'
require 'coffee-script'
require 'sinatra/auth'
require 'sinatra/flash'
require 'song'
require 'asset-handler'

class Website < Sinatra::Base
	use AssetHandler
	register Sinatra::Auth
	register Sinatra::Flash

	configure do
		enable :sessions
		set :username, 'jack'
		set :password, 'jack'
		set :session_secret, 'try to make this long and hard to guess'
	end

	configure :development do
		set :email_address => 'smtp.gmail.com',
		:email_user_name => 'daz',
		:email_password => 'secret',
		:email_domain => 'localhost.localdomain'
	end

	configure :production do
		set :email_address => 'smtp.sendgrid.net',
		:email_user_name => ENV['SENDGRID_USERNAME'],
		:email_password => ENV['SENDGRID_PASSWORD'],
		:email_domain => 'heroku.com'
	end

	configure do
		set :start_time, Time.now
	end

	configure :development do
		set :port, 1337
	end

	before do
		set_title
	end

	before do
		last_modified settings.start_time
		etag settings.start_time.to_s
		cache_control :public, :must_revalidate
	end

	def css(*stylesheets)
	stylesheets.map do |stylesheet|
		"<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
		end.join
	end

	def current?(path='/')
		(request.path==path || request.path==path+'/') ? "current" : nil
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

	post '/contact' do
		flash[:notice] = "Thank you for your message. We'll be in touch soon."
		redirect to('/')
	end

	not_found do
		slim :not_found
	end
end