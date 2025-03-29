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
░░        ░   ▒  ░       ░ ░░ ░ ░   ▒       ░ v1.0.2░

Developer: @rtros
Date: October 1, 2024
Compatibility: Modern Warfare Remastered (HM2 Mod)

Notes:
- N/A
*/

#include scripts\utility;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\_retropack_binds;
#include scripts\mp\_retropack_utility;
#include scripts\mp\_retropack_functions;

retropack_variables() {
  /* Menu Variables */
  self.menuWidth = 150;
  self.menuHeight = 130;
  self.menuTOGap = 25;
  self.retropack["utility"] = spawnstruct();
  self.retropack["utility"].font = "objective";
  self.retropack["utility"].font_scale = 0.7;
  self.retropack["utility"].option_limit = 7;
  self.retropack["utility"].option_spacing = 11;
  self.retropack["utility"].x_offset = -(self.menuWidth / 2);
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
        if (is_player_gamepad_enabled()) {
          if (self adsbuttonpressed()) {
            if (return_toggle(self.retropack["utility"].interaction))
              self playsoundtoplayer("h1_ui_menu_warning_box_appear", self);

            self open_menu();
            self thread menu_up();
            self thread menu_down();
            self thread menu_left();
            self thread menu_right();
            self thread slider_left();
            self thread slider_right();
            if (isDefined(self.pers["control_text"]) && self.pers["control_text"])
              self thread print_controls(is_player_gamepad_enabled());
            wait 0.15;
          }
        } else {
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
          if (isDefined(self.pers["control_text"]) && self.pers["control_text"])
            self thread print_controls(is_player_gamepad_enabled());
          wait 0.15;
        }
      }
    }
    wait 0.15;
  }
}

print_controls(gamepad) {
  self endon("end_menu");
  self endon("end_controls");
  while (true) {
    if (!isDefined(gamepad) || !gamepad) {
      self clear_obituary();
      self iPrintln("^5Menu Controls^7:");
      self iPrintln("^5[{+attack}]^7: Confirm/Select");
      self iPrintln("^5[{+toggleads_throw}]^7: Back/Exit");
      self iPrintln("^5[{+forward}] / [{+back}]^7: Navigate Up/Down");
      self iPrintln("^5[{+moveleft}] / [{+moveright}]^7: Slider Left/Right");
    } else if (gamepad) {
      self clear_obituary();
      self iPrintln("^5Menu Controls^7:");
      self iPrintln("^7[{+reload}]: Confirm/Select");
      self iPrintln("^7[{+melee_zoom}]: Back/Exit");
      self iPrintln("^7[{+actionslot 1}] / [{+actionslot 2}]: Navigate Up/Down");
      self iPrintln("^7[{+actionslot 3}] / [{+actionslot 4}]: Slider Left/Right");
    }
    wait 7;
    if (!isDefined(self.pers["quick_binds"]) || self.pers["quick_binds"]) {
      self clear_obituary();
      self iPrintln("^5Quick Binds^7:");
      self iPrintln("^5[{+actionslot 2}] + Prone^7: Save Location");
      self iPrintln("^5[{+actionslot 2}] + Crouch^7: Load Location");
      self iPrintln("^5[{+actionslot 3}] + Crouch^7: Teleport Enemies to Crosshair");
      self iPrintln("^5[{+melee_zoom}] + Crouch^7: Toggle UFO");
      wait 7;
    }
    waitframe();
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

      if (return_toggle(self.structure[cursor].slider))
        self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5);
      else
        self thread execute_function(self.structure[cursor].function, self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5);

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
        self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.pers["storage_array" + menu + cursor]] : self.pers["storage_increment" + menu + cursor], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5);
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
        self thread execute_function(self.structure[cursor].function, isdefined(self.structure[cursor].array) ? self.structure[cursor].array[self.pers["storage_array" + menu + cursor]] : self.pers["storage_increment" + menu + cursor], self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3, self.structure[cursor].argument_4, self.structure[cursor].argument_5);
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
    self add_option("Raise Menu", ::new_menu, "Raise");
    self add_option("Animation Menu", ::new_menu, "Animation");
    self add_option("Afterhit Menu", ::new_menu, "Afterhit");
    self add_option("Bot Menu", ::new_menu, "Bots");
    self add_option("Player Menu", ::new_menu, "User");
    break;
  case "Trickshot":
    self add_menu(menu);
    self add_string("EB Weapon", true, ::select_eb_weapon, ["Snipers", "Selected Weapon"], self);
    self add_string("EB Type", true, ::AimbotType, ["Weapon", "Claymore", "C4"], undefined, self);
	self add_increment("EB Delay", true, ::AimbotDelay, 0.1, 0.1, 0.5, 0.1, undefined, self);
    self add_increment("EB Radius", true, ::AimbotStrength, 0, 0, 1000, 100, undefined, self);
    self add_string("Tag Weapon", true, ::select_tag_eb_weapon, ["All", "Selected Weapon"], self);
    self add_increment("Tag Radius", true, ::TagStrength, 0, 0, 1000, 100, undefined, self);
    self add_divider();
    self add_toggle("Save Location", ::do_save_location, self.pers["saved_location"], undefined, self, false);
    self add_option("Load Location", ::do_load_location, self, true);
    self add_option("Drop Can Swap", ::give_can_swap);
    if (getDvar("g_gametype") == "dm" || getDvar("g_gametype") == "war") {
      self add_option("Fast Last", ::do_fast_last, self);
      self add_option("Reset Kills", ::do_reset_scores, 0, self);
      self add_toggle("Give TK after Tac Insert", ::toggle_tk_insert, self.pers["tk_tact"]);
    }
    self add_toggle("Quick Binds", ::toggle_quick_binds, self.pers["quick_binds"]);
    self add_toggle("Auto-Prone", ::do_auto_prone, self.pers["auto_prone"]);
    self add_toggle("Auto-Replenish Ammo", ::toggle_replenish_ammo, self.pers["auto_replenish"]);
    break;
  case "Afterhit":
    self add_menu(menu);
    self add_toggle("Afterhit", ::toggle_afterhit_status, self.pers["do_afterhit"]);
    self add_toggle("Afterhit Trigger Weapon", ::toggle_afterhit_weapon, self.pers["select_afterhit"]);
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
  case "Raise":
    self add_menu(menu);
    self add_toggle("Always Raise", ::toggle_raise_status, self.pers["do_raise"]);
    self add_string("Always Raise Type", true, ::set_raise_type, ["None", "Fast Glide", "G-Flip", "Can Swap", "Can Zoom", "Instashoot"]);
    self add_toggle("Always Raise Weapon", ::toggle_raise_weapon, self.pers["select_raise"]);
    break;
  case "Animation":
    self add_menu(menu);
    //self add_toggle("Always Reload Nac (WIP)", ::toggle_reloadnac, self.pers["reload_nac"]); // todo
    self add_toggle("Always Knife Lunge", ::toggle_knife_lunge, self.pers["knife_lunge"]);
    self add_toggle("Always R-Mala", ::toggle_rmala, self.pers["rmala"]);
    self add_toggle("Always Insta Tac Plant", ::toggle_instaplant, self.pers["instaplant"]);
    self add_toggle("Always Wildscope", ::toggle_wildscope, self.pers["wildscope"]);
    self add_toggle("Always Wildscope (Lunge)", ::toggle_wildscopelunge, self.pers["wildscope_lunge"]);
    self add_divider();
	self add_bind("Can Swap Bind", ::bind_canswap, "canswap");
    self add_bind("Can Zoom Bind", ::bind_canzoom, "zoom");
    self add_bind("Care Package Nac Bind", ::bind_fakenac, "cpnac", "airdrop_marker_mp");
    self add_bind("Laptop Nac Bind", ::bind_fakenac, "prednac", "predator_mp");
    self add_bind("Smooth Bind", ::bind_animation, "smooth", 1);
    self add_bind("Mantle Bind", ::bind_animation, "mantle", 50);
    self add_bind("Sprint Bind", ::bind_animation, "running", 33);
    self add_bind("Knife Lunge Bind", ::bind_lunge, "knifeanim");
    self add_bind("Inspect Bind", ::bind_animation, "inspect", 58);
    self add_bind("Cock Back Bind", ::bind_animation, "cockback", 7);
    self add_bind("Empty Mag Bind", ::bind_animation, "emptymag", 21);
    self add_bind("Reload Bind", ::bind_animation, "reload", 20);
    self add_bind("Invisible Gun Bind", ::bind_animation, "invisible", 17);
    self add_bind("Fast Glide Bind", ::bind_fastglide, "fastglide");
    break;
  case "Binds":
    self add_menu(menu);
    self add_option("Damage Buffer", ::new_menu, "Damage Buffer");
	self add_option("Bolt Movement", ::new_menu, "Bolt");
    self add_option("Velocity", ::new_menu, "Velocity");
    self add_bind("Nac Mod Bind", ::bind_nacmod, "nacmod");
    self add_bind("Instaswap Bind", ::bind_instaswap, "instaswap");
	self add_bind("Empty Mag Bind", ::bind_emptymag_real, "emptymag_real");
	self add_bind("Last Bullet Bind", ::bind_lastbullet, "lastbullet");
    self add_bind("G-Flip Bind", ::bind_gflip, "gflip");
    self add_bind("Alt Swap Bind", ::bind_altswap, "altswap");
    self add_bind("Bot EMP Bind", ::bind_emp, "doemp");
    self add_bind("Change Class Bind", ::bind_classchange, "classchange");
    self add_bind("Damage Bind", ::bind_damage, "damage");
    self add_bind("Scavenger Bind", ::bind_scavenger, "scavenger");
    self add_bind("Hitmarker Bind", ::bind_hitmarker, "hitmarker");
    self add_bind("Flash Bind", ::bind_flash, "flash");
    self add_bind("Third Eye Bind", ::bind_thirdeye, "thirdeye");
    self add_bind("Semtext Stuck Bind", ::bind_stuck, "stuck");
    self add_bind("Last Stand Bind", ::bind_laststand, "laststand");
    self add_bind("Final Stand Bind", ::bind_finalstand, "finalstand");
    self add_bind("Destroy Tac Bind", ::bind_destroytac, "destroytac");
    self add_bind("OMA Shax Bind", ::bind_omashax, "omashax");
    self add_bind("Vish Bind", ::bind_vish, "vish");
    self add_bind("Copycat Bind", ::bind_copycat, "copycat");
    self add_bind("Painkiller Bind", ::bind_painkiller, "painkiller");
    self add_bind("Blast Shield Bind", ::bind_blastshield, "blastshield");
    self add_bind("Repeater Bind", ::bind_repeater, "repeater");
    break;
  case "Damage Buffer":
    self add_menu(menu);
    self add_bind("Damage Buffer Bind", ::bind_damagebuffer, "damagebuffer");
    self add_option("Damage Buffer Targets", ::new_menu, "User");
    break;
  case "Bolt":
    self add_menu(menu);
    self add_bind("Bolt Bind", ::bind_bolt, "bolt");
    self add_category("Bolt Editor");
    self add_option("Record Bolt Path", ::bolt_record);
    self add_option("Save Point", ::bolt_save);
    self add_option("Delete Point", ::bolt_delete);
    self add_option("Preview Bolt", ::bolt_start);
    self add_option("Reset Bolt", ::bolt_reset);
    self add_increment("Bolt Duration", true, ::bolt_time, 3, 1, 10, 1);
    break;
  case "Velocity":
    self add_menu(menu);
    self add_bind("Velocity Bind", ::bind_velocity, "velocity");
    self add_category("Velocity Editor");
    self add_increment("Velocity X", true, ::velocity_axis, 0, -1500, 1500, 25, "X");
    self add_increment("Velocity Y", true, ::velocity_axis, 0, -1500, 1500, 25, "Y");
    self add_increment("Velocity Z", true, ::velocity_axis, 0, -1500, 1500, 25, "Z");
    self add_option("Track Velocity", ::velocity_track);
    self add_option("Preview Velocity", ::velocity_start);
    self add_option("Reset Velocity", ::velocity_reset);
    self add_increment("Velocity Multiplier", false, ::velocity_speed, 1, 0.25, 2.5, 0.25);
    self add_increment("Velocity Divider", false, ::velocity_speed, 1, 0.25, 2.5, 0.25, true);
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
      self add_option("None", ::select_weapon_rp, "None");
      self add_category(retropack_storage(1, "Weapons"));
    }
    self add_option("Snipers", ::new_menu, "Snipers", retropack_storage(1, "Weapons"));
    self add_option("Shotguns", ::new_menu, "Shotguns", retropack_storage(1, "Weapons"));
    self add_option("Pistols", ::new_menu, "Pistols", retropack_storage(1, "Weapons"));
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
    self add_shaderoption("hud_icon_cheytac", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_cheytac_mp;No Attachments", "h2_cheytac_mp_silencersniper;Silencer", "h2_cheytac_mp_acog;ACOG", "h2_cheytac_mp_fmj;FMJ", "h2_cheytac_mp_thermal;Thermal", "h2_cheytac_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "Intervention");
    self add_shaderoption("hud_icon_barrett50cal", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_barrett_mp;No Attachments", "h2_barrett_mp_silencersniper;Silencer", "h2_barrett_mp_acog;ACOG", "h2_barrett_mp_fmj;FMJ", "h2_barrett_mp_thermal;Thermal", "h2_barrett_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "Barrett .50cal");
    self add_shaderoption("hud_icon_wa2000", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_wa2000_mp;No Attachments", "h2_wa2000_mp_silencersniper;Silencer", "h2_wa2000_mp_acog;ACOG", "h2_wa2000_mp_fmj;FMJ", "h2_wa2000_mp_thermal;Thermal", "h2_wa2000_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "WA2000");
    self add_shaderoption("hud_icon_m14ebr_scope", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m21_mp;No Attachments", "h2_m21_mp_silencersniper;Silencer", "h2_m21_mp_acog;ACOG", "h2_m21_mp_fmj;FMJ", "h2_m21_mp_thermal;Thermal", "h2_m21_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M21 EBR");
    self add_shaderoption("hud_icon_m40a3", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m40a3_mp;No Attachments", "h2_m40a3_mp_silencersniper;Silencer", "h2_m40a3_mp_acog;ACOG", "h2_m40a3_mp_fmj;FMJ", "h2_m40a3_mp_thermal;Thermal", "h2_m40a3_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M40A3");
    break;
  case "Shotguns":
    self add_menu(menu);
    self add_shaderoption("hud_icon_spas12", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_spas12_mp;No Attachments", "h2_spas12_mp_reflex;Red Dot", "h2_spas12_mp_silencershotgun;Silencer", "h2_spas12_mp_foregrip;Grip", "h2_spas12_mp_fmj;FMJ", "h2_spas12_mp_holo;Holo Sight", "h2_spas12_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "SPAS-12");
    self add_shaderoption("hud_icon_aa12", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_aa12_mp;No Attachments", "h2_aa12_mp_reflex;Red Dot", "h2_aa12_mp_silencershotgun;Silencer", "h2_aa12_mp_foregrip;Grip", "h2_aa12_mp_fmj;FMJ", "h2_aa12_mp_holo;Holo Sight", "h2_aa12_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "AA-12");
    self add_shaderoption("hud_icon_striker", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_striker_mp;No Attachments", "h2_striker_mp_reflex;Red Dot", "h2_striker_mp_silencershotgun;Silencer", "h2_striker_mp_foregrip;Grip", "h2_striker_mp_fmj;FMJ", "h2_striker_mp_holo;Holo Sight", "h2_striker_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "Striker");
    self add_shaderoption("hud_icon_sawed_off", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_ranger_mp;No Attachments", "h2_ranger_mp_akimbo;Akimbo", "h2_ranger_mp_fmj;FMJ"], retropack_storage(1, "Weapons"), "Ranger");
    self add_shaderoption("hud_icon_benelli_m4", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m1014_mp;No Attachments", "h2_m1014_mp_reflex;Red Dot", "h2_m1014_mp_silencershotgun;Silencer", "h2_m1014_mp_foregrip;Grip", "h2_m1014_mp_fmj;FMJ", "h2_m1014_mp_holo;Holo Sight", "h2_m1014_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M1014");
    self add_shaderoption("hud_icon_model1887", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_model1887_mp;No Attachments", "h2_model1887_mp_akimbo;Akimbo", "h2_model1887_mp_fmj;FMJ"], retropack_storage(1, "Weapons"), "Model 1887");
    break;
  case "Pistols":
    self add_menu(menu);
    self add_shaderoption("hud_icon_usp_45", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_usp_mp;No Attachments", "h2_usp_mp_fmj;FMJ", "h2_usp_mp_silencerpistol;Silencer", "h2_usp_mp_akimbo;Akimbo", "h2_usp_mp_tacknifeusp;Tact. Knife", "h2_usp_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "USP .45");
    self add_shaderoption("hud_icon_colt_anaconda", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_coltanaconda_mp;No Attachments", "h2_coltanaconda_mp_fmj;FMJ", "h2_coltanaconda_mp_akimbo;Akimbo", "h2_coltanaconda_mp_tacknifecolt44;Tact. Knife"], retropack_storage(1, "Weapons"), "44 Magnum");
    self add_shaderoption("hud_icon_m9beretta", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m9_mp;No Attachments", "h2_m9_mp_fmj;FMJ", "h2_m9_mp_silencerpistol;Silencer", "h2_m9_mp_akimbo;Akimbo", "h2_m9_mp_tacknifem9;Tact. Knife", "h2_m9_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M9");
    self add_shaderoption("hud_icon_desert_eagle", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_deserteagle_mp;No Attachments", "h2_deserteagle_mp_fmj;FMJ", "h2_deserteagle_mp_akimbo;Akimbo", "h2_deserteagle_mp_tacknifedeagle;Tact. Knife"], retropack_storage(1, "Weapons"), "Deagle");
    self add_shaderoption("hud_icon_colt_45", false, 18, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_colt45_mp;No Attachments", "h2_colt45_mp_fmj;FMJ", "h2_colt45_mp_silencerpistol;Silencer", "h2_colt45_mp_akimbo;Akimbo", "h2_colt45_mp_tacknifecolt45;Tact. Knife", "h2_colt45_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M1911");
    break;
  case "Machine Pistols":
    self add_menu(menu);
    self add_shaderoption("hud_icon_pp2000", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_pp2000_mp;No Attachments", "h2_pp2000_mp_reflex;Red Dot", "h2_pp2000_mp_silencerpistol;Silencer", "h2_pp2000_mp_fmj;FMJ", "h2_pp2000_mp_akimbo;Akimbo", "h2_pp2000_mp_holo;Holo Sight", "h2_pp2000_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "PP2000");
    self add_shaderoption("hud_icon_glock", false, 26, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_glock_mp;No Attachments", "h2_glock_mp_reflex;Red Dot", "h2_glock_mp_silencerpistol;Silencer", "h2_glock_mp_fmj;FMJ", "h2_glock_mp_akimbo;Akimbo", "h2_glock_mp_holo;Holo Sight", "h2_glock_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "G18");
    self add_shaderoption("hud_icon_beretta393", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_beretta393_mp;No Attachments", "h2_beretta393_mp_reflex;Red Dot", "h2_beretta393_mp_silencerpistol;Silencer", "h2_beretta393_mp_fmj;FMJ", "h2_beretta393_mp_akimbo;Akimbo", "h2_beretta393_mp_holo;Holo Sight", "h2_beretta393_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M93 Raffica");
    self add_shaderoption("hud_icon_mp9", false, 26, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_tmp_mp;No Attachments", "h2_tmp_mp_reflex;Red Dot", "h2_tmp_mp_silencerpistol;Silencer", "h2_tmp_mp_fmj;FMJ", "h2_tmp_mp_akimbo;Akimbo", "h2_tmp_mp_holo;Holo Sight", "h2_tmp_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "TMP");
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
    break;
  case "Submachine Guns":
    self add_menu(menu);
    self add_shaderoption("hud_icon_mp5k", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_mp5k_mp;No Attachments", "h2_mp5k_mp_fastfire;Rapid Fire", "h2_mp5k_mp_reflex;Red Dot", "h2_mp5k_mp_silencersmg;Silencer", "h2_mp5k_mp_acog;ACOG", "h2_mp5k_mp_fmj;FMJ", "h2_mp5k_mp_akimbo;Akimbo", "h2_mp5k_mp_holo;Holo Sight", "h2_mp5k_mp_thermal;Thermal", "h2_mp5k_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "MP5K");
    self add_shaderoption("hud_icon_ump45", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_ump45_mp;No Attachments", "h2_ump45_mp_fastfire;Rapid Fire", "h2_ump45_mp_reflex;Red Dot", "h2_ump45_mp_silencersmg;Silencer", "h2_ump45_mp_acog;ACOG", "h2_ump45_mp_fmj;FMJ", "h2_ump45_mp_akimbo;Akimbo", "h2_ump45_mp_holo;Holo Sight", "h2_ump45_mp_thermal;Thermal", "h2_ump45_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "UMP45");
    self add_shaderoption("hud_icon_kriss", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_kriss_mp;No Attachments", "h2_kriss_mp_fastfire;Rapid Fire", "h2_kriss_mp_reflex;Red Dot", "h2_kriss_mp_silencersmg;Silencer", "h2_kriss_mp_acog;ACOG", "h2_kriss_mp_fmj;FMJ", "h2_kriss_mp_akimbo;Akimbo", "h2_kriss_mp_holo;Holo Sight", "h2_kriss_mp_thermal;Thermal", "h2_kriss_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "Vector");
    self add_shaderoption("hud_icon_p90", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_p90_mp;No Attachments", "h2_p90_mp_fastfire;Rapid Fire", "h2_p90_mp_reflex;Red Dot", "h2_p90_mp_silencersmg;Silencer", "h2_p90_mp_acog;ACOG", "h2_p90_mp_fmj;FMJ", "h2_p90_mp_akimbo;Akimbo", "h2_p90_mp_holo;Holo Sight", "h2_p90_mp_thermal;Thermal", "h2_p90_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "P90");
    self add_shaderoption("hud_icon_mini_uzi", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_uzi_mp;No Attachments", "h2_uzi_mp_fastfire;Rapid Fire", "h2_uzi_mp_reflex;Red Dot", "h2_uzi_mp_silencersmg;Silencer", "h2_uzi_mp_acog;ACOG", "h2_uzi_mp_fmj;FMJ", "h2_uzi_mp_akimbo;Akimbo", "h2_uzi_mp_holo;Holo Sight", "h2_uzi_mp_thermal;Thermal", "h2_uzi_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "Mini-Uzi");
    self add_shaderoption("hud_icon_ak74u", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_AK74U_mp;No Attachments", "h2_AK74U_mp_fastfire;Rapid Fire", "h2_AK74U_mp_reflex;Red Dot", "h2_AK74U_mp_silencerar;Silencer", "h2_AK74U_mp_acog;ACOG", "h2_AK74U_mp_fmj;FMJ", "h2_AK74U_mp_akimbo;Akimbo", "h2_AK74U_mp_holo;Holo Sight", "h2_AK74U_mp_thermal;Thermal", "h2_AK74U_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "AK47U");
    break;
  case "Light Machine Guns":
    self add_menu(menu);
    self add_shaderoption("hud_icon_sa80_lmg", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_sa80_mp;No Attachments", "h2_sa80_mp_reflex;Red Dot", "h2_sa80_mp_silencerlmg,Silencer", "h2_sa80_mp_acog;ACOG", "h2_sa80_mp_fmj;FMJ", "h2_sa80_mp_holo;Holo Sight", "h2_sa80_mp_thermal;Thermal", "h2_sa80_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "L86 LSW");
    self add_shaderoption("hud_icon_rpd", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_rpd_mp;No Attachments", "h2_rpd_mp_reflex;Red Dot", "h2_rpd_mp_silencerlmg,Silencer", "h2_rpd_mp_acog;ACOG", "h2_rpd_mp_fmj;FMJ", "h2_rpd_mp_holo;Holo Sight", "h2_rpd_mp_thermal;Thermal", "h2_rpd_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "RPD");
    self add_shaderoption("hud_icon_mg4", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_mg4_mp;No Attachments", "h2_mg4_mp_reflex;Red Dot", "h2_mg4_mp_silencerlmg,Silencer", "h2_mg4_mp_acog;ACOG", "h2_mg4_mp_fmj;FMJ", "h2_mg4_mp_holo;Holo Sight", "h2_mg4_mp_thermal;Thermal", "h2_mg4_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "MG4");
    self add_shaderoption("hud_icon_steyr", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_aug_mp;No Attachments", "h2_aug_mp_reflex;Red Dot", "h2_aug_mp_silencerlmg,Silencer", "h2_aug_mp_acog;ACOG", "h2_aug_mp_fmj;FMJ", "h2_aug_mp_holo;Holo Sight", "h2_aug_mp_thermal;Thermal", "h2_aug_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "AUG HBAR");
    self add_shaderoption("hud_icon_m240", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m240_mp;No Attachments", "h2_m240_mp_reflex;Red Dot", "h2_m240_mp_silencerlmg,Silencer", "h2_m240_mp_acog;ACOG", "h2_m240_mp_fmj;FMJ", "h2_m240_mp_holo;Holo Sight", "h2_m240_mp_thermal;Thermal", "h2_m240_mp_xmag;X-Mags"], retropack_storage(1, "Weapons"), "M240");
    break;
  case "Launchers":
    self add_menu(menu);
    self add_shaderoption("hud_icon_at4", false, 28, 9, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["at4_mp;AT4-HS"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "AT4-HS" : "");
    self add_shaderoption("hud_icon_m79", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_m79_mp;Thumper"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Thumper" : "");
    self add_shaderoption("hud_icon_stinger", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["stinger_mp;Stinger"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Stinger" : "");
    self add_shaderoption("hud_icon_javelin", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["javelin_mp;Javelin"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "Javelin" : "");
    self add_shaderoption("hud_icon_rpg", false, 28, 14, self.previous[self.previous.size - 2] == "Class" || self.previous[self.previous.size - 2] == "Afterhit" ? ::select_weapon_rp : ::give_weapon, ["h2_rpg_mp;RPG"], retropack_storage(1, "Weapons"), self.previous[self.previous.size - 2] == "Class" ? "RPG" : "");
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
    self add_category("Give Streak");
    self add_string("UAV", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "radar_mp;UAV");
    self add_string("Care Package", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "airdrop_marker_mp;Care Package");
    self add_string("Counter-UAV", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "counter_radar_mp;Counter-UAV");
    self add_string("Sentry Gun", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "sentry_mp;Sentry Gun");
    self add_string("Predator Missile", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "predator_mp;Predator Missile");
    self add_string("Precision Airstrike", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "airstrike_mp;Precision Airstrike");
    self add_string("Attack Helicopter", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "helicopter_mp;Attack Helicopter");
    self add_string("Harrier Strike", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "harrier_airstrike_mp;Harrier Strike");
    self add_string("Pavelow", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "pavelow_mp;Pavelow");
    self add_string("Emergency Airdrop", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "airdrop_mega_marker_mp;Emergency Airdrop");
    self add_string("Stealth Bomber", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "stealth_airstrike_mp;Stealth Bomber");
    self add_string("Chopper Gunner", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "chopper_gunner_mp;Chopper Gunner");
    self add_string("AC130", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "ac130_mp;AC130");
    self add_string("EMP", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "emp_mp;EMP");
    self add_string("Tactical Nuke", false, ::give_killstreak, [1, 2, 3, 4, 5, 6, 7, 9, 10], "nuke_mp;Tactical Nuke");
    break;
  case "Bots":
    self add_menu(menu);
    self add_string("Spawn Bot", false, ::spawn_bot, [getOtherTeam(self.team), self.team]);
    if (self ishost() || isDefined(self.pers["rp_host"]) && self.pers["rp_host"])
      self add_string("Spawn Bot Fill", false, ::spawn_bot_wrapper, [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16], "fill");
    self add_string("Bots to Crosshairs", false, ::do_teleport_bots, [getOtherTeam(self.team), self.team, "All"]);
    self add_string("Bots to You", false, ::do_teleport_bots_to_you, [getOtherTeam(self.team), self.team, "All"]);
    self add_string("Freeze/Unfreeze Bots", false, ::toggle_bot_freeze, [getOtherTeam(self.team), self.team, "All"]);
    self add_string("Randomise Bot Levels", false, ::func_randomise_bot_levels, [getOtherTeam(self.team), self.team, "All"]);
    self add_string("Kill Bots", false, ::func_bot_kick_or_kill, [getOtherTeam(self.team), self.team, "All"], "kill");
    self add_string("Kick Bots", false, ::func_bot_kick_or_kill, [getOtherTeam(self.team), self.team, "All"], "kick");
    break;
  case "Game":
    self add_menu(menu);
    if (self ishost() || isDefined(self.pers["rp_host"]) && self.pers["rp_host"]) {
      self add_option("Health and Damage", ::new_menu, "Health and Damage");
      self add_toggle("Stop Game Timer", ::do_pause_timer, self.pausetimer);
      self add_string("Stopwatch", true, ::toggle_autopause, ["Off", 5, 10, 15, 30, 45, 60]);
      self add_string("Auto-Nuke", true, ::toggle_autonuke, ["Off", 5, 10, 15, 30, 45, 60], false);
      if (getDvar("g_gametype") == "sd") {
        self add_string("Auto-Plant", true, ::toggle_autoplant, ["Off", 5, 10, 15, 30, 45, 60]);
        self add_toggle("Auto-Defuse", ::toggle_autodefuse, self.pers["auto_defuse"]);
        self add_toggle("Revives", ::toggle_revives, self.pers["revives"]);
      }
      if (getDvarInt("g_hardcore") != 1) {
        self add_toggle("Hardcore", ::toggle_hardcore, self.pers["hardcore_mode"]);
      }
    }
    if (self ishost() || isDefined(self.pers["rp_host"]) && self.pers["rp_host"]) {
      if (getDvar("g_gametype") == "sd")
        self add_toggle("Headshots (+1000)", ::toggle_headshots, self.pers["rp_headshots"]);
      self add_toggle("First Blood (+600)", ::toggle_firstblood, self.pers["rp_firstblood"]);
      self add_toggle("Distance Meter", ::toggle_distance, self.pers["distance_meter"]);
	  self add_toggle("Head Bounces", ::toggle_headbounce, self.pers["rp_headbounce"]);
      self add_toggle("Soft Lands", ::toggle_softlands, self.pers["soft_lands"]);
      self add_toggle("Depatch Elevators", ::toggle_elevators, self.pers["do_elevators"]);
      self add_toggle("Death Barriers", ::toggle_death_barriers, self.pers["death_barriers"]);
    }
    if (getDvar("g_gametype") == "sd")
      self add_option("Reset Rounds", ::do_round_reset);
    self add_option("Fast Restart", ::func_fast_restart);
    self add_option("Leave Game", ::exit_level);
    self add_increment("Pickup Radius", true, ::set_pickup_radius, getDvarInt("player_useRadius"), 0, 1024, 64);
    self add_increment("Frag Pickup Radius", true, ::set_grenade_pickup_radius, getDvarInt("player_throwbackInnerRadius"), 0, 1080, 45);
    self add_increment("Timescale", true, ::set_timescale, getDvarInt("timescale"), 0.25, 8, 0.25);
    self add_increment("Gravity", true, ::set_gravity, getDvarInt("g_gravity"), 100, 1500, 100);
    self add_increment("Ladder Knockback", true, ::set_ladder_knockback, getDvarInt("jump_ladderPushVel"), 0, 1024, 64);
    break;
  case "Health and Damage":
    self add_menu(menu);
    self add_increment("Lobby Health", true, ::set_player_health, getDvar("g_gametype") != "sd" ? 100 : 25, 25, 400, 25);
	self add_increment("Sniper Damage", true, ::set_sniper_damage, getDvarInt("rp_sniper_damage"), 0, 100, 25);
    self add_increment("Bot Damage", true, ::set_bot_damage, getDvarFloat("rp_bot_damage"), 0, 2, 0.25);
    self add_increment("Melee Damage", true, ::set_melee_damage, getDvarInt("rp_melee_damage"), 0, 100, 25);
    break;
  case "User":
    self add_menu(menu);
    for (i = 0; i < level.players.size; i++) {
      if (self.previous[self.previous.size - 1] == "Damage Buffer") {
        self add_toggle(sanitise_name(level.players[i].name), ::toggle_damage_buffer, level.players[i].pers["damage_buffer_victim"], undefined, level.players[i]);
      } else {
        if (level.players[i] != self)
          self add_option(sanitise_name(level.players[i].name), ::player_index, level.players[i]);
      }
    }
    break;
  case "Admin":
    self add_menu(menu);
    self add_option("Account Menu", ::new_menu, "Account");
    self add_option("Perk Menu", ::new_menu, "Perks");
    self add_divider();
    self add_string("Select Hand Model", true, ::set_viewhand_model, ["Ghillie", "Infected", "Militia", "SEALs", "TF141", "Rangers", "Spetsnaz", "OpFor"]);
    self add_string("UAV", true, ::do_radar, ["Fast", "Off", "Normal"]);
    self add_toggle("God Mode", ::toggle_god_mode, self.pers["god_mode"]);
    self add_toggle("Clip Warning", ::toggle_clipwarning, self.pers["clip_warning"]);
    self add_toggle("End of Game Freeze", ::toggle_afterhit, self.pers["after_hit"]);
    self add_toggle("Killcam Timer", ::toggle_killcam_timer, self.pers["rp_timer"]);
	self add_string("Killcam Timer Font", true, ::set_killcam_timer_font, ["Retro-Pack", "Classic"]);
    self add_toggle("Menu Controls", ::toggle_rp_text, self.pers["show_open"]);
    self add_toggle("Print Version At Spawn", ::toggle_spawn_text, self.pers["spawn_text"]);
    self add_toggle("Print Menu Controls", ::toggle_controls_text, self.pers["control_text"]);
    self add_option("Print GUID", ::print_guid, self);
    self add_category("Spoof Editor");
    self add_shaderarray("Spoof Prestige", false, ::spoof_prestige, ["rank_comm", "h2m_rank_prestige1", "h2m_rank_prestige3", "h2m_rank_prestige4", "h2m_rank_prestige5", "h2m_rank_prestige6", "h2m_rank_prestige7", "h2m_rank_prestige8", "h2m_rank_prestige9", "h2m_rank_prestige10", "h2m_cheytac_ui", "em_st_180"], self, false);
    self add_string("Spoof Level", false, ::spoof_rank, [1, 5, 25, 69, 70], self, false);
    self add_increment("Spoof XP Progress", false, ::spoof_xp_bar, 0, 0, 100, 5, self, false);
    break;
  case "Account":
    self add_menu(menu);
    self add_shaderarray("Set Prestige", false, ::set_prestige, ["rank_comm", "h2m_rank_prestige1", "h2m_rank_prestige3", "h2m_rank_prestige4", "h2m_rank_prestige5", "h2m_rank_prestige6", "h2m_rank_prestige7", "h2m_rank_prestige8", "h2m_rank_prestige9", "h2m_rank_prestige10", "h2m_cheytac_ui"], 2515999);
    self add_option("Derank", ::set_prestige, 0, 0);
    self add_option("Unlock All", ::set_challenges);
    self add_string("Overkill Classes", false, ::set_overkill_classes, ["Snipers", "AR", "SMG"]);
    self add_toggle("Coloured Classes", ::set_coloured_classes, self.colouredClasses);
    break;
  case "Camo":
    self add_menu(menu);
    if (isDefined(self.pers["cacPrimaryConsole"]) && self.previous[self.previous.size - 1] == "Class" && is_launcher(self.pers["cacPrimaryConsole"]) ||
      isDefined(self.pers["cacSecondaryConsole"]) && self.previous[self.previous.size - 1] == "Class" && is_launcher(self.pers["cacSecondaryConsole"])) {
      self add_option("None", self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, "None", retropack_storage(1, "Camo"));
    } else {
      self add_option("None", self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, "None", retropack_storage(1, "Camo"));
      self add_option("Random", self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, random_camo(true), retropack_storage(1, "Camo"));
      self add_shaderarray("Classic", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo016;h2m_img_camo_desert", "camo017;h2m_img_camo_arctic", "camo018;h2m_img_camo_woodland", "camo019;h2m_img_camo_digital", "camo020;h2m_img_camo_urban", "camo021;h2m_img_camo_blue_tiger", "camo022;h2m_img_camo_red_tiger", "camo023;h2m_img_camo_orange_fall", "gold;h2m_img_camo_gold", "golddiamond;h2m_img_camo_diamond", "toxicwaste;h2m_img_camo_toxic_waste"], retropack_storage(1, "Camo"));
      self add_shaderarray("Solid Colour", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo024;h2m_img_camo_yellow", "camo025;h2m_img_camo_white", "camo026;h2m_img_camo_red", "camo027;h2m_img_camo_purple", "camo028;h2m_img_camo_pink", "camo029;h2m_img_camo_pastel_brown", "camo030;h2m_img_camo_orange", "camo031;h2m_img_camo_light_pink", "camo032;h2m_img_camo_green", "camo033;h2m_img_camo_dark_red", "camo034;h2m_img_camo_dark_green", "camo035;h2m_img_camo_cyan", "camo036;h2m_img_camo_brown", "camo037;h2m_img_camo_blue", "camo038;h2m_img_camo_black"], retropack_storage(1, "Camo"));
      self add_shaderarray("Polyatomic", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo041;h2m_img_camo_polyatomic", "camo043;h2m_img_camo_poly_blue", "camo047;h2m_img_camo_poly_cyan", "camo042;h2m_img_camo_poly_dred", "camo045;h2m_img_camo_poly_green", "camo040;h2m_img_camo_poly_orange", "camo044;h2m_img_camo_poly_pink", "camo046;h2m_img_camo_poly_red", "camo039;h2m_img_camo_poly_yellow"], retropack_storage(1, "Camo"));
      self add_shaderarray("Elemental", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo052;h2m_img_camo_ice", "camo049;h2m_img_camo_lava", "camo053;h2m_img_camo_storm", "camo050;h2m_img_camo_water", "camo051;h2m_img_camo_fire", "camo048;h2m_img_camo_gas"], retropack_storage(1, "Camo"));
      self add_shaderarray("Bonus", true, self.previous[self.previous.size - 1] == "Weapons" ? ::give_camo_rp : ::select_camo_rp, ["camo057;h2m_img_camo_doomsday", "camo054;h2m_img_camo_nuclear_blue", "camo056;h2m_img_camo_nuclear_red", "camo058;h2m_img_camo_soaring"], retropack_storage(1, "Camo"));
    }
    break;
  case "Class":
    self add_menu(menu);
    self add_label("Primary:", self.pers["cacPrimaryName"], ::new_menu, "Weapons", "Primary");
    self add_label("Attachment 2:", self.pers["cacPrimaryAttachment2Name"], ::new_menu, "Attachment", "Primary");
    self add_label("Camo:", self.pers["cacPrimaryCamoName"], ::new_menu, "Camo", "Primary");
    self add_category("Secondary");
    self add_label("Secondary:", self.pers["cacSecondaryName"], ::new_menu, "Weapons", "Secondary");
    self add_label("Attachment 2:", self.pers["cacSecondaryAttachment2Name"], ::new_menu, "Attachment", "Secondary");
    self add_label("Camo:", self.pers["cacSecondaryCamoName"], ::new_menu, "Camo", "Secondary");
    self add_category("Equipment");
    self add_label("Equipment:", self.pers["cacEquipmentName"], ::new_menu, "Equipment");
    self add_label("Off Hand:", self.pers["cacOffHandName"], ::new_menu, "Offhand");
    self add_category("Perks");
    self add_label("Perk 1:", self.pers["cacPerkName1"], ::new_menu, "Perks", 1);
    self add_label("Perk 2:", self.pers["cacPerkName2"], ::new_menu, "Perks", 2);
    self add_label("Perk 3:", self.pers["cacPerkName3"], ::new_menu, "Perks", 3);
    self add_category("Save Options");
    self add_option("Give Class", ::give_rpclass);
    self add_string("Save as Custom Class", false, ::set_rpclass, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
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
    }
    break;
  case "Perks":
    self add_menu(menu);
    if (self.previous[self.previous.size - 1] == "Class")
      self add_option("None", ::select_perk_rp, "None", undefined, retropack_storage(1, "Perks"));

    if (self.previous[self.previous.size - 1] != "Class") {
      self add_toggle("Perks Carry-Over", ::toggle_flag_perk, self.pers["flag_perk"]);
      self add_category("Perks");
    }
    for (i = 1; i < 33; i++) {
      perk = tableLookup("mp/perkTable.csv", 0, i, 1);
      name = get_localised_perk(perk);
      if (!isSubStr(perk, "specialty_"))
        continue;

      if (self maps\mp\_utility::_hasPerk(perk) || isDefined(self.pers["set_" + perk]) && self.pers["set_" + perk])
        self.pers["set_" + perk] = true;
      else
        self.pers["set_" + perk] = false;

      if (self.previous[self.previous.size - 1] != "Class") {
        self add_toggle(name, ::toggle_perk, self.pers["set_" + perk], undefined, perk);
      } else {
        if (maps\mp\perks\_perks::validateperk(retropack_storage(1, "Perks") - 1, perk) == "specialty_null")
          continue;

        self add_option(name, ::select_perk_rp, perk, name, retropack_storage(1, "Perks"));
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
    self add_string("EB Weapon", true, ::select_eb_weapon, ["Snipers", "Selected Weapon"], player);
    self add_string("EB Type", true, ::AimbotType, ["Weapon", "Claymore", "C4"], undefined, player);
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
  if (self ishost())
    self add_toggle("Co-Host", ::toggle_cohost, player.pers["rp_host"], undefined, player);
  if (!player ishost()) {
    self add_shaderarray("Spoof Prestige", false, ::spoof_prestige, ["rank_comm", "h2m_rank_prestige1", "h2m_rank_prestige3", "h2m_rank_prestige4", "h2m_rank_prestige5", "h2m_rank_prestige6", "h2m_rank_prestige7", "h2m_rank_prestige8", "h2m_rank_prestige9", "h2m_rank_prestige10", "h2m_cheytac_ui", "em_st_180"], player, false);
    self add_string("Spoof Level", false, ::spoof_rank, [1, 5, 25, 69, 70], player, false);
  }
  self set_menu("Player_" + player.name);
  self create_option();
}