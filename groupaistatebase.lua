-- Update Stealth/Loud status
Hooks:PostHook(GroupAIStateBase, "set_whisper_mode", "send_whisper_mode_data_to_rich_presence_discord", function (self, enabled)
	if not Global.game_settings.single_player then
		managers.platform:set_rich_presence_discord("MPPlaying")
	else
		managers.platform:set_rich_presence_discord("SPPlaying")
	end
end)