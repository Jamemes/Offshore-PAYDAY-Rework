local data = ExperienceManager.on_loot_drop_xp
function ExperienceManager:on_loot_drop_xp(value_id, force)
	data(self, value_id, true)
end

local data = ExperienceManager.cash_string
function ExperienceManager:cash_string(cash, cash_sign)
	local currency = managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node() and managers.menu:active_menu().logic:selected_node():item("bet_item") and managers.menu:active_menu().logic:selected_node():item("bet_item"):value() or "offshore"
	if currency == "coins" then
		if string.len(cash) >= 6 and cash ~= managers.custom_safehouse:coins() and cash ~= managers.money:offshore() then
			cash = cash / 100000
		end

		cash_sign = ""
	end
	
	return data(self, cash, cash_sign)
end