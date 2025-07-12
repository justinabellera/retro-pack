/*
       ██▀███ ▓████▄▄▄█████▓██▀███  ▒█████ 
      ▓██ ▒ ██▓█   ▓  ██▒ ▓▓██ ▒ ██▒██▒  ██▒ 
      ▓██ ░▄█ ▒███ ▒ ▓██░ ▒▓██ ░▄█ ▒██░  ██▒ 
      ▒██▀▀█▄ ▒▓█  ░ ▓██▓ ░▒██▀▀█▄ ▒██   ██░
      ░██▓ ▒██░▒████▒▒██▒ ░░██▓ ▒██░ ████▓▒░
      ░ ▒▓ ░▒▓░░ ▒░ ░▒ ░░  ░ ▒▓ ░▒▓░ ▒░▒░▒░
 ██▓███▒ ▄▄▄ ▒ ░  ▄████▄░ ██ ▄█▄▄▄ ▒░  ▒ ▄████▓█████
▓██░  ██▒████▄   ▒██▀ ▀█  ██▄█▒████▄    ██▒ ▀█▓█   ▀
▓██░ ██▓▒██  ▀█▄ ▒▓█    ▄▓███▄▒██  ▀█▄ ▒██░▄▄▄▒███ 
▒██▄█▓▒ ░██▄▄▄▄██▒▓▓▄ ▄██▓██ █░██▄▄▄▄██░▓█  ██▒▓█  ▄ 
▒██▒ ░  ░▓█   ▓██▒ ▓███▀ ▒██▒ █▓█   ▓██░▒▓███▀░▒████▒
▒▓▒░ ░  ░▒▒   ▓▒█░ ░▒ ▒  ▒ ▒▒ ▓▒▒   ▓▒█░░▒   ▒░░ ▒░
░▒ ░      ▒   ▒▒ ░ ░  ▒  ░ ░▒ ▒░▒   ▒▒ 
░░        ░   ▒  ░       ░ ░░ ░ ░   ▒       ░ v1.0.3

Developer: @rtros
Date: May 19, 2025
Compatibility: Modern Warfare Remastered (HMW Mod)

Notes:
- Added animation_duration variable (when opening/closing menu)
- Added Nightshade Update options (Guns, Killstreaks) (thanks to @bbsaabaru for the help)
*/

#include scripts\utility;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\_retropack_binds;
#include scripts\mp\_retropack_utility;
#include scripts\mp\_retropack_functions;

retropack_variables() {
  /* Menu Variables */
  self.retropack["utility"] = spawnstruct();
  self.retropack["utility"].font = "objective";
  self.retropack["utility"].font_scale = 0.7;
  self.retropack["utility"].option_limit = 8;
  self.retropack["utility"].option_spacing = 11;
	self.retropack["utility"].animation_duration = 0.08;
	self.retropack["utility"].menu_title_gap = 25;
	self.retropack["utility"].menu_width = 150;
	self.retropack["utility"].menu_height = 23 + self.retropack["utility"].menu_title_gap + (self.retropack["utility"].option_limit * self.retropack["utility"].option_spacing);
  self.retropack["utility"].offscreen_y_offset = -200;
  self.retropack["utility"].x_offset = -(self.retropack["utility"].menu_width / 2);
  self.retropack["utility"].y_offset = -165 * GetDvarFloat("safeArea_adjusted_vertical");
  self.retropack["utility"].element_list = ["text", "submenu", "toggle", "category", "slider", "divider"];
  self.retropack["utility"].interaction = true;
  self.element_count = 0;

  /* Menu Storage */
  self.cursor = [];
  self.previous = [];

  self set_menu("Home");
}

monitor_buttons() {
  self endon("disconnect");
  level endon("game_ended");
  self notifyOnPlayerCommand("menu_open", "+actionslot 1");
  self notifyOnPlayerCommand("menu_open", "+lookup");
  self notifyOnPlayerCommand("menu_left", "+melee");
  self notifyOnPlayerCommand("menu_left", "+melee_zoom");
  self notifyOnPlayerCommand("menu_right", "+reload");
  self notifyOnPlayerCommand("menu_right", "+usereload");
  self notifyOnPlayerCommand("menu_up", "+actionslot 1");
  self notifyOnPlayerCommand("menu_down", "+actionslot 2");
  self notifyOnPlayerCommand("menu_leftPC", "+toggleads_throw");
  self notifyOnPlayerCommand("menu_rightPC", "+attack");
  self notifyOnPlayerCommand("menu_upPC", "+forward");
  self notifyOnPlayerCommand("menu_downPC", "+back");
  self notifyOnPlayerCommand("menu_sliderleft", "+actionslot 3");
  self notifyOnPlayerCommand("menu_sliderright", "+actionslot 4");
  self notifyOnPlayerCommand("menu_sliderleftPC", "+moveleft");
  self notifyOnPlayerCommand("menu_sliderrightPC", "+moveright");
  while (true) { 
    if (self really_alive()) {
      if (!self in_menu()) {
        self waittill("menu_open");
				if (self adsbuttonpressed() && is_player_gamepad_enabled()) {
					if (return_toggle(self.retropack["utility"].interaction))
						self playsoundtoplayer("h1_ui_menu_warning_box_appear", self);

					self open_menu();
					self thread menu_up();
					self thread menu_down();
					self thread menu_left();
					self thread menu_right();
					self thread slider_left();
					self thread slider_right();
					if (!isDefined(self.pers["quick_binds"]) || isDefined(self.pers["quick_binds"]) && self.pers["quick_binds"])
						self thread print_quick_binds();
					wait 0.15;
				} else if (!is_player_gamepad_enabled()) {
					if (return_toggle(self.retropack["utility"].interaction))
							self playsoundtoplayer("h1_ui_menu_warning_box_appear", self);

					self open_menu();
					self thread menu_up();
					self thread menu_down();
					self thread menu_left();
					self thread menu_right();
					self thread slider_left();
					self thread slider_right();
					self freezeControls(true);
					if (!isDefined(self.pers["quick_binds"]) || isDefined(self.pers["quick_binds"]) && self.pers["quick_binds"])
							self thread print_quick_binds();
					wait 0.15;
				}
				setDvar("timescale", 1);
			}
    }
    wait 0.15;
  }
}

print_quick_binds() {
  self endon("end_menu");
  self endon("end_controls");
  while (true) {
		self clear_obituary();
		self iPrintln("^5Quick Binds^7:");
		self iPrintln("^5[{+actionslot 2}] + Prone^7: Save Location");
		self iPrintln("^5[{+actionslot 2}] + Crouch^7: Load Location");
		self iPrintln("^5[{+actionslot 3}] + Crouch^7: Bots to Crosshair");
		self iPrintln("^5[{+melee_zoom}] + Crouch^7: Toggle UFO");
		wait 7;
  }
}

menu_up() {
  self endon("disconnect");
  self endon("end_menu");
  for (;;) {
    self waittill(is_player_gamepad_enabled() ? "menu_up" : "menu_upPC");
    cursor = self get_cursor();
    if (isdefined(self.structure) && self.structure.size >= 2) {
      if (return_toggle(self.retropack["utility"].interaction))
        self playsoundtoplayer("h1_ui_menu_scroll", self);

      self set_cursor((cursor - 1));
      self update_scrolling(-1);
    }
    wait 0.1;
  }
}

menu_down() {
  self endon("disconnect");
  self endon("end_menu");
  for (;;) {
    self waittill(is_player_gamepad_enabled() ? "menu_down" : "menu_downPC");
    cursor = self get_cursor();
    if (isdefined(self.structure) && self.structure.size >= 2) {
      if (return_toggle(self.retropack["utility"].interaction))
        self playsoundtoplayer("h1_ui_menu_scroll", self);

      self set_cursor((cursor + 1));
      self update_scrolling(1);
    }
    wait 0.1;
  }
}

menu_left() {
  self endon("disconnect");
  self endon("end_menu");
  for (;;) {
    self waittill(is_player_gamepad_enabled() ? "menu_left" : "menu_leftPC");
    menu = self get_menu();
    if (return_toggle(self.retropack["utility"].interaction))
      self playsoundtoplayer(isdefined(self.previous[(self.previous.size - 1)]) ? "h1_ui_pause_menu_resume" : "h1_ui_box_text_disappear", self);

    if (isdefined(self.previous[(self.previous.size - 1)])) {
      self new_menu(self.previous[menu]);
    } else {
      self close_menu();
    }
    if (isSubStr(menu, "Player_")) {
      self new_menu("User");
    }
    wait 0.15;
  }
}

menu_right() {
  self endon("disconnect");
  self endon("end_menu");
  for (;;) {
    self waittill(is_player_gamepad_enabled() ? "menu_right" : "menu_rightPC");
    menu = self get_menu();
    cursor = self get_cursor();
    if (isdefined(self.structure[cursor].function)) {
      if (return_toggle(self.retropack["utility"].interaction))
        self playsoundtoplayer(isdefined(self.structure[cursor].toggle) ? return_toggle(self.structure[cursor].toggle) ? "mp_ui_decline" : "mp_ui_accept" : "h1_ui_menu_accept", self);

      if(menu == "Velocity" || menu == "Bolt") {
        if (return_toggle(self.structure[cursor].slider))
          self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.slider[menu + "_" + cursor + retropack_storage(1, menu)]] : self.slider[menu + "_" + cursor + retropack_storage(1, menu)], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5, self.structure[cursor].argument_6, self.structure[cursor].argument_7, self.structure[cursor].argument_8);
        else
          self thread execute_function(self.structure[cursor].function, self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5, self.structure[cursor].argument_6, self.structure[cursor].argument_7, self.structure[cursor].argument_8);
      } else {
        if (return_toggle(self.structure[cursor].slider))
          self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5, self.structure[cursor].argument_6, self.structure[cursor].argument_7, self.structure[cursor].argument_8);
        else
          self thread execute_function(self.structure[cursor].function, self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5, self.structure[cursor].argument_6, self.structure[cursor].argument_7, self.structure[cursor].argument_8);
	  }
      if (isdefined(self.structure[cursor].toggle))
        self update_menu(menu, cursor);
    }
    wait .2;
  }
}

slider_left() {
  self endon("disconnect");
  self endon("end_menu");
  for (;;) {
    self waittill(is_player_gamepad_enabled() ? "menu_sliderleft" : "menu_sliderleftPC");
    menu = self get_menu();
    cursor = self get_cursor();
    if (return_toggle(self.structure[cursor].slider)) {
      if (return_toggle(self.retropack["utility"].interaction))
        self playsoundtoplayer("h1_ui_menu_scroll", self);

      self set_slider(1);

      if (return_toggle(self.structure[cursor].execute)) {
        if(menu == "Velocity" || menu == "Bolt")
		  self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.pers["storage_array" + menu + cursor + retropack_storage(1, menu)]] : self.pers["storage_increment" + menu + cursor + retropack_storage(1, menu)], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5, self.structure[cursor].argument_6, self.structure[cursor].argument_7, self.structure[cursor].argument_8);
        else
		  self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.pers["storage_array" + menu + cursor]] : self.pers["storage_increment" + menu + cursor], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5, self.structure[cursor].argument_6, self.structure[cursor].argument_7, self.structure[cursor].argument_8);
	  }
    }
  }
}

slider_right() {
  self endon("disconnect");
  self endon("end_menu");
  for (;;) {
    self waittill(is_player_gamepad_enabled() ? "menu_sliderright" : "menu_sliderrightPC");
    menu = self get_menu();
    cursor = self get_cursor();
    if (return_toggle(self.structure[cursor].slider)) {
      if (return_toggle(self.retropack["utility"].interaction))
        self playsoundtoplayer("h1_ui_menu_scroll", self);

      self set_slider(-1);

      if (return_toggle(self.structure[cursor].execute)) {
        if(menu == "Velocity" || menu == "Bolt")
          self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.pers["storage_array" + menu + cursor + retropack_storage(1, menu)]] : self.pers["storage_increment" + menu + cursor + retropack_storage(1, menu)], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5, self.structure[cursor].argument_6, self.structure[cursor].argument_7, self.structure[cursor].argument_8);
        else
	      self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.pers["storage_array" + menu + cursor]] : self.pers["storage_increment" + menu + cursor], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5, self.structure[cursor].argument_6, self.structure[cursor].argument_7, self.structure[cursor].argument_8);		
	  }
    }
  }
}

menu_index() {
  menu = self get_menu();
  if (!isdefined(menu))
    menu = "Empty Menu";
  switch (menu) {
  case "Home":
    self add_menu(menu);
    self add_option("Trickshot Menu", ::new_menu, "Trickshot");
    self add_option("Game Settings", ::new_menu, "Game");
    self add_option(sanitise_name(self.name) + " Menu", ::new_menu, "Admin");
    self add_option("Weapon Menu", ::new_menu, "Weapons");
    self add_option("Bind Menu", ::new_menu, "Binds");
    self add_option("Killstreak Menu", ::new_menu, "Killstreak");
    self add_option("Always Menu", ::new_menu, "Always");
    self add_option("Afterhit Menu", ::new_menu, "Afterhit");
    self add_option("Player Menu", ::new_menu, "User");
    break;
  case "Trickshot":
    self add_menu(menu);
    self add_string("EB Weapon", true, ::select_eb_weapon, ["Snipers", "Select Weapon"], self);
    self add_string("EB Target", true, ::AimbotType, ["Player", "Claymore", "C4"], undefined, self);
		self add_increment("EB Delay", true, ::AimbotDelay, 0.1, 0.1, 0.5, 0.1, undefined, self);
    self add_increment("EB Radius", true, ::AimbotStrength, 0, 0, 1000, 100, undefined, self);
    self add_string("Tag Weapon", true, ::select_tag_eb_weapon, ["All", "Select Weapon"], self);
    self add_increment("Tag Radius", true, ::TagStrength, 0, 0, 1000, 100, undefined, self);
    self add_divider();
    self add_toggle("Save Location", ::do_save_location, self.pers["saved_location"], undefined, self, false);
    self add_option("Load Location", ::do_load_location, self, true);
    self add_option("Drop Can Swap", ::give_can_swap);
		self add_option("Suicide", ::do_kill, self);
    if (getDvar("g_gametype") == "dm" || getDvar("g_gametype") == "war") {
      self add_option("Fast Last", ::do_fast_last, self);
      self add_option("Reset Kills", ::do_reset_scores, 0, self);
      self add_toggle("Give TK after Tac Insert", ::toggle_tk_insert, self.pers["tk_tact"]);
    }
    self add_toggle("Quick Binds", ::toggle_quick_binds, self.pers["quick_binds"]);
    self add_toggle("Auto-Prone", ::do_auto_prone, self.pers["auto_prone"]);
    self add_toggle("Auto-Replenish Ammo", ::toggle_replenish_ammo, self.pers["auto_replenish"]);
		self add_string("Spawn Bot", false, ::spawn_bot, ["^1Enemy", "^2Friendly", "All"]);
    self add_string("Kick Bots", false, ::func_bot_kick_or_kill, ["^1Enemy", "^2Friendly", "All"], "kick");
    self add_string("Reset Bot Locations", false, ::func_reset_bot_locations, ["^1Enemy", "^2Friendly", "All"]);
    break;
  case "Afterhit":
    self add_menu(menu);
    self add_toggle("Afterhit", ::toggle_afterhit_status, self.pers["do_afterhit"]);
		self add_string("Afterhit Weapon", true, ::set_afterhit_weapon, ["All", "Select Weapon"]);
    self add_string("Frequency", true, ::set_afterhit_type, ["Every Shot", "End of Game"]);
    self add_category("Options");
    self add_togglemenu("Weapon", ::new_menu, self.pers["afterhit_option_weapon"], "Weapons", undefined, "Afterhit");
    self add_toggle("Knife Lunge", ::set_afterhit, self.pers["afterhit_option_lunge"], undefined, "Function", ::do_knife_lunge, "Knife Lunge", "lunge");
    self add_toggle("Melee", ::set_afterhit, self.pers["afterhit_option_melee"], undefined, "Animation", 10, "Melee", "melee");
    self add_toggle("Sprint", ::set_afterhit, self.pers["afterhit_option_sprint"], undefined, "Animation", 33, "Sprint", "sprint");
    self add_toggle("Mantle", ::set_afterhit, self.pers["afterhit_option_mantle"], undefined, "Animation", 50, "Mantle", "mantle");
    self add_toggle("Care Package Nac", ::set_afterhit, self.pers["afterhit_option_cp_nac"], undefined, "Nac", "airdrop_marker_mp", "Care Package Nac", "cp_nac");
    self add_toggle("Laptop Nac", ::set_afterhit, self.pers["afterhit_option_laptop_nac"], undefined, "Nac", "predator_mp", "Laptop Nac", "laptop_nac");
    self add_toggle("Laptop Nac (Fast)", ::set_afterhit, self.pers["afterhit_option_laptop_nac_fast"], undefined, "Fast Pred", "predator_mp", "Laptop Nac (Fast)", "laptop_nac_fast");
    self add_toggle("Laptop Nac Lunge", ::set_afterhit, self.pers["afterhit_option_laptop_nac_lunge"], undefined, "Pred Knife", "predator_mp", "Laptop Nac Lunge", "laptop_nac_lunge");
    break;
  case "Always":
    self add_menu(menu);
    self add_toggle("Always Raise", ::toggle_raise_status, self.pers["do_raise"]);
    self add_string("Raise Type", true, ::set_raise_type, ["None", "Fast Glide", "G-Flip", "Can Swap", "Can Zoom", "Sprint", "Invisible", "Instashoot"]);
    self add_string("Raise Weapon", true, ::set_raise_weapon, ["All", "Select Weapon", "Sniper"]);
	self add_divider();
	self add_toggle("Always Knife Lunge", ::toggle_knife_lunge, self.pers["knife_lunge"]);
    self add_toggle("Always R-Mala", ::toggle_rmala, self.pers["rmala"]);
    self add_toggle("Always Insta Tac Plant", ::toggle_instaplant, self.pers["instaplant"]);
	self add_toggle("Always OMA Shax", ::toggle_shax, self.pers["oma_shax"]);
	self add_toggle("Always OMA Running Man", ::toggle_running_man, self.pers["oma_running"]);
    self add_toggle("Always Wildscope", ::toggle_wildscope, self.pers["wildscope"]);
    self add_toggle("Always Wildscope (Lunge)", ::toggle_wildscopelunge, self.pers["wildscope_lunge"]);
    break;
	case "Binds":
	self add_menu(menu);
	buttons = [];
	for (i = 0; i < level.button_index.size; i++) {
			buttons[i] = create_button_struct(level.button_index[i], "[{" + level.button_index[i] + "}]");
	}
	for (i = 0; i < buttons.size; i++) {
			button = buttons[i];
			self add_label("   " + button.display, self.pers["bind_" + button.key + "_text"], ::new_menu, "Binds 2", button.display);
			for (j = 0; j < level.bind_features.size; j++) {
					feature = level.bind_features[j];
					if (isDefined(self.pers["bind_" + feature.key + button.key]) && self.pers["bind_" + feature.key + button.key]) {
							self add_option("   ([{" + button.key + "}]) " + feature.option_text, ::new_menu, feature.menu_name, button.key);
					}
			}
	}
  break;
  case "Binds 2":
    self add_menu(menu);
	self add_option("Off", ::set_bind, retropack_storage(1, "Binds 2"), undefined, undefined, "Off", undefined);
	self add_option("Alt Swap", ::set_bind, retropack_storage(1, "Binds 2"), "altswap", ::bind_altswap, "Alt Swap", undefined);
	self add_option("Blast Shield", ::set_bind, retropack_storage(1, "Binds 2"), "blastshield", ::bind_blastshield, "Blast Shield", undefined);
	self add_option("Bolt", ::set_bind, retropack_storage(1, "Binds 2"), "bolt", ::bind_bolt, "Bolt", undefined);
	self add_option("Bot EMP", ::set_bind, retropack_storage(1, "Binds 2"), "doemp", ::bind_emp, "Bot EMP", undefined);
	self add_option("Can Swap", ::set_bind, retropack_storage(1, "Binds 2"), "canswap", ::bind_canswap, "Can Swap", undefined);
	self add_option("Can Zoom", ::set_bind, retropack_storage(1, "Binds 2"), "zoom", ::bind_canzoom, "Can Zoom", undefined);
	self add_option("Care Package Nac", ::set_bind, retropack_storage(1, "Binds 2"), "cpnac", ::bind_fakenac, "Care Package Nac", "airdrop_marker_mp");
	self add_option("Change Class", ::set_bind, retropack_storage(1, "Binds 2"), "classchange", ::bind_classchange, "Change Class", undefined);
	self add_option("Cock Back", ::set_bind, retropack_storage(1, "Binds 2"), "cockback", ::bind_animation, "Cock Back", 7);
	self add_option("Copycat", ::set_bind, retropack_storage(1, "Binds 2"), "copycat", ::bind_copycat, "Copycat", undefined);
	self add_option("Damage Buffer", ::set_bind, retropack_storage(1, "Binds 2"), "damagebuffer", ::bind_damagebuffer, "Damage Buffer", undefined);
	self add_option("Damage", ::set_bind, retropack_storage(1, "Binds 2"), "damage", ::bind_damage, "Damage", undefined);
	self add_option("Destroy Tac", ::set_bind, retropack_storage(1, "Binds 2"), "destroytac", ::bind_destroytac, "Destroy Tac", undefined);
	self add_option("Empty Mag", ::set_bind, retropack_storage(1, "Binds 2"), "emptymag", ::bind_emptymag_real, "Empty Mag", undefined);
	self add_option("Fast Glide", ::set_bind, retropack_storage(1, "Binds 2"), "fastglide", ::bind_fastglide, "Fast Glide", undefined);
	self add_option("Final Stand", ::set_bind, retropack_storage(1, "Binds 2"), "finalstand", ::bind_finalstand, "Final Stand", undefined);
	self add_option("Flash", ::set_bind, retropack_storage(1, "Binds 2"), "flash", ::bind_flash, "Flash", undefined);
	self add_option("G-Flip", ::set_bind, retropack_storage(1, "Binds 2"), "gflip", ::bind_gflip, "G-Flip", undefined);
	self add_option("Hitmarker", ::set_bind, retropack_storage(1, "Binds 2"), "hitmarker", ::bind_hitmarker, "Hitmarker", undefined);
	self add_option("Inspect", ::set_bind, retropack_storage(1, "Binds 2"), "inspect", ::bind_animation, "Inspect", 58);
	self add_option("Instaswap", ::set_bind, retropack_storage(1, "Binds 2"), "instaswap", ::bind_instaswap, "Instaswap", undefined);
	self add_option("Invisible Gun", ::set_bind, retropack_storage(1, "Binds 2"), "invisible", ::bind_animation, "Invisible Gun", 17);
	self add_option("Knife Lunge", ::set_bind, retropack_storage(1, "Binds 2"), "knifeanim", ::bind_lunge, "Knife Lunge", undefined);
	self add_option("Laptop Nac", ::set_bind, retropack_storage(1, "Binds 2"), "prednac", ::bind_fakenac, "Laptop Nac", "predator_mp");
	self add_option("Last Bullet", ::set_bind, retropack_storage(1, "Binds 2"), "lastbullet", ::bind_lastbullet, "Last Bullet", undefined);
	self add_option("Last Stand", ::set_bind, retropack_storage(1, "Binds 2"), "laststand", ::bind_laststand, "Last Stand", undefined);
	self add_option("Mantle", ::set_bind, retropack_storage(1, "Binds 2"), "mantle", ::bind_animation, "Mantle", 50);
	self add_option("Nac Mod", ::set_bind, retropack_storage(1, "Binds 2"), "nacmod", ::bind_nacmod, "Nac Mod", undefined);
	self add_option("OMA Shax", ::set_bind, retropack_storage(1, "Binds 2"), "omashax", ::bind_omashax, "OMA Shax", undefined);
	self add_option("Painkiller", ::set_bind, retropack_storage(1, "Binds 2"), "painkiller", ::bind_painkiller, "Painkiller", undefined);
	self add_option("Reload", ::set_bind, retropack_storage(1, "Binds 2"), "reload", ::bind_animation, "Reload", 20);
	self add_option("Repeater", ::set_bind, retropack_storage(1, "Binds 2"), "repeater", ::bind_repeater, "Repeater", undefined);
	self add_option("Scavenger", ::set_bind, retropack_storage(1, "Binds 2"), "scavenger", ::bind_scavenger, "Scavenger", undefined);
	self add_option("Semtext Stuck", ::set_bind, retropack_storage(1, "Binds 2"), "stuck", ::bind_stuck, "Semtext Stuck", undefined);
	self add_option("Smooth", ::set_bind, retropack_storage(1, "Binds 2"), "smooth", ::bind_animation, "Smooth", 1);
	self add_option("Sprint", ::set_bind, retropack_storage(1, "Binds 2"), "running", ::bind_animation, "Sprint", 33);
	self add_option("Third Eye", ::set_bind, retropack_storage(1, "Binds 2"), "thirdeye", ::bind_thirdeye, "Third Eye", undefined);
	self add_option("Velocity", ::set_bind, retropack_storage(1, "Binds 2"), "velocity", ::bind_velocity, "Velocity", undefined);
	self add_option("Vish", ::set_bind, retropack_storage(1, "Binds 2"), "vish", ::bind_vish, "Vish", undefined);
    break;
  case "Bolt":
    self add_menu(menu);
    self add_option("Record Bolt Path", ::bolt_record, retropack_storage(1, "Bolt"));
    self add_option("Save Point", ::bolt_save, undefined, retropack_storage(1, "Bolt"));
    self add_option("Delete Point", ::bolt_delete, retropack_storage(1, "Bolt"));
    self add_option("Preview Bolt", ::bolt_start, retropack_storage(1, "Bolt"));
    self add_option("Reset Bolt", ::bolt_reset, retropack_storage(1, "Bolt"));
    self add_increment("Bolt Duration", true, ::bolt_time, 3, 1, 10, 1, retropack_storage(1, "Bolt"));
    break;
  case "Velocity":
    self add_menu(menu);
    self add_increment("Velocity X", true, ::velocity_axis, 0, -1500, 1500, 50, "X", retropack_storage(1, "Velocity"));
    self add_increment("Velocity Y", true, ::velocity_axis, 0, -1500, 1500, 50, "Y", retropack_storage(1, "Velocity"));
    self add_increment("Velocity Z", true, ::velocity_axis, 0, -1500, 1500, 50, "Z", retropack_storage(1, "Velocity"));
    self add_option("Track Velocity", ::velocity_track, retropack_storage(1, "Velocity"));
    self add_option("Preview Velocity", ::velocity_start, retropack_storage(1, "Velocity"));
    self add_option("Reset Velocity", ::velocity_reset, retropack_storage(1, "Velocity"));
    self add_increment("Velocity Multiplier", false, ::velocity_speed, 1, 0.25, 2.5, 0.25, undefined, retropack_storage(1, "Velocity"));
    self add_increment("Velocity Divider", false, ::velocity_speed, 1, 0.25, 2.5, 0.25, true, retropack_storage(1, "Velocity"));
    break;
  case "Weapons":
    self add_menu(menu);
    if (self.previous[self.previous.size - 1] == "Home") {
      self add_option("Take Current Weapon", ::do_take_weapon);
      self add_option("Drop Current Weapon", ::do_drop_weapon);
      self add_option("Empty Clip", ::do_empty_clip);
      self add_option("Last Bullet In Clip", ::do_one_bullet);
      self add_option("Change Camo", ::new_menu, "Camo");
      self add_option("Create a Class", ::new_menu, "Class");
      self add_category("Give Weapon");
    }
    if (self.previous[self.previous.size - 1] == "Class") {
	  self add_option("None", ::select_weapon_rp, "None", retropack_storage(1, "Weapons"));
      self add_category(retropack_storage(1, "Weapons"));
    }
    self add_option("Sniper Rifles", ::new_menu, "Snipers", retropack_storage(1, "Weapons"));
    self add_option("Shotguns", ::new_menu, "Shotguns", retropack_storage(1, "Weapons"));
    self add_option("Handguns", ::new_menu, "Pistols", retropack_storage(1, "Weapons"));
    self add_option("Machine Pistols", ::new_menu, "Machine Pistols", retropack_storage(1, "Weapons"));
    self add_option("Assault Rifles", ::new_menu, "Assault Rifles", retropack_storage(1, "Weapons"));
    self add_option("Submachine Guns", ::new_menu, "Submachine Guns", retropack_storage(1, "Weapons"));
    self add_option("Light Machine Guns", ::new_menu, "Light Machine Guns", retropack_storage(1, "Weapons"));
    self add_option("Launchers", ::new_menu, "Launchers", retropack_storage(1, "Weapons"));
    self add_option("Melee", ::new_menu, "Melee", retropack_storage(1, "Weapons"));
    if (self.previous[self.previous.size - 1] == "Home") {
      self add_option("Miscellaneous", ::new_menu, "Misc");
    }
    break;
  case "Snipers":
    self add_menu(menu);
    self add_shaderoption("hud_icon_cheytac", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_cheytac_mp;No Attachments", "h2_cheytac_mp_silencersniper;Silencer", "h2_cheytac_mp_acog;ACOG", "h2_cheytac_mp_fmj;FMJ", "h2_cheytac_mp_thermal;Thermal", "h2_cheytac_mp_xmag;X-Mags", "h2_cheytac_mp_heartbeat;Heartbeat"], retropack_storage(1, "Weapons"), "Intervention");
    self add_shaderoption("hud_icon_barrett50cal", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_barrett_mp;No Attachments", "h2_barrett_mp_silencersniper;Silencer", "h2_barrett_mp_acog;ACOG", "h2_barrett_mp_fmj;FMJ", "h2_barrett_mp_thermal;Thermal", "h2_barrett_mp_xmag;X-Mags", "h2_barrett_mp_heartbeat;Heartbeat"], retropack_storage(1, "Weapons"), "Barrett .50cal");
    self add_shaderoption("hud_icon_wa2000", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_wa2000_mp;No Attachments", "h2_wa2000_mp_silencersniper;Silencer", "h2_wa2000_mp_acog;ACOG", "h2_wa2000_mp_fmj;FMJ", "h2_wa2000_mp_thermal;Thermal", "h2_wa2000_mp_xmag;X-Mags", "h2_wa2000_mp_heartbeat;Heartbeat"], retropack_storage(1, "Weapons"), "WA2000");
    self add_shaderoption("hud_icon_m14ebr_scope", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m21_mp;No Attachments", "h2_m21_mp_silencersniper;Silencer", "h2_m21_mp_acog;ACOG", "h2_m21_mp_fmj;FMJ", "h2_m21_mp_thermal;Thermal", "h2_m21_mp_xmag;X-Mags", "h2_m21_mp_heartbeat;Heartbeat"], retropack_storage(1, "Weapons"), "M21 EBR");
    self add_shaderoption("hud_icon_m40a3", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m40a3_mp;No Attachments", "h2_m40a3_mp_silencersniper;Silencer", "h2_m40a3_mp_acog;ACOG", "h2_m40a3_mp_fmj;FMJ", "h2_m40a3_mp_thermal;Thermal", "h2_m40a3_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M40A3");
    // HMW
		self add_shaderoption("hud_icon_msr", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_msr_mp;No Attachments", "h2_msr_mp_silencersniper;Silencer", "h2_msr_mp_acog;ACOG", "h2_msr_mp_fmj;FMJ", "h2_msr_mp_thermal;Thermal", "h2_msr_mp_xmag;X-Mags", "h2_msr_mp_heartbeat;Heartbeat"], retropack_storage(1, "Weapons"), "MSR");
		self add_shaderoption("hud_icon_febsnp", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_d25s_mp;No Attachments", "h2_d25s_mp_silencersniper;Silencer", "h2_d25s_mp_acog;ACOG", "h2_d25s_mp_fmj;FMJ", "h2_d25s_mp_thermal;Thermal", "h2_d25s_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "D25S");
    self add_shaderoption("hud_icon_as50", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_as50_mp;No Attachments", "h2_as50_mp_silencersniper;Silencer", "h2_as50_mp_acog;ACOG", "h2_as50_mp_fmj;FMJ", "h2_as50_mp_thermal;Thermal", "h2_as50_mp_xmag;X-Mags", "h2_as50_mp_heartbeat;Heartbeat"], retropack_storage(1, "Weapons"), "AS50");
		break;
  case "Shotguns":
    self add_menu(menu);
    self add_shaderoption("hud_icon_spas12", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_spas12_mp;No Attachments", "h2_spas12_mp_reflex;Red Dot", "h2_spas12_mp_silencershotgun;Silencer", "h2_spas12_mp_foregrip;Grip", "h2_spas12_mp_fmj;FMJ", "h2_spas12_mp_holo;Holo Sight", "h2_spas12_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "SPAS-12");
    self add_shaderoption("hud_icon_aa12", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_aa12_mp;No Attachments", "h2_aa12_mp_reflex;Red Dot", "h2_aa12_mp_silencershotgun;Silencer", "h2_aa12_mp_foregrip;Grip", "h2_aa12_mp_fmj;FMJ", "h2_aa12_mp_holo;Holo Sight", "h2_aa12_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "AA-12");
    self add_shaderoption("hud_icon_striker", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_striker_mp;No Attachments", "h2_striker_mp_reflex;Red Dot", "h2_striker_mp_silencershotgun;Silencer", "h2_striker_mp_foregrip;Grip", "h2_striker_mp_fmj;FMJ", "h2_striker_mp_holo;Holo Sight", "h2_striker_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "Striker");
    self add_shaderoption("hud_icon_sawed_off", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_ranger_mp;No Attachments", "h2_ranger_mp_akimbo;Akimbo", "h2_ranger_mp_fmj;FMJ"], retropack_storage(1, "Weapons"), "Ranger");
    self add_shaderoption("hud_icon_benelli_m4", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m1014_mp;No Attachments", "h2_m1014_mp_reflex;Red Dot", "h2_m1014_mp_silencershotgun;Silencer", "h2_m1014_mp_foregrip;Grip", "h2_m1014_mp_fmj;FMJ", "h2_m1014_mp_holo;Holo Sight", "h2_m1014_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M1014");
    self add_shaderoption("hud_icon_model1887", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_model1887_mp;No Attachments", "h2_model1887_mp_akimbo;Akimbo", "h2_model1887_mp_fmj;FMJ"], retropack_storage(1, "Weapons"), "Model 1887");
    // HMW
		self add_shaderoption("hud_icon_ksg", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_ksg_mp;No Attachments", "h2_ksg_mp_reflex;Red Dot", "h2_ksg_mp_silencershotgun;Silencer", "h2_ksg_mp_fmj;FMJ"], retropack_storage(1, "Weapons"), "KSG");
		self add_shaderoption("hud_icon_winchester_1200", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_winchester1200_mp;No Attachments", "h2_winchester1200_mp_foregrip;Grip", "h2_winchester1200_mp_reflex;Red Dot", "h2_winchester1200_mp_silencershotgun;Silencer", "h2_winchester1200_mp_fmj;FMJ", "h2_winchester1200_mp_holo;Holo Sight"], retropack_storage(1, "Weapons"), "Winchester 1200");
    break;
  case "Pistols":
    self add_menu(menu);
    self add_shaderoption("hud_icon_usp_45", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_usp_mp;No Attachments", "h2_usp_mp_fmj;FMJ", "h2_usp_mp_silencerpistol;Silencer", "h2_usp_mp_akimbo;Akimbo", "h2_usp_mp_tacknifeusp;Tact. Knife", "h2_usp_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "USP .45");
    self add_shaderoption("hud_icon_colt_anaconda", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_coltanaconda_mp;No Attachments", "h2_coltanaconda_mp_fmj;FMJ", "h2_coltanaconda_mp_akimbo;Akimbo", "h2_coltanaconda_mp_tacknifecolt44;Tact. Knife"], retropack_storage(1, "Weapons"), "44 Magnum");
    self add_shaderoption("hud_icon_m9beretta", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m9_mp;No Attachments", "h2_m9_mp_fmj;FMJ", "h2_m9_mp_silencerpistol;Silencer", "h2_m9_mp_akimbo;Akimbo", "h2_m9_mp_tacknifem9;Tact. Knife", "h2_m9_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M9");
    self add_shaderoption("hud_icon_desert_eagle", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_deserteagle_mp;No Attachments", "h2_deserteagle_mp_fmj;FMJ", "h2_deserteagle_mp_akimbo;Akimbo", "h2_deserteagle_mp_tacknifedeagle;Tact. Knife"], retropack_storage(1, "Weapons"), "Deagle");
    self add_shaderoption("hud_icon_colt_45", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_colt45_mp;No Attachments", "h2_colt45_mp_fmj;FMJ", "h2_colt45_mp_silencerpistol;Silencer", "h2_colt45_mp_akimbo;Akimbo", "h2_colt45_mp_tacknifecolt45;Tact. Knife", "h2_colt45_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M1911");
    // HMW
		self add_shaderoption("hud_icon_mp412", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_mp412_mp;No Attachments", "h2_mp412_mp_fmj;FMJ", "h2_mp412_mp_akimbo;Akimbo", "h2_mp412_mp_tacknifemp412;Tact. Knife"], retropack_storage(1, "Weapons"), "MP412");
		break;
  case "Machine Pistols":
    self add_menu(menu);
    self add_shaderoption("hud_icon_pp2000", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_pp2000_mp;No Attachments", "h2_pp2000_mp_reflex;Red Dot", "h2_pp2000_mp_silencerpistol;Silencer", "h2_pp2000_mp_fmj;FMJ", "h2_pp2000_mp_akimbo;Akimbo", "h2_pp2000_mp_holo;Holo Sight", "h2_pp2000_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "PP2000");
    self add_shaderoption("hud_icon_glock", false, 26, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_glock_mp;No Attachments", "h2_glock_mp_reflex;Red Dot", "h2_glock_mp_silencerpistol;Silencer", "h2_glock_mp_fmj;FMJ", "h2_glock_mp_akimbo;Akimbo", "h2_glock_mp_holo;Holo Sight", "h2_glock_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "G18");
    self add_shaderoption("hud_icon_beretta393", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_beretta393_mp;No Attachments", "h2_beretta393_mp_reflex;Red Dot", "h2_beretta393_mp_silencerpistol;Silencer", "h2_beretta393_mp_fmj;FMJ", "h2_beretta393_mp_akimbo;Akimbo", "h2_beretta393_mp_holo;Holo Sight", "h2_beretta393_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M93 Raffica");
    self add_shaderoption("hud_icon_mp9", false, 26, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_tmp_mp;No Attachments", "h2_tmp_mp_reflex;Red Dot", "h2_tmp_mp_silencerpistol;Silencer", "h2_tmp_mp_fmj;FMJ", "h2_tmp_mp_akimbo;Akimbo", "h2_tmp_mp_holo;Holo Sight", "h2_tmp_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "TMP");
    // HMW
		self add_shaderoption("hud_icon_fmg9", false, 19, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_fmg9_mp;No Attachments", "h2_fmg9_mp_reflex;Red Dot", "h2_fmg9_mp_silencerpistol;Silencer", "h2_fmg9_mp_fmj;FMJ", "h2_fmg9_mp_akimbo;Akimbo", "h2_fmg9_mp_holo;Holo Sight", "h2_fmg9_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "FMG9");
    break;
  case "Assault Rifles":
    self add_menu(menu);
    self add_shaderoption("hud_icon_m4_grunt", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m4_mp;No Attachments", "alt_h2_m4_mp_gl_glpre;Gren. Launcher", "h2_m4_mp_reflex;Red Dot", "h2_m4_mp_silencerar;Silencer", "h2_m4_mp_acog;ACOG", "h2_m4_mp_fmj;FMJ", "alt_h2_m4_mp_sho_shopre;Shotgun", "h2_m4_mp_holo;Holo Sight", "h2_m4_mp_thermal;Thermal", "h2_m4_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M4A1");
    self add_shaderoption("hud_icon_famas", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_famas_mp;No Attachments", "alt_h2_famas_mp_gl_glpre;Gren. Launcher", "h2_famas_mp_reflex;Red Dot", "h2_famas_mp_silencerar;Silencer", "h2_famas_mp_acog;ACOG", "h2_famas_mp_fmj;FMJ", "alt_h2_famas_mp_sho_shopre;Shotgun", "h2_famas_mp_holo;Holo Sight", "h2_famas_mp_thermal;Thermal", "h2_famas_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "FAMAS");
    self add_shaderoption("hud_icon_scar_h", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_scar_mp;No Attachments", "alt_h2_scar_mp_gl_glpre;Gren. Launcher", "h2_scar_mp_reflex;Red Dot", "h2_scar_mp_silencerar;Silencer", "h2_scar_mp_acog;ACOG", "h2_scar_mp_fmj;FMJ", "alt_h2_scar_mp_sho_shopre;Shotgun", "h2_scar_mp_holo;Holo Sight", "h2_scar_mp_thermal;Thermal", "h2_scar_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "SCAR");
    self add_shaderoption("hud_icon_tavor", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_tavor_mp;No Attachments", "alt_h2_tavor_mp_gl_glpre;Gren. Launcher", "h2_tavor_mp_reflex;Red Dot", "h2_tavor_mp_silencerar;Silencer", "h2_tavor_mp_acog;ACOG", "h2_tavor_mp_fmj;FMJ", "alt_h2_tavor_mp_sho_shopre;Shotgun", "h2_tavor_mp_holo;Holo Sight", "h2_tavor_mp_thermal;Thermal", "h2_tavor_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "TAR-21");
    self add_shaderoption("hud_icon_fnfal", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_fal_mp;No Attachments", "alt_h2_fal_mp_gl_glpre;Gren. Launcher", "h2_fal_mp_reflex;Red Dot", "h2_fal_mp_silencerar;Silencer", "h2_fal_mp_acog;ACOG", "h2_fal_mp_fmj;FMJ", "alt_h2_fal_mp_sho_shopre;Shotgun", "h2_fal_mp_holo;Holo Sight", "h2_fal_mp_thermal;Thermal", "h2_fal_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "FAL");
    self add_shaderoption("hud_icon_m16a4", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m16_mp;No Attachments", "alt_h2_m16_mp_gl_glpre;Gren. Launcher", "h2_m16_mp_reflex;Red Dot", "h2_m16_mp_silencerar;Silencer", "h2_m16_mp_acog;ACOG", "h2_m16_mp_fmj;FMJ", "alt_h2_m16_mp_sho_shopre;Shotgun", "h2_m16_mp_holo;Holo Sight", "h2_m16_mp_thermal;Thermal", "h2_m16_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M16A4");
    self add_shaderoption("hud_icon_m4carbine", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_masada_mp;No Attachments", "alt_h2_masada_mp_gl_glpre;Gren. Launcher", "h2_masada_mp_reflex;Red Dot", "h2_masada_mp_silencerar;Silencer", "h2_masada_mp_acog;ACOG", "h2_masada_mp_fmj;FMJ", "alt_h2_masada_mp_sho_shopre;Shotgun", "h2_masada_mp_holo;Holo Sight", "h2_masada_mp_thermal;Thermal", "h2_masada_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "ACR");
    self add_shaderoption("hud_icon_fn2000", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_fn2000_mp;No Attachments", "alt_h2_fn2000_mp_gl_glpre;Gren. Launcher", "h2_fn2000_mp_reflex;Red Dot", "h2_fn2000_mp_silencerar;Silencer", "h2_fn2000_mp_acog;ACOG", "h2_fn2000_mp_fmj;FMJ", "alt_h2_fn2000_mp_sho_shopre;Shotgun", "h2_fn2000_mp_holo;Holo Sight", "h2_fn2000_mp_thermal;Thermal", "h2_fn2000_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "F2000");
    self add_shaderoption("hud_icon_ak47", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_ak47_mp;No Attachments", "alt_h2_ak47_mp_gl_glpre;Gren. Launcher", "h2_ak47_mp_reflex;Red Dot", "h2_ak47_mp_silencerar;Silencer", "h2_ak47_mp_acog;ACOG", "h2_ak47_mp_fmj;FMJ", "alt_h2_ak47_mp_sho_shopre;Shotgun", "h2_ak47_mp_holo;Holo Sight", "h2_ak47_mp_thermal;Thermal", "h2_ak47_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "AK47");
		// HMW
    self add_shaderoption("hud_icon_g36c_mp", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_g36c_mp;No Attachments", "h2_g36c_mp_reflex;Red Dot", "h2_g36c_mp_silencerar;Silencer", "h2_g36c_mp_acog;ACOG", "h2_g36c_mp_fmj;FMJ", "h2_g36c_mp_holo;Holo Sight", "h2_g36c_mp_xmag;X-Mags", "h2_g36c_mp_heartbeat;Heartbeat"], retropack_storage(1, "Weapons"), "G36C");
    self add_shaderoption("hud_icon_cm901", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_cm901_mp;No Attachments", "h2_cm901_mp_reflex;Red Dot", "h2_cm901_mp_silencerar;Silencer", "h2_cm901_mp_acog;ACOG", "h2_cm901_mp_fmj;FMJ", "h2_cm901_mp_holo;Holo Sight", "h2_cm901_mp_xmag;X-Mags", "h2_cm901_mp_heartbeat;Heartbeat"], retropack_storage(1, "Weapons"), "CM901");
    break;
  case "Submachine Guns":
    self add_menu(menu);
    self add_shaderoption("hud_icon_mp5k", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_mp5k_mp;No Attachments", "h2_mp5k_mp_fastfire;Rapid Fire", "h2_mp5k_mp_reflex;Red Dot", "h2_mp5k_mp_silencersmg;Silencer", "h2_mp5k_mp_acog;ACOG", "h2_mp5k_mp_fmj;FMJ", "h2_mp5k_mp_akimbo;Akimbo", "h2_mp5k_mp_holo;Holo Sight", "h2_mp5k_mp_thermal;Thermal", "h2_mp5k_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "MP5K");
    self add_shaderoption("hud_icon_ump45", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_ump45_mp;No Attachments", "h2_ump45_mp_fastfire;Rapid Fire", "h2_ump45_mp_reflex;Red Dot", "h2_ump45_mp_silencersmg;Silencer", "h2_ump45_mp_acog;ACOG", "h2_ump45_mp_fmj;FMJ", "h2_ump45_mp_akimbo;Akimbo", "h2_ump45_mp_holo;Holo Sight", "h2_ump45_mp_thermal;Thermal", "h2_ump45_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "UMP45");
    self add_shaderoption("hud_icon_kriss", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_kriss_mp;No Attachments", "h2_kriss_mp_fastfire;Rapid Fire", "h2_kriss_mp_reflex;Red Dot", "h2_kriss_mp_silencersmg;Silencer", "h2_kriss_mp_acog;ACOG", "h2_kriss_mp_fmj;FMJ", "h2_kriss_mp_akimbo;Akimbo", "h2_kriss_mp_holo;Holo Sight", "h2_kriss_mp_thermal;Thermal", "h2_kriss_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "Vector");
    self add_shaderoption("hud_icon_p90", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_p90_mp;No Attachments", "h2_p90_mp_fastfire;Rapid Fire", "h2_p90_mp_reflex;Red Dot", "h2_p90_mp_silencersmg;Silencer", "h2_p90_mp_acog;ACOG", "h2_p90_mp_fmj;FMJ", "h2_p90_mp_akimbo;Akimbo", "h2_p90_mp_holo;Holo Sight", "h2_p90_mp_thermal;Thermal", "h2_p90_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "P90");
    self add_shaderoption("hud_icon_mini_uzi", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_uzi_mp;No Attachments", "h2_uzi_mp_fastfire;Rapid Fire", "h2_uzi_mp_reflex;Red Dot", "h2_uzi_mp_silencersmg;Silencer", "h2_uzi_mp_acog;ACOG", "h2_uzi_mp_fmj;FMJ", "h2_uzi_mp_akimbo;Akimbo", "h2_uzi_mp_holo;Holo Sight", "h2_uzi_mp_thermal;Thermal", "h2_uzi_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "Mini-Uzi");
    self add_shaderoption("hud_icon_ak74u", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_AK74U_mp;No Attachments", "h2_AK74U_mp_fastfire;Rapid Fire", "h2_AK74U_mp_reflex;Red Dot", "h2_AK74U_mp_silencerar;Silencer", "h2_AK74U_mp_acog;ACOG", "h2_AK74U_mp_fmj;FMJ", "h2_AK74U_mp_akimbo;Akimbo", "h2_AK74U_mp_holo;Holo Sight", "h2_AK74U_mp_thermal;Thermal", "h2_AK74U_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "AK47U");
    // HMW
		self add_shaderoption("hud_icon_pp90", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_pm9_mp;No Attachments", "h2_pm9_mp_reflex;Red Dot", "h2_pm9_mp_silencerar;Silencer", "h2_pm9_mp_acog;ACOG", "h2_pm9_mp_fmj;FMJ", "h2_pm9_mp_holo;Holo Sight", "h2_pm9_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "PP90M1");
    self add_shaderoption("hud_icon_mp7", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_mp7_mp;No Attachments", "h2_mp7_mp_reflex;Red Dot", "h2_mp7_mp_silencerar;Silencer", "h2_mp7_mp_acog;ACOG", "h2_mp7_mp_fmj;FMJ", "h2_mp7_mp_holo;Holo Sight", "h2_mp7_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "MP7");
    break;
  case "Light Machine Guns":
    self add_menu(menu);
    self add_shaderoption("hud_icon_sa80_lmg", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_sa80_mp;No Attachments", "h2_sa80_mp_reflex;Red Dot", "h2_sa80_mp_silencerlmg,Silencer", "h2_sa80_mp_acog;ACOG", "h2_sa80_mp_fmj;FMJ", "h2_sa80_mp_holo;Holo Sight", "h2_sa80_mp_thermal;Thermal", "h2_sa80_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "L86 LSW");
    self add_shaderoption("hud_icon_rpd", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_rpd_mp;No Attachments", "h2_rpd_mp_reflex;Red Dot", "h2_rpd_mp_silencerlmg,Silencer", "h2_rpd_mp_acog;ACOG", "h2_rpd_mp_fmj;FMJ", "h2_rpd_mp_holo;Holo Sight", "h2_rpd_mp_thermal;Thermal", "h2_rpd_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "RPD");
    self add_shaderoption("hud_icon_mg4", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_mg4_mp;No Attachments", "h2_mg4_mp_reflex;Red Dot", "h2_mg4_mp_silencerlmg,Silencer", "h2_mg4_mp_acog;ACOG", "h2_mg4_mp_fmj;FMJ", "h2_mg4_mp_holo;Holo Sight", "h2_mg4_mp_thermal;Thermal", "h2_mg4_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "MG4");
    self add_shaderoption("hud_icon_steyr", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_aug_mp;No Attachments", "h2_aug_mp_reflex;Red Dot", "h2_aug_mp_silencerlmg,Silencer", "h2_aug_mp_acog;ACOG", "h2_aug_mp_fmj;FMJ", "h2_aug_mp_holo;Holo Sight", "h2_aug_mp_thermal;Thermal", "h2_aug_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "AUG HBAR");
    self add_shaderoption("hud_icon_m240", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m240_mp;No Attachments", "h2_m240_mp_reflex;Red Dot", "h2_m240_mp_silencerlmg,Silencer", "h2_m240_mp_acog;ACOG", "h2_m240_mp_fmj;FMJ", "h2_m240_mp_holo;Holo Sight", "h2_m240_mp_thermal;Thermal", "h2_m240_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M240");
    // HMW
		self add_shaderoption("hud_icon_feblmg", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_pkm_mp;No Attachments", "h2_pkm_mp_reflex;Red Dot", "h2_pkm_mp_acog;ACOG", "h2_pkm_mp_thermal;Thermal"], retropack_storage(1, "Weapons"), "PKM");
    break;
  case "Launchers":
    self add_menu(menu);
    self add_shaderoption("hud_icon_at4", false, 28, 9, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["at4_mp;AT4-HS"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "AT4-HS" : "");
    self add_shaderoption("hud_icon_m79", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m79_mp;Thumper"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Thumper" : "");
    self add_shaderoption("hud_icon_stinger", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["stinger_mp;Stinger"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Stinger" : "");
    self add_shaderoption("hud_icon_javelin", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["javelin_mp;Javelin"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Javelin" : "");
    self add_shaderoption("hud_icon_rpg", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_rpg_mp;RPG"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "RPG" : "");
    // HMW
		self add_shaderoption("hud_icon_m320", false, 28, 12, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m320_mp;M320 GLM"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "M320 GLM" : "");
    break;
  case "Melee":
    self add_menu(menu);
    self add_shaderoption("hud_icon_hatchet", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_hatchet_mp;Hatchet"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Hatchet" : "");
    self add_shaderoption("hud_icon_sickle", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_sickle_mp;Sickle"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Sickle" : "");
    self add_shaderoption("hud_icon_shovel", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_shovel_mp;Shovel"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Shovel" : "");
    self add_shaderoption("hud_icon_ice_pick", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_icepick_mp;Ice Pick"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Ice Pick" : "");
    self add_shaderoption("hud_icon_karambit", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_karambit_mp;Karambit"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Karambit" : "");
    break;
  case "Misc":
    self add_menu(menu);
    self add_option("^1Infected", ::give_weapon, "h2_infect_mp;Infected");
    self add_option("^5Glitch:^7 USP Akimbo Knife", ::give_weapon, "h2_usp_mp_akimbo_tacknifeusp;USP Akimbo + Tac Knife");
    self add_option("^5Glitch:^7 M9 Akimbo Knife", ::give_weapon, "h2_m9_mp_akimbo_tacknifem9;M9 Akimbo + Tac Knife");
    self add_option("^5Glitch:^7 Magnum Akimbo Knife", ::give_weapon, "h2_coltanaconda_mp_akimbo_tacknifecolt44;Magnum Akimbo + Tac Knife");
    self add_option("^5Glitch:^7 Deagle Akimbo Knife", ::give_weapon, "h2_deserteagle_mp_akimbo_tacknifedeagle;Deagle Akimbo + Tac Knife");
    self add_option("^5Glitch:^7 USP \"Bayonet\"", ::give_weapon, "h2_usp_mp_tacknifeusp_tacknifeusp;USP \"Bayonet\"");
    self add_option("^5Glitch:^7 M9 \"Bayonet\"", ::give_weapon, "h2_m9_mp_tacknifem9_tacknifem9;M9 \"Bayonet\"");
    self add_option("^5Glitch:^7 Deagle \"Bayonet\"", ::give_weapon, "h2_deserteagle_mp_tacknifedeagle_tacknifem9;Deagle \"Bayonet\"");
    break;
  case "Killstreak":
    self add_menu(menu);
    self add_option("Spawn Care Package", ::do_crate);
    self add_option("Delete Care Packages", ::delete_carepack);
    self add_divider();
    self add_integer("UAV", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "radar_mp;UAV");
    self add_integer("Care Package", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "airdrop_marker_mp;Care Package");
    self add_integer("Counter-UAV", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "counter_radar_mp;Counter-UAV");
    self add_integer("Predator Missile", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "predator_mp;Predator Missile");
		self add_integer("Sentry Gun", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "sentry_mp;Sentry Gun");
    self add_integer("Precision Airstrike", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "airstrike_mp;Precision Airstrike");
		self add_integer("Harrier Strike", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "harrier_airstrike_mp;Harrier Strike");
    self add_integer("Attack Helicopter", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "helicopter_mp;Attack Helicopter");
		self add_integer("Emergency Airdrop", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "airdrop_mega_marker_mp;Emergency Airdrop");
		self add_integer("Advanced UAV", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "advanced_uav_mp;Advanced UAV"); // HMW
    self add_integer("Pavelow", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "pavelow_mp;Pavelow");
    self add_integer("Stealth Bomber", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "stealth_airstrike_mp;Stealth Bomber");
		self add_integer("AH6 Overwatch", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "ah6_mp;AH6 Overwatch"); // HMW
		self add_integer("Reaper", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "reaper_mp;Reaper"); // HMW
		self add_integer("AC130", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "ac130_mp;AC130");
    self add_integer("Chopper Gunner", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "chopper_gunner_mp;Chopper Gunner");
    self add_integer("EMP", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "emp_mp;EMP");
    self add_integer("Tactical Nuke", &"^5x", true, false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "nuke_mp;Tactical Nuke");
    break;
  case "Game":
    self add_menu(menu);
		if (self ishost() || isDefined(self.pers["rp_host"]) && self.pers["rp_host"]) {
			self add_option("Health and Damage", ::new_menu, "Health and Damage");
			self add_option("DVARs", ::new_menu, "DVARs");
			self add_option("Killcam Setings", ::new_menu, "Killcam Settings");
			self add_option("Lobby Settings", ::new_menu, "Lobby Settings");
			self add_option("Fast Restart", ::func_fast_restart);
		}
		self add_option("Leave Game", ::exit_level);
    break;
	case "Killcam Settings":
    self add_menu(menu);
    self add_toggle("Killcam Timer", ::toggle_killcam_timer, self.pers["rp_timer"]);
		self add_string("Killcam Timer Font", true, ::set_killcam_timer_font, ["Classic", "Retro-Pack"]);
    break;
  case "Health and Damage":
    self add_menu(menu);
    self add_increment("Lobby Health", true, ::set_player_health, getDvar("g_gametype") != "sd" ? 100 : 25, 25, 400, 25);
		self add_increment("Sniper Damage", true, ::set_sniper_damage, getDvarInt("rp_sniper_damage"), 0, 100, 25);
    self add_increment("Bot Damage", true, ::set_bot_damage, getDvarFloat("rp_bot_damage"), 0, 2, 0.25);
    self add_increment("Melee Damage", true, ::set_melee_damage, getDvarInt("rp_melee_damage"), 0, 100, 25);
    break;
	case "DVARs":
		self add_menu(menu);
		self add_increment("Pickup Radius", true, ::set_pickup_radius, getDvarInt("player_useRadius"), 0, 1024, 64);
    self add_increment("Frag Pickup Radius", true, ::set_grenade_pickup_radius, getDvarInt("player_throwbackInnerRadius"), 0, 1080, 45);
    self add_increment("Timescale", true, ::set_timescale, getDvarInt("timescale"), 1, 0.5, 8, 0.5, undefined, true);
    self add_increment("Gravity", true, ::set_gravity, getDvarInt("g_gravity"), 100, 1500, 100);
    self add_increment("Ladder Knockback", true, ::set_ladder_knockback, getDvarInt("jump_ladderPushVel"), 0, 1024, 64);
		break;
	case "Lobby Settings":
		self add_menu(menu);
		self add_toggle("Stop Game Timer", ::do_pause_timer, self.pausetimer);
		self add_integer("Stopwatch", &"^5", undefined, true, ::toggle_autopause, [0, 5, 10, 15, 30, 45, 60]);
		self add_integer("Auto-Nuke", &"^5", undefined, true, ::toggle_autonuke, [0, 5, 10, 15, 30, 45, 60], false);
		if (getDvar("g_gametype") == "sd") {
			self add_integer("Auto-Plant", &"^5", undefined, true, ::toggle_autoplant, [0, 5, 10, 15, 30, 45, 60]);
			self add_toggle("Auto-Defuse", ::toggle_autodefuse, self.pers["auto_defuse"]);
			self add_toggle("Revives", ::toggle_revives, self.pers["revives"]);
			self add_option("Reset Rounds", ::do_round_reset, false, "^5Rounds Resetted");
			self add_toggle("Headshots (+1000)", ::toggle_headshots, self.pers["rp_headshots"]);
			self add_toggle("First Blood (+600)", ::toggle_firstblood, self.pers["rp_firstblood"]);
		}
		self add_toggle("End of Game Freeze", ::toggle_afterhit, self.pers["after_hit"]);
		if (getDvarInt("g_hardcore") != 1) {
			self add_toggle("Hardcore Mode", ::toggle_hardcore, self.pers["hardcore_mode"]);
		}
		self add_toggle("Distance Meter", ::toggle_distance, self.pers["distance_meter"]);
		self add_toggle("Head Bounces", ::toggle_headbounce, self.pers["rp_headbounce"]);
		self add_toggle("Soft Lands", ::toggle_softlands, self.pers["soft_lands"]);
		self add_toggle("Depatch Elevators", ::toggle_elevators, self.pers["do_elevators"]);
		self add_toggle("Death Barriers", ::toggle_death_barriers, self.pers["death_barriers"]);
		break;
  case "User":
    self add_menu(menu);
    for (i = 0; i < level.players.size; i++) {
      if (self.previous[self.previous.size - 1] == "Binds") {
        self add_toggle(sanitise_name(level.players[i].name), ::toggle_damage_buffer, level.players[i].pers["damage_buffer_victim" + retropack_storage(1, "User")], undefined, level.players[i], retropack_storage(1, "User"));
      } else {
        if (level.players[i] != self)
          self add_option(sanitise_name(level.players[i].name), ::player_index, level.players[i]);
      }
    }
    break;
  case "Admin":
    self add_menu(menu);
    self add_option("Perk Menu", ::new_menu, "Perks");
    self add_divider();
    self add_string("Select Hand Model", true, ::set_viewhand_model, ["Ghillie", "Infected", "Militia", "SEALs", "TF141", "Rangers", "Spetsnaz", "OpFor"]);
    self add_string("UAV", true, ::do_radar, ["Fast", "Off", "Normal", "Advanced"]);
		//self add_toggle("Classic HUD", ::toggle_hud_mode, self.pers["hud_classic"]); //WIP
    self add_toggle("God Mode", ::toggle_god_mode, self.pers["god_mode"]);
    self add_toggle("Clip Warning", ::toggle_clipwarning, self.pers["clip_warning"]);
    self add_toggle("Display Menu Controls", ::toggle_rp_text, self.pers["show_open"]);
    self add_toggle("Print Version At Spawn", ::toggle_spawn_text, self.pers["spawn_text"]);
    self add_option("Print GUID", ::print_guid, self);
    self add_divider();
    //self add_shaderarray("Spoof Prestige", false, ::spoof_prestige, ["rank_comm", "h2m_rank_prestige1", "h2m_rank_prestige2", "h2m_rank_prestige3", "h2m_rank_prestige4", "h2m_rank_prestige5", "h2m_rank_prestige6", "h2m_rank_prestige7", "h2m_rank_prestige8", "h2m_rank_prestige9", "h2m_rank_prestige10", "h2m_cheytac_ui", "em_st_180"], self, false);
    self add_integer("Spoof Prestige", &"^5", undefined, false, ::spoof_prestige, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 1000], self, false);
    self add_integer("Spoof Level", &"^5", undefined, false, ::spoof_rank, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70], self, false);
    self add_increment("Spoof XP Progress", false, ::spoof_xp_bar, 0, 0, 100, 5, self, false);
    break;
  case "Camo":
    self add_menu(menu);
    if (isDefined(self.pers["cacPrimaryConsole"]) && self.previous[self.previous.size - 1] == "Class" && is_launcher(self.pers["cacPrimaryConsole"]) ||
      isDefined(self.pers["cacSecondaryConsole"]) && self.previous[self.previous.size - 1] == "Class" && is_launcher(self.pers["cacSecondaryConsole"])) {
      self add_option("None", self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, "None", retropack_storage(1, "Camo"));
    } else {
	  self add_option("None", self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, "None", retropack_storage(1, "Camo"));
      if(self.previous[self.previous.size - 1] == "Weapons")
	    self add_option("Random", self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, random_camo(true), retropack_storage(1, "Camo"));
	  if(self.previous[self.previous.size - 1] == "Class" && isDefined(self.pers["cac" + retropack_storage(1, "Weapons") + "Shader"]) || self.previous[self.previous.size - 1] != "Class") {
	    self add_shaderarray("Classic", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo016;h2m_img_camo_desert", "camo017;h2m_img_camo_arctic", "camo018;h2m_img_camo_woodland", "camo019;h2m_img_camo_digital", "camo020;h2m_img_camo_urban", "camo021;h2m_img_camo_blue_tiger", "camo022;h2m_img_camo_red_tiger", "camo023;h2m_img_camo_orange_fall", "gold;h2m_img_camo_gold", "golddiamond;h2m_img_camo_diamond", "toxicwaste;h2m_img_camo_toxic_waste"], retropack_storage(1, "Camo"));
        self add_shaderarray("Solid Colour", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo024;h2m_img_camo_yellow", "camo025;h2m_img_camo_white", "camo026;h2m_img_camo_red", "camo027;h2m_img_camo_purple", "camo028;h2m_img_camo_pink", "camo029;h2m_img_camo_pastel_brown", "camo030;h2m_img_camo_orange", "camo031;h2m_img_camo_light_pink", "camo032;h2m_img_camo_green", "camo033;h2m_img_camo_dark_red", "camo034;h2m_img_camo_dark_green", "camo035;h2m_img_camo_cyan", "camo036;h2m_img_camo_brown", "camo037;h2m_img_camo_blue", "camo038;h2m_img_camo_black"], retropack_storage(1, "Camo"));
        self add_shaderarray("Polyatomic", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo041;h2m_img_camo_polyatomic", "camo043;h2m_img_camo_poly_blue", "camo047;h2m_img_camo_poly_cyan", "camo042;h2m_img_camo_poly_dred", "camo045;h2m_img_camo_poly_green", "camo040;h2m_img_camo_poly_orange", "camo044;h2m_img_camo_poly_pink", "camo046;h2m_img_camo_poly_red", "camo039;h2m_img_camo_poly_yellow"], retropack_storage(1, "Camo"));
        self add_shaderarray("Elemental", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo052;h2m_img_camo_ice", "camo049;h2m_img_camo_lava", "camo053;h2m_img_camo_storm", "camo050;h2m_img_camo_water", "camo051;h2m_img_camo_fire", "camo048;h2m_img_camo_gas"], retropack_storage(1, "Camo"));
        self add_shaderarray("Bonus", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo057;h2m_img_camo_doomsday", "camo054;h2m_img_camo_nuclear_blue", "camo056;h2m_img_camo_nuclear_red", "camo058;h2m_img_camo_soaring"], retropack_storage(1, "Camo"));
	  }
	}
    break;
  case "Class":
    self add_menu(menu);
	self add_shaderlabel("Primary:", self.pers["cacPrimaryShader"], undefined, self.pers["cacPrimaryShaderX"], self.pers["cacPrimaryShaderY"], ::new_menu, "Weapons", "Primary");
    self add_label("Attachment 2:", self.pers["cacPrimaryAttachment2Name"], ::new_menu, "Attachment", "Primary");
		//self add_shaderlabel("2nd Attachment:", self.pers["cacPrimaryAttachment2Shader"], undefined, self.pers["cacPrimaryAttachment2ShaderX"], self.pers["cacPrimaryAttachment2ShaderY"], ::new_menu, "Attachment", "Primary");
    self add_shaderlabel("Camo:", self.pers["cacPrimaryCamoShader"], undefined, self.pers["cacPrimaryCamoShaderX"], self.pers["cacPrimaryCamoShaderY"], ::new_menu, "Camo", "Primary");
    self add_divider();
	self add_shaderlabel("Secondary:", self.pers["cacSecondaryShader"], undefined, self.pers["cacSecondaryShaderX"], self.pers["cacSecondaryShaderY"], ::new_menu, "Weapons", "Secondary");
    self add_label("Attachment 2:", self.pers["cacSecondaryAttachment2Name"], ::new_menu, "Attachment", "Secondary");
		//self add_shaderlabel("2nd Attachment:", self.pers["cacSecondaryAttachment2Shader"], undefined, self.pers["cacSecondaryAttachment2ShaderX"], self.pers["cacSecondaryAttachment2ShaderY"], ::new_menu, "Attachment", "Secondary");
    self add_shaderlabel("Camo:", self.pers["cacSecondaryCamoShader"], undefined, self.pers["cacSecondaryCamoShaderX"], self.pers["cacSecondaryCamoShaderY"], ::new_menu, "Camo", "Secondary");
    self add_divider();
	//self add_shaderlabel("Equipment:", self.pers["cacEquipmentShader"], undefined, 12, 12, ::new_menu, "Equipment");
    self add_label("Equipment:", self.pers["cacEquipmentName"], ::new_menu, "Equipment");
    self add_label("Off Hand:", self.pers["cacOffHandName"], ::new_menu, "Offhand"); // can't precache anymore shaders :(
    self add_divider();
    self add_label("Perk 1:", self.pers["cacPerkName1"], ::new_menu, "Perks", 1);
    self add_label("Perk 2:", self.pers["cacPerkName2"], ::new_menu, "Perks", 2);
    self add_label("Perk 3:", self.pers["cacPerkName3"], ::new_menu, "Perks", 3);
    self add_divider();
    self add_option("Give Class", ::give_rpclass);
    self add_integer("Save as Custom Class", &"^5", undefined, false, ::set_rpclass, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
    break;
  case "Equipment":
    self add_menu(menu);
    self add_option("None", ::select_equipment_rp, "None");
		self add_option("Frag Grenade", ::select_equipment_rp, "h1_fraggrenade_mp;Frag Grenade");
    self add_option("Semtex", ::select_equipment_rp, "h2_semtex_mp;Semtex");
    self add_option("Throwing Knife", ::select_equipment_rp, "iw9_throwknife_mp;Throwing Knife");
    self add_option("Tactical Insert", ::select_equipment_rp, "specialty_tacticalinsertion;Tact. Insert");
    self add_option("Blast Shield", ::select_equipment_rp, "specialty_blastshield;Blast Shield");
    self add_option("Claymore", ::select_equipment_rp, "h1_claymore_mp;Claymore");
    self add_option("C4", ::select_equipment_rp, "h1_c4_mp;C4");
		/*
		self add_shaderoption("weapon_fraggrenade", false, 12, 12, ::select_equipment_rp, [ "h1_fraggrenade_mp;Frag Grenade" ], "weapon_fraggrenade");
		self add_shaderoption("weapon_semtex", false, 12, 12, ::select_equipment_rp, [ "h2_semtex_mp;Semtex" ], "weapon_semtex");
		self add_shaderoption("weapon_throwingknife", false, 12, 12, ::select_equipment_rp, [ "iw9_throwknife_mp;Throwing Knife" ], "weapon_throwingknife");
		self add_shaderoption("dpad_tacticalinsert", false, 12, 12, ::select_equipment_rp, [ "specialty_tacticalinsertion;Tact. Insert" ], "dpad_tacticalinsert");
		self add_shaderoption("weapon_blastshield", false, 12, 12, ::select_equipment_rp, [ "specialty_blastshield;Blast Shield" ], "weapon_blastshield");
		self add_shaderoption("h2m_weapon_claymore", false, 12, 12, ::select_equipment_rp, [ "h1_claymore_mp;Claymore" ], "h2m_weapon_claymore");
		self add_shaderoption("h2m_weapon_c4", false, 12, 12, ::select_equipment_rp, [ "h1_c4_mp;C4" ], "h2m_weapon_c4");
		*/
		
    break;
  case "Offhand":
    self add_menu(menu);
    self add_option("None", ::select_offhand_rp, "None");
    self add_option("Smoke Grenade", ::select_offhand_rp, "h1_smokegrenade_mp;Smoke Grenade");
    self add_option("Stun Grenade", ::select_offhand_rp, "h1_concussiongrenade_mp;Stun Grenade");
    self add_option("Flash Grenade", ::select_offhand_rp, "h1_flashgrenade_mp;Flash Grenade");
    break;
  case "Attachment":
    self add_menu(menu);
    for (i = 1; i < tablegetrowcount("mp/attachkits.csv"); i++) {
      attachment = tableLookup("mp/attachkits.csv", 0, i, 1);

      if (!maps\mp\gametypes\_class::isvalidattachkit(attachment, (retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], 1))
        continue;

      if (is_sniper((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"])) {
        if (i == 14 || i == 15 || i == 25)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_usp")) {
        if (i == 18 || i == 19 || i == 22 || i == 23)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_coltanaconda")) {
        if (i == 24 || i == 19 || i == 22 || i == 23)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_m9")) {
        if (i == 18 || i == 19 || i == 22 || i == 24)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_deserteagle")) {
        if (i == 18 || i == 24 || i == 22 || i == 23)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_colt45")) {
        if (i == 18 || i == 19 || i == 24 || i == 23)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_pp2000") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_glock") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_beretta393") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_tmp")) {
        if (i == 18 || i == 19 || i == 24 || i == 23 || i == 22)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_sa80") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_rpd") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_m240") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_mg4")) {
        if (i == 15)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_m4") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_famas") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_scar") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_tavor") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_fal") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_m16") ||
        isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_masada")) {
        if (i == 3 || i == 9 || i == 10)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_ak47")) {
        if (i == 2 || i == 9 || i == 10)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_fn2000")) {
        if (i == 3 || i == 6 || i == 10)
          continue;
      }
      if (isSubStr((retropack_storage(1, "Attachment") == "Primary") ? self.pers["cacPrimaryBase"] : self.pers["cacSecondaryBase"], "h2_aug") && i == 14) {
        continue;
      }
			self add_option(get_localised_attachment(attachment), ::select_attachment_rp, attachment, retropack_storage(1, "Attachment"));
		//self add_shaderoption(get_attachment(attachment), false, 12, 12, ::select_attachment_rp, undefined, attachment, retropack_storage(1, "Weapons"), get_attachment(attachment));
    }
    break;
  case "Perks":
    self add_menu(menu);
    if (self.previous[self.previous.size - 1] == "Class")
      self add_option("None", ::select_perk_rp, "None", undefined, retropack_storage(1, "Perks"));

    if (self.previous[self.previous.size - 1] != "Class") {
      self add_toggle("Perks Stick", ::toggle_flag_perk, self.pers["flag_perk"]);
      self add_divider();
    }
    for (i = 1; i < 33; i++) {
      perk = tableLookup("mp/perkTable.csv", 0, i, 1);
	  name = get_string_perk(perk);
      if (!isSubStr(perk, "specialty_"))
        continue;
	
	  if (i == 2 || i == 4 || i == 6 || i == 8 || i == 10 || i == 12 || i == 14 || i == 16 || i == 18 || i == 20 || i == 22 || i == 24 || i == 26 || i == 28 || i == 30 ||  i == 32)
        continue;

      if (self maps\mp\_utility::_hasPerk(perk) || isDefined(self.pers["set_" + perk]) && self.pers["set_" + perk]) {
        self.pers["set_" + perk] = true;
		self.pers["set_" + get_perk_upgrade(perk)] = true;
      } else {
        self.pers["set_" + perk] = false;
		self.pers["set_" + get_perk_upgrade(perk)] = false;
	  }

      if (self.previous[self.previous.size - 1] != "Class") {
        self add_toggle(name, ::toggle_perk, self.pers["set_" + perk], undefined, perk);
      } else {
        if (maps\mp\perks\_perks::validateperk(retropack_storage(1, "Perks") - 1, perk) == "specialty_null")
          continue;

        self add_option(name, ::select_perk_rp, perk, get_string_perk(perk), retropack_storage(1, "Perks"));
      }
    }
    break;
  case "Empty Menu":
    self add_menu(menu);
    self add_option("Unassigned Menu");
    break;
  }
}

player_index(player) {
  self add_menu("Player_" + player.name);
  if (self ishost() || isDefined(self.pers["rp_host"]) && self.pers["rp_host"]) {
    self add_string("EB Weapon", true, ::select_eb_weapon, ["Snipers", "Select Weapon"], player);
    self add_string("EB Type", true, ::AimbotType, ["Player", "Claymore", "C4"], undefined, player);
    self add_increment("EB Radius", true, ::AimbotStrength, 0, 0, 1000, 100, undefined, player);
  }
  self add_option("Player to Crosshairs", ::do_teleport_to_crosshairs, player);
  self add_option("Player to You", ::do_teleport_to_self, player);
  if (!player ishost()) {
    self add_option("Kick Player", ::do_kick, player);
    self add_option("Kill Player", ::do_kill, player);
    self add_toggle("Freeze Player", ::do_freeze, player.pers["freeze"], undefined, player);
    if (getDvar("g_gametype") == "dm" || getDvar("g_gametype") == "war") {
      self add_option("Fast Last", ::do_fast_last, player);
      self add_option("Reset Kills", ::do_reset_scores, 0, player);
    }
  }
  self add_option("Print GUID", ::print_guid, player);
	self add_toggle("Saved Location", ::toggle_save_location, player.pers["saved_location"], undefined, player);
  if (self ishost())
    self add_toggle("Co-Host", ::toggle_cohost, player.pers["rp_host"], undefined, player);
  if (!player ishost()) {
    //self add_shaderarray("Spoof Prestige", false, ::spoof_prestige, ["rank_comm", "h2m_rank_prestige1", "h2m_rank_prestige2", "h2m_rank_prestige3", "h2m_rank_prestige4", "h2m_rank_prestige5", "h2m_rank_prestige6", "h2m_rank_prestige7", "h2m_rank_prestige8", "h2m_rank_prestige9", "h2m_rank_prestige10", "h2m_cheytac_ui", "em_st_180"], player, false);
    self add_integer("Spoof Prestige", &"^5", undefined, false, ::spoof_prestige, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 1000], player, false);
    self add_integer("Spoof Level", &"^5", undefined, false, ::spoof_rank, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70], player, false);
  }
  self set_menu("Player_" + player.name);
  self create_option();
}