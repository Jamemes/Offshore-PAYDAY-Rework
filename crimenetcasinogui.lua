function CrimeNetCasinoGui:_place_bet()
	if self._betting then
		return
	end

	local secure_cards, increase_infamous, preferred_card = self:_crimenet_casino_additional_cost()

	if not managers.money:can_afford_casino_fee(secure_cards, increase_infamous, preferred_card) then
		return
	end

	local params = {
		dialog = "menu_cn_casino_pay_fee",
		contract_fee = managers.experience:cash_string(managers.money:get_cost_of_casino_fee(secure_cards, increase_infamous, preferred_card)),
		offshore = managers.experience:cash_string(managers.money:offshore()),
		yes_func = callback(self, self, "_crimenet_casino_pay_fee")
	}
	
	local currency = managers.menu:active_menu().logic:selected_node():item("bet_item"):value()
	if currency == "cash" then
		params.dialog = "menu_cn_casino_pay_cash"
		params.offshore = managers.experience:cash_string(managers.money:total())
	elseif currency == "coins" then
		params.dialog = "menu_cn_casino_pay_coins"
		params.offshore = managers.experience:experience_string(managers.custom_safehouse and managers.custom_safehouse:coins())
		params.contract_fee = managers.experience:experience_string(managers.money:get_cost_of_casino_fee(secure_cards, increase_infamous, preferred_card))
	end

	managers.menu:show_confirm_pay_casino_fee(params)
end

function CrimeNetCasinoGui:_crimenet_casino_pay_fee()
	local secure_cards, increase_infamous, preferred_card = self:_crimenet_casino_additional_cost()

	if not managers.money:can_afford_casino_fee(secure_cards, increase_infamous, preferred_card) then
		return
	end
	
	local casino_fee = managers.money:get_cost_of_casino_fee(secure_cards, increase_infamous, preferred_card)
	if managers.menu:active_menu().logic:selected_node():item("preferred_item") then
		local currency = managers.menu:active_menu().logic:selected_node():item("bet_item"):value()
		if currency == "cash" then
			managers.money:deduct_from_total(casino_fee)
		elseif currency == "coins" then
			managers.custom_safehouse:deduct_coins(casino_fee)
		else
			managers.money:deduct_from_offshore(casino_fee)
		end
		
		if type(managers.money.dispatch_event) ~= "nil" then
			managers.money:dispatch_event("casino_fee_paid", casino_fee)
		end
		
		managers.menu:active_menu().renderer:selected_node():set_offshore_text()

		local casino_data = {
			preferred_item = preferred_card,
			secure_cards = secure_cards,
			increase_infamous = increase_infamous,
			rolls_amount = managers.menu:active_menu().logic:selected_node():item("rolls_item"):value() or 1
		}

		managers.menu:open_node(casino_data.rolls_amount > 1 and "offshore_casino_claim_rewards" or "crimenet_contract_casino_lootdrop", {casino_data})
	end
end