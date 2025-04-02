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

#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\_retropack_menu;

vector_scale(vec, scale) {
  vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
  return vec;
}

do_server_message(string, bold, warning) {
  foreach(player in level.players) {
    if (isDefined(warning)) {
      if (isDefined(player.pers["clip_warning"]) && player.pers["clip_warning"]) {
        if (isDefined(bold))
          player iprintlnbold(string);
        else
          player iprintln(string);
      }
    } else {
      if (isDefined(bold))
        player iprintlnbold(string);
      else
        player iprintln(string);
    }
  }
}

clear_obituary() {
  self iPrintln("");
  self iPrintln("");
  self iPrintln("");
  self iPrintln("");
  self iPrintln("");
  self iPrintln("");
  self iPrintln("");
}

exit_level() {
  setDvar("xblive_privatematch", 1);
  waitframe();
  exitlevel(0);
}

take_weapon_with_ammo(weap) {
  self.saved_weapon = weap;
  self.weapon_stock = self getWeaponAmmoStock(self.saved_weapon);
  self.weapon_clip = self getWeaponAmmoClip(self.saved_weapon);
  self takeWeapon(self.saved_weapon);
}

give_weapon_with_ammo() {
  self giveWeapon(self.saved_weapon);
  self setWeaponAmmoStock(self.saved_weapon, self.weapon_stock == 0 ? 999 : self.weapon_stock);
  self setWeaponAmmoClip(self.saved_weapon, self.weapon_clip == 0 ? 999 : self.weapon_clip);
}

/* 
	Is()
*/

is_bot() {
  return isSubStr(self getguid(), "bot");
}

is_sniper(weapon) {
  return (
    isSubstr(weapon, "h2_cheytac") ||
    isSubstr(weapon, "h2_barrett") ||
    isSubstr(weapon, "h2_wa2000") ||
    isSubstr(weapon, "h2_m21") ||
    isSubstr(weapon, "h2_m40a3"));
}

is_offhand(equip) {
  return (
    isSubstr(equip, "h1_smokegrenade_mp") ||
    isSubstr(equip, "h1_concussiongrenade_mp") ||
    isSubstr(equip, "h1_flashgrenade_mp"));
}

is_equipment(equip) {
  return (
    isSubstr(equip, "h1_fraggrenade_mp") ||
    isSubstr(equip, "h2_semtex_mp") ||
    isSubstr(equip, "iw9_throwknife_mp") ||
    isSubstr(equip, "specialty_tacticalinsertion") ||
    isSubstr(equip, "specialty_blastshield") ||
    isSubstr(equip, "h1_claymore_mp") ||
    isSubstr(equip, "h1_c4_mp"));
}

is_launcher(weapon) {
  return (
    isSubStr(weapon, "h2_rpg_") ||
    isSubStr(weapon, "h2_m79_") ||
    isSubStr(weapon, "at4_") ||
    isSubStr(weapon, "stinger_") ||
    isSubStr(weapon, "javelin_"));
}

is_knife(weapon) {
  return (
    isSubStr(weapon, "h2_hatchet_mp") ||
    isSubStr(weapon, "h2_sickle_mp") ||
    isSubStr(weapon, "h2_shovel_mp") ||
    isSubStr(weapon, "h2_icepick_mp") ||
    isSubStr(weapon, "h2_karambit_mp"));
}

is_attacker_alive() {
  foreach(player in level.players) {
    if (player.team == game["attackers"] && isAlive(player))
      return true;
  }
  return false;
}

is_on_last(value) {
  if (getDvar("g_gametype") == "dm") {
    if (self.pers["score"] == (getWatchedDvar("scorelimit") - value))
      return true;
  }
  if (getDvar("g_gametype") == "war") {
    if (game["teamScores"][self.team] == (getWatchedDvar("scorelimit") - value))
      return true;
  }
  if (getDvar("g_gametype") == "sd") {
	foreach ( player in level.players )
    {
        if ( player == self )
            continue;

        if ( player maps\mp\gametypes\_playerlogic::mayspawn() )
            return false;

        if ( maps\mp\_utility::isreallyalive( player ) )
            return false;
		
		if (level.teamBased && player.pers["team"] == self.pers["team"])
			return false;
    }
	return true;
  }

  return false;
}

is_positive(value) {
  if (int(value) > 0)
    return true;

  return false;
}

is_negative(value) {
  if (int(value) <= 0)
    return true;

  return false;
}

/* 
	Return()
*/

return_toggle(variable) {
  return isdefined(variable) && variable;
}

/* 
	Get()
*/

get_players() {
  player = 0;
  foreach(player in level.players) {
    if (!player is_bot()) {
      player++;
    }
  }
  return player;
}

get_clients() {
  client = 0;
  foreach(player in level.players) {
    client++;
  }
  return client;
}

get_allies() {
  ally = 0;
  foreach(player in level.players) {
    if (player.pers["team"] == "allies") {
	  ally++;
	}
  }
  return ally;
}

get_axis() {
  axis = 0;
  foreach(player in level.players) {
    if (player.pers["team"] == "axis") {
	  axis++;
	}
  }
  return axis;
}

get_bots() {
  bots = 0;
  foreach(player in level.players) {
    if (player is_bot()) {
      bots++;
    }
  }
  return bots;
}

get_camo_shader(camo) {
  return tablelookupistring("mp/camotable.csv", 1, camo, 4);
}

get_camo_id(camo) {
  return tablelookupistring("mp/camotable.csv", 4, camo, 1);
}

get_time_limit_float() {
  return getDvarFloat("scr_" + getDvar("g_gametype") + "_timeLimit");
}

get_menu() {
  return self.retropack["menu"];
}

get_cursor() {
  return self.cursor[self get_menu()];
}

get_title() {
  return self.retropack["title"];
}

get_next_weapon() {
  weapons_list = self getWeaponsListPrimaries();
  current_weapon = self getCurrentWeapon();
  for (i = 0; i < weapons_list.size; i++) {
    if (current_weapon == weapons_list[i]) {
      if (isDefined(weapons_list[i + 1]))
        return weapons_list[i + 1];
      else
        return weapons_list[0];
    }
  }
}

get_perk_upgrade( perk )
{
    perk = tablelookup( "mp/perktable.csv", 1, perk, 8 );

    if ( perk == "" || perk == "specialty_null" )
        return "specialty_null";

    return perk;
}

get_viewhands_console(model) {
  if (model == "Infected")
    return "viewhands_infect";
  else if (model == "Ghillie")
    return "viewhands_h2_ghillie";
  else if (model == "Militia")
    return "globalViewhands_mw2_militia";
  else if (model == "SEALs")
    return "viewhands_udt";
  else if (model == "Rangers")
    return "viewhands_rangers";
  else if (model == "Spetsnaz")
    return "globalViewhands_mw2_airborne";
  else if (model == "OpFor")
    return "viewhands_h1_arab_desert_mp_camo";
  else if (model == "TF141")
    return "viewhands_tf141";
}

get_attachment(attachment) {
  sep = strTok(attachment, ";");
  if (isEndStr(sep[0], "mp") || is_launcher(sep[0]) || is_knife(sep[0]))
    return "specialty_null";
  if (isEndStr(sep[0], "gl_glpre") || isEndStr(sep[0], "gl"))
    return "weapon_attachment_shotgun";
  if (isEndStr(sep[0], "reflex"))
    return "h2_reflex";
  if (isEndStr(sep[0], "silencerar") ||
    isEndStr(sep[0], "silencerlmg") ||
    isEndStr(sep[0], "silencersniper") ||
    isEndStr(sep[0], "silencerpistol") ||
    isEndStr(sep[0], "silencershotgun") ||
    isEndStr(sep[0], "silencersmg"))
    return "weapon_attachment_suppressor";
  if (isEndStr(sep[0], "acog") || isEndStr(sep[0], "acogh2"))
    return "weapon_attachment_acog";
  if (isEndStr(sep[0], "fmj"))
    return "weapon_attachment_fmj";
  if (isEndStr(sep[0], "sho_shopre") || isEndStr(sep[0], "sho") )
    return "weapon_attachment_shotty";
  if (isEndStr(sep[0], "holo"))
    return "weapon_attachment_holographic";
  if (isEndStr(sep[0], "thermal"))
    return "weapon_attachment_thermal2";
  if (isEndStr(sep[0], "xmag"))
    return "weapon_attachment_xmag";
  if (isEndStr(sep[0], "fastfire"))
    return "weapon_attachment_fastfire";
  if (isEndStr(sep[0], "akimbo"))
    return "weapon_attachment_akimbo";
  if (isEndStr(sep[0], "tacknifeusp") ||
    isEndStr(sep[0], "tacknifecolt44") ||
    isEndStr(sep[0], "tacknifem9") ||
    isEndStr(sep[0], "tacknifedeagle") ||
    isEndStr(sep[0], "tacknifecolt45"))
    return "weapon_attachment_tacknife";
  if (isEndStr(sep[0], "foregrip"))
    return "weapon_attachment_grip";
}

get_localised_camo(camo) {
  if (camo == "none" || !isDefined(camo) || camo == "") // using localised perks as a variable is buggy, have to hard-code.
    return "None";
  else if (camo == "_camo016")
    return "Desert";
  else if (camo == "_camo017")
    return "Arctic";
  else if (camo == "_camo018")
    return "Woodland";
  else if (camo == "_camo019")
    return "Digital";
  else if (camo == "_camo020")
    return "Urban";
  else if (camo == "_camo021")
    return "Blue Tiger";
  else if (camo == "_camo022")
    return "Red Tiger";
  else if (camo == "_camo023")
    return "Fall";
  else if (camo == "_gold")
    return "Gold";
  else if (camo == "_golddiamond")
    return "Diamond";
  else if (camo == "_camo024")
    return "Yellow";
  else if (camo == "_camo025")
    return "White";
  else if (camo == "_camo026")
    return "Red";
  else if (camo == "_camo027")
    return "Purple";
  else if (camo == "_camo028")
    return "Pink";
  else if (camo == "_camo029")
    return "Pastel Brown";
  else if (camo == "_camo030")
    return "Orange";
  else if (camo == "_camo031")
    return "Light Pink";
  else if (camo == "_camo032")
    return "Green";
  else if (camo == "_camo033")
    return "Dark Red";
  else if (camo == "_camo034")
    return "Dark Green";
  else if (camo == "_camo035")
    return "Cyan";
  else if (camo == "_camo036")
    return "Brown";
  else if (camo == "_camo037")
    return "Blue";
  else if (camo == "_camo038")
    return "Black";
  else if (camo == "_camo041")
    return "Polyatomic";
  else if (camo == "_camo043")
    return "Polyatomic Blue";
  else if (camo == "_camo047")
    return "Polyatomic Cyan";
  else if (camo == "_camo042")
    return "Polyatomic Dark Red";
  else if (camo == "_camo045")
    return "Polyatomic Green";
  else if (camo == "_camo040")
    return "Polyatomic Orange";
  else if (camo == "_camo044")
    return "Polyatomic Pink";
  else if (camo == "_camo046")
    return "Polyatomic Red";
  else if (camo == "_camo039")
    return "Polyatomic Yellow";
  else if (camo == "_camo052")
    return "Ice";
  else if (camo == "_camo049")
    return "Lava";
  else if (camo == "_camo053")
    return "Storm";
  else if (camo == "_camo050")
    return "Water";
  else if (camo == "_camo051")
    return "Fire";
  else if (camo == "_camo048")
    return "Gas";
  else if (camo == "_camo057")
    return "Doomsday";
  else if (camo == "_camo054")
    return "Nuclear Blue";
  else if (camo == "_camo056")
    return "Nuclear Red";
  else if (camo == "_camo058")
    return "SoaR";
  else if (camo == "_toxicwaste")
    return "Toxic Waste";
}

get_localised_attachment(attachment) {
  if (attachment == "none" || !isDefined(attachment) || attachment == "") // using localised perks as a variable is buggy, have to hard-code.
    return "None";
  else if (attachment == "gl" || attachment == "glpre" || attachment == "glak47")
    return "Grenade Launcher";
  else if (attachment == "sho" || attachment == "shopre")
    return "Shotgun";
  else if (attachment == "fastfire")
    return "Rapid Fire";
  else if (attachment == "foregrip")
    return "Grip";
  else if (attachment == "reflex" || attachment == "f2000scope" || attachment == "mars")
    return "Red Dot Sight";
  else if (attachment == "silencershotgun" || attachment == "silencersmg" || attachment == "silencerlmg" || attachment == "silencerar" || attachment == "silencersniper" || attachment == "silencerpistol")
    return "Silencer";
  else if (attachment == "acogh2" || attachment == "acog" || attachment == "augscope")
    return "ACOG";
  else if (attachment == "fmj")
    return "FMJ";
  else if (attachment == "akimbo")
    return "Akimbo";
  else if (attachment == "tacknifecolt44" || attachment == "tacknifedeagle" || attachment == "tacknifecolt45" || attachment == "tacknifem9" || attachment == "tacknifeusp")
    return "Tactical Knife";
  else if (attachment == "holo")
    return "Holo Sight";
  else if (attachment == "thermal")
    return "Thermal";
  else if (attachment == "xmag")
    return "X-Mags";
}

get_localised_perk(perk) {
  for (i = 1; i < tablegetrowcount("mp/perktable.csv"); i++) {
    table = tableLookup("mp/perktable.csv", 0, i, 1);
    if (perk != table)
		continue;
	
    return tableLookup("mp/perktable.csv", 0, i, 2);
  }
}

get_localised_perk_hardcoded(perk) {
  if (perk == "specialty_longersprint")
    return &"PERKS_MARATHON";
  else if (perk == "specialty_fastmantle")
    return &"PERKS_MARATHON_PRO";
  else if (perk == "specialty_quickdraw")
    return &"PERKS_SLEIGHT_OF_HAND";
  else if (perk == "specialty_extraammo")
    return &"PERKS_SCAVENGER_PRO";
  else if (perk == "specialty_secondarybling")
    return &"PERKS_BLING_PRO";
  else if (perk == "specialty_omaquickchange")
    return &"PERKS_ONE_MAN_ARMY_PRO";
  else if (perk == "specialty_armorpiercing")
    return &"PERKS_STOPPING_POWER_PRO";
  else if (perk == "specialty_fastsprintrecovery")
    return &"PERKS_LIGHTWEIGHT_PRO";
  else if (perk == "specialty_rollover")
    return &"PERKS_HARDLINE_PRO";
  else if (perk == "specialty_spygame")
    return &"PERKS_COLD_BLOODED_PRO";
  else if (perk == "specialty_dangerclose")
    return &"PERKS_DANGER_CLOSE_PRO";
  else if (perk == "specialty_falldamage")
    return &"PERKS_COMMANDO_PRO";
  else if (perk == "specialty_holdbreath")
    return &"PERKS_STEADY_AIM_PRO";
  else if (perk == "specialty_delaymine")
    return &"PERKS_SCRAMBLER_PRO";
  else if (perk == "specialty_quieter")
    return &"PERKS_NINJA_PRO";
  else if (perk == "specialty_selectivehearing")
    return &"PERKS_SITREP_PRO";
  else if (perk == "specialty_longersprint")
    return &"PERKS_MARATHON";
  else if (perk == "specialty_fastreload")
    return &"PERKS_SLEIGHT_OF_HAND";
  else if (perk == "specialty_scavenger")
    return &"PERKS_SCAVENGER";
  else if (perk == "specialty_bling")
    return &"PERKS_BLING";
  else if (perk == "specialty_onemanarmy")
    return &"PERKS_ONE_MAN_ARMY";
  else if (perk == "specialty_bulletdamage")
    return &"PERKS_STOPPING_POWER";
  else if (perk == "specialty_lightweight")
    return &"PERKS_LIGHTWEIGHT";
  else if (perk == "specialty_hardline")
    return &"PERKS_HARDLINE";
  else if (perk == "specialty_radarimmune")
    return &"PERKS_COLD_BLOODED";
  else if (perk == "specialty_explosivedamage")
    return &"PERKS_DANGER_CLOSE";
  else if (perk == "specialty_extendedmelee")
    return &"PERKS_COMMANDO";
  else if (perk == "specialty_bulletaccuracy")
    return &"PERKS_STEADY_AIM";
  else if (perk == "specialty_localjammer")
    return &"PERKS_SCRAMBLER";
  else if (perk == "specialty_heartbreaker")
    return &"PERKS_NINJA";
  else if (perk == "specialty_detectexplosive")
    return &"PERKS_SITREP";
  else if (perk == "specialty_pistoldeath")
    return &"PERKS_LAST_STAND";
  else if (perk == "specialty_laststandoffhand")
    return &"PERKS_LAST_STAND_PRO";
}

get_string_perk(perk) {
  if (perk == "specialty_longersprint") // maps\mp\perks\_perks::perktablelookuplocalizedname(perk); also works but dont use
    return "Marathon";
  else if (perk == "specialty_fastmantle")
    return "Marathon Pro";
  else if (perk == "specialty_quickdraw")
    return "Sleight of Hand Pro";
  else if (perk == "specialty_extraammo")
    return "Scavenger Pro";
  else if (perk == "specialty_secondarybling")
    return "Bling Pro";
  else if (perk == "specialty_omaquickchange")
    return "One Man Army Pro";
  else if (perk == "specialty_armorpiercing")
    return "Stopping Power Pro";
  else if (perk == "specialty_fastsprintrecovery")
    return "Lightweight Pro";
  else if (perk == "specialty_rollover")
    return "Hardline Pro";
  else if (perk == "specialty_spygame")
    return "Cold Blooded Pro";
  else if (perk == "specialty_dangerclose")
    return "Danger Close Pro";
  else if (perk == "specialty_falldamage")
    return "Commando Pro";
  else if (perk == "specialty_holdbreath")
    return "Steady Aim Pro";
  else if (perk == "specialty_delaymine")
    return "Scrambler Pro";
  else if (perk == "specialty_quieter")
    return "Ninja Pro";
  else if (perk == "specialty_selectivehearing")
    return "Sitrep Pro";
  else if (perk == "specialty_longersprint")
    return "Marathon";
  else if (perk == "specialty_fastreload")
    return "Sleight of Hand";
  else if (perk == "specialty_scavenger")
    return "Scavenger";
  else if (perk == "specialty_bling")
    return "Bling";
  else if (perk == "specialty_onemanarmy")
    return "One Man Army";
  else if (perk == "specialty_bulletdamage")
    return "Stopping Power";
  else if (perk == "specialty_lightweight")
    return "Lightweight";
  else if (perk == "specialty_hardline")
    return "Hardline";
  else if (perk == "specialty_radarimmune")
    return "Cold Blooded";
  else if (perk == "specialty_explosivedamage")
    return "Danger Close";
  else if (perk == "specialty_extendedmelee")
    return "Commando";
  else if (perk == "specialty_bulletaccuracy")
    return "Steady Aim";
  else if (perk == "specialty_localjammer")
    return "Scrambler";
  else if (perk == "specialty_heartbreaker")
    return "Ninja";
  else if (perk == "specialty_detectexplosive")
    return "Sitrep";
  else if (perk == "specialty_pistoldeath")
    return "Last Stand";
  else if (perk == "specialty_laststandoffhand")
    return "Final Stand";
}

get_localised_animation(animation) {
  if (animation == 1)
    return "Neutral";
  else if (animation == 2)
    return "Usage";
  else if (animation == 7)
    return "Cock Back";
  else if (animation == 10)
    return "Knife";
  else if (animation == 12)
    return "Knife Lunge";
  else if (animation == 17)
    return "Put Away (Heavy)";
  else if (animation == 18)
    return "Raise (Heavy)";
  else if (animation == 19)
    return "Can Swap";
  else if (animation == 20)
    return "Reload";
  else if (animation == 21)
    return "Empty Mag";
  else if (animation == 27)
    return "Put Away (Light)";
  else if (animation == 28)
    return "Raise (Light)";
  else if (animation == 29)
    return "Put Away (Heavy, Fast)";
  else if (animation == 30)
    return "Raise (Heavy, Fast)";
  else if (animation == 31)
    return "Glide 1";
  else if (animation == 32)
    return "Glide 2";
  else if (animation == 33)
    return "Sprint 1";
  else if (animation == 34)
    return "Sprint 2";
  else if (animation == 50)
    return "Mantle (High)";
  else if (animation == 58)
    return "Inspect";
}

get_crosshair() {
  return bulletTrace(self getTagOrigin("j_head"), vector_scale(anglestoforward(self getPlayerAngles()), 1000000), false, self)["position"];
}

get_kit(weapon) {
  kit = [];
  table = "mp/attachkits.csv";
  for (i = 1; i < tablegetrowcount(table); i++) {
    attachment = tableLookup(table, 0, i, 1);

    if (!maps\mp\gametypes\_class::isvalidattachkit(attachment, weapon, 1))
      continue;

    kit[kit.size] = attachment;
  }
  return kit;
}

/* 
	Set()
*/

set_timescale(timescale, spawn) {
  if (isDefined(spawn))
    wait 0.5;
  setDvar("timescale", timescale);
  self.pers["time_scale"] = timescale;
  if (!isDefined(spawn)) {
    if (timescale == 1)
      self iPrintln("Timescale: ^5" + timescale + " (Default)");
    else
      self iPrintln("Timescale: ^5" + timescale);
  }
}

set_gravity(gravity) {
  setDvar("g_gravity", gravity);
  self.pers["gravity"] = gravity;
  if (gravity == 800)
    self iPrintln("Gravity: ^5" + gravity + " (Default)");
  else
    self iPrintln("Gravity: ^5" + gravity);
}

set_ladder_knockback(knockback) {
  setDvar("jump_ladderPushVel", knockback);
  if (knockback == 128)
    self iPrintln("Ladder Knockback: ^5" + knockback + " (Default)");
  else
    self iPrintln("Ladder Knockback: ^5" + knockback);
}

set_pickup_radius(radius) {
  setDvar("player_useRadius", radius);
  if (radius == 128)
    self iPrintln("Pick Up Radius: ^5" + radius + " (Default)");
  else
    self iPrintln("Pick Up Radius: ^5" + radius);
}

set_melee_damage(damage) {
  setDvar("rp_melee_damage", damage);
  if (damage == 100)
    self iPrintln("Melee Damage: ^5" + damage + " (Default)");
  else
    self iPrintln("Melee Damage: ^5" + damage);
}

set_sniper_damage(damage) {
  setDvar("rp_sniper_damage", damage);
  self iPrintln("Sniper Damage: ^5" + damage);
}

set_bot_damage(damage) {
  setDvar("rp_bot_damage", damage);
  if (damage == 1)
    self iPrintln("Bot Weapon Damage Multiplier: ^5x" + damage + " (Default)");
  else
    self iPrintln("Bot Weapon Damage Multiplier: ^5x" + damage);
}

set_player_health(hp, spawn) {
  foreach(player in level.players) {
    player.maxhealth = hp;
    player.health = hp;
  }
  player.pers["max_health"] = hp;
  if (!isDefined(spawn)) {
    if (hp == 100)
      self iPrintln("Lobby Health: ^5" + hp + " HP (Default)");
    else
      self iPrintln("Lobby Health: ^5" + hp + " HP");
  }
}

set_grenade_pickup_radius(radius) {
  setDvar("player_throwbackOuterRadius", radius);
  setDvar("player_throwbackInnerRadius", radius);
  if (radius == 90)
    self iPrintln("Frag Grenade Pick Up Radius: ^5" + radius + " (Default)");
  else
    self iPrintln("Frag Grenade Pick Up Radius: ^5" + radius);
}

set_killcam_timer_font(font) {
  self iPrintln("Killcam Timer Font: ^5" + font);
  if (font == "Retro-Pack")	 
	  font = "objective";
  else if (font == "Classic")	
	  font = "hudbig";

  self.pers["rp_timer_font"] = font;
}

set_viewhand_model(model) {
  self setviewmodel(get_viewhands_console(model));
  self.pers["viewhands"] = get_viewhands_console(model);
  self iPrintln("Viewhand Model Set: ^5" + model);
}

set_menu(menu) {
  if (isdefined(menu))
    self.retropack["menu"] = menu;
}

set_cursor(cursor, menu) {
  if (isdefined(cursor))
    self.cursor[isdefined(menu) ? menu : self get_menu()] = cursor;
}

set_state() {
  self.retropack["utility"].in_menu = !return_toggle(self.retropack["utility"].in_menu);
}

set_text(text) {
  if (!isdefined(self) || !isdefined(text))
    return;

  self.text = text;
  self settext(text);
}

set_slider(scrolling, index) {
  menu = self get_menu();
  index = isdefined(index) ? index : self get_cursor();
  storage = (menu + "_" + index);

  if (!isDefined(self.pers["storage_array" + menu + index]) || isDefined(self.structure[index].execute) && !self.structure[index].execute)
    self.pers["storage_array" + menu + index] = 0;

  if (!isDefined(self.pers["storage_increment" + menu + index]) || isDefined(self.structure[index].execute) && !self.structure[index].execute)
    self.pers["storage_increment" + menu + index] = self.structure[index].start;

  if (!isdefined(self.slider[storage]))
    self.slider[storage] = isdefined(self.structure[index].array) ? self.pers["storage_array" + menu + index] : self.pers["storage_increment" + menu + index];

  if (isdefined(self.structure[index].array)) {
    self notify("string_slider");
    if (scrolling == -1)
      self.slider[storage]++;

    if (scrolling == 1)
      self.slider[storage]--;

    if (self.slider[storage] > (self.structure[index].array.size - 1))
      self.slider[storage] = 0;

    if (self.slider[storage] < 0)
      self.slider[storage] = (self.structure[index].array.size - 1);

    self.pers["storage_array" + menu + index] = self.slider[storage];

    if (isdefined(self.structure[index].shaderarray)) {
      sep = strTok(self.structure[index].array[self.slider[storage]], ";");
      if (self get_menu() == "Camo")
        self.retropack["hud"]["slider"][3][index] setShader(sep[1], 12, 12);
      else
        self.retropack["hud"]["slider"][3][index] setShader(excluded_menu() ? get_attachment(sep[0]) : self.structure[index].array[self.pers["storage_array" + menu + index]], 12, 12);
    } else {
	  if (isdefined(self.structure[index].integer)) {
	    self.retropack["hud"]["slider"][5][index] setValue(self.structure[index].array[self.pers["storage_array" + menu + index]]);
	  } else if (self.structure[index].text == "Spawn Bot") {
        current = self.structure[index].array[self.slider[storage]];
        if (current == getOtherTeam(self.team))
          current = "^1Enemy";
        else if (current == self.team)
          current = "^2Friendly";
        else if (current == "All")
          current = "^5All";
        self.retropack["hud"]["slider"][0][index] set_text(current);
      } else {
        if ( isDefined(self.structure[index].bind) && self.structure[index].bind ) {
          if ( self.structure[index].array[self.pers["storage_array" + menu + index]] != "Off" ) {
		    self.retropack["hud"]["slider"][0][index] set_text("^5" + self.structure[index].array[self.pers["storage_array" + menu + index]]);
		  } else {
			self.retropack["hud"]["slider"][0][index] set_text("");
		  }
		} else {
		  self.retropack["hud"]["slider"][0][index] set_text("^5" + self.structure[index].array[self.pers["storage_array" + menu + index]]);
		}
      }
    } 
  } else {
    self notify("increment_slider"); 
    if (scrolling == -1)
      self.slider[storage] += self.structure[index].increment;

    if (scrolling == 1)
      self.slider[storage] -= self.structure[index].increment;

    if (self.slider[storage] > self.structure[index].maximum)
      self.slider[storage] = self.structure[index].minimum;

    if (self.slider[storage] < self.structure[index].minimum)
      self.slider[storage] = self.structure[index].maximum;

    self.pers["storage_increment" + menu + index] = self.slider[storage];

    position = abs((self.structure[index].maximum - self.structure[index].minimum)) / ((50 - 8));
    self.retropack["hud"]["slider"][0][index] setvalue(self.pers["storage_increment" + menu + index]);
    self.retropack["hud"]["slider"][2][index].x = (self.retropack["hud"]["slider"][1][index].x + (abs((self.pers["storage_increment" + menu + index] - self.structure[index].minimum)) / position) - 42);
  }
}

set_shader(shader, width, height) {
  if (!isdefined(shader)) {
    if (!isdefined(self.shader))
      return;

    shader = self.shader;
  }

  if (!isdefined(width)) {
    if (!isdefined(self.width))
      return;

    width = self.width;
  }

  if (!isdefined(height)) {
    if (!isdefined(self.height))
      return;

    height = self.height;
  }

  self.shader = shader;
  self.width = width;
  self.height = height;
  self setshader(shader, width, height);
}

set_bind(arg, bind, func, text, arg2) {
  button = undefined;

  if (arg == "Off") {
    button = "Off";
    self.pers["bind_" + bind + button] = false;
    self.pers["bind_" + bind + button + "_button"] = undefined;
    self.pers["bind_" + bind + button + "_function"] = undefined;
    self.pers["bind_" + bind + button + "_bind"] = undefined;
    self.pers["bind_" + bind + button + "_arg"] = undefined;
  } else if (arg == "[{+actionslot 1}]")
    button = "+actionslot 1";
  else if (arg == "[{+actionslot 2}]")
    button = "+actionslot 2";
  else if (arg == "[{+actionslot 3}]")
    button = "+actionslot 3";
  else if (arg == "[{+actionslot 4}]")
    button = "+actionslot 4";
  else if (arg == "[{+smoke}]")
    button = "+smoke";
  else if (arg == "[{+frag}]")
    button = "+frag";
  else if (arg == "[{+melee_zoom}]")
    button = "+melee_zoom";
  else if (arg == "[{+usereload}]")
    button = "+usereload";
  else if (arg == "[{+breath_sprint}]")
    button = "+breath_sprint";
  else if (arg == "[{+speed_throw}]")
    button = "+speed_throw";
  else if (arg == "[{+stance}]")
    button = "+stance";
  else if (arg == "[{+attack}]")
    button = "+attack";

  foreach( binded in level.bind_index ) {
	if (self.pers["bind_" + binded + button]) {
	  if (arg == self.pers["bind_" + binded + button + "_buttonstring"]) {
	    self.pers["bind_" + binded + button] = false;
	    self notify("stop" + binded + button);
	  }
	}
  }

  if(text != "Off")
    self.pers["bind_" + button + "_text"] = text;
  else
    self.pers["bind_" + button + "_text"] = undefined;
  self.pers["bind_" + bind + button + "_button"] = button;
  self.pers["bind_" + bind + button + "_buttonstring"] = arg;
  self.pers["bind_" + bind + button + "_function"] = func;
  self.pers["bind_" + bind + button + "_bind"] = bind;
  self.pers["bind_" + bind + button + "_arg"] = arg2;
  self.pers["bind_" + bind + button] = true;

  self thread[[func]](button, bind, arg2);
  
  self iPrintLn(arg + ": ^5" + text);
}

/* 
	Random()
*/

random_kit(weapon) {
  kit = get_kit(weapon);
  while (true) {
    kit = random(kit);
    return kit;
  }
}

random_prestige() {
  value = "";
  switch (randomIntRange(0, 12)) {
  case 0:
    value = "h2m_rank_prestige1";
    break;

  case 1:
    value = "h2m_rank_prestige2";
    break;

  case 2:
    value = "h2m_rank_prestige3";
    break;

  case 3:
    value = "h2m_rank_prestige4";
    break;

  case 4:
    value = "h2m_rank_prestige5";
    break;

  case 5:
    value = "h2m_rank_prestige6";
    break;

  case 6:
    value = "h2m_rank_prestige7";
    break;

  case 7:
    value = "h2m_rank_prestige8";
    break;

  case 8:
    value = "h2m_rank_prestige9";
    break;

  case 9:
    value = "h2m_rank_prestige10";
    break;

  case 10:
    value = "h2m_cheytac_ui";
    break;

  case 11:
    value = "em_st_180";
    break;
  }
  return value;
}

random_gun() {
  gunRandom = "";
  switch (randomIntRange(0, 3)) {
  case 0:
    gunRandom = random_smg();
    break;

  case 1:
    gunRandom = random_ar();
    break;

  case 2:
    gunRandom = random_sniper();
    break;
  }
  return gunRandom;
}

random_smg() {
  smgRandom = "";
  switch (randomIntRange(0, 6)) {
  case 0:
    smgRandom = "h2_mp5k";
    break;

  case 1:
    smgRandom = "h2_ump45";
    break;

  case 2:
    smgRandom = "h2_kriss";
    break;

  case 3:
    smgRandom = "h2_p90";
    break;

  case 4:
    smgRandom = "h2_uzi";
    break;

  case 5:
    smgRandom = "h2_AK74U";
    break;
  }
  return smgRandom;
}

random_ar() {
  arRandom = "";
  switch (randomIntRange(0, 8)) {
  case 0:
    arRandom = "h2_m4";
    break;

  case 1:
    arRandom = "h2_famas";
    break;

  case 2:
    arRandom = "h2_scar";
    break;

  case 3:
    arRandom = "h2_fal";
    break;

  case 4:
    arRandom = "h2_m16";
    break;

  case 5:
    arRandom = "h2_masada";
    break;

  case 6:
    arRandom = "h2_fn2000";
    break;

  case 7:
    arRandom = "h2_ak47";
    break;
  }
  return arRandom;
}

random_sniper() {
  sniperRandom = "";
  switch (randomIntRange(0, 5)) {
  case 0:
    sniperRandom = "h2_barrett";
    break;

  case 1:
    sniperRandom = "h2_cheytac";
    break;

  case 2:
    sniperRandom = "h2_wa2000";
    break;

  case 3:
    sniperRandom = "h2_m21";
    break;

  case 4:
    sniperRandom = "h2_m40a3";
    break;
  }
  return sniperRandom;
}

random_camo(sep) {
  camoRandom = "";
  switch (randomIntRange(0, 31)) {
  case 0:
    camoRandom = "";
    break;

  case 1:
    camoRandom = "camo016";
    break;

  case 2:
    camoRandom = "camo017";
    break;

  case 3:
    camoRandom = "camo018";
    break;

  case 4:
    camoRandom = "camo019";
    break;

  case 5:
    camoRandom = "camo020";
    break;

  case 6:
    camoRandom = "camo021";
    break;

  case 7:
    camoRandom = "camo022";
    break;

  case 8:
    camoRandom = "camo023";
    break;

  case 9:
    camoRandom = "camo024";
    break;

  case 10:
    camoRandom = "camo025";
    break;

  case 11:
    camoRandom = "camo026";
    break;

  case 12:
    camoRandom = "camo027";
    break;

  case 13:
    camoRandom = "camo028";
    break;

  case 14:
    camoRandom = "camo029";
    break;

  case 15:
    camoRandom = "camo030";
    break;

  case 16:
    camoRandom = "camo031";
    break;

  case 17:
    camoRandom = "camo032";
    break;

  case 18:
    camoRandom = "camo033";
    break;

  case 19:
    camoRandom = "camo034";
    break;

  case 20:
    camoRandom = "camo035";
    break;

  case 21:
    camoRandom = "camo036";
    break;

  case 22:
    camoRandom = "camo037";
    break;

  case 23:
    camoRandom = "camo038";
    break;

  case 24:
    camoRandom = "camo039";
    break;

  case 25:
    camoRandom = "camo040";
    break;

  case 26:
    camoRandom = "camo041";
    break;

  case 27:
    camoRandom = "camo042";
    break;

  case 28:
    camoRandom = "camo043";
    break;

  case 29:
    camoRandom = "camo044";
    break;

  case 30:
    camoRandom = "camo045";
    break;
  }
  if (sep)
    return camoRandom + ";";
  else
    return camoRandom;
}

/* 
	Extract()
*/

extract_attachment(weapon) {
  sep = strTok(weapon, ";");
  if (isEndStr(sep[0], "_mp") || is_launcher(sep[0]) || is_knife(sep[0]))
    return "";
  if (isEndStr(sep[0], "_gl_glpre"))
    return "gl";
  if (isEndStr(sep[0], "_reflex"))
    return "reflex";
  if (isEndStr(sep[0], "_silencerar"))
    return "silencerar";
  if (isEndStr(sep[0], "_acog"))
    return "acog";
  if (isEndStr(sep[0], "_fmj"))
    return "fmj";
  if (isEndStr(sep[0], "_sho_shopre"))
    return "sho";
  if (isEndStr(sep[0], "_holo"))
    return "holo";
  if (isEndStr(sep[0], "_thermal"))
    return "thermal";
  if (isEndStr(sep[0], "_xmag"))
    return "xmag";
  if (isEndStr(sep[0], "_fastfire"))
    return "fastfire";
  if (isEndStr(sep[0], "_silencersmg"))
    return "silencersmg";
  if (isEndStr(sep[0], "_akimbo"))
    return "akimbo";
  if (isEndStr(sep[0], "_silencerlmg"))
    return "silencerlmg";
  if (isEndStr(sep[0], "_silencersniper"))
    return "silencersniper";
  if (isEndStr(sep[0], "_silencerpistol"))
    return "silencerpistol";
  if (isEndStr(sep[0], "_silencershotgun"))
    return "silencershotgun";
  if (isEndStr(sep[0], "_tacknifeusp"))
    return "tacknifeusp";
  if (isEndStr(sep[0], "_tacknifecolt44"))
    return "tacknifecolt44";
  if (isEndStr(sep[0], "_tacknifem9"))
    return "tacknifem9";
  if (isEndStr(sep[0], "_tacknifedeagle"))
    return "tacknifedeagle";
  if (isEndStr(sep[0], "_tacknifecolt45"))
    return "tacknifecolt45";
  if (isEndStr(sep[0], "_foregrip"))
    return "foregrip";
}

detach_camo(weapon) {
  if (isSubStr(weapon, "at4_") ||
    isSubStr(weapon, "stinger_") ||
    isSubStr(weapon, "javelin_") ||
    isSubStr(weapon, "h2_mp5k"))
    return "";

  if (common_scripts\utility::string_find(weapon, "_camo") >= 0) {
    start = common_scripts\utility::string_find(weapon, "h2_");
    end = common_scripts\utility::string_find(weapon, "_camo");
    if (end >= 0 && start >= 0) {
      weapon = getsubstr(weapon, start, end);
      return weapon;
    }
  }
  return weapon;
}

/* 
	Retro Package Structs
*/

really_alive() {
  return isalive(self) && !return_toggle(self.inlaststand);
}

has_menu() {
  return return_toggle(self.retropack["user"].has_menu);
}

in_menu() {
  return return_toggle(self.retropack["utility"].in_menu);
}

in_array(array, item) {
  for (i = 0; i < array.size; i++)
    if (array[i] == item)
      return true;

  return false;
}

array_remove(array, index) {
  if (!isdefined(array) || !isdefined(index))
    return;

  new_array = [];
  for (i = 0; i < array.size; i++)
    if (array[i] != index)
      new_array[new_array.size] = array[i];

  return new_array;
}

execute_function(function, argument_1, argument_2, argument_3, argument_4, argument_5, argument_6, argument_7, argument_8) {
  if (!isdefined(function))
    return;

  if (isdefined(argument_8))
    return self thread[[function]](argument_1, argument_2, argument_3, argument_4, argument_5, argument_6, argument_7, argument_8);

  if (isdefined(argument_7))
    return self thread[[function]](argument_1, argument_2, argument_3, argument_4, argument_5, argument_6, argument_7);

  if (isdefined(argument_6))
    return self thread[[function]](argument_1, argument_2, argument_3, argument_4, argument_5, argument_6);

  if (isdefined(argument_5))
    return self thread[[function]](argument_1, argument_2, argument_3, argument_4, argument_5);

  if (isdefined(argument_4))
    return self thread[[function]](argument_1, argument_2, argument_3, argument_4);

  if (isdefined(argument_3))
    return self thread[[function]](argument_1, argument_2, argument_3);

  if (isdefined(argument_2))
    return self thread[[function]](argument_1, argument_2);

  if (isdefined(argument_1))
    return self thread[[function]](argument_1);

  return self thread[[function]]();
}

should_archive() {
  if (!isalive(self) || self.element_count < 21)
    return false;

  return true;
}

clear_option() {
  for (i = 0; i < self.retropack["utility"].element_list.size; i++) {
    clear_all(self.retropack["hud"][self.retropack["utility"].element_list[i]]);
    self.retropack["hud"][self.retropack["utility"].element_list[i]] = [];
  }
}

check_option(player, menu, cursor) {
  if (isdefined(self.structure) && self.structure.size)
    for (i = 0; i < self.structure.size; i++)
      if (player.structure[cursor].text == self.structure[i].text && self get_menu() == menu)
        return true;

  return false;
}

create_label(text, value, font, font_scale, alignment, relative, x_offset, y_offset, color, alpha, sorting) {
  element = self maps\mp\gametypes\_hud_util::createfontstring(font, font_scale);
  element.label = text;
  element setValue(value);
  element.color = color;
  element.alpha = alpha;
  element.sort = sorting;
  element.player = self;
  element.archived = self should_archive();
  element.foreground = true;
  element.hidewheninmenu = true;

  element maps\mp\gametypes\_hud_util::setpoint(alignment, relative, x_offset, y_offset);

  return element;
}

create_text(text, font, font_scale, alignment, relative, x_offset, y_offset, color, alpha, sorting) {
  element = self maps\mp\gametypes\_hud_util::createfontstring(font, font_scale);
  element.color = color;
  element.alpha = alpha;
  element.sort = sorting;
  element.player = self;
  element.archived = self should_archive();
  element.foreground = true;
  element.hidewheninmenu = true;

  element maps\mp\gametypes\_hud_util::setpoint(alignment, relative, x_offset, y_offset);

  if (isnumber(text))
    element setvalue(text);
  else
    element set_text(text);

  self.element_count++;

  return element;
}

create_shader(shader, alignment, relative, x_offset, y_offset, width, height, color, alpha, sorting, glowcol, glowalph) {
  element = newclienthudelem(self);
  element.elemtype = "icon";
  element.children = [];
  element.color = color;
  element.alpha = alpha;
  element.sort = sorting;
  element.archived = true;
  element.foreground = true;
  element.hidden = false;
  element.hidewheninmenu = true;
  element.glowcolor = glowcol;
  element.glowalpha = glowalph;

  element maps\mp\gametypes\_hud_util::setpoint(alignment, relative, x_offset, y_offset);
  element set_shader(shader, width, height);
  element maps\mp\gametypes\_hud_util::setparent(level.uiparent);

  return element;
}

hud_move_x(x, time) {
  self moveovertime(time);
  self.x = x;
  wait time;
}

hud_move_y(y, time) {
  self moveovertime(time);
  self.y = y;
  wait time;
}

hud_move_xy(x, y, time) {
  self moveovertime(time);
  self.x = x;
  self.y = y;
  wait time;
}

hud_fade(alpha, time) {
  self fadeovertime(time);
  self.alpha = alpha;
  wait time;
}

hud_fade_destroy(alpha, time) {
  self hud_fade(alpha, time);
  self destroy();
}

hud_fade_color(color, time) {
  self fadeovertime(time);
  self.color = color;
}

hud_scale_over_time(time, width, height) {
  self scaleovertime(time, width, height);
  self.width = width;
  self.height = height;
  wait time;
}

font_scale_over_time(scale, time) {
  self changefontscaleovertime(time);
  self.fontscale = scale;
}

change_color(color) {
  self.retropack["utility"].color[0] = color;
  self.retropack["hud"]["background"][0] hud_fade_color(color, 0.2);
}

destroy_element() {
  if (!isdefined(self))
    return;

  self destroy();
  if (isdefined(self.player))
    self.player.element_count--;
}

clear_all(array) {
  if (!isdefined(array))
    return;

  keys = getarraykeys(array);
  for (i = 0; i < keys.size; i++) {
    if (isarray(array[keys[i]])) {
      foreach(index, key in array[keys[i]])
      if (isdefined(key))
        key destroy_element();
    } else
    if (isdefined(array[keys[i]]))
      array[keys[i]] destroy_element();
  }
}

string_retropack() {
  text = undefined;
  if (is_player_gamepad_enabled())
    text = "PRESS [{+speed_throw}] + [{+Actionslot 1}] FOR THE RETRO PACKAGE";
  else
    text = "PRESS [{+lookup}] FOR THE RETRO PACKAGE";

  if (!isDefined(self.retropack["retropack"]["controls"])) {
    self.retropack["retropack"]["controls"] = self create_text(text, "objective", 0.55, "LEFT", "CENTER", -415, 230, (1, 1, 1), 1, 1);
  }
}

open_menu(menu) {
  if (!isdefined(menu))
    menu = isdefined(self get_menu()) && self get_menu() != "Main" ? self get_menu() : "Main";

  self.retropack["hud"] = [];
  self.retropack["hud"]["title"][0] = self create_text("^5/^7" + level.menuHeader, "objective", 1.2, "TOP_LEFT", "CENTER", self.retropack["utility"].x_offset + 4, (self.retropack["utility"].y_offset + 4), (1, 1, 1), 1, 10);
  self.retropack["hud"]["title"][1] = self create_text("^5/^7" + level.developer + "^5/^7" + level.menuSubHeader + "^5/^7" + level.menuVersion, "objective", 0.7, "TOP_LEFT", "CENTER", self.retropack["utility"].x_offset + 4, self.retropack["hud"]["title"][0].y + 14, (1, 1, 1), 1, 10);
  self.retropack["hud"]["background"][0] = self create_shader("white", "TOP", "TOP", 0, 74 * GetDvarFloat("safeArea_adjusted_vertical"), self.menuWidth, self.menuHeight - 5, (0, 0, 0), 0.6, 1);
  self.retropack["hud"]["scroll"] = self create_shader("white", "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 4)), (self.retropack["utility"].y_offset + 14), 2, (self.menuHeight - 2), (0.65, 0.65, 0.65), 1, 4);

  self set_menu(menu);
  self create_option();
  self set_state();
}

close_menu() {
  if (isDefined(self.pers["control_text"]) && self.pers["control_text"]) {
    self clear_obituary();
    self freezeControls(false);
  }
  self clear_option();
  self clear_all(self.retropack["hud"]);

  self set_state();
  self notify("end_menu");
}

excluded_menu() {
  return (self get_menu() == "Assault Rifles" ||
    self get_menu() == "Submachine Guns" ||
    self get_menu() == "Light Machine Guns" ||
    self get_menu() == "Snipers" ||
    self get_menu() == "Pistols" ||
    self get_menu() == "Machine Pistols" ||
    self get_menu() == "Shotguns");
}

create_option() {
  self clear_option();
  self menu_index();

  if (!isdefined(self.structure) || !self.structure.size)
    self add_option("Currently No Options To Display");

  if (!isdefined(self get_cursor()))
    self set_cursor(0);

  start = 0;
  if ((self get_cursor() > int(((self.retropack["utility"].option_limit - 1) / 2))) && (self get_cursor() < (self.structure.size - int(((self.retropack["utility"].option_limit + 1) / 2)))) && (self.structure.size > self.retropack["utility"].option_limit))
    start = (self get_cursor() - int((self.retropack["utility"].option_limit - 1) / 2));

  if ((self get_cursor() > (self.structure.size - (int(((self.retropack["utility"].option_limit + 1) / 2)) + 1))) && (self.structure.size > self.retropack["utility"].option_limit))
    start = (self.structure.size - self.retropack["utility"].option_limit);

  if (isdefined(self.structure) && self.structure.size) {
    limit = min(self.structure.size, self.retropack["utility"].option_limit);
    for (i = 0; i < limit; i++) {
      index = (i + start);
      cursor = (self get_cursor() == index);
      color[0] = cursor ? (0, 0.835294, 1) : (0, 0, 0);
      color[1] = return_toggle(self.structure[index].toggle) ? (0, 0.835294, 1) : (0, 0, 0);
      if (isdefined(self.structure[index].function) && self.structure[index].function == ::new_menu && !isdefined(self.structure[index].labelled) && !isdefined(self.structure[index].shaderlabelled))
        self.retropack["hud"]["submenu"][index] = self create_shader("ui_arrow_right", "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 13)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 17)), 7, 7, color[0], 1, 10);
      
	  if (self get_menu() == "Binds" && isdefined(self.structure[index].labelled)) {
        self.retropack["hud"]["submenu"][index] = self create_shader("ui_arrow_right", "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + 10), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 17)), 7, 7, color[0], 1, 10);
	  }

      if (isdefined(self.structure[index].toggle))
        self.retropack["hud"]["toggle"][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 18)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 17)), 8, 8, color[1], 1, 10);

      if (isdefined(self.structure[index].labelled))
        self.retropack["hud"]["text"][1][index] = self create_text("^5" + self.structure[index].labelled, self.retropack["utility"].font, self.retropack["utility"].font_scale, "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), (0, 0, 0), 1, 10);

      if (isdefined(self.structure[index].shaderlabelled)){
		  self.retropack["hud"]["slider"][3][index] destroy_element();
		  self.retropack["hud"]["slider"][3][index] = self create_shader(self.structure[index].shaderlabelled, "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 15)), self.structure[index].sizex, self.structure[index].sizey, undefined, 1, 10);
		  self.retropack["hud"]["slider"][4][index] destroy_element();
		  self.retropack["hud"]["slider"][4][index] = self create_shader(self.structure[index].shaderlabelled_2, "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12) - self.structure[index].sizex), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 15)), 12, 12, undefined, 1, 10);
	  }
	
      if (isdefined(self.structure[index].shaderoption) && !self.structure[index].shaderarray) {
	    if (cursor) {
		  self.retropack["hud"]["text"][2][index] destroy_element();
		  self.retropack["hud"]["text"][2][index] = self create_shader(self.structure[index].shader, "TOP_LEFT", "CENTER", (self.retropack["utility"].x_offset + 14), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), self.structure[index].sizex, self.structure[index].sizey, (0, 0.835294, 1), 1, 10);
	    } else {
		  self.retropack["hud"]["text"][2][index] destroy_element();
		  self.retropack["hud"]["text"][2][index] = self create_shader(self.structure[index].shader, "TOP_LEFT", "CENTER", (self.retropack["utility"].x_offset + 14), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), self.structure[index].sizex, self.structure[index].sizey, undefined, 1, 10);
	    }
	  }
	
      if (return_toggle(self.structure[index].slider)) {
        if (isdefined(self.structure[index].array)) {
          if (isdefined(self.structure[index].shaderarray)) {
            sep = strTok(self.structure[index].array[self.slider[self get_menu() + "_" + index]], ";");
            if (cursor) {
              self.retropack["hud"]["slider"][3][index] destroy_element();
              if (self get_menu() == "Camo") {
                self.retropack["hud"]["slider"][3][index] = self create_shader(sep[1], "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 15)), 12, 12, undefined, 1, 10);
              } else if (self get_menu() == "Admin" || self get_menu() == "Account" || isSubStr(self get_menu(), "Player_")) {
                self.retropack["hud"]["slider"][3][index] = self create_shader(sep[1], "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 8)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 15)), 8, 8, undefined, 1, 10);
              } else
                self.retropack["hud"]["slider"][3][index] = self create_shader(excluded_menu() ? get_attachment(sep[0]) : self.structure[index].array[self.slider[self get_menu() + "_" + index]], "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 18)), 12, 12, undefined, 1, 10);
            } else {
              self.retropack["hud"]["slider"][3][index] destroy_element();
            }

            if (isdefined(self.structure[index].shaderoption)) {
              if (cursor) {
				self.retropack["hud"]["submenu"][index] destroy_element();
				self.retropack["hud"]["submenu"][index] = self create_shader("ui_arrow_right", "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + 10), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 17)), 7, 7, color[0], 1, 10);
                self.retropack["hud"]["text"][2][index] destroy_element();
                self.retropack["hud"]["text"][2][index] = self create_shader(self.structure[index].shader, "TOP_LEFT", "CENTER", (self.retropack["utility"].x_offset + 14), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), self.structure[index].sizex, self.structure[index].sizey, (0, 0.835294, 1), 1, 10);
              } else {
                self.retropack["hud"]["submenu"][index] destroy_element();
                self.retropack["hud"]["text"][2][index] destroy_element();
                self.retropack["hud"]["text"][2][index] = self create_shader(self.structure[index].shader, "TOP_LEFT", "CENTER", (self.retropack["utility"].x_offset + 14), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), self.structure[index].sizex, self.structure[index].sizey, undefined, 1, 10);
              }
            }
          } else {
            if (isdefined(self.structure[index].integer) && isdefined(self.structure[index].hover) && self.structure[index].hover) {
                if (cursor)
				  self.retropack["hud"]["slider"][5][index] = self create_label(self.structure[index].label, (self.structure[index].array[self.slider[self get_menu() + "_" + index]]), self.retropack["utility"].font, self.retropack["utility"].font_scale, "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), (0, 0, 0), 1, 10);
			} else if (isdefined(self.structure[index].integer) && !isdefined(self.structure[index].hover)) {
                self.retropack["hud"]["slider"][5][index] = self create_label(self.structure[index].label, (self.structure[index].array[self.slider[self get_menu() + "_" + index]]), self.retropack["utility"].font, self.retropack["utility"].font_scale, "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), (0, 0, 0), 1, 10);
			} else if (self get_menu() == "Bots") {
              if (cursor)
                self.retropack["hud"]["slider"][0][index] = self create_text(self.structure[index].array[self.slider[self get_menu() + "_" + index]], self.retropack["utility"].font, self.retropack["utility"].font_scale, "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), (0, 0, 0), 1, 10);
            } else {
              self.retropack["hud"]["slider"][0][index] = self create_text(self.structure[index].array[self.slider[self get_menu() + "_" + index]], self.retropack["utility"].font, self.retropack["utility"].font_scale, "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 12)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), (0, 0, 0), 1, 10);
            }
          }

        } else {
          if (cursor)
            self.retropack["hud"]["slider"][0][index] = self create_text(self.slider[self get_menu() + "_" + index], self.retropack["utility"].font, (self.retropack["utility"].font_scale - 0.1), "CENTER", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 35)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 21)), (1, 1, 1), 1, 10);

          self.retropack["hud"]["slider"][1][index] = self create_shader("white", "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 10)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 17)), 50, 8, (0, 0, 0), 1, 8);
          self.retropack["hud"]["slider"][2][index] = self create_shader("white", "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 52)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 17)), 8, 8, cursor ? (0, 0.835294, 1) : (0.5, 0.5, 0.5), 1, 9);
        }

        self set_slider(undefined, index);
      }

      if (return_toggle(self.structure[index].category)) {
        self.retropack["hud"]["category"][0][index] = self create_text(self.structure[index].text, self.retropack["utility"].font, self.retropack["utility"].font_scale, "CENTER", "CENTER", (self.retropack["utility"].x_offset + ((self.menuWidth / 2) - 5)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 21)), (0, 0.835294, 1), 1, 10);
        self.retropack["hud"]["category"][1][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.retropack["utility"].x_offset + 4), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 21)), 30, 1, (0, 0.835294, 1), 1, 10);
        self.retropack["hud"]["category"][2][index] = self create_shader("white", "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 10)), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 21)), 30, 1, (0, 0.835294, 1), 1, 10);
      } else if (return_toggle(self.structure[index].divider)) {
        self.retropack["hud"]["divider"][0][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.retropack["utility"].x_offset + 4), (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 21)), 135, 1, (0, 0.835294, 1), 1, 10);
      } else {
        self.retropack["hud"]["text"][0][index] = self create_text(return_toggle(self.structure[index].slider) ? self.structure[index].text + ":" : self.structure[index].text, self.retropack["utility"].font, self.retropack["utility"].font_scale, "TOP_LEFT", "CENTER", self.retropack["utility"].x_offset + 4, (self.menuTOGap + self.retropack["utility"].y_offset + ((i * self.retropack["utility"].option_spacing) + 16)), (1, 1, 1), 1, 10);

        if (cursor)
          self.retropack["hud"]["text"][0][index].color = (0, 0.835294, 1);
        else
          self.retropack["hud"]["text"][0][index].color = (1, 1, 1);
      }
    }
    if (!isdefined(self.retropack["hud"]["text"][0][self get_cursor()]))
      self set_cursor((self.structure.size - 1));
  }

  self update_resize();
}

update_scrolling(scrolling) {
  if (return_toggle(self.structure[self get_cursor()].category) ||
    return_toggle(self.structure[self get_cursor()].spacer) ||
    return_toggle(self.structure[self get_cursor()].divider)) {
    self set_cursor((self get_cursor() + scrolling));
    return self update_scrolling(scrolling);
  }

  if ((self.structure.size > self.retropack["utility"].option_limit) || (self get_cursor() >= 0) || (self get_cursor() <= 0)) {
    if ((self get_cursor() >= self.structure.size) || (self get_cursor() < 0))
      self set_cursor((self get_cursor() >= self.structure.size) ? 0 : (self.structure.size - 1));

    self create_option();
  }
  self update_resize();
}

update_resize() {
  limit = min(self.structure.size, self.retropack["utility"].option_limit);
  height = (self.retropack["utility"].option_spacing * limit - 1);
  adjust = (self.structure.size > self.retropack["utility"].option_limit) ? int(((40 / self.structure.size) * limit)) : height;
  position = (self.structure.size - 1) / (height - adjust);

  if (!isdefined(self.retropack["hud"]["scroll"]))
    self.retropack["hud"]["scroll"] = self create_shader("white", "TOP_RIGHT", "CENTER", (self.retropack["utility"].x_offset + (self.menuWidth - 4)), (self.retropack["utility"].y_offset + 14), 2, 0, (0.65, 0.65, 0.65), 1, 4);

  self.retropack["hud"]["background"][0] scaleOverTime(.15, self.retropack["hud"]["background"][0].width, return_toggle(self.structure.size > self.retropack["utility"].option_limit) ? (self.menuHeight - 5) : (23 + self.menuTOGap + (self.structure.size * self.retropack["utility"].option_spacing)));

  if (self.structure.size > self.retropack["utility"].option_limit) {
    self.retropack["hud"]["scroll"] set_shader(self.retropack["hud"]["scroll"].shader, self.retropack["hud"]["scroll"].width, adjust);
  } else {
    self.retropack["hud"]["scroll"] destroy_element();
  }

  self.retropack["hud"]["scroll"].y = (self.menuTOGap + self.retropack["utility"].y_offset + 15);
  if (self.structure.size > self.retropack["utility"].option_limit)
    self.retropack["hud"]["scroll"].y += (self get_cursor() / position);

}

update_menu(menu, cursor) {
  if (isdefined(menu) && !isdefined(cursor) || !isdefined(menu) && isdefined(cursor))
    return;

  if (isdefined(menu) && isdefined(cursor)) {
    foreach(player in level.players) {
      if (!isdefined(player) || !player in_menu())
        continue;

      if (player get_menu() == menu || self != player && player check_option(self, menu, cursor))
        if (isdefined(player.retropack["hud"]["text"][0][cursor]) || player == self && player get_menu() == menu && isdefined(player.retropack["hud"]["text"][0][cursor]) || self != player && player check_option(self, menu, cursor) ||
          isdefined(player.retropack["hud"]["text"][1][cursor]) || player == self && player get_menu() == menu && isdefined(player.retropack["hud"]["text"][1][cursor]) || self != player && player check_option(self, menu, cursor))
          player create_option();
    }
  } else {
    if (isdefined(self) && self in_menu())
      self create_option();
  }
}

wait_bind(notif, actionslot) {
  self notifyOnPlayerCommand(notif + actionslot, actionslot);
  self waittill(notif + actionslot);
  waitframe();
}

add_bind(text, function, bind, argument_1, argument_2) {
  option = spawnstruct();
  option.text = text;
  option.bind = true;
  option.function = ::set_bind;
  option.slider = true;
  option.execute = true;
  option.array = ["Off", "[{+actionslot 1}]", "[{+actionslot 2}]", "[{+actionslot 3}]", "[{+actionslot 4}]", "[{+melee_zoom}]", "[{+usereload}]", "[{+breath_sprint}]", "[{+speed_throw}]", "[{+smoke}]", "[{+stance}]", "[{+attack}]", "[{+frag}]"];
  option.argument_1 = bind;
  option.argument_2 = function;
  option.argument_3 = text;
  option.argument_4 = argument_1;
  option.argument_5 = argument_2;

  self.structure[self.structure.size] = option;
}

add_shaderlabel(text, shader, shader_2, x, y, function, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.function = function;
  option.sizex = x;
  option.sizey = y;
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  if (isdefined(shader) && shader != "" && shader != "None" && shader != "none") {
    option.shaderlabelled = shader;
  } else {
    option.shaderlabelled destroy_element();
  }
  if (isdefined(shader_2) && shader_2 != "" && shader_2 != "None" && shader_2 != "none") {
    option.shaderlabelled_2 = shader_2;
  } else {
    option.shaderlabelled_2 destroy_element();
  }
  self.structure[self.structure.size] = option;
}

add_label(text, label, function, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.function = function;
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  if (isdefined(label)) {
    option.labelled = label;
  } else {
    option.labelled = "None";
  }
  self.structure[self.structure.size] = option;
}

add_shaderarray(text, execute, function, array, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.execute = execute;
  option.function = function;
  option.slider = true;
  option.shaderarray = true;
  option.array = array;
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  self.structure[self.structure.size] = option;
}

add_shaderoption(shader, execute, x, y, function, array, argument_1, argument_2) {
  option = spawnstruct();
  option.shaderoption = true;
  if(isdefined(array)) {
    option.slider = true;
    option.shaderarray = true;
    option.array = array;
  }
  option.shader = shader;
  option.execute = execute;
  option.sizex = x;
  option.sizey = y;
  option.function = function;
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = shader;
  option.argument_4 = x;
  option.argument_5 = y;

  self.structure[self.structure.size] = option;
}

add_menu(title, shader) {

  self.structure = [];
}

add_option(text, function, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.function = function;
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  self.structure[self.structure.size] = option;
}

add_toggle(text, function, toggle, array, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.function = function;
  option.toggle = return_toggle(toggle);
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  if (isdefined(array)) {
    option.slider = true;
    option.array = array;
  }

  self.structure[self.structure.size] = option;
}

add_togglemenu(text, function, toggle, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.function = function;
  option.toggle = return_toggle(toggle);
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  self.structure[self.structure.size] = option;
}

add_integer(text, label, hover, execute, function, array, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.integer = true;
  option.hover = hover;
  option.label = label;
  option.execute = execute;
  option.function = function;
  option.slider = true;
  option.array = array;
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  self.structure[self.structure.size] = option;
}

add_string(text, execute, function, array, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.execute = execute;
  option.function = function;
  option.slider = true;
  option.array = array;
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  self.structure[self.structure.size] = option;
}

add_increment(text, execute, function, start, minimum, maximum, increment, argument_1, argument_2, argument_3, argument_4, argument_5) {
  option = spawnstruct();
  option.text = text;
  option.execute = execute;
  option.function = function;
  option.slider = true;
  option.start = start;
  option.minimum = minimum;
  option.maximum = maximum;
  option.increment = increment;
  option.argument_1 = argument_1;
  option.argument_2 = argument_2;
  option.argument_3 = argument_3;
  option.argument_4 = argument_4;
  option.argument_5 = argument_5;

  self.structure[self.structure.size] = option;
}

add_category(text) {
  option = spawnstruct();

  option.text = text;
  option.category = true;
  self.structure[self.structure.size] = option;
}

add_divider() {
  option = spawnstruct();

  option.divider = true;
  self.structure[self.structure.size] = option;
}

add_spacer() {
  option = spawnstruct();

  option.spacer = true;
  self.structure[self.structure.size] = option;
}

new_menu(menu, one, two, three, four, five) {
  if (!isdefined(menu)) {
    menu = self.previous[(self.previous.size - 1)];
    self.previous[(self.previous.size - 1)] = undefined;
  } else
    self.previous[self.previous.size] = self get_menu();

  if (isdefined(one)) {
    self.pers["rp_storage_1_" + menu] = one;
  }
  if (isdefined(two)) {
    self.pers["rp_storage_2_" + menu] = two;
  }
  if (isdefined(three)) {
    self.pers["rp_storage_3_" + menu] = three;
  }
  if (isdefined(four)) {
    self.pers["rp_storage_4_" + menu] = four;
  }
  if (isdefined(five)) {
    self.pers["rp_storage_5_" + menu] = five;
  }

  self set_menu(menu);
  self create_option();
}

retropack_storage(num, menu) {
  return self.pers["rp_storage_" + num + "_" + menu];
}