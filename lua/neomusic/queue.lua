---@class Queue
---@field items table
---@field max_items integer
local Queue = {}

Queue.__index = Queue

---Create a new queue
---@param max_items? integer
---@return Queue
function Queue:new(max_items)
    local queue = setmetatable({
        items = {},
        max_items = max_items or 1000
    }, self)

    return queue
end

---Push an element into the queue
---@param item any
function Queue:push(item)
    local nm_win = require("neomusic.window")

    if #self.items == self.max_items then
        nm_win.notification("The music queue is full, please remove some items")
        return
    end
    table.insert(self.items, item)
end

---Pop an element from the queue
---@return any
function Queue:pop()
    if self:is_empty() then
        return nil
    end
    local item = table.remove(self.items, 0)
    return item
end

---Empty the queue completely
function Queue:drain()
    for _, item in ipairs(self.items) do
        table.remove(self.items, item)
    end
end

---Check if the queue is empty
---@return boolean
function Queue:is_empty()
    return vim.tbl_isempty(self.items)
end

return Queue
