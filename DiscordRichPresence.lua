core:module("PlatformManager")

local character_ids = {
    "russian", -- Dallas
    "german", -- Wolf
    "american", -- Houston
    "spanish", -- Chains
    "old_hoxton",
    "dragan", -- The best character
    "jowi",
    "bodhi",
    "bonnie",
    "chico",
    "dragon",
    "ecp_female",
    "ecp_male",
    "female_1",
    "jacket",
    "jimmy",
    "joy",
    "myh",
    "max",
    "sokol",
    "sydney",
    "wild"
}

local icon_style = {
	"_vanilla_masks",
	"_colored",
	"_polaroid_v1",
	"_polaroid_v2",			
	"_safehouse",
	"_fbi",
}

local function get_difficulty_text(crime_spree_active, holdout_active, job_name)
	local loc = managers.localization
	
	local job_difficulty = _G.tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or 1
    local job_difficulty_text = " [" .. loc:to_upper_text(_G.tweak_data.difficulty_name_ids[job_difficulty]) .. "]"

    -- Nuke difficulty text if CS or Holdout is active
	if crime_spree_active or holdout_active then
		job_difficulty_text = ""
	end
	
	if job_name == loc:text("discord_rp_noheist_string") then
        job_difficulty_text = ""
    end

	return job_difficulty_text
end

local function set_character_data()
	local DRP = _G.DiscordRichPresenceMod
	local loc = managers.localization
	
	local character = managers.blackmarket:get_preferred_character()
    local character_name = loc:text("menu_" .. managers.blackmarket:get_preferred_character())
	local heister_icon_style = DRP.settings.heister_icon
	heister_icon_style = icon_style[heister_icon_style]

    for _, char in pairs(character_ids) do
        if character == char then           
			Discord:set_small_image(tostring(character)..heister_icon_style, tostring(character_name))
            break
        end
    end
end

local function get_day_string(crime_spree_active, holdout_active, for_large_image)
	local loc = managers.localization
	local day_string = ""
	local day_number = nil
	
	if not holdout_active and not crime_spree_active and #(managers.job:current_job_chain_data() or {}) > 1 then
		if not for_large_image then
			day_string = loc:to_upper_text("discord_rp_day_string", {
				day = tostring(managers.job:current_stage())
			})
			day_string = " " .. day_string
			return day_string
		else
			day_number = tostring(managers.job:current_stage())
			return day_number
		end
	else
		if not for_large_image then
			return day_string
		else
			return day_number
		end
	end	
end

function WinPlatformManager:set_rich_presence_discord(name)
	local DRP = _G.DiscordRichPresenceMod
	
	local loc = managers.localization
	local overhaul_tag = DRP:set_overhaul_tag()
	local tag_whisper_string = ""
    if overhaul_tag ~= "" then
		tag_whisper_string = "[".. overhaul_tag .."] "
	end
    local job_data = managers.job:current_job_data()
    local job_name = job_data and loc:text(job_data.name_id) or loc:text("discord_rp_noheist_string")
	local job_id = job_data and job_data.name_id or "no_briefheist"
	--log("job_id is "..tostring(job_id))
    local playing = self._current_presence == "Playing" or false

    set_character_data()
	
	local crime_spree_active = false
	local holdout_active = false
	-- Show CS rank
	if managers.crime_spree and managers.crime_spree:is_active() then
		crime_spree_active = true
		DRP:SetLargeImage("crime_spree", job_name)
		if name ~= "MPLobby" then -- Don't show host rank in lobby
			job_name = job_name .. loc:text("discord_rp_cs_rank_string") .. tostring(managers.crime_spree:server_spree_level())
		end
	end
	-- Add Holdout prefix
	if managers.skirmish and managers.skirmish:is_skirmish() then
		job_name = loc:text("menu_skirmish") .. " - " .. job_name
		DRP:SetLargeImage("skirmish", loc:text("menu_skirmish"))
		holdout_active = true
	end
	
	local num_players = 0
	local max_players = _G.tweak_data and _G.tweak_data.max_players or 4
	
	if name == "MPPlaying" or name == "SPPlaying" then
		if managers and managers.network then
			num_players = managers.network:session():amount_of_alive_players()
		end
	end

    if (name == "MPPlaying" or name == "SPPlaying") and num_players > 0 then
		local whisper_state = ""
		if managers and managers.groupai and not holdout_active then
			if managers.groupai:state():whisper_mode() then
				whisper_state = loc:text("menu_plan_stealth") .. ": "
			else
				whisper_state = loc:text("menu_plan_loud").. ": "
			end
		end
		tag_whisper_string = tag_whisper_string .. whisper_state
		
        local job_difficulty_text = get_difficulty_text(crime_spree_active, holdout_active, job_name)
		
		local day_string = get_day_string(crime_spree_active, holdout_active, false)

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. day_string .. job_difficulty_text, loc:text("menu_lobby_server_state_in_game"), name)

		if playing then
            Discord:set_start_time_relative(0)
        end

        if name == "MPPlaying" then
			Discord:set_party_size(managers.network:session():amount_of_players(), max_players)
		end		
    elseif name == "MPLobby" then        
		local job_difficulty_text = get_difficulty_text(crime_spree_active, holdout_active, job_name)
		
		local day_number = get_day_string(crime_spree_active, holdout_active, true)		
		
		if not crime_spree_active and not holdout_active then
			DRP:SetLargeImage(job_id, job_name, true, day_number)
		end

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. job_difficulty_text, loc:text("menu_lobby_server_state_in_lobby"), name)
        Discord:set_party_size(managers.network:session():amount_of_players(), max_players)
    elseif name == "SPEnd" or name == "MPEnd" then
		local day_string = get_day_string(crime_spree_active, holdout_active, false)

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. day_string, loc:text("menu_l_lootscreen"), name)
        Discord:set_start_time(0)
    elseif _G.game_state_machine and _G.game_state_machine:current_state_name() == "menu_main" then
        Discord:set_party_size(0, 0)
		Discord:set_large_image("pd2_main_menu_drp", "PAYDAY 2")
        DRP:SetDiscordPresence(tag_whisper_string, loc:text("discord_rp_mainmenu_string"), "Main_menu")
	else -- Preplanning state
        local job_difficulty_text = get_difficulty_text(crime_spree_active, holdout_active, job_name)
		
		local day_string = get_day_string(crime_spree_active, holdout_active, false)
		local day_number = get_day_string(crime_spree_active, holdout_active, true)
			
		if not crime_spree_active and not holdout_active then
			DRP:SetLargeImage(job_id, job_name, true, day_number)
		end

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. day_string .. job_difficulty_text, loc:text("menu_lobby_server_state_briefing"), "Preplanning")

		if playing then
            Discord:set_start_time_relative(0)
        end

        if name == "MPPlaying" then
			Discord:set_party_size(managers.network:session():amount_of_players(), max_players)
		end
    end
end

-- idk why Sora nuke these functions instead of overriding them properly to update data when game request it
function WinPlatformManager:update_discord_character()
	set_character_data()
end

function WinPlatformManager:update_discord_heist()
	local DRP = _G.DiscordRichPresenceMod
	
	local name = self._current_rich_presence
	
	local loc = managers.localization
	local overhaul_tag = DRP:set_overhaul_tag()
	local tag_whisper_string = ""
    if overhaul_tag ~= "" then	
		tag_whisper_string = "[".. overhaul_tag .."] "
	end
	local job_data = managers.job:current_job_data()	
    local job_name = job_data and loc:text(job_data.name_id) or loc:text("discord_rp_noheist_string")
	local job_id = job_data and job_data.name_id or "no_briefheist"
	
	local holdout_active = false
	-- Add Holdout prefix
	if managers.skirmish and managers.skirmish:is_skirmish() then
		job_name = loc:text("menu_skirmish") .. " - " .. job_name
		DRP:SetLargeImage("skirmish", loc:text("menu_skirmish"))
		holdout_active = true
	end
	
	local max_players = _G.tweak_data and _G.tweak_data.max_players or 4
	
	if name == "MPLobby" then
        local job_difficulty_text = get_difficulty_text(false, holdout_active, job_name)
		
		local day_number = get_day_string(false, holdout_active, true)
		
		if not holdout_active then
			DRP:SetLargeImage(job_id, job_name, true, day_number)
		end

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. job_difficulty_text, loc:text("menu_lobby_server_state_in_lobby"), name)
        Discord:set_party_size(managers.network:session():amount_of_players(), max_players)
	end
end

Hooks:PostHook(WinPlatformManager, "set_rich_presence", "set_rich_presence_drp", function(self, key, value)
    self:set_rich_presence_discord(self._current_rich_presence)
end)