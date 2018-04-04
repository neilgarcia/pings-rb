require 'sinatra'
require 'mysql2'
require 'json'

client = Mysql2::Client.new(:host => 'localhost', :username => 'root', :database => 'tanda')

post '/:device_id/:epoch_time' do
  statement = client.prepare("INSERT INTO pings (device_id, epoch_time) VALUES (?, ?)")
  statement.execute(params[:device_id], params[:epoch_time])
end

post '/clear_data' do
  client.query("DELETE FROM pings")
end

get '/devices' do
  devices = []
  client.query("SELECT DISTINCT device_id FROM pings").each do |row|
    devices << row["device_id"]
  end

  devices.to_json
end

get '/:device_id/:date' do
  start_date = convert_to_epoch_time(params[:date])
  end_date = start_date + 60 * 60 * 24
  if params[:device_id] == "all"
    pings = Hash.new
    statement = client.prepare("SELECT * FROM pings WHERE epoch_time >= ? AND epoch_time < ?")
    results = statement.execute(start_date, end_date)
    results.each do |row|
      pings[row["device_id"]] ||= []
      pings[row["device_id"]] << row["epoch_time"]
    end
  else
    pings = []
    statement = client.prepare("SELECT epoch_time FROM pings WHERE epoch_time >= ? AND epoch_time < ? AND device_id = ?")
    results = statement.execute(start_date, end_date, params[:device_id])
    results.each do |row|
      pings << row["epoch_time"]
    end
  end

  pings.to_json
end

get '/:device_id/:from/:to' do
  start_date = convert_to_epoch_time(params[:from])
  end_date = convert_to_epoch_time(params[:to])
  if params[:device_id] == "all"
    pings = Hash.new
    statement = client.prepare("SELECT * FROM pings WHERE epoch_time >= ? AND epoch_time < ?")
    results = statement.execute(start_date, end_date)
    results.each do |row|
      pings[row["device_id"]] ||= []
      pings[row["device_id"]] << row["epoch_time"]
    end
  else
    pings = []
    statement = client.prepare("SELECT epoch_time FROM pings WHERE epoch_time >= ? AND epoch_time < ? AND device_id = ?")
    results = statement.execute(start_date, end_date, params[:device_id])
    results.each do |row|
      pings << row["epoch_time"]
    end
  end

  pings.to_json
end

private

def convert_to_epoch_time(date)
  return date if epoch_time?(date)
  year, month, date = date.split("-")
  Time.utc(year, month, date).to_i
end

def epoch_time?(obj)
   obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
end
