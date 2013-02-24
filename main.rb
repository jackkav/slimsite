require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require 'pony'
require 'sinatra/flash'
require './song.rb'

configure :development do
	DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end
configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'])
end
configure do
	enable :sessions
	set :username, 'frank'
	set :password, 'sinatra'
	set :session_secret, 'try to make this long and hard to guess'
end
configure do
	set :port, 1337
end

get('/styles.css'){ scss :styles }

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

get '/set/:name' do
	session[:name] = params[:name]
end

get '/login' do
	slim :login
end

post '/login' do
	if params[:username] == settings.username && params[:password] == settings.password
		session[:admin] = true
		redirect to('/songs')
	else
		slim :login
	end
end

get '/logout' do
	session.clear
	redirect to('/login')
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
	send_message
	flash[:notice] = "Thank you for your message. We'll be in touch soon."
	redirect to('/')
end

def send_message
	Pony.mail(
		:from => params[:name] + "<" + params[:email] + ">",
		:to => 'jackkav@gmail.com',
		:subject => params[:name] + " has contacted you",
		:body => params[:message],
		:port => '587',
		:via => :smtp,
		:via_options => {
			:address
			=> 'smtp.gmail.com',
			:port
			=> '587',
			:enable_starttls_auto => true,
			:user_name
			=> 'daz',
			:password
			=> 'secret',
			:authentication
			=> :plain,
			:domain
			=> 'localhost.localdomain'
		})
end

not_found do
	slim :not_found
end