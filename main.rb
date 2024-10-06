require 'httparty'
require 'json'

API_KEY = "G8ZVuIdnmShiKLE7eCidCQmQXDSYao9P9y+dnwzEDCczTSenUADgipRYO+wjaO5hgBQ046YxY7pq55Pd4vnIUw=="
BASE_URL = "http://contest.elecard.ru/api"

def get_tasks
  response = HTTParty.post(BASE_URL, body: {
    key: API_KEY,
    method: "GetTasks",
    params: nil
  }.to_json, headers: { 'Content-Type' => 'application/json' })

  JSON.parse(response.body)
end

def calculate_bounding_box(circles)
  min_x = circles.map { |circle| circle['x'] - circle['radius'] }.min
  max_x = circles.map { |circle| circle['x'] + circle['radius'] }.max
  min_y = circles.map { |circle| circle['y'] - circle['radius'] }.min
  max_y = circles.map { |circle| circle['y'] + circle['radius'] }.max

  {
    left_bottom: { x: min_x, y: min_y },
    right_top: { x: max_x, y: max_y }
  }
end

def check_results(results)
  response = HTTParty.post(BASE_URL, body: {
    key: API_KEY,
    method: "CheckResults",
    params: results
  }.to_json, headers: { 'Content-Type' => 'application/json' })

  JSON.parse(response.body)
end

response = get_tasks

if response["error"]
  puts "Ошибка при получении задач: #{response["error"]["message"]}"
else
  tasks = response["result"]
  results = []

  tasks.each do |circles|
    bounding_box = calculate_bounding_box(circles)
    results << bounding_box
  end

  check_response = check_results(results)

  if check_response["error"]
    puts "Ошибка при проверке результатов: #{check_response["error"]["message"]}"
  else
    puts "Результаты тестов: #{check_response["result"].inspect}"
  end
end
