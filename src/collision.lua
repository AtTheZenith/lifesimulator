FUNCTIONS = {}

FUNCTIONS.colliding = function(entity_1, entity_2)
	local dx = entity_2.x - entity_1.x
	local dy = entity_2.y - entity_1.y

	local overlap_x = (entity_1.width + entity_2.width) / 2 - math.abs(dx)
	local overlap_y = (entity_1.height + entity_2.height) / 2 - math.abs(dy)

	return overlap_x > 0 and overlap_y > 0
end

FUNCTIONS.handle = function(entity_1, entity_2)
	local dx = entity_2.x - entity_1.x
	local dy = entity_2.y - entity_1.y

	local overlap_x = (entity_1.width + entity_2.width) / 2 - math.abs(dx)
	local overlap_y = (entity_1.height + entity_2.height) / 2 - math.abs(dy)

	if overlap_x > 0 and overlap_y > 0 then
		local b1_vx = entity_1.move_direction[0] * entity_1.speed * entity_1.size
		local b1_vy = entity_1.move_direction[1] * entity_1.speed * entity_1.size
		local b2_vx = entity_2.move_direction[0] * entity_2.speed * entity_2.size
		local b2_vy = entity_2.move_direction[1] * entity_2.speed * entity_2.size

		local relative_vx = b2_vx - b1_vx
		local relative_vy = b2_vy - b1_vy

		local max_correction = 5
		local correction_factor = 0.3

		if overlap_x < overlap_y then
			local move_x = overlap_x * correction_factor

			if math.abs(relative_vx) > 0 then
				move_x = math.max(-max_correction, math.min(move_x, max_correction))
				if relative_vx > 0 then
					entity_1.manual_pos(entity_1.x + move_x, entity_1.y)
					entity_2.manual_pos(entity_2.x - move_x, entity_2.y)
				else
					entity_1.manual_pos(entity_1.x - move_x, entity_1.y)
					entity_2.manual_pos(entity_2.x + move_x, entity_2.y)
				end
			else
				if math.abs(b1_vx) > math.abs(b2_vx) then
					entity_1.manual_pos(entity_1.x + move_x, entity_1.y)
					entity_2.manual_pos(entity_2.x - move_x, entity_2.y)
				else
					entity_1.manual_pos(entity_1.x - move_x, entity_1.y)
					entity_2.manual_pos(entity_2.x + move_x, entity_2.y)
				end
			end
		else
			local move_y = overlap_y * correction_factor
			if math.abs(relative_vy) > 0 then
				move_y = math.max(-max_correction, math.min(move_y, max_correction))
				if relative_vy > 0 then
					entity_1.manual_pos(entity_1.x, entity_1.y + move_y)
					entity_2.manual_pos(entity_2.x, entity_2.y - move_y)
				else
					entity_1.manual_pos(entity_1.x, entity_1.y - move_y)
					entity_2.manual_pos(entity_2.x, entity_2.y + move_y)
				end
			else
				if math.abs(b1_vy) > math.abs(b2_vy) then
					entity_1.manual_pos(entity_1.x, entity_1.y + move_y)
					entity_2.manual_pos(entity_2.x, entity_2.y - move_y)
				else
					entity_1.manual_pos(entity_1.x, entity_1.y - move_y)
					entity_2.manual_pos(entity_2.x, entity_2.y + move_y)
				end
			end
		end
	end
end
