--[[
    The set library allows you to have an efficient and simple functionality array for consistent data pushes.
    Inspired partly by Python's sets.Set data type, it acts like a stack while keeping track of any values
    you push into it. So you can never have more than one of the samething in your set.
]]--

local myset = set()

-- Using a set is simple, e.g. pushing.
set.push(myset, "hello")
set.push(myset, Entity(0))
set.push(myset, Entity(0)) -- Wont push again into the set!

-- Removing aswell,
set.remove(myset, "hello")

-- The amount of pushes so far.
print(set.count(myset)) -- prints '2'

-- We can index them the order they were pushed too.
print(myset[1]) -- prints 'hello'

-- And get said index too.
set.index(myset, "hello")

-- Checking to see if value already exists.
print(set.exists(myset, "hello"))

--[[
    Unlike in normal tables, you don't have to loop through a set or use table.HasValue(which is practically the same thing).
    Instead set.exists relies on a internal cache, for quick and efficient lookup. Providing little to no overhead compared to the above methods.
]]--

-- Two more functions exist too. Given that I said it was stack-like, it also provides to functions to complement that.
local value = set.pop(myset) -- Removes and returns the last pushed value.
print(value) -- prints '[0][worldspawn]'

local value = set.shift(myset) -- Removes and returns the first pushed value.
print(value) -- prints 'hi'

-- And to check if any variable is a set
print(set.IsSet("i am a string!")) -- prints 'false'

-- Like table.* functions, all functions can be called as a method.
myset:pop()
myset:count() or #myset
myset:push("hello")

-- etc