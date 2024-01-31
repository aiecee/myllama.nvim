local M = {}

function M.switch(value)
  return function(cases)
    local case = cases[value] or cases.default
    if case then
      return case(value)
    else
      error(string.format("Unhandled case (%s)", value), 2)
    end
  end
end

function M.notify_once_wrap(msg, level, opts)
  vim.schedule_wrap(vim.notify_once)(msg, level, opts)
end

return M
