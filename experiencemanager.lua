local data = ExperienceManager.on_loot_drop_xp
function ExperienceManager:on_loot_drop_xp(value_id, force)
	data(self, value_id, true)
end