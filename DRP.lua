_G.DiscordRichPresenceMod = {
	mod_path = ModPath,
	save_path = SavePath,
	save_name = "DiscordRichPresenceMod.json",
	settings = {
		heister_icon = 1,
		use_overhaul_tag = true,
		use_rpd_string = false,
	},
}

-- Define different difficulty showcase table here
local difficulty_showcase_stars = {
	"",
	"☆☆☆☆☆☆",
	"★☆☆☆☆☆",
	"★★☆☆☆☆",
	"★★★☆☆☆",
	"★★★★☆☆",
	"★★★★★☆",
	"★★★★★★"
}

if _G.Eclipse then
	difficulty_showcase_stars = {
		"",
		"☆☆☆☆",
		"★☆☆☆",
		"★★☆☆",
		"★★★☆",
		"★★★★",
		"★★★★",
		"★★★★",
	}
elseif _G.NQR then
	difficulty_showcase_stars = {
		"",
		"☆☆☆",
		"★☆☆",
		"★★☆",
		"★★★",
		"★★★",
		"★★★",
		"★★★"
	}
end

local suffixList = {
	"_prof$",
	"_day$",
	"_night$",
	"_wrapper$"
}
local ignoreSuffix = {
	["election_day"] = true
}

local vanilla_heists = {
	"jewelry_store",
	"four_stores",
	"nightclub",
	"mallcrasher",
	"ukrainian_job",
	"branchbank_deposit",
	"branchbank_cash",
	"branchbank",
	"branchbank_gold",
	"branchbank_hl",
	"roberts",
	"firestarter",
	"alex",
	"watchdogs",
	"watchdogs_night",
	"framing_frame",
	"welcome_to_the_jungle",
	"family",
	"election_day",
	"kosugi",
	"arm_fac",
	"arm_par",
	"arm_hcm",
	"arm_und",
	"arm_cro",
	"arm_for",
	"big",
	"mia",
	"gallery",
	"hox",
	"hox_3",
	"pines",
	"cage",
	"mus",
	"crojob1",
	"crojob2",
	"rat",
	"shoutout_raid",
	"arena",
	"kenaz_full",
	"jolly",
	"red2",
	"dinner",
	"nail",
	"cane",
	"pbr",
	"pbr2",
	"peta",
	"pal",
	"man",
	"mad",
	"dark",
	"born",
	"chill",
	"chill_combat",
	"friend",
	"flat",
	"help",
	"haunted",
	"spa",
	"fish",
	"moon",
	"run",
	"glace",
	"dah",
	"rvd",
	"hvh",
	"wwh",
	"brb",
	"tag",
	"des",
	"nmh",
	"sah",
	"vit",
	"bph",
	"mex",
	"mex_cooking",
	"bex",
	"pex",
	"fex",
	"chas",
	"sand",
	"chca",
	"pent",
	"ranc",
	"trai",
	"corp",
	"deep"
}

function DiscordRichPresenceMod:InitDiscord()	
	Discord:set_large_image("jerome", "Jerome")
	Discord:set_small_image("like", "DRP init")
	
	Discord:set_start_time(0)
end

function DiscordRichPresenceMod:SetDiscordPresence(desc, game_status, state)
	if _G.DiscordRichPresenceMod.settings.use_rpd_string and _G.RichPresenceDefinitive then
		DiscordRichPresenceMod:BuildStatusFromRPD(state)
	else
		Discord:set_status(tostring(game_status), tostring(desc))
	end
end

function DiscordRichPresenceMod:SetLargeImage(id, text, is_heist, day)
	log("id is "..tostring(id))
	if not is_heist then
		Discord:set_large_image(id, text)
	else
		local custom_heist = true
		for _, value in ipairs(vanilla_heists) do
			value = "heist_" .. value
			if value == id or id == "no_briefheist" then
				custom_heist = false
				break
			end
		end
		if custom_heist then
			id = "heist_unknown"
			Discord:set_large_image(id, text)
			return
		end
		
		if day then
			--Workaround for Election Day
			if id == "heist_election_day" then
				local level_id = Global.game_settings.level_id
				--log("level_id is "..tostring(level_id))
				if level_id:find("election_day_3") then
					id = id .. "_" .. "3"
				else
					id = id .. "_" .. day
				end
			else
				id = id .. "_" .. day
			end
		end
		if string.find(id, "heist_branchbank") then
			id = "heist_branchbank"
		end
		Discord:set_large_image(id, text)
	end
end

-- Overhaul tag definition. Unlike RPD - there will be no http requests due no Dev branch check, maybe add in the future if people would request but idk
function DiscordRichPresenceMod:set_overhaul_tag()
	local tag = "Vanilla"
	
	if not _G.DiscordRichPresenceMod.settings.use_overhaul_tag then
		tag = ""
		return tag
	end
	
	-- Resmod
	if _G.SC then
		tag = "Restoration Mod"
	-- Hyper Heisting
	elseif _G.PD2THHSHIN then
		tag = "Hyper Heisting"	
	-- Crackdown
	elseif _G.deathvox then
		tag = "Crackdown"	
	-- Classic Heisting
	elseif _G.ch_settings then
		tag = "Classic Heisting"	
	-- Streamlined Heisting
	elseif _G.StreamHeist then
		tag = "Streamlined Heisting"	
	-- Original Pack
	elseif _G.OriginalPackOptions then
		tag = "Original Pack"	
	--Eclipse
	elseif _G.EclipseDebug or _G.Eclipse then
		tag = "Eclipse"	
	-- Heat (it's fucking DEAD)
	elseif _G.heat then
		tag = "HEAT"	
	-- NQR
	elseif _G.NQR then
		tag = "NQR"
	end
	
	-- Nuke tag if no overhaul detected
	if tag == "Vanilla" then
		tag = ""
	end
	
	return tag
end

-- Using RPD settings for building string
function DiscordRichPresenceMod:BuildStatusFromRPD(state)
	local RPDC = _G.RichPresenceDefinitive
			
	local gap = ""
	local BRACKET_LEFT_TAG = ""
	local BRACKET_RIGHT_TAG = ""
	local BRACKET_LEFT_1 = ""
	local BRACKET_RIGHT_1 = ""
	local BRACKET_LEFT_2 = ""
	local BRACKET_RIGHT_2 = ""
	local COMA = ""
	local ONE_DOWN_MOD = ""
	local whisper_mode = ""
	local tag_string = ""
	local steam_mm = ""
	local difficulty = ""
	local heist_name = ""
	local day_string = ""
	local heist_mode = ""
	
	local job_data = ""
	local job_id = ""
	
	if RPDC.settings.steammm_tag and SystemInfo:matchmaking() == Idstring("MM_STEAM") then
		if RPDC.settings.tag == "" then
			steam_mm = "Steam MM"
		else
			steam_mm = " Steam MM"
		end
	end

	if string.len(tostring(RPDC.settings.days)) > 1 then
		gap = " "
	end	
	
	if RPDC.settings.bracket_tag then
		BRACKET_LEFT_TAG = RPDC.settings.bracket1
		BRACKET_RIGHT_TAG = RPDC.settings.bracket2
	end

	if RPDC.settings.bracket_days then
		BRACKET_LEFT_1 = RPDC.settings.bracket1
		BRACKET_RIGHT_1 = RPDC.settings.bracket2
	end

	if RPDC.settings.bracket_diffs then
		BRACKET_LEFT_2 = RPDC.settings.bracket1
		BRACKET_RIGHT_2 = RPDC.settings.bracket2
	end

	if RPDC.settings.coma ~= "" then
		COMA = " "..RPDC.settings.coma
	end

	if Global.game_settings.one_down and RPDC.settings.one_down_mod ~= "" then 
	    ONE_DOWN_MOD = " "..RPDC.settings.one_down_mod
	else
	    ONE_DOWN_MOD = ""
	end
	
	-- OD replacement if playing in Resmod/Eclipse with PJ modifier and OD string is default one
	if ONE_DOWN_MOD == " OD" and ( _G.Eclipse or _G.SC) then
		ONE_DOWN_MOD = " PJ"
	end
	
	if RPDC.settings.od_showcase == 2 and Global.game_settings.one_down then
		ONE_DOWN_MOD = " 🕱"
	elseif RPDC.settings.od_showcase == 3 and Global.game_settings.one_down then
		ONE_DOWN_MOD = " 🕶"
	end	
	
	if RPDC.settings.tag_mode == 2 or not _G.DiscordRichPresenceMod.settings.use_overhaul_tag then
		-- Tag is unused
	else
		tag_string = BRACKET_LEFT_TAG..RPDC.settings.tag..steam_mm..BRACKET_RIGHT_TAG.." "
	end
	
	local difficulties_table = {
		RPDC.settings.ez,
		RPDC.settings.nrml,
		RPDC.settings.hrd,
		RPDC.settings.vh,
		RPDC.settings.ovk,
		RPDC.settings.mh,
		RPDC.settings.dw,
		RPDC.settings.ds,
	}		

	-- Different difficulty showcase
	if RPDC.settings.difficulty_showcase == 2 and difficulty then
		for i = 1, 8 do
			difficulties_table[i] = difficulty_showcase_stars[i]
		end
	end
	
	if state ~= "Main_menu" then
		job_data = managers.job:current_job_data()
		job_id = job_data and job_data.name_id or "no_briefheist"
		job_id = job_id:gsub("heist_", "")
		job_id = job_id:gsub("_full", "")
		job_id = job_id:gsub("_name", "")
		job_id = job_id:gsub("_hl", "")
		local cs_active = managers.crime_spree and managers.crime_spree:is_active()
		local ho_active = managers.skirmish and managers.skirmish:is_skirmish()
		if cs_active then
			heist_mode = RPDC.settings.cs..COMA.." "
		elseif ho_active then
			heist_mode = RPDC.settings.ho..COMA.." "
		end
		if job_id ~= "no_briefheist" then			
			if #(managers.job:current_job_chain_data() or {}) > 1 then
				day_string = " "..BRACKET_LEFT_1..RPDC.settings.days..gap..tostring(managers.job:current_stage())..BRACKET_RIGHT_1
			end
			if not cs_active then
				if RPDC.settings.use_save_file ~= 2 then -- Not game loc
					if job_id ~= "crojob2" and job_id ~= "tag" then -- I fucking love LGL (no)
						heist_name = RPDC.settings[job_id]..day_string
					elseif job_id == "crojob2" then
						heist_name = RPDC.settings.crojob..day_string
					elseif job_id == "tag" then
						heist_name = RPDC.settings.tag_job..day_string
					end
				else -- Game loc
					heist_name = managers.localization:text(job_data.name_id)..day_string
				end
			else
				local level_id = Global.game_settings.level_id
				if RPDC.settings.use_save_file ~= 2 then -- Not game loc
					if level_id and not ignoreSuffix[level_id] then
						for _, suffix in ipairs(suffixList) do
							level_id = level_id:gsub(suffix, "")
						end
					end
					level_id = "level_"..level_id					
					heist_name = RPDC.settings[level_id]
				else -- Game loc
					local name_id = level_id and _G.tweak_data.levels[level_id] and _G.tweak_data.levels[level_id].name_id
					if name_id then
						heist_name = managers.localization:text(name_id) or heist_name
					end
				end
			end
			if not ho_active and not cs_active then
				difficulty = tweak_data:difficulty_to_index(Global.game_settings and Global.game_settings.difficulty or 2)
				difficulty = " "..BRACKET_LEFT_2..difficulties_table[difficulty]..ONE_DOWN_MOD..BRACKET_RIGHT_2
			elseif cs_active then
				difficulty = " ("..RPDC.settings.cs_rank.." "..tostring(managers.crime_spree:server_spree_level())..")"				
			end
		else
			heist_name = managers.localization:text("discord_rp_noheist_string")
		end

		if RPDC.settings.game_state_status and (state == "MPPlaying" or state == "SPPlaying") then
			if managers.groupai:state():whisper_mode() then
				whisper_state = RPDC.settings.game_state_stealth..": "
			else
				whisper_state = RPDC.settings.game_state_loud..": "
			end
		end
	end
	
	if state == "MPPlaying" or state == "SPPlaying" then
		Discord:set_status(RPDC.settings.ingame, tag_string..whisper_state..heist_mode..heist_name..COMA..difficulty)
	elseif state == "MPLobby" then
		Discord:set_status(RPDC.settings.lobby, tag_string..heist_mode..heist_name..COMA..difficulty)
	elseif state == "SPEnd" or state == "MPEnd" then
		Discord:set_status(RPDC.settings.payday, tag_string..heist_mode..heist_name..COMA..difficulty)
	elseif state == "Main_menu" then
		Discord:set_status(RPDC.settings.menu, tag_string)
	elseif state == "Preplanning" then
		Discord:set_status(RPDC.settings.preplanning, tag_string..heist_mode..heist_name..COMA..difficulty)
	end
end

if Hooks then
	Hooks:Add("SetupInitManagers", "PostInitManager_DiscordRichPresenceMod", function()
		DiscordRichPresenceMod:InitDiscord()
	end)
end


-- Mod menu and loc stuff
Hooks:Add("LocalizationManagerPostInit", "drp_loc_init", function(...)		
	LocalizationManager:add_localized_strings({
		-- Strings for Discord
		discord_rp_cs_rank_string = " Rank ",
		discord_rp_mainmenu_string = "Main Menu",
		discord_rp_noheist_string = "No Heist Selected",
		-- Menu strings
		menu_DiscordRichPresenceMod = "Discord Rich Presence",
		
		menu_heister_icon_multiple_choice = "Heister Icon",
		menu_heister_icon_multiple_choice_desc = "Choose which heister icon style will be presented in Discord Rich Presence",
		--heister_icon_vanilla = "Vanilla",
		heister_icon_vanilla_masks = "Masks",
		heister_icon_polaroid_v1 = "Polaroid Masked",
		heister_icon_polaroid_v2 = "Polaroid Unmasked",
		heister_icon_colored = "Colored Masks",
		heister_icon_safehouse = "Safehouse Icons",
		heister_icon_fbi = "FBI Files Sketches",
		
		menu_use_rpd_string = "Build Discord RP string by using RPD string",
		menu_use_rpd_string_desc = "Discord Rich Presence will show your status generated by RPD mod.",
		
		menu_use_overhaul_tag = "Overhaul Tag",
		menu_use_overhaul_tag_desc = "Show overhaul tag in Discord Rich Presence. Affect tag showcase from RPD mod too.",
	})
	
	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			-- Strings for Discord
			discord_rp_cs_rank_string = " Ранг ",
			discord_rp_mainmenu_string = "Главное меню",
			discord_rp_noheist_string = "Ограбление не выбрано",
			-- Menu strings
			menu_DiscordRichPresenceMod = "Discord Rich Presence",
			
			menu_heister_icon_multiple_choice = "Иконка грабителя",
			menu_heister_icon_multiple_choice_desc = "Выберите каким стилем будет отображаться иконка грабителя Вашего выбранного персонажа в Discord Rich Presence",
			--heister_icon_vanilla = "Vanilla",
			heister_icon_vanilla_masks = "Маски",
			heister_icon_polaroid_v1 = "Полароид с масками",
			heister_icon_polaroid_v2 = "Полароид без масок",
			heister_icon_colored = "Цветные маски",
			heister_icon_safehouse = "Иконки сейфхауса",
			heister_icon_fbi = "Скетчи из файлов FBI",
			
			menu_use_rpd_string = "Использовать настройки RPD для Discord RP",
			menu_use_rpd_string_desc = "Discord Rich Presence будет использовать настройки из мода Rich Presence Definitive.",
			
			menu_use_overhaul_tag = "Тэг оверхалов",
			menu_use_overhaul_tag_desc = "Показывать тег оверхала, в который Вы сейчас играете. Влияет на отображение тега от Rich Presence Definitive тоже.",
		})
	end
end)

function DiscordRichPresenceMod:Save()
	local DRP = _G.DiscordRichPresenceMod
	local file = io.open(DRP.save_path..DRP.save_name, "w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function DiscordRichPresenceMod:Load()
	local DRP = _G.DiscordRichPresenceMod
	local file = io.open(DRP.save_path..DRP.save_name, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			self.settings[k] = v
		end
		file:close()
	else
		self:Save()
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_DiscordRichPresenceMod", function(...)
	DiscordRichPresenceMod:Load()
	MenuHelper:LoadFromJsonFile(DiscordRichPresenceMod.mod_path .. "DiscordRichPresenceMod.json", DiscordRichPresenceMod, DiscordRichPresenceMod.settings)
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusDiscordRichPresenceMod", function(menu_manager, nodes)
	function MenuCallbackHandler:drp_heister_icon_callback(item)
		DiscordRichPresenceMod.settings.heister_icon = item:value()
		DiscordRichPresenceMod:Save()
	end
	
	function MenuCallbackHandler:drp_toggle_callback(item)
		DiscordRichPresenceMod.settings[item:name()] = item:value() == "on"
		DiscordRichPresenceMod:Save()
	end

	local menu_id = "DiscordRichPresenceMod_options"
	MenuHelper:NewMenu(menu_id)

	MenuHelper:AddMultipleChoice({
		id = "heister_icon_multiple_choice",
		title = "menu_heister_icon_multiple_choice",
		desc = "menu_heister_icon_multiple_choice_desc",
		callback = "drp_heister_icon_callback",
		items = {
			"heister_icon_vanilla_masks",
			"heister_icon_colored",
			"heister_icon_polaroid_v1",
			"heister_icon_polaroid_v2",			
			"heister_icon_safehouse",
			"heister_icon_fbi",
		},
		value = DiscordRichPresenceMod.settings.heister_icon,
		menu_id = menu_id,
		priority = 6,
	})
	
	MenuHelper:AddToggle({
		id = "use_rpd_string",
		title = "menu_use_rpd_string",
		desc = "menu_use_rpd_string_desc",
		callback = "drp_toggle_callback",
		value = DiscordRichPresenceMod.settings.use_rpd_string,
		menu_id = menu_id,
		priority = 3,
	})
	MenuHelper:AddToggle({
		id = "use_overhaul_tag",
		title = "menu_use_overhaul_tag",
		desc = "menu_use_overhaul_tag_desc",
		callback = "drp_toggle_callback",
		value = DiscordRichPresenceMod.settings.use_overhaul_tag,
		menu_id = menu_id,
	})	

	nodes[menu_id] = MenuHelper:BuildMenu(menu_id)

	MenuHelper:AddMenuItem(nodes["blt_options"], menu_id, "menu_DiscordRichPresenceMod")
end)