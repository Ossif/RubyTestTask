require 'httparty'
require 'json'
require 'dotenv/load'

API_KEY = ENV['API_KEY']
BASE_URL = "http://contest.elecard.ru/api"

def api_request(method, params = nil)
  response = HTTParty.post(BASE_URL, body: {
    key: API_KEY,
    method: method,
    params: params
  }.to_json, headers: { 'Content-Type' => 'application/json' })

  JSON.parse(response.body)
end

def get_tasks
  api_request("GetTasks")
end

def calculate_bounding_box(circles)
  minx = circles.map { |circle| circle['x'] - circle['radius'] }.min
  maxx = circles.map { |circle| circle['x'] + circle['radius'] }.max
  miny = circles.map { |circle| circle['y'] - circle['radius'] }.min
  maxy = circles.map { |circle| circle['y'] + circle['radius'] }.max
  {
    left_bottom: { x: minx, y: miny },
    right_top: { x: maxx, y: maxy }
  }
end

def check_results(results)
  api_request("CheckResults", results)
end

response = get_tasks

if response["error"]
  puts "Ошибка при получении задач: #{response["error"]["message"]}"
else
  
  tasks = response["result"]
  results = tasks.map do |circles|
    calculate_bounding_box(circles)
  end

  check_response = check_results(results)

  if check_response["error"]
    puts "Ошибка при проверке результатов: #{check_response["error"]["message"]}"
  else
    puts "Результаты тестов: #{check_response["result"].inspect}"
  end
end
