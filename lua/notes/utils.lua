local M = {}

-- Configuration will be set by init.lua
local config = {}

-- Function to set up utils configuration
function M.setup(opts)
	config = opts or {}
end

-- Function to get today's date in configured format
function M.get_today_date()
	return os.date(config.date_format)
end

-- Function to get yesterday's date in configured format
function M.get_yesterday_date()
	return os.date(config.date_format, os.time() - 86400)
end

-- Function to get current time in configured format
function M.get_current_time()
	return os.date(config.time_format)
end

-- Function to get date with a specific day offset (can be negative or positive)
function M.get_date_with_offset(days_offset)
	return os.date(config.date_format, os.time() + (days_offset * 86400))
end

-- Function to get the configured space replacement character
function M.get_space_replacement()
	return config.space_replacement or "-"
end

return M
