function MoneyManager:can_afford_casino_fee(secured_cards, increase_infamous, preferred_card, currency)
	local node = managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node()
	if not currency then
		currency = node and node:item("bet_item") and node:item("bet_item"):value() or "offshore"
	end
	
	local casino_fee = currency == "sell_items" and 1 or self:get_cost_of_casino_fee(secured_cards, increase_infamous, preferred_card)
	local currencies = {
		offshore = self:offshore(),
		cash = self:total(),
		coins = managers.custom_safehouse and managers.custom_safehouse:coins() or 0,
		sell_items = 0
	}
	
	if node and node:item("rolls_item") and node:item("rolls_item"):value() and currency == "sell_items" then
		currencies.sell_items = node:item("rolls_item"):value()
	end
	
	return casino_fee <= currencies[currency], math.max(math.floor(currencies[currency] / casino_fee), 1)
end

local data = MoneyManager.get_cost_of_casino_fee
function MoneyManager:get_cost_of_casino_fee(secured_cards, increase_infamous, preferred_card)
	local currency = managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node() and managers.menu:active_menu().logic:selected_node():item("bet_item") and managers.menu:active_menu().logic:selected_node():item("bet_item"):value() or "offshore"
	local mul = currency ~= "sell_items" and managers.menu:active_menu() and managers.menu:active_menu().logic:selected_node():item("rolls_item") and managers.menu:active_menu().logic:selected_node():item("rolls_item"):value()
	return math.round(data(self, secured_cards, increase_infamous, preferred_card) * (mul or 1) / (currency == "coins" and 100000 or 1))
end