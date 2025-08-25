function MoneyManager:can_afford_casino_fee(secured_cards, increase_infamous, preferred_card)
	local currency = managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node():item("bet_item") and managers.menu:active_menu().logic:selected_node():item("bet_item"):value() or "offshore"
	local casino_fee = self:get_cost_of_casino_fee(secured_cards, increase_infamous, preferred_card)

	local currencies = {
		offshore = self:offshore(),
		cash = self:total(),
		coins = managers.custom_safehouse and managers.custom_safehouse:coins() or 0
	}
	
	return casino_fee <= currencies[currency]
end

local data = MoneyManager.get_cost_of_casino_fee
function MoneyManager:get_cost_of_casino_fee(secured_cards, increase_infamous, preferred_card)
	local currency = managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node() and managers.menu:active_menu().logic:selected_node():item("bet_item") and managers.menu:active_menu().logic:selected_node():item("bet_item"):value() or "offshore"
	local mul = managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node():item("rolls_item") and managers.menu:active_menu().logic:selected_node():item("rolls_item"):value()
	return math.round(data(self, secured_cards, increase_infamous, preferred_card) * (mul or 1) / (currency == "coins" and 100000 or 1))
end
