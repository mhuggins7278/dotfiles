local tasknotes = require 'tasknotes'

return function()
  -- Use basic list endpoint with NO filters - filtering is done in Lua below
  local response = tasknotes.tasks.list()

  if not response.success then
    vim.notify('Error fetching tasks: ' .. (response.error or 'Unknown error'), vim.log.levels.ERROR)
    return
  end

  local tasks = response.data.tasks or {}
  
  -- Debug: print what we got from API
  vim.notify('API returned ' .. #tasks .. ' tasks', vim.log.levels.INFO)
  for i, task in ipairs(tasks) do
    vim.notify('Task ' .. i .. ': status=' .. (task.status or 'nil') .. ', title=' .. task.title, vim.log.levels.INFO)
  end
  
  -- Filter out "done" and archived tasks, keep "todo" and "in-progress"
  tasks = vim.tbl_filter(function(task)
    return task.status ~= 'done' and not task.archived
  end, tasks)
  
  vim.notify('After filtering: ' .. #tasks .. ' tasks', vim.log.levels.INFO)
  
  if #tasks == 0 then
    vim.notify('No active tasks found', vim.log.levels.INFO)
    return
  end

  -- Sort tasks by priority (high > normal > low) then by due date
  local priority_order = { high = 1, normal = 2, low = 3 }
  table.sort(tasks, function(a, b)
    local a_priority = priority_order[a.priority] or 2
    local b_priority = priority_order[b.priority] or 2
    
    if a_priority ~= b_priority then
      return a_priority < b_priority
    end
    
    -- If priority is same, sort by due date (earliest first, nil dates last)
    if a.due and b.due then
      return a.due < b.due
    elseif a.due then
      return true
    elseif b.due then
      return false
    end
    
    return a.title < b.title
  end)

  -- Helper to open task details in floating window
  local function open_task_details(task, reopen_picker)
    if not task then return end
    
    -- Fetch full task details from API (list endpoint may not include all fields)
    local response = tasknotes.tasks.get(task.id)
    
    if not response.success then
      vim.notify('Error fetching task details: ' .. (response.error or 'Unknown error'), vim.log.levels.ERROR)
      return
    end
    
    -- Use the full task data from the API
    local full_task = response.data.task or response.data
    
    -- Read the actual markdown file to get content/details
    local vault_path = vim.fn.expand '~/github/mhuggins7278/notes'
    local file_path = vault_path .. '/' .. full_task.path
    local file_details = ''
    
    -- Try to read the file
    local file = io.open(file_path, 'r')
    if file then
      local content = file:read('*all')
      file:close()
      
      -- Extract content after frontmatter
      -- TaskNotes uses --- delimiters for YAML frontmatter
      local after_frontmatter = content:match('%-%-%-\n.*\n%-%-%-\n(.*)$')
      if after_frontmatter then
        file_details = after_frontmatter:gsub('^%s+', ''):gsub('%s+$', '') -- trim whitespace
      end
    end
    
    -- Create a new scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'filetype', 'yaml')
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    
    -- Helper to format array fields
    local function format_array(arr)
      if not arr or type(arr) ~= 'table' or #arr == 0 then return '' end
      return table.concat(arr, ', ')
    end
    
    -- Helper to safely convert field to string
    local function to_string(val)
      if val == nil or val == vim.NIL then
        return ''
      end
      return tostring(val)
    end
    
    -- Format task details in editable YAML-like format
    local lines = {
      '# Task Details - Edit and save with :w',
      '# Press q to close and reopen picker',
      '',
      'title: ' .. to_string(full_task.title),
      'status: ' .. (full_task.status or 'todo'),
      'priority: ' .. (full_task.priority or 'normal'),
      'due: ' .. to_string(full_task.due),
      'scheduled: ' .. to_string(full_task.scheduled),
      'tags: ' .. format_array(full_task.tags),
      'contexts: ' .. format_array(full_task.contexts),
      'projects: ' .. format_array(full_task.projects),
      'timeEstimate: ' .. to_string(full_task.timeEstimate),
      '',
      '# Details (everything below this line)',
    }
    
    -- Add file content as details
    if file_details and file_details ~= '' then
      for line in file_details:gmatch('[^\n]+') do
        table.insert(lines, line)
      end
    end
    
    -- Set buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_name(buf, 'Task: ' .. full_task.title)
    
    -- Calculate floating window size
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    -- Open in a floating window
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
      title = ' Task: ' .. full_task.title .. ' ',
      title_pos = 'center',
    })
    
    -- Set up save handler
    vim.api.nvim_create_autocmd('BufWriteCmd', {
      buffer = buf,
      callback = function()
        local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        
        -- Parse the edited content
        local updated_task = {}
        local in_details = false
        local details_lines = {}
        
        for i, line in ipairs(content) do
          -- Check if we've reached the details section
          if line:match('^# Details') then
            in_details = true
          elseif in_details and not line:match('^#') then
            -- Collect everything after the details marker
            table.insert(details_lines, line)
          elseif not in_details and not line:match('^#') then
            -- Parse field lines
            if line:match('^title:%s*(.*)') then
              updated_task.title = line:match('^title:%s*(.*)')
            elseif line:match('^status:%s*(.*)') then
              updated_task.status = line:match('^status:%s*(.*)')
            elseif line:match('^priority:%s*(.*)') then
              updated_task.priority = line:match('^priority:%s*(.*)')
            elseif line:match('^due:%s*(.*)') then
              local due = line:match('^due:%s*(.*)')
              updated_task.due = (due ~= '' and due) or vim.NIL
            elseif line:match('^scheduled:%s*(.*)') then
              local scheduled = line:match('^scheduled:%s*(.*)')
              updated_task.scheduled = (scheduled ~= '' and scheduled) or vim.NIL
            elseif line:match('^tags:%s*(.*)') then
              local tags_str = line:match('^tags:%s*(.*)')
              if tags_str and tags_str ~= '' then
                updated_task.tags = {}
                for tag in tags_str:gmatch('[^,%s]+') do
                  table.insert(updated_task.tags, tag)
                end
              else
                updated_task.tags = {}
              end
            elseif line:match('^contexts:%s*(.*)') then
              local contexts_str = line:match('^contexts:%s*(.*)')
              if contexts_str and contexts_str ~= '' then
                updated_task.contexts = {}
                for context in contexts_str:gmatch('[^,%s]+') do
                  table.insert(updated_task.contexts, context)
                end
              else
                updated_task.contexts = {}
              end
            elseif line:match('^projects:%s*(.*)') then
              local projects_str = line:match('^projects:%s*(.*)')
              if projects_str and projects_str ~= '' then
                updated_task.projects = {}
                for project in projects_str:gmatch('[^,%s]+') do
                  table.insert(updated_task.projects, project)
                end
              else
                updated_task.projects = {}
              end
            elseif line:match('^timeEstimate:%s*(.*)') then
              local estimate = line:match('^timeEstimate:%s*(.*)')
              if estimate and estimate ~= '' then
                updated_task.timeEstimate = tonumber(estimate)
              else
                updated_task.timeEstimate = vim.NIL
              end
            end
          end
        end
        
        -- Join details lines
        local new_file_details = ''
        if #details_lines > 0 then
          new_file_details = table.concat(details_lines, '\n')
        end
        
        -- Update task metadata via API (without details)
        local response = tasknotes.tasks.update(full_task.id, updated_task)
        
        if response.success then
          -- Now update the file content with the new details
          local file = io.open(file_path, 'r')
          if file then
            local original_content = file:read('*all')
            file:close()
            
            -- Replace content after frontmatter
            local before_end = original_content:match('(%-%-%-\n.*\n%-%-%-)\n')
            if before_end then
              local new_content = before_end .. '\n' .. new_file_details .. '\n'
              
              -- Write updated content back
              file = io.open(file_path, 'w')
              if file then
                file:write(new_content)
                file:close()
                vim.notify('Task updated successfully', vim.log.levels.INFO)
                vim.api.nvim_buf_set_option(buf, 'modified', false)
              else
                vim.notify('Error writing file details', vim.log.levels.ERROR)
              end
            else
              vim.notify('Could not parse frontmatter', vim.log.levels.ERROR)
            end
          else
            vim.notify('Task metadata updated (could not update details)', vim.log.levels.WARN)
            vim.api.nvim_buf_set_option(buf, 'modified', false)
          end
        else
          vim.notify('Error updating task: ' .. (response.error or 'Unknown error'), vim.log.levels.ERROR)
        end
      end,
    })
    
    -- Set up close handler to reopen picker
    local function close_and_reopen()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if reopen_picker then
        vim.schedule(function()
          vim.cmd('Obsidian tasknotes')
        end)
      end
    end
    
    -- Set keymaps
    vim.keymap.set('n', 'q', close_and_reopen, { buffer = buf, nowait = true, desc = 'Close and reopen picker' })
    vim.keymap.set('n', '<Esc>', close_and_reopen, { buffer = buf, nowait = true, desc = 'Close and reopen picker' })
  end

  -- Helper to toggle task status
  local function toggle_task_status(task, callback)
    -- Cycle through: todo -> in-progress -> done -> todo
    local status_cycle = {
      todo = 'in-progress',
      ['in-progress'] = 'done',
      done = 'todo',
    }
    
    local new_status = status_cycle[task.status] or 'in-progress'
    local response = tasknotes.tasks.update(task.id, { status = new_status })
    
    if response.success then
      vim.notify('Task status changed to: ' .. new_status, vim.log.levels.INFO)
      if callback then callback() end
    else
      vim.notify('Error toggling status: ' .. (response.error or 'Unknown error'), vim.log.levels.ERROR)
    end
  end

  -- Helper to start/stop time tracking
  local function toggle_time_tracking(task)
    -- Check if time is currently active
    local active_response = tasknotes.time.active_sessions()
    
    if not active_response.success then
      vim.notify('Error fetching active sessions: ' .. vim.inspect(active_response), vim.log.levels.ERROR)
      return
    end
    
    -- API returns data.activeSessions array
    -- Each session has structure: { task: { id, title, ... }, session: { startTime, ... }, elapsedMinutes: ... }
    local sessions = {}
    if active_response.data and active_response.data.activeSessions then
      sessions = active_response.data.activeSessions
    end
    
    -- Look for an active session matching this task
    for _, active_session in ipairs(sessions) do
      -- Each session has { task: { id: ... }, session: {...} }
      if active_session.task and active_session.task.id and tostring(active_session.task.id) == tostring(task.id) then
        -- Stop tracking
        local response = tasknotes.time.stop(task.id)
        if response.success then
          vim.notify('Stopped time tracking for: ' .. task.title, vim.log.levels.INFO)
        else
          vim.notify('Error stopping time: ' .. vim.inspect(response), vim.log.levels.ERROR)
        end
        return
      end
    end
    
    -- Start tracking (no active session found)
    local response = tasknotes.time.start(task.id)
    if response.success then
      vim.notify('Started time tracking for: ' .. task.title, vim.log.levels.INFO)
    else
      vim.notify('Error starting time: ' .. vim.inspect(response), vim.log.levels.ERROR)
    end
  end

  -- Helper to archive task
  local function archive_task(task, callback)
    local response = tasknotes.tasks.archive(task.id)
    if response.success then
      vim.notify('Archived task: ' .. task.title, vim.log.levels.INFO)
      if callback then callback() end
    else
      vim.notify('Error archiving: ' .. (response.error or 'Unknown error'), vim.log.levels.ERROR)
    end
  end

  -- Helper to toggle pomodoro (start/stop based on current state)
  local function toggle_pomodoro(task)
    -- First check current pomodoro status
    local status = tasknotes.pomodoro.status()
    
    -- Debug logging
    vim.notify('Status response: ' .. vim.inspect(status), vim.log.levels.DEBUG)
    
    if status.success and status.data and status.data.isRunning then
      -- If a pomodoro is running, stop it
      local response = tasknotes.pomodoro.stop()
      if response.success then
        vim.notify('Stopped pomodoro', vim.log.levels.INFO)
      else
        vim.notify('Error stopping pomodoro: ' .. (response.error or 'Unknown error'), vim.log.levels.ERROR)
      end
    else
      -- If no active pomodoro, start one for this task
      local response = tasknotes.pomodoro.start(task.id)
      if response.success then
        vim.notify('Started pomodoro for: ' .. task.title, vim.log.levels.INFO)
      else
        vim.notify('Error starting pomodoro: ' .. (response.error or 'Unknown error'), vim.log.levels.ERROR)
      end
    end
  end

  -- Helper to format task display
  local function format_task(task)
    local parts = {}
    
    -- Priority icon/indicator
    local priority = task.priority or 'normal'
    local priority_icon = priority == 'high' and '🔴' or (priority == 'low' and '🔵' or '⚪')
    table.insert(parts, priority_icon)
    
    -- Title
    table.insert(parts, task.title)
    
    -- Due date
    if task.due then
      table.insert(parts, '→ ' .. task.due)
    end
    
    return table.concat(parts, '  ')
  end

  -- Try Snacks picker first
  local has_snacks, snacks = pcall(require, 'snacks')
  if has_snacks and snacks.picker then
    local vault_path = vim.fn.expand '~/github/mhuggins7278/notes'
    local items = vim.tbl_map(function(task)
      return {
        text = format_task(task),
        file = vault_path .. '/' .. task.path,  -- Add file field to prevent errors
        task = task,
      }
    end, tasks)

    snacks.picker.pick {
      title = 'TaskNotes Tasks',
      items = items,
      formatters = {},  -- Disable default formatters
      format = function(item)
        -- Determine highlight group based on status
        local hl_group = 'Comment'  -- Default gray for todo
        if item.task.status == 'in-progress' then
          hl_group = 'WarningMsg'  -- Yellow for in-progress
        end
        
        -- Return highlight chunks with spacing
        return { { item.text, hl_group } }
      end,
      confirm = function(picker, item)
        if item then
          picker:close()
          open_task_details(item.task, true)
        end
      end,
      actions = {
        toggle_status = function(picker, item)
          if item then
            picker:close()
            toggle_task_status(item.task, function()
              -- Refresh picker after toggle
              vim.schedule(function()
                vim.cmd('Obsidian tasknotes')
              end)
            end)
          end
        end,
        toggle_time = function(picker, item)
          if item then
            toggle_time_tracking(item.task)
          end
        end,
        archive = function(picker, item)
          if item then
            picker:close()
            archive_task(item.task, function()
              -- Refresh picker after archive
              vim.schedule(function()
                vim.cmd('Obsidian tasknotes')
              end)
            end)
          end
        end,
        pomodoro = function(picker, item)
          if item then
            toggle_pomodoro(item.task)
          end
        end,
      },
      win = {
        input = {
          keys = {
            ['<c-t>'] = { 'toggle_status', mode = { 'n', 'i' }, desc = 'Toggle Task Status' },
            ['<c-s>'] = { 'toggle_time', mode = { 'n', 'i' }, desc = 'Start/Stop Time Tracking' },
            ['<c-v>'] = { 'archive', mode = { 'n', 'i' }, desc = 'Archive Task' },
            ['<c-p>'] = { 'pomodoro', mode = { 'n', 'i' }, desc = 'Toggle Pomodoro' },
          },
        },
      },
    }
    return
  end

  -- Try Telescope picker second
  local has_telescope, pickers = pcall(require, 'telescope.pickers')
  local has_finders, finders = pcall(require, 'telescope.finders')
  local has_conf, conf = pcall(require, 'telescope.config')
  local has_actions, actions = pcall(require, 'telescope.actions')
  local has_action_state, action_state = pcall(require, 'telescope.actions.state')

  if has_telescope and has_finders and has_conf and has_actions and has_action_state then
    pickers
      .new({}, {
        prompt_title = 'TaskNotes Tasks',
        finder = finders.new_table {
          results = tasks,
          entry_maker = function(task)
            return {
              value = task,
              display = format_task(task),
              ordinal = task.title,
            }
          end,
        },
        sorter = conf.values.generic_sorter {},
        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            open_task_details(selection and selection.value)
          end)
          return true
        end,
      })
      :find()
    return
  end

  -- Fallback to vim.ui.select
  vim.ui.select(tasks, {
    prompt = 'Select a TaskNotes task:',
    format_item = format_task,
  }, open_task_details)
end
