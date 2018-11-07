-- Copyright(c) Cragon. All rights reserved.
-- 由ControllerPlayer管理

---------------------------------------
OnlineReward = {}

---------------------------------------
function OnlineReward:new(o, view_mgr)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.ViewMgr = view_mgr
    o.OnlineRewardState = OnlineRewardState.CountDown
    o.LeftTm = 0
    o.CanGetReward = false
    o.NextReward = 0
    o.FormatLeftTm = ""
    return o
end

---------------------------------------
function OnlineReward:Update()
    local tm = 1
    if (self.CanGetReward == false) then
        if (self.LeftTm > 0) then
            self.LeftTm = self.LeftTm - tm
            self.FormatLeftTm = CS.Casinos.LuaHelper.FormatTmFromSecondToMinute(self.LeftTm, false)
            local ev = self.ViewMgr:GetEv("EvEntityRefreshLeftOnlineRewardTm")
            if (ev == nil) then
                ev = EvEntityRefreshLeftOnlineRewardTm:new(nil)
            end
            ev.left_reward_second = self.FormatLeftTm
            ev.give_chip_min = give_gold_min
            ev.is_success = is_success
            self.ViewMgr:SendEv(ev)

            if (self.LeftTm <= 0) then
                self.CanGetReward = true
                self:_sendCanGetReward()
            end
        end
    end
end

---------------------------------------
function OnlineReward:setOnlineRewardState(online_reward_state, left_reward_second, next_reward)
    self.OnlineRewardState = online_reward_state
    self.NextReward = next_reward
    if (self.OnlineRewardState == OnlineRewardState.Wait4GetReward) then
        self.CanGetReward = true
    else
        self.CanGetReward = false
        self.LeftTm = left_reward_second
    end
    self:_sendCanGetReward()
end

---------------------------------------
function OnlineReward:onGetReward()
    if (self.CanGetReward == true) then
        local ev = self.ViewMgr:GetEv("EvRequestGetOnLineReward")
        if (ev == nil) then
            ev = EvRequestGetOnLineReward:new(nil)
        end
        self.ViewMgr:SendEv(ev)
    else
        ViewHelper:UiShowInfoSuccess(string.format(self.ViewMgr.LanMgr:getLanValue("OnlineReward"), tostring(self.FormatLeftTm), tostring(self.NextReward)))
    end
end

---------------------------------------
function OnlineReward:IfCanGetReward()
    return self.CanGetReward
end

---------------------------------------
function OnlineReward:_sendCanGetReward()
    local ev = self.ViewMgr:GetEv("EvEntityCanGetOnlineReward")
    if (ev == nil) then
        ev = EvEntityCanGetOnlineReward:new(nil)
    end
    ev.can_getreward = self.CanGetReward
    self.ViewMgr:SendEv(ev)
end