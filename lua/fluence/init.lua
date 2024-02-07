local curl = require('plenary.curl')

---@alias FluenceInstance { url: string, username: string, token: string }

---@class FluenceInstances
---@field [string] FluenceInstance

---@class FluencePartialConfig
---@field instances? FluenceInstances

---@class Fluence
---@field instance_name string
---@field instances FluenceInstances
---@field space_key string
local Fluence = {}

Fluence.__index = Fluence

function Fluence:new()
  local fluence = setmetatable({
    instance_name = 'default',
    instances = {},
    space_key = '',
  }, self)

  return fluence
end

function Fluence:get_spaces()
  local instance = self.instances[self.instance_name]
  local res = curl.get({
    url = instance.url .. '/wiki/api/v2/spaces',
    auth = instance.username .. ':' .. instance.token,
    timeout = 5000,
  })

  local spaces = vim.json.decode(res.body).results

  vim.ui.select(spaces, {
    prompt = 'Select the space you want to use:',
    format_item = function(space)
      return space.name
    end,
  }, function(choice)
    self.space_key = choice.key
  end)

  print(self.space_key)
end

local the_fluence = Fluence:new()

---@param self Fluence
---@param partial_config FluencePartialConfig
---@return Fluence
function Fluence.setup(self, partial_config)
  if self ~= the_fluence then
    ---@diagnostic disable-next-line: cast-local-type
    partial_config = self
    self = the_fluence
  end

  if partial_config.instances ~= nil then
    self.instances = partial_config.instances
  end

  return self
end

return the_fluence
