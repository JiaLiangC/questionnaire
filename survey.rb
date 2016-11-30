require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "pry"
require "pry-nav"
require "csv"

PATH = File.expand_path("../data/",__FILE__)

configure do
  enable :sessions
  set :session_secret, "1qaz"
end

before  do
  load_questions
end

def load_questions
  @questions ||= CSV.foreach(PATH + "/questions.csv").to_a
  @options ||= CSV.foreach(PATH + "/options.csv").to_a
end


helpers do
  def controller_name
    request.path_info.delete('/') 
  end
end

get "/" do
  erb :home
end

# question page
get "/questions" do
  erb :questions
end

post "/answers" do 

  answer = params[:answer]

  res = @questions.length.times.map do |x|
    params[:answer][x.to_s]
  end.join(",") 


  file_name = Time.now.utc.to_i.to_s + ("%04d" % rand(9999))
  File.open(PATH + "/#{file_name}.csv", "w+") do |file|
    file.puts res
  end
  redirect "/reports"
end

get "/reports" do
  @res = statics
  erb :reports
end

def statics
  files = Dir.glob(PATH + "/*[1-9].csv")
    res = {}
    files.each do |file|
      CSV.foreach(file).to_a[0].each_with_index do |opt, idx|
        if opt
          res[idx.to_s] ||= {}
          res[idx.to_s][opt] ||= 0
          res[idx.to_s][opt] += 1
        end
      end
    end
 return  res
end
