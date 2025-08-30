local pcs = {
	10,
	20,
	30,
	40,
	50,
	60,
	70,
	80,
	80,
	90,
	100
}

for k, v in pairs(tweak_data.blackmarket.xp) do
	v.pcs = pcs
end

if tweak_data.blackmarket.xp.xp_pda9_1 then
	tweak_data.blackmarket.xp.xp_pda9_1.weight = 0.1
	tweak_data.blackmarket.xp.xp_pda9_2.weight = 0.1
	tweak_data.blackmarket.xp.xp_pda9_1.infamous = true
	tweak_data.blackmarket.xp.xp_pda9_2.infamous = true
end