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

-- TODO: Clean-up this function after mod release because I got tired while resolving all bullshit with discord rich presence assets shenanigans
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

    local character = managers.blackmarket:get_preferred_character()
    local character_name = loc:text("menu_" .. managers.blackmarket:get_preferred_character())
	local heister_icon_style = DRP.settings.heister_icon
	heister_icon_style = icon_style[heister_icon_style]

    for _, char in pairs(character_ids) do
        if character == char then           
			Discord:set_small_image(tostring(character).. heister_icon_style, tostring(character_name))
            break
        end
    end
	
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
		
        local job_difficulty = _G.tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or 1
        local job_difficulty_text = " [" .. loc:to_upper_text(_G.tweak_data.difficulty_name_ids[job_difficulty]) .. "]"
		
		-- Nuke difficulty if CS or Holdout is active
		if crime_spree_active or holdout_active then
			job_difficulty_text = ""
		end		

        if job_name == loc:text("discord_rp_noheist_string") then
            job_difficulty_text = ""
        end
		
		local day_string = ""

		if #(managers.job:current_job_chain_data() or {}) > 1 then
			day_string = loc:to_upper_text("discord_rp_day_string", {
				day = tostring(managers.job:current_stage())
			})
			day_string = " " .. day_string
		end

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. day_string .. job_difficulty_text, loc:text("discord_rp_ingame_string"))

		if playing then
            Discord:set_start_time_relative(0)
        end

        if name == "MPPlaying" then
			Discord:set_party_size(managers.network:session():amount_of_players(), _G.tweak_data.max_players)
		end
		
    elseif name == "MPLobby" then
        local job_difficulty = _G.tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or 1
        local job_difficulty_text = " [" .. loc:to_upper_text(_G.tweak_data.difficulty_name_ids[job_difficulty]) .. "]"

        if job_name == loc:text("discord_rp_noheist_string") then
            job_difficulty_text = ""
        end
		
		-- Nuke difficulty if CS or Holdout is active
		if crime_spree_active or holdout_active then
			job_difficulty_text = ""
		end
		
		local day_number = nil
		if not holdout_active and not crime_spree_active then
			if #(managers.job:current_job_chain_data() or {}) > 1 then
				day_number = tostring(managers.job:current_stage())
			end
			
			DRP:SetLargeImage(job_id, job_name, true, day_number)
		end

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. job_difficulty_text, loc:text("discord_rp_lobby_string"))
        Discord:set_party_size(managers.network:session():amount_of_players(), _G.tweak_data.max_players)

    elseif name == "SPEnd" or name == "MPEnd" then
		local day_string = ""

		if #(managers.job:current_job_chain_data() or {}) > 1 then
			day_string = loc:to_upper_text("discord_rp_day_string", {
				day = tostring(managers.job:current_stage())
			})
			day_string = " " .. day_string
		end

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. day_string, loc:text("menu_l_lootscreen"))
        Discord:set_start_time(0)
    elseif _G.game_state_machine and _G.game_state_machine:current_state_name() == "menu_main" then
        Discord:set_party_size(0, 0)
		Discord:set_large_image("pd2_main_menu_drp", "PAYDAY 2") 
        DRP:SetDiscordPresence(tag_whisper_string, loc:text("discord_rp_mainmenu_string"))
	else -- Preplanning state
        local job_difficulty = _G.tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or 1
        local job_difficulty_text = " [" .. loc:to_upper_text(_G.tweak_data.difficulty_name_ids[job_difficulty]) .. "]"
		
		-- Nuke difficulty if CS or Holdout is active
		if crime_spree_active or holdout_active then
			job_difficulty_text = ""
		end	
		
		local day_string = ""
		local day_number = nil
		
		if not holdout_active and not crime_spree_active then
			if #(managers.job:current_job_chain_data() or {}) > 1 then
				day_string = loc:to_upper_text("discord_rp_day_string", {
					day = tostring(managers.job:current_stage())
				})
				day_number = tostring(managers.job:current_stage())
				day_string = " " .. day_string
			end
		end			
			
		DRP:SetLargeImage(job_id, job_name, true, day_number)
		

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. day_string .. job_difficulty_text, loc:text("discord_rp_preplanning_string"))

		if playing then
            Discord:set_start_time_relative(0)
        end

        if name == "MPPlaying" then
			Discord:set_party_size(managers.network:session():amount_of_players(), _G.tweak_data.max_players)
		end
    end
end

-- idk why Sora nuke these functions instead of overriding them properly to update data when game request it
function WinPlatformManager:update_discord_character()
	local DRP = _G.DiscordRichPresenceMod
	local loc = managers.localization	
	
	local character = managers.blackmarket:get_preferred_character()
    local character_name = loc:text("menu_" .. managers.blackmarket:get_preferred_character())
	local heister_icon_style = DRP.settings.heister_icon
	heister_icon_style = icon_style[heister_icon_style]

    for _, char in pairs(character_ids) do
        if character == char then           
			Discord:set_small_image(tostring(character).. heister_icon_style, tostring(character_name))
            break
        end
    end
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
	
	if name == "MPLobby" then
        local job_difficulty = _G.tweak_data.difficulties[managers.job:current_difficulty_stars() + 2] or 1
        local job_difficulty_text = " [" .. loc:to_upper_text(_G.tweak_data.difficulty_name_ids[job_difficulty]) .. "]"

        if job_name == loc:text("discord_rp_noheist_string") then
            job_difficulty_text = ""
        end
		
		local day_number = nil
		if not holdout_active and not crime_spree_active then
			if #(managers.job:current_job_chain_data() or {}) > 1 then
				day_number = tostring(managers.job:current_stage())
			end
			
			DRP:SetLargeImage(job_id, job_name, true, day_number)
		end

        DRP:SetDiscordPresence(tag_whisper_string .. job_name .. job_difficulty_text, loc:text("discord_rp_lobby_string"))
        Discord:set_party_size(managers.network:session():amount_of_players(), _G.tweak_data.max_players)
	end
end

--[[ Branch, car shop, go bank, Alesso, trans harbor, trans park, 
Hostile
Counterfeit Heat Street No mercy
Mid ranch
Firestarter 
Dragon heist Ukrainian prsioner
Beneath Birth BorderMeth Breakfast Brooklyn bank 
Yacht
Big bank DaDiamond
Election Biker heist
Black cat Buluc Four stores Goat Nightclub San Martion Stealing xmas 
--]]