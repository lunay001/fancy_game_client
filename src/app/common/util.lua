function plog(msg, ...)
    -- release_print(msg, ...)
    print(msg, ...)
end

function calcDist(x1, x2, y1, y2)
    dx = math.abs(x1 - x2)
    dy = math.abs(y1 - y2)
    return math.sqrt(dx * dx + dy * dy)
end

function createTouchableSprite(p)
    local sprite = display.newScale9Sprite(p.image)
    sprite:setContentSize(p.size)

    local cs = sprite:getContentSize()
    local label = ui.newTTFLabel({text = p.label, color = p.labelColor})
    label:setPosition(cs.width / 2, label:getContentSize().height)
    sprite:addChild(label)
    sprite.label = label

    return sprite
end

function checkDiv(s, t)
    if t == 0 then
        return 0
    elseif s == 0 then
        return 0
    else
        return s/t
    end
end

function checkMin(n, min)
    if n < min then
        return min
    else
        return n
    end
end

function checkMax(n, max)
    if n > max then
        return max
    else
        return n
    end
end

function checkRange(n, min, max)
    if n < min then
        return min
    elseif n > max then
        return max
    else
        return n
    end
end

-- 给文件名加上.png后缀
function mypng(fn)
    return string.format("%s.png", fn)
end

-- table转成string
function str2tab(str)
    local a = loadstring("return "..str)
    local b = a()
    if type(b)=="table" then
        return b
    else
        return {}
    end
end

-- 自动换行
function autoNewline(str, n)
    local len = string.utf8len(str)
    local max = math.floor(len / n) + 1
    if max > 1 then
        local rtn = ""
        local left = ""
        
        for i=1,max do
            if i>1 then
                rtn = rtn.."\n"
            end
            rtn = rtn..string.sub(str, (i-1)*15+1, i*15)
        end

        return rtn
    else
        return str
    end
end
