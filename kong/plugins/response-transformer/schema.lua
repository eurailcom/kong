local find = string.find
local re_match = ngx.re.match
-- entries must have colons to set the key and value apart
local function check_for_value(value)
  for i, entry in ipairs(value) do
    local ok = find(entry, ":")
    if not ok then 
      return false, "key '"..entry.."' has no value"
    end
  end
  return true
end



local function check_regex(value)
  if value then
    for _, regex in ipairs(value) do
      local pattern, replace = string.match(regex, "(.*) => (.*)")
      if pattern == nil and replace == nil then
        return false, "value '"..regex.."' does not contain a pattern and replace"
      end
      local _, err1 = re_match("just a string to test", pattern)
      if err1 then
        return false, "value '"..pattern.."' is not a valid regex"
      end
      local _, err2 = re_match("just a string to test", replace)
      if err2 then
        return false, "value '"..replace.."' is not a valid regex"
      end
    end
  end
  return true
end

return {
  fields = {
    -- add: Add a value (to response headers or response JSON body) only if the key does not already exist.
    remove = { 
      type = "table",
      schema = {
        fields = {
          json = {type = "array", default = {}}, -- does not need colons
          headers = {type = "array", default = {}} -- does not need colons
        }
      }
    },
    replace = {
      type = "table",
      schema = {
        fields = {
          json = {type = "array", default = {}, func = check_for_value},
          headers = {type = "array", default = {}, func = check_for_value},
          body = {type = "array", default = {}, func = check_regex}
        }
      }
    },
    add = {
      type = "table",
      schema = {
        fields = {
          json = {type = "array", default = {}, func = check_for_value},
          headers = {type = "array", default = {}, func = check_for_value}
        }
      }
    },
    append = { 
      type = "table", 
      schema = {
        fields = {
          json = {type = "array", default = {}, func = check_for_value},
          headers = {type = "array", default = {}, func = check_for_value}
        }
      }
    }
  }
}
