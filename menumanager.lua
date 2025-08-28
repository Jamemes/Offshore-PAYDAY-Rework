Hooks:Add("LocalizationManagerPostInit", "TweakdataListGui_loc", function(...)		
	LocalizationManager:add_localized_strings({
		menu_cs_generating_rewards = "Generating Loot...",
		menu_cs_loot_drops_remaining = "Remaining Loot Drops: $loot;",
		menu_cs_loot_drops_not_shown = "Plus $remaining; more loot drops!",
		menu_bet_offshore = "Offshore",
		menu_bet_cash = "Cash",
		menu_bet_coins = "Coins",
		menu_rolls_item = "Rolls",
		menu_bet_item = "Bet",
		menu_casino_stat_cash = "Spending Cash",
		menu_casino_stat_xp = "Experience",
		menu_sell_items = "Items",
		menu_disposal_item = "Pawn",
		menu_sell_payout_item = "Items to sell amount",
		menu_casino_sell_prefer_title = "Preferred item to sell",
		menu_casino_total_sell = "Overall Items Value: $casino_bet;",
		menu_generating_sells = "Selling Loot...",
		menu_loot_drops_selling = "Remaining Loot to be sold: $loot;",
		menu_loot_sells_not_shown = "Plus $remaining; more loot has been sold.",
		menu_cn_casino_pay_cash = "A fee will be deducted from your spending cash when you enter the casino.\n\nCost: $contract_fee;\nSpending cash: $offshore;",
		menu_cn_casino_pay_coins = "A fee will be deducted from your continental coins when you enter the casino.\n\nCost: $contract_fee;\nContinental coins: $offshore;",
		menu_cn_casino_sell_items = "After confirmation, some items will be sold from your stock and you will receive cash in return. The type of items will be selected randomly, except if you have selected the category. If the expected amount of money exceeds the total value of all the items, then all the items that you have will be sold.\n\nAmount of items to be sold: $contract_fee;",
	})
	
	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			menu_cs_generating_rewards = "Создаем добычу...",
			menu_cs_loot_drops_remaining = "Еще наград: $loot;",
			menu_cs_loot_drops_not_shown = "Еще $remaining; карточек с добычей!",
			menu_bet_offshore = "Офшор",
			menu_bet_cash = "Наличные",
			menu_bet_coins = "Монеты",
			menu_rolls_item = "Кол-во ставок",
			menu_bet_item = "Ставка",
			menu_casino_stat_cash = "Наличные",
			menu_casino_stat_xp = "Опыт",
			menu_sell_items = "Вещи",
			menu_disposal_item = "Заложить",
			menu_sell_payout_item = "Вещей на продажу",
			menu_casino_sell_prefer_title = "Предпочтительная вещь",
			menu_casino_total_sell = "Общая ценность вещей: $casino_bet;",
			menu_generating_sells = "Продаем добычу...",
			menu_loot_drops_selling = "Оставшаяся добыча на продажу: $loot;",
			menu_loot_sells_not_shown = "Еще $remaining; добычи было продано.",
			menu_cn_casino_pay_cash = "Средства будут списаны с ваших наличных, когда вы войдете в казино.\n\nСтоимость: $contract_fee;\nНаличные: $offshore;",
			menu_cn_casino_pay_coins = "Средства будут списаны с ваших Континенталь монет, когда вы войдете в казино.\n\nСтоимость: $contract_fee;\nКонтиненталь монеты: $offshore;",
			menu_cn_casino_sell_items = "После подтверждения, некоторые предметы будут проданы из вашего запаса и вы получите взамен наличные деньги. Тип предметов будут выбраны в случайном порядке, за исключением если вы выбрали категорию. Если ожидаемая сумма денег превышает общую стоимость всех вещей, то все вещи которые у вас есть будут проданы.\n\nКоличество вещей на продажу: $contract_fee;",
		})
	end
end)

function MenuCrimeNetCasinoInitiator:refresh_node(node)
	local options = {
		bet = node:item("bet_item"):value(),
		rolls = node:item("rolls_item"):value(),
		preferred = node:item("preferred_item"):value(),
		infamous = node:item("increase_infamous"):value(),
		card1 = node:item("secure_card_1"):value(),
		card2 = node:item("secure_card_2"):value(),
		card3 = node:item("secure_card_3"):value()
	}

	node:clean_items()
	self:_create_items(node, options)

	return node
end

function MenuCrimeNetCasinoInitiator:_create_items(node, options)
	local visible_callback = "casino_betting_visible"
	local bet_data = {
		{
			value = "offshore",
			text_id = "menu_bet_offshore",
			_meta = "option"
		},
		{
			value = "cash",
			text_id = "menu_bet_cash",
			_meta = "option"
		},
		type = "MenuItemMultiChoice"
	}
	
	if managers.custom_safehouse then
		table.insert(bet_data, {
			value = "coins",
			text_id = "menu_bet_coins",
			_meta = "option"
		})
	end
	
	table.insert(bet_data, {
		value = "sell_items",
		text_id = "menu_sell_items",
		_meta = "option"
	})
	
	local bet_params = {
		name = "bet_item",
		callback = "crimenet_casino_update",
		text_id = "",
		visible_callback = visible_callback
	}
	local bet_item = node:create_item(bet_data, bet_params)
	bet_item:set_value(options and options.bet or "offshore")

	node:add_item(bet_item)

	self:create_divider(node, "casino_divider_bet", nil, 12)
	
	local sell_items = options and options.bet and options.bet == "sell_items"
	local card1 = options and options.card1 == "on" and 1 or 0
	local card2 = options and options.card2 == "on" and 1 or 0
	local card3 = options and options.card3 == "on" and 1 or 0
	local secure_cards = card1 + card2 + card3
	local _, max_bets = managers.money:can_afford_casino_fee(secure_cards, tostring(options and options.infamous) == "on", options and options.preferred or "none", bet_item:value())

	if sell_items then
		_, max_bets = managers.lootdrop:get_stashed_items(options and options.preferred or "none")
	end
	
	local rolls_data = {
		localize = false,
		show_value = true,
		step = 1,
		type = "CoreMenuItemSlider.ItemSlider",
		decimal_count = 0,
		min = 1,
		max = max_bets
	}
		
	local rolls_params = {
		name = "rolls_item",
		callback = "crimenet_casino_update_slider",
		text_id = " ",
		visible_callback = visible_callback
	}
	local rolls_item = node:create_item(rolls_data, rolls_params)
	rolls_item:set_value(options and options.rolls or 1)

	node:add_item(rolls_item)
	
	local preferred_data = {
		{
			value = "none",
			text_id = sell_items and "menu_any" or "menu_casino_option_prefer_none",
			_meta = "option"
		},
		{
			value = "weapon_mods",
			text_id = "menu_casino_stat_weapon_mods",
			_meta = "option"
		},
		{
			value = "masks",
			text_id = "menu_casino_stat_masks",
			_meta = "option"
		},
		{
			value = "materials",
			text_id = "menu_casino_stat_materials",
			_meta = "option"
		},
		{
			value = "textures",
			text_id = "menu_casino_stat_textures",
			_meta = "option"
		},
		{
			value = "colors",
			text_id = "menu_casino_stat_colors",
			_meta = "option"
		},
		type = "MenuItemMultiChoice"
	}
	
	if not sell_items then
		table.insert(preferred_data, 2, {
			value = "cash",
			text_id = "menu_casino_stat_cash",
			_meta = "option"
		})
		
		table.insert(preferred_data, 2, {
			value = "xp",
			text_id = "menu_casino_stat_xp",
			_meta = "option"
		})
	end
	
	local preferred_params = {
		name = "preferred_item",
		callback = "crimenet_casino_update",
		text_id = "",
		visible_callback = visible_callback
	}
	local preferred_item = node:create_item(preferred_data, preferred_params)

	if not sell_items and managers.experience:current_level() < tweak_data:get_value("casino", "secure_card_level", 1) then
		preferred_item:set_value("none")
		preferred_item:set_enabled(false)
	else
		preferred_item:set_value(options and options.preferred or "none")
	end

	node:add_item(preferred_item)

	local infamous_data = {
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "on",
			s_w = 24,
			s_h = 24,
			s_x = 24,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 24,
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "off",
			s_w = 24,
			s_h = 24,
			s_x = 0,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 0,
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	local infamous_params = {
		name = "increase_infamous",
		callback = "crimenet_casino_update",
		text_id = "menu_casino_option_infamous_title",
		icon_by_text = true,
		disabled_color = Color(0.25, 1, 1, 1),
		visible_callback = visible_callback
	}
	local infamous_items = {
		textures = true,
		colors = false,
		materials = true,
		weapon_mods = false,
		masks = true
	}
	local preferred_value = preferred_item:value()
	local infamous_item = node:create_item(infamous_data, infamous_params)

	infamous_item:set_enabled(not sell_items and infamous_items[preferred_value])

	if not infamous_item:enabled() then
		infamous_item:set_value("off")
	else
		infamous_item:set_value(options and options.infamous or "off")
	end

	node:add_item(infamous_item)
	self:create_divider(node, "casino_divider_securecards")

	local card1_data = {
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "on",
			s_w = 24,
			s_h = 24,
			s_x = 24,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 24,
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "off",
			s_w = 24,
			s_h = 24,
			s_x = 0,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 0,
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	local card1_params = {
		name = "secure_card_1",
		callback = "crimenet_casino_safe_card1",
		text_id = "menu_casino_option_safecard1",
		icon_by_text = true,
		disabled_color = Color(0.25, 1, 1, 1),
		visible_callback = visible_callback
	}

	if managers.experience:current_level() < tweak_data:get_value("casino", "secure_card_level", 1) then
		card1_params.disabled_color = Color(1, 0.6, 0.2, 0.2)
		card1_params.text_id = managers.localization:to_upper_text("menu_casino_option_safecard1") .. " - " .. managers.localization:to_upper_text("menu_casino_option_safecard_lock", {
			level = tweak_data:get_value("casino", "secure_card_level", 1)
		})
		card1_params.localize = "false"
	end

	local card1_item = node:create_item(card1_data, card1_params)

	card1_item:set_value(preferred_item:value() ~= "none" and options and options.card1 or "off")

	if sell_items or managers.experience:current_level() < tweak_data:get_value("casino", "secure_card_level", 1) then
		card1_item:set_enabled(false)
	else
		card1_item:set_enabled(preferred_item:value() ~= "none")
	end

	node:add_item(card1_item)

	local card2_data = {
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "on",
			s_w = 24,
			s_h = 24,
			s_x = 24,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 24,
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "off",
			s_w = 24,
			s_h = 24,
			s_x = 0,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 0,
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	local card2_params = {
		name = "secure_card_2",
		callback = "crimenet_casino_safe_card2",
		text_id = "menu_casino_option_safecard2",
		icon_by_text = true,
		disabled_color = Color(0.25, 1, 1, 1),
		visible_callback = visible_callback
	}

	if managers.experience:current_level() < tweak_data:get_value("casino", "secure_card_level", 2) then
		card2_params.disabled_color = Color(1, 0.6, 0.2, 0.2)
		card2_params.text_id = managers.localization:to_upper_text("menu_casino_option_safecard2") .. " - " .. managers.localization:to_upper_text("menu_casino_option_safecard_lock", {
			level = tweak_data:get_value("casino", "secure_card_level", 2)
		})
		card2_params.localize = "false"
	end

	local card2_item = node:create_item(card2_data, card2_params)

	card2_item:set_value(preferred_item:value() ~= "none" and options and options.card2 or "off")

	if sell_items or managers.experience:current_level() < tweak_data:get_value("casino", "secure_card_level", 2) then
		card2_item:set_enabled(false)
	else
		card2_item:set_enabled(preferred_item:value() ~= "none")
	end

	node:add_item(card2_item)

	local card3_data = {
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "on",
			s_w = 24,
			s_h = 24,
			s_x = 24,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 24,
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = 24,
			y = 0,
			h = 24,
			s_y = 24,
			value = "off",
			s_w = 24,
			s_h = 24,
			s_x = 0,
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = 0,
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	local card3_params = {
		name = "secure_card_3",
		callback = "crimenet_casino_safe_card3",
		text_id = "menu_casino_option_safecard3",
		icon_by_text = true,
		disabled_color = Color(0.25, 1, 1, 1),
		visible_callback = visible_callback
	}

	if managers.experience:current_level() < tweak_data:get_value("casino", "secure_card_level", 3) then
		card3_params.disabled_color = Color(1, 0.6, 0.2, 0.2)
		card3_params.text_id = managers.localization:to_upper_text("menu_casino_option_safecard3") .. " - " .. managers.localization:to_upper_text("menu_casino_option_safecard_lock", {
			level = tweak_data:get_value("casino", "secure_card_level", 3)
		})
		card3_params.localize = "false"
	end

	local card3_item = node:create_item(card3_data, card3_params)

	card3_item:set_value(preferred_item:value() ~= "none" and options and options.card3 or "off")

	if sell_items or managers.experience:current_level() < tweak_data:get_value("casino", "secure_card_level", 3) then
		card3_item:set_enabled(false)
	else
		card3_item:set_enabled(preferred_item:value() ~= "none")
	end

	node:add_item(card3_item)
	self:create_divider(node, "casino_cost")

	local increase_infamous = infamous_item:value() == "on"
	local secured_cards = (card1_item:value() == "on" and 1 or 0) + (card2_item:value() == "on" and 1 or 0) + (card3_item:value() == "on" and 1 or 0)

	if options then
		managers.menu:active_menu().renderer:selected_node():set_update_values(preferred_item:value(), secured_cards, increase_infamous, infamous_item:enabled(), card1_item:enabled())
		managers.menu_component:can_afford()
	end
end

function MenuCallbackHandler:crimenet_casino_update_slider(item)
	if item:enabled() then
		item._value = math.round(item._value)
		local node = managers.menu:active_menu().logic:selected_node()
		local card1 = node:item("secure_card_1") and node:item("secure_card_1"):value() == "on" and 1 or 0
		local card2 = node:item("secure_card_2") and node:item("secure_card_2"):value() == "on" and 1 or 0
		local card3 = node:item("secure_card_3") and node:item("secure_card_3"):value() == "on" and 1 or 0
		local secure_cards = card1 + card2 + card3
		local infamous_item = node:item("increase_infamous") and node:item("increase_infamous")
		local preferred_card = node:item("preferred_item") and node:item("preferred_item"):value() or "none"
		local preferred_card = node:item("preferred_item") and node:item("preferred_item"):value() or "none"
		managers.menu:active_menu().renderer:selected_node():set_update_values(preferred_card, secure_cards, infamous_item:value() == "on", infamous_item:enabled(), node:item("secure_card_1") and node:item("secure_card_1"):enabled())
		managers.menu_component:can_afford()
	end
end

function MenuManager:show_confirm_pay_casino_fee(params)
	local dialog_data = {
		title = managers.localization:text("dialog_casino_pay_title"),
		text = managers.localization:text(params.dialog, {
			contract_fee = params.contract_fee,
			offshore = params.offshore
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("menu_cn_casino_pay_accept"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuCallbackHandler:casino_betting_visible()
	return true
end