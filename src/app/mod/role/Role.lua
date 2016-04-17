--
-- 角色数据
--

Role = class("Role")

function Role:ctor()
    self.rid = 0
    self.platform = ""
    self.zone_id = 0
    self.name = ""
    self.lev = 0
    self.hp_max = 0
    self.hp = 0
end
