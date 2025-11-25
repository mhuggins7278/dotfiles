local M = {}

-- Configuration
M.config = {
  api_url = 'http://localhost:8080',
  auth_token = nil,
}

-- Setup function
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend('force', M.config, opts)
end

-- Helper to URL encode a string
local function url_encode(str)
  if not str then return '' end
  str = tostring(str)
  -- Replace special characters with percent-encoded equivalents
  str = string.gsub(str, "([^%w%-%.%_%~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  return str
end

-- Helper to make HTTP requests using curl
local function make_request(method, endpoint, data)
  local url = M.config.api_url .. endpoint
  local headers = { 'Content-Type: application/json' }

  if M.config.auth_token then
    table.insert(headers, 'Authorization: Bearer ' .. M.config.auth_token)
  end

  local curl_args = {
    'curl',
    '-s',
    '-X',
    method,
  }

  for _, header in ipairs(headers) do
    table.insert(curl_args, '-H')
    table.insert(curl_args, header)
  end

  if data then
    table.insert(curl_args, '-d')
    table.insert(curl_args, vim.fn.json_encode(data))
  end

  table.insert(curl_args, url)

  local result = vim.fn.system(curl_args)

  local success, decoded = pcall(vim.fn.json_decode, result)
  if not success then
    return { success = false, error = 'Failed to decode JSON response: ' .. result }
  end

  return decoded
end

-- API Methods

-- Health check
function M.health()
  return make_request('GET', '/api/health')
end

-- Task Operations
M.tasks = {}

function M.tasks.list(params)
  -- If params are provided, use the query endpoint
  if params and next(params) then
    return M.tasks.query(params)
  end
  -- Otherwise use basic list
  return make_request('GET', '/api/tasks')
end

function M.tasks.query(filter_query)
  return make_request('POST', '/api/tasks/query', filter_query)
end

function M.tasks.get(task_id)
  local encoded_id = url_encode(task_id)
  return make_request('GET', '/api/tasks/' .. encoded_id)
end

function M.tasks.create(task_data)
  return make_request('POST', '/api/tasks', task_data)
end

function M.tasks.update(task_id, task_data)
  local encoded_id = url_encode(task_id)
  return make_request('PUT', '/api/tasks/' .. encoded_id, task_data)
end

function M.tasks.delete(task_id)
  local encoded_id = url_encode(task_id)
  return make_request('DELETE', '/api/tasks/' .. encoded_id)
end

function M.tasks.toggle_status(task_id)
  local encoded_id = url_encode(task_id)
  return make_request('POST', '/api/tasks/' .. encoded_id .. '/toggle-status')
end

function M.tasks.archive(task_id)
  local encoded_id = url_encode(task_id)
  return make_request('POST', '/api/tasks/' .. encoded_id .. '/archive')
end

-- Time Tracking Operations
M.time = {}

function M.time.start(task_id, description)
  local encoded_id = url_encode(task_id)
  local endpoint = '/api/tasks/' .. encoded_id .. '/time/start'

  if description then
    endpoint = '/api/tasks/' .. encoded_id .. '/time/start-with-description'
    return make_request('POST', endpoint, { description = description })
  else
    return make_request('POST', endpoint)
  end
end

function M.time.stop(task_id)
  local encoded_id = url_encode(task_id)
  return make_request('POST', '/api/tasks/' .. encoded_id .. '/time/stop')
end

function M.time.get_task_time(task_id)
  local encoded_id = url_encode(task_id)
  return make_request('GET', '/api/tasks/' .. encoded_id .. '/time')
end

function M.time.active_sessions()
  return make_request('GET', '/api/time/active')
end

function M.time.summary(period, from_date, to_date)
  period = period or 'today'
  local query_parts = { 'period=' .. period }

  if from_date then
    table.insert(query_parts, 'from=' .. from_date)
  end
  if to_date then
    table.insert(query_parts, 'to=' .. to_date)
  end

  local query_string = table.concat(query_parts, '&')
  return make_request('GET', '/api/time/summary?' .. query_string)
end

-- Pomodoro Operations
M.pomodoro = {}

function M.pomodoro.start(task_id)
  local data = task_id and { taskId = task_id } or {}
  return make_request('POST', '/api/pomodoro/start', data)
end

function M.pomodoro.stop()
  return make_request('POST', '/api/pomodoro/stop')
end

function M.pomodoro.pause()
  return make_request('POST', '/api/pomodoro/pause')
end

function M.pomodoro.resume()
  return make_request('POST', '/api/pomodoro/resume')
end

function M.pomodoro.status()
  return make_request('GET', '/api/pomodoro/status')
end

function M.pomodoro.sessions(limit, date)
  local query_parts = {}
  if limit then
    table.insert(query_parts, 'limit=' .. limit)
  end
  if date then
    table.insert(query_parts, 'date=' .. date)
  end

  local query_string = #query_parts > 0 and ('?' .. table.concat(query_parts, '&')) or ''
  return make_request('GET', '/api/pomodoro/sessions' .. query_string)
end

function M.pomodoro.stats(date)
  local query_string = date and ('?date=' .. date) or ''
  return make_request('GET', '/api/pomodoro/stats' .. query_string)
end

-- Statistics
function M.stats()
  return make_request('GET', '/api/stats')
end

function M.filter_options()
  return make_request('GET', '/api/filter-options')
end

return M
