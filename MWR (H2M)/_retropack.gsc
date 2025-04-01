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
Date: April 1, 2025
Compatibility: Modern Warfare Remastered (H2M/HMW Mod)

Notes:
- N/A
*/

#include scripts\mp\_retropack_menu;
#include scripts\mp\_retropack_utility;
#include scripts\mp\_retropack_functions;
#include scripts\mp\_retropack_binds;
#include scripts\mp\_retropack_bots;
#include common_scripts\utility;

retropack() {
  self endon("disconnect");

  /* Precaches */
  foreach(index, shader in ["h2m_weapon_claymore", "weapon_semtex", "weapon_fraggrenade", "weapon_throwingknife", "dpad_tacticalinsert", "h2m_weapon_c4", "weapon_blastshield", "hud_icon_mp9", "hud_icon_cheytac", "hud_icon_hatchet", "hud_icon_ice_pick", "hud_icon_sickle", "hud_icon_shovel", "hud_icon_karambit", "hud_icon_famas", "hud_icon_ak74u", "hud_icon_wa2000", "hud_icon_kriss", "hud_icon_mini_uzi", "hud_icon_usp_45", "hud_icon_ump45", "hud_icon_tavor", "hud_icon_striker", "hud_icon_stinger", "hud_icon_steyr", "hud_icon_spas12", "hud_icon_scar_h", "hud_icon_sa80_lmg", "hud_icon_rpg", "hud_icon_rpd", "hud_icon_riot_shield", "hud_icon_sawed_off", "hud_icon_pp2000", "hud_icon_p90", "hud_icon_mp9", "hud_icon_mp5k", "hud_icon_model1887", "hud_icon_mg4", "hud_icon_m79", "hud_icon_m4_grunt", "hud_icon_m40a3", "hud_icon_m240", "hud_icon_m16a4", "hud_icon_benelli_m4", "hud_icon_javelin", "hud_icon_glock", "hud_icon_fn2000", "hud_icon_fnfal", "hud_icon_m14ebr_scope", "hud_icon_desert_eagle", "hud_icon_colt_anaconda", "hud_icon_colt_45", "hud_icon_cheytac", "hud_icon_m9beretta", "hud_icon_beretta393", "hud_icon_barrett50cal", "hud_icon_at4", "hud_icon_ak47", "hud_icon_m4carbine", "hud_icon_aa12", "h2m_cheytac_ui", "em_st_180", "rank_comm", "h2m_rank_prestige1", "h2m_rank_prestige1", "h2m_rank_prestige3", "h2m_rank_prestige4", "h2m_rank_prestige5", "h2m_rank_prestige6", "h2m_rank_prestige7", "h2m_rank_prestige8", "h2m_rank_prestige9", "h2m_rank_prestige10", "ui_arrow_right", "weapon_attachment_suppressor", "weapon_attachment_reflex", "weapon_attachment_fastfire", "weapon_attachment_tacknife", "weapon_attachment_holographic", "weapon_attachment_shotty", "weapon_attachment_thermal2", "weapon_attachment_xmag", "weapon_attachment_shotgun", "weapon_attachment_grip", "weapon_attachment_acog", "specialty_null", "weapon_attachment_akimbo", "weapon_attachment_fmj", "h2_reflex"])
  precacheshader(shader);

  foreach(index, gloves in ["viewhands_infect", "viewhands_h2_ghillie", "globalViewhands_mw2_militia", "viewhands_udt", "viewhands_rangers", "globalViewhands_mw2_airborne", "viewhands_h1_arab_desert_mp_camo", "viewhands_tf141"])
  precachemodel(gloves);
  
  for (i = 0; i < 44; i++) {
    perk = tableLookup("mp/perktable.csv", 0, i, 2);
    precachestring(&"" + perk);
  }
  
  precachestring(&"LUA_MENU_SNIPER_RIFLES_CAPS");
  precachestring(&"LUA_MENU_ASSAULT_RIFLES_CAPS");
  precachestring(&"LUA_MENU_SMGS_CAPS");
  precachestring(&"LUA_MENU_LMGS_CAPS");
  precachestring(&"LUA_MENU_MACHINE_PISTOLS_CAPS");
  precachestring(&"LUA_MENU_SHOTGUNS_CAPS");
  precachestring(&"LUA_MENU_HANDGUNS_CAPS");
  precachestring(&"LUA_MENU_LAUNCHERS_CAPS");
  precachestring(&"LUA_MENU_MELEE1_CAPS");

  for (i = 1; i < tablegetrowcount("mp/camotable.csv"); i++) {
    camo = tableLookup("mp/camotable.csv", 0, i, 4);
    precacheshader(camo);
  }

  /* Dvars */
  setDvar("nightVisionDisableEffects", 1);
  setDvar("pm_bouncing", 1);
  setDvar("pm_bouncingAllAngles", 1);
  setDvar("perk_armorPiercingDamage", 9999);
  setDvar("perk_bulletPenetrationMultiplier", 30);
  setDvar("bg_surfacePenetration", 9999);
  setDvar("safeArea_adjusted_vertical", 0.87);
  setDvar("safeArea_adjusted_horizontal", 0.87);
  setDvarIfUninitialized("rp_bot_count", 0);
  setDvarIfUninitialized("rp_bot_damage", 1);
  setDvarIfUninitialized("rp_melee_damage", 100);
  setDvarIfUninitialized("rp_sniper_damage", 100);
  setDvarIfUninitialized("rp_revives", 1);
  setDvarIfUninitialized("rp_distance_meter", 1);
  setDvarIfUninitialized("rp_firstblood", 0);
  setDvarIfUninitialized("rp_headbounce", 0);

  /* Retro Package */
  level.rankedmatch = 1;
  level.menuName = "Retro Package";
  level.menuHeader = "RETRO_PACKAGE";
  level.menuSubHeader = "H2M";
  level.menuVersion = "1.0.3";
  level.developer = "@rtros";

  level thread retropack_binds();
  level thread retropack_bots();
  level thread on_player_connect();
  level thread monitor_round();
  level thread monitor_end_game();
}

on_player_connect() {
  level endon("game_ended");
  for (;;) {
    level waittill("connected", player);
    if (!player is_bot()) {
      if (player ishost()) {
        if (getDvar("g_gametype") != "sd")
          player thread monitor_bots();
        if (!isDefined(player.pers["first_spawn"]))
          player.pers["first_spawn"] = true;
      }
      player thread on_joined_team();
      if (!isDefined(player.pers["eb_weapon"]))
        player.pers["eb_weapon"] = "Snipers";
      if (!isDefined(player.pers["eb_delay"]))
        player.pers["eb_weapon"] = 0.1;
      if (!isDefined(player.pers["tag_weapon"]))
        player.pers["tag_weapon"] = "All";
      if (!isDefined(player.pers["explosive_bullets_type"]))
        player.pers["explosive_bullets_type"] = "Weapon";
      if (!isDefined(player.pers["clip_warning"]))
        player.pers["clip_warning"] = true;
      if (!isDefined(player.pers["do_radar"]))
        player.pers["do_radar"] = "Fast";
      if (!isDefined(player.pers["death_barriers"]))
        player.pers["death_barriers"] = true;
      if (!isDefined(player.pers["control_text"]))
        player.pers["control_text"] = true;
      if (!isDefined(player.pers["select_afterhit"]))
        player.pers["select_afterhit"] = false;
      if (!isDefined(player.pers["select_raise"]))
        player.pers["select_raise"] = false;
      if (!isDefined(player.pers["raise_type"]))
        player.pers["raise_type"] = "None";
      if (!isDefined(player.pers["afterhit_frequency"]))
        player.pers["afterhit_frequency"] = "Every Shot";
      if (!isDefined(player.pers["do_afterhit"]))
        player.pers["do_afterhit"] = false;
      if (!isDefined(player.pers["spawn_text"]))
        player.pers["spawn_text"] = true;
      if (!isDefined(player.pers["quick_binds"]))
        player.pers["quick_binds"] = true;
      if (!isDefined(player.pers["auto_replenish"]))
        player.pers["auto_replenish"] = true;
      if (!isDefined(player.pers["show_open"]))
        player.pers["show_open"] = true;
      if (!isDefined(player.pers["rp_timer"]))
        player.pers["rp_timer"] = true;
      if (!isDefined(player.pers["tk_tact"]))
        player.pers["tk_tact"] = true;
      if (!isDefined(player.pers["after_hit"]))
        player.pers["after_hit"] = true;
      if (!isDefined(player.pers["hardcore_mode"]))
        player.pers["hardcore_mode"] = false;
      if (!isDefined(player.pers["revives"]))
        player.pers["revives"] = getDvarInt("rp_revives");
      if (!isDefined(player.pers["distance_meter"]))
        player.pers["distance_meter"] = getDvarInt("rp_distance_meter");
      if (!isDefined(player.pers["rp_headshots"]))
        player.pers["rp_headshots"] = 1;
      if (!isDefined(player.pers["rp_firstblood"]))
        player.pers["rp_firstblood"] = getDvarInt("rp_firstblood");
      if (!isDefined(player.pers["knife_lunge"]))
        player.pers["knife_lunge"] = false;
      if (!isDefined(player.pers["soft_lands"])) {
        player.pers["soft_lands"] = getDvar("g_gametype") != "sd" ? false : true;
        setDvar("jump_enableFallDamage", getDvar("g_gametype") != "sd" ? 1 : 0);
      }
    }
    if (!isDefined(player.pers["max_health"]))
      player.pers["max_health"] = getDvar("g_gametype") != "sd" ? 100 : 25;
    player thread on_player_spawned();
  }
}

on_player_spawned() {
  self endon("disconnect");
  self.retropack = [];
  self.retropack["user"] = spawnstruct();
  for (;;) {
    event = self common_scripts\utility::waittill_any_return("spawned_player", "death");
    switch (event) {
    case "spawned_player":
      self apply_flags(self);
      if (self is_bot()) {
        self maps\mp\_utility::giveperk("specialty_falldamage");
        self maps\mp\_utility::_unsetperk("specialty_radarimmune");
        self maps\mp\_utility::_unsetperk("specialty_spygame");
        self maps\mp\_utility::_unsetperk("specialty_localjammer");
      } else {
        if (self ishost()) {
          if (getDvar("g_gametype") == "sd") {
            self thread monitor_bots();
            self thread set_timescale(self.pers["time_scale"], true);
          }
        } else {
          maps\mp\_utility::gameflagwait("prematch_done");
          if (!isDefined(self.pers["spoof_progress"])) {
            self thread spoof_xp_bar(99, self, true);
            waitframe();
            self thread spoof_xp_bar(100, self, true);
            self.pers["spoof_progress"] = true;
          }
        }
        if (!isDefined(self.retropack["user"].has_menu)) {
          self.retropack["user"].has_menu = true;
          if (self ishost() && !isDefined(self.pers["rp_host"]))
            self.pers["rp_host"] = true;
          self retropack_variables();
          self thread monitor_buttons();
        }
        self thread do_class_change();
        self thread call_binds(self);
        self thread monitor_hit_message();
		self thread monitor_headbounce();
      }
      maps\mp\gametypes\_damage::revivesetup(self);
      self thread do_load_location(self, false);
      self thread monitor_last();
	  if (isDefined(self.pers["first_spawn"]) && self.pers["first_spawn"])
        self.pers["first_spawn"] = false;
      break;
    case "death":
      if (self in_menu())
        self close_menu();
      self set_class_save();
      break;
    default:
      if (self in_menu())
        self close_menu();
      break;
    }
  }
}

apply_flags(player) {
  if (player is_bot()) {
    if (getDvar("g_gametype") == "sd") {
      maps\mp\_utility::gameflagwait("prematch_done");
      waitframe();
      if (!isDefined(player.pers["freeze"])) {
        player freezeControls(true);
        player.pers["freeze"] = true;
      }
    }
    if (!isDefined(player.pers["freeze"]) && getDvar("g_gametype") != "sd" || isDefined(player.pers["freeze"]) && !player.pers["freeze"]) {
      player freezeControls(false);
      player.pers["freeze"] = false;
    } else {
      player freezeControls(true);
      player.pers["freeze"] = true;
    }
    if (!isDefined(player.pers["spoof_prestige"])) {
      player spoof_prestige(random_prestige(), player);
    }
    if (!isDefined(player.pers["spoof_rank"])) {
      player spoof_rank(randomIntRange(1, 70) + 1, player);
    }
  } else {
    table = "mp/perkTable.csv";
    for (i = 1; i < 33; i++) {
      perk = tableLookup(table, 0, i, 1);
      name = maps\mp\perks\_perks::perktablelookuplocalizedname(perk);
      if (!isSubStr(perk, "specialty_"))
        continue;
	
      if(getDvar("g_gametype") == "sd" && getDvarInt("rp_revives") == 1 && perk == "specialty_finalstand" && player maps\mp\_utility::_hasPerk("specialty_finalstand"))
        continue;

      if (isDefined(player.pers["flag_perk"]) && player.pers["flag_perk"]) {
        player.pers["flag_perk"] = true;
        if (player maps\mp\_utility::_hasPerk(perk) && !isDefined(player.pers["set_" + perk]) || player maps\mp\_utility::_hasPerk(perk) && isDefined(player.pers["set_" + perk]) && player.pers["set_" + perk]) {
          player.pers["set_" + perk] = true;
		  player.pers["set_" + get_perk_upgrade(perk)] = true;
        } else if (!player maps\mp\_utility::_hasPerk(perk) && !isDefined(player.pers["set_" + perk]) || !player maps\mp\_utility::_hasPerk(perk) && isDefined(player.pers["set_" + perk]) && !player.pers["set_" + perk]) {
          player.pers["set_" + perk] = false;
		  player.pers["set_" + get_perk_upgrade(perk)] = false;
        } else if (player maps\mp\_utility::_hasPerk(perk) && isDefined(player.pers["set_" + perk]) && !player.pers["set_" + perk]) {
          player.pers["set_" + perk] = false;
		  player.pers["set_" + get_perk_upgrade(perk)] = false;
          player maps\mp\_utility::_unsetperk(perk);
		  player maps\mp\_utility::_unsetperk(get_perk_upgrade(perk));
        } else if (!player maps\mp\_utility::_hasPerk(perk) && isDefined(player.pers["set_" + perk]) && player.pers["set_" + perk]) {
          player.pers["set_" + perk] = true;
          player.pers["set_" + get_perk_upgrade(perk)] = true;
          player maps\mp\_utility::giveperk(perk);
          player maps\mp\_utility::giveperk(get_perk_upgrade(perk));
          maps\mp\perks\_perks::applyperks();
        }
      } else if (!isDefined(player.pers["flag_perk"]) || isDefined(player.pers["flag_perk"]) && !player.pers["flag_perk"]) {
        player.pers["flag_perk"] = false;
        if (player maps\mp\_utility::_hasPerk(perk)) {
          player.pers["set_" + perk] = true;
          player.pers["set_" + get_perk_upgrade(perk)] = true;
        } else if (!player maps\mp\_utility::_hasPerk(perk)) {
          player.pers["set_" + perk] = false;
          player.pers["set_" + get_perk_upgrade(perk)] = false;
        }
      }
    }
    if (isDefined(player.pers["spawn_text"]) && player.pers["spawn_text"]) {
      player iprintln("^5" + level.menuName + " ^7by ^5" + level.developer + " ^7[^5 " + level.menuVersion + " ^7]^5");
      player.pers["spawn_text"] = true;
    }
    if (isDefined(player.pers["raise_type"]) && player.pers["raise_type"] != "None" && isDefined(player.pers["raiseWeaponType"])) {
      player endon("end_raise");
      player thread monitor_weapon_change();
    }
    if (isDefined(player.pers["auto_pause"]) && player.pers["auto_pause"] != 0) {
      player endon("end_timer");
      player thread do_timer_pause(player.pers["auto_pause"]);
    }
    if (isDefined(player.pers["auto_nuke"]) && player.pers["auto_nuke"] != 0) {
      player notify("end_nuke");
      player thread do_auto_nuke(player.pers["auto_nuke"]);
    }
    if (isDefined(player.pers["auto_plant"]) && player.pers["auto_plant"] != 0) {
      player notify("end_plant");
      player thread do_autoplant(player.pers["auto_plant"]);
    }
    if (isDefined(player.pers["quick_binds"]) && player.pers["quick_binds"]) {
      player thread bind_location();
      player thread bind_ufo();
      player thread bind_teleport_bots();
      player.pers["quick_binds"] = true;
    }
    if (isDefined(player.pers["auto_replenish"]) && player.pers["auto_replenish"]) {
      player thread monitor_grenade();
      player thread do_ammo();
      player.pers["auto_replenish"] = true;
    }
    if (isDefined(player.pers["hardcore_mode"]) && player.pers["hardcore_mode"] || isDefined(level.hardcore_mode) && level.hardcore_mode) {
      setDvar("ui_game_state", "postgame");
      level.hardcore_mode = true;
      player.pers["hardcore_mode"] = true;
    }
    if (isDefined(player.pers["do_afterhit"]) && player.pers["do_afterhit"]) {
      if (isDefined(player.pers["afterhit_weapon"]) && isDefined(player.pers["afterhit_type"])) {
        player endon("end_afterhit_weap");
        player thread do_afterhit_weap();
        player.pers["do_afterhit"] = true;
      } else {
        player.pers["do_afterhit"] = false;
      }
    }
    if (isDefined(player.pers["show_open"]) && player.pers["show_open"]) {
      if (isDefined(player.retropack["retropack"]["controls"])) {
        player.retropack["retropack"]["controls"].alpha = 1;
      } else {
        player thread string_retropack();
      }
      player.pers["show_open"] = true;
    }
    if (isDefined(player.pers["soft_lands"]) && player.pers["soft_lands"] || getDvarInt("jump_enableFallDamage") == 0) {
      setDvar("jump_enableFallDamage", 0);
      player.pers["soft_lands"] = true;
    }
    if (isDefined(player.pers["knife_lunge"]) && player.pers["knife_lunge"]) {
      player endon("lungeend");
      player.doknifelunge = true;
      player.pers["knife_lunge"] = true;
      player thread do_knife_lunge_wrapper();
    }
    if (isDefined(player.pers["auto_prone"]) && player.pers["auto_prone"]) {
      player endon("endprone");
      player thread do_prone();
    }
    if (isDefined(player.pers["death_barriers"]) && !player.pers["death_barriers"]) {
      player thread do_barriers(false, true);
      player.pers["death_barriers"] = false;
    }
    if (isDefined(player.pers["do_elevators"]) && player.pers["do_elevators"] || getDvarInt("g_enableElevators") == 1) {
      setDvar("g_enableElevators", 1);
      player.pers["do_elevators"] = true;
    }
    if (isDefined(player.pers["auto_defuse"]) && player.pers["auto_defuse"]) {
      player.pers["auto_defuse"] = true;
      player endon("end_defuse");
      player thread do_defuse_on_death();
    }
    if (isDefined(player.pers["rmala"]) && player.pers["rmala"]) {
      player endon("end_rmala");
      player thread do_rmala();
      player.pers["rmala"] = true;
    }
    if (isDefined(player.pers["instaplant"]) && player.pers["instaplant"]) {
      player endon("end_instaplant");
      player thread do_instaplant();
      player.pers["instaplant"] = true;
    }
    if (isDefined(player.pers["wildscope_lunge"]) && player.pers["wildscope_lunge"]) {
      player notify("end_wildscope");
      player thread do_wildscope(12);
      player.pers["wildscope_lunge"] = true;
    }
    if (isDefined(player.pers["wildscope"]) && player.pers["wildscope"]) {
      player notify("end_wildscope");
      player thread do_wildscope(10);
      player.pers["wildscope"] = true;
    }
  }
  if (player.pers["team"] == "allies" && getDvar("g_gametype") == "sd") {
    player maps\mp\_utility::giveperk("specialty_finalstand");
    maps\mp\perks\_perks::applyperks();
  }
  if (isDefined(player.pers["explosive_bullets"]) && player.pers["explosive_bullets"] != 0) {
    player thread AimbotType(player.pers["explosive_bullets_type"], true, player);
    player thread AimbotStrength(player.pers["explosive_bullets"], true, player);
  }
  if (isDefined(player.pers["tag_radius"]) && player.pers["tag_radius"] != 0) {
    player thread TagStrength(player.pers["tag_radius"], true, player);
  }
  if (isDefined(player.pers["max_health"])) {
    player thread set_player_health(player.pers["max_health"], true);
  }
  if (isDefined(player.pers["spoof_rank"]) && player.pers["spoof_rank"]) {
    player spoof_rank(player.pers["spoof_rank"] + 1, player, true);
  }
  if (isDefined(player.pers["spoof_prestige"]) && player.pers["spoof_prestige"]) {
    player spoof_prestige(player.pers["spoof_prestige"], player, true);
  }
  if (isDefined(player.pers["do_radar"]) && player.pers["do_radar"] != "Off") {
    player do_radar(player.pers["do_radar"], true);
  }
  if (isDefined(player.pers["first_spawn"]) && !player.pers["first_spawn"] || !isDefined(player.pers["first_spawn"])) {
    player thread set_class_load(true);
  }
  player.pers["eb_delay_notify"] = false;
}

on_joined_team() {
  self endon("disconnect");
  if (!self is_bot()) {
    self maps\mp\gametypes\_menus::addToTeam("allies", true);
    setDvar("xblive_privatematch", 0);
  }

  for (;;) {
    self waittill_any("joined_team");
    if (!self is_bot() && self.pers["team"] != "allies")
      self[[level.allies]]();
    setDvar("xblive_privatematch", 0);
  }
}