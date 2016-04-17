local map_data = {}
local item
local baseList = {}
map_data["base"] = baseList

item = {}
item.id = 10000
item.name = "平原"
item.width = 4500
item.height = 3000
baseList[1] = item


local startupList = {}
map_data["startup"] = startupList
return map_data
