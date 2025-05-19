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
- Setting/Spoofing Prestige now uses raw Integers as values (previous code still remains however)
- Added Advanced UAV to do_radar()
*/

#include scripts\utility;
#include maps\mp\_utility;
#include scripts\mp\_retropack;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\mp\_retropack_utility;

test_function() {
  self iPrintLn("^5RETRO^7PACK");
}

/* 
	Utils
*/

print_guid(player) {
  self iPrintln("^5" + sanitise_name(player.name) + "'s GUID: ^7" + player.guid);
}

sticky_perks(player) {
	table = "mp/perkTable.csv";
    for (i = 1; i < 33; i++) {
      perk = tableLookup(table, 0, i, 1);
      if (!isSubStr(perk, "specialty_"))
        continue;
	
      if(getDvar("g_gametype") == "sd" && getDvarInt("rp_revives") == 1 && perk == "specialty_finalstand" && player maps\mp\_utility::_hasPerk("specialty_finalstand"))
        continue;

      if (isDefined(player.pers["flag_perk"]) && player.pers["flag_perk"]) {
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
        if (player maps\mp\_utility::_hasPerk(perk)) {
          player.pers["set_" + perk] = true;
          player.pers["set_" + get_perk_upgrade(perk)] = true;
        } else if (!player maps\mp\_utility::_hasPerk(perk)) {
          player.pers["set_" + perk] = false;
          player.pers["set_" + get_perk_upgrade(perk)] = false;
        }
      }
    }
}

delete_carepack() {
  level.airDropCrates = getEntArray("care_package", "targetname");
  level.oldAirDropCrates = getEntArray("airdrop_crate", "targetname");

  if (level.airDropCrates.size) {
    foreach(crate in level.AirDropCrates) {
      _objective_delete(crate.objIdFriendly);
      _objective_delete(crate.objIdEnemy);
      crate delete();
    }
  }
}

should_raise(weapon) {
  if (self.pers["raise_weapon"] == "Sniper" && is_sniper(weapon))
    return true;

  if (self.pers["raise_weapon"] == "All Weapons")
    return true;

  if (self.pers["raise_weapon"] == weapon)
    return true;

  return false;
}

get_nac_time(weapon, soh) { //wip. scrapped. 
  if (!soh) {
    if (isSubstr(weapon, "h2_cheytac"))
      return 0.56;
    else if (isSubstr(weapon, "h2_barrett"))
      return 2.9;
    else if (isSubstr(weapon, "h2_wa2000"))
      return 2.47;
    else if (isSubstr(weapon, "h2_m21"))
      return 1.92499999599;
    //return 1.924999892196;
    else if (isSubstr(weapon, "h2_m40a3"))
      return 0.5;
  } else {
    if (isSubstr(weapon, "h2_cheytac"))
      return 0.28;
    else if (isSubstr(weapon, "h2_barrett"))
      return 1.2;
    else if (isSubstr(weapon, "h2_wa2000"))
      return 1.10;
    else if (isSubstr(weapon, "h2_m21"))
      return 0.96;
    else if (isSubstr(weapon, "h2_m40a3"))
      return 0.25;
  }

  return 0.01;
}

/* 
	#################################################################################################################################
	## Fun Fact: The Basis of modern Explosive Bullets (EB)                                                                        ##
	##                                                                                                                             ##
	## Explosive Bullets v2 (now known as Silent Aimbot) was originally released with Project Helios v2.5 along                    ##
	## with the first ever Trickshotting Binds (Nac-Mod, originally known as Insta Mod & Bounce-Mod (ripped from CoDJumper)).      ##
	## The Explosive Bullets v2 function was made to improve the original by including "Blood FX" and prevent shooting             ##                                                                                                                        ##
	## actual "explosive" bullets (flying dummies, shooting yourself with EB, un-wallbangable, etc).                               ##
	##                                                                                                                             ##
	## Project Helios (the first ever Azza menu on PS3, circa. 2011-12 (a.k.a ModMenu12))                                          ##
	#################################################################################################################################
*/

AimbotType(value, spawn, player) {
  if (value == "Player") {
    player.claymoreeb = undefined;
    player.c4eb = undefined;
  } else if (value == "Claymore") {
    player.claymoreeb = true;
    player.c4eb = undefined;
  } else if (value == "C4") {
    player.claymoreeb = undefined;
    player.c4eb = true;
  }

  player.pers["explosive_bullets_type"] = value;
  if (!isDefined(spawn)) {
    if (player != self) {
      player iPrintln("Explosive Bullet Target: ^5" + value + " ^7set by " + sanitise_name(self.name));
      self iPrintln(player.name + "'s Explosive Bullets Type: ^5" + value);
    } else {
      self iPrintln("Explosive Bullet Target: ^5" + value);
    }
  }
}

AimbotStrength(value, spawn, player) {
  player notify("NewRange");
  text = "";

  if (value == 0)
    text = " (Off)";
  else if (value == 200)
    text = " (Weak)";
  else if (value == 500)
    text = " (Strong)";
  else if (value == 1000)
    text = " (Everywhere)";

  if (!isDefined(spawn)) {
    if (player != self) {
      player iPrintln("Explosive Bullet Radius: ^5" + value + text + " ^7set by " + sanitise_name(self.name));
      self iPrintln(player.name + "'s Explosive Bullets Radius: ^5" + value + text);
    } else {
      self iPrintln("Explosive Bullet Radius: ^5" + value + text);
    }
  }

  if (value == 1000)
    value = 999999999;

  player.pers["explosive_bullets"] = value;
  player thread Aimbot(value, player);
}

AimbotDelay(value, spawn, player) {
  player notify("end_delay");
  text = "";

  if (value == 0.1)
    text = " (Off)";

  if (!isDefined(spawn)) {
    if (player != self) {
      player iPrintln("Explosive Bullet Delay: ^5" + value + text + " ^7set by " + sanitise_name(self.name));
      self iPrintln(player.name + "'s Explosive Bullets Delay: ^5" + value + text);
    } else {
      self iPrintln("Explosive Bullet Delay: ^5" + value + text);
    }
  }

  if (value == 0.2)
    value = 0.035;
  else if (value == 0.3)
    value = 0.135;
  else if (value == 0.4)
    value = 0.280;
  else if (value == 0.5)
    value = 0.325;
  else 
	  value = 0.1;

  player.pers["eb_delay"] = value;
}

Aimbot(range, client) {
  client endon("disconnect");
  client endon("NewRange");
  level endon("game_ended");
  client.pers["eb_delay_notify"] = false;
  for (;;) {
    aimAt = undefined;
    claymore = undefined;
    claymoreTarget = undefined;
    c4 = undefined;
    c4Target = undefined;
    client waittill("weapon_fired");
    weaponClass = client getCurrentWeapon();
    forward = client getTagOrigin("tag_eye");
    end = vector_scale(anglestoforward(client getPlayerAngles()), 1000000);
    ExpLocation = BulletTrace(forward, end, false, client)["position"];

    foreach(player in level.players) {
      if (isDefined(player.claymorearray)) {
        foreach(claymore in player.claymorearray) {
          claymoreTarget = undefined;
          if (distance(claymore.origin, ExpLocation) <= range) {
            claymoreTarget = claymore;
          }
        }
      }
      if (isDefined(player.manuallydetonatedarray[0][0])) {
        for (c4 = 0; c4 < player.manuallydetonatedarray.size; c4++) {
          c4Target = undefined;
          if (distance(player.manuallydetonatedarray[c4][0].origin, ExpLocation) <= range) {
            c4Target = player.manuallydetonatedarray[c4][0];
          }
        }
      }
      if ((player == client) || (!isAlive(player)) || (level.teamBased && client.pers["team"] == player.pers["team"]))
        continue;
      if (isDefined(aimAt)) {
        if (closer(ExpLocation, player getTagOrigin("tag_eye"), aimAt getTagOrigin("tag_eye")))
          aimAt = player;
      } else aimAt = player;
    }

    doModRandom = randomInt(40);
    if (doModRandom == 1)
      doMod = "MOD_HEAD_SHOT";
    else
      doMod = "MOD_RIFLE_BULLET";
    doLoc = "torso_upper";
    doDesti = aimAt.origin + (0, 0, randomIntRange(10, 60));
	
	if( isAlive(aimAt) || isDefined(aimAt.inlaststand) && aimAt.inlaststand ) {
      if (client.pers["eb_weapon"] == "Snipers") {
        if (is_sniper(weaponClass)) {
		  client AimbotKill(client, weaponClass, doDesti, doMod, aimAt, doLoc, c4Target, claymoreTarget, ExpLocation, range);
        }
      } else {
        if (weaponClass == client.pers["eb_weapon"]) {
		  client AimbotKill(client, weaponClass, doDesti, doMod, aimAt, doLoc, c4Target, claymoreTarget, ExpLocation, range);
        }
      }
	}
    waitframe();
  }
}

AimbotKill(player, weapon, destination, mod, victim, location, c4Target, claymoreTarget, radius, range) {
  player endon("disconnect");
  player endon("NewRange");
  level endon("game_ended");
  if (isDefined(player.c4eb) && player.c4eb) {
	if (isDefined(c4Target.trigger)) {
	  c4Target.trigger delete();
	  c4Target detonate();
	}
  } else if (isDefined(player.claymoreeb) && player.claymoreeb) {
	if (isDefined(claymoreTarget.trigger)) {
	  claymoreTarget.trigger delete();
	  claymoreTarget detonate();
	}
  } else {
	if (distance(victim.origin, radius) <= range) {
	  if(isDefined(player.pers["eb_delay"]) && player.pers["eb_delay"] != 0.1) {
		foreach ( button in level.button_index ) {
		  if (isDefined(player.pers["bind_damagebuffer" + button]) && player.pers["bind_damagebuffer" + button]) {
		    if (isDefined(victim.pers["damage_buffer_victim" + button]) && victim.pers["damage_buffer_victim" + button])
			  player waittill("damage_buffer" + button);
		  }
		}
		if (isDefined(player.c4eb) && player.c4eb || isDefined(player.claymoreeb) && player.claymoreeb || isDefined(player.pers["eb_delay"]) && player.pers["eb_delay"] != 0.1 && distance(victim.origin, radius) <= range) {
		  player scripts\mp\patches::updateDamageFeedback_stub("killshot");
		  if ( isDefined(player.c4eb) && player.c4eb || isDefined(player.claymoreeb) && player.claymoreeb )
		    player playsoundtoplayer("mp_hit_default", player);
		}
		player thread maps\mp\gametypes\_rank::xpPointsPopup( undefined, get_explosive_bullets_xp(player, weapon, mod, victim) );
	    player.pers["eb_delay_notify"] = true;
		if (getDvar("g_gametype") == "sd" && player is_on_last() == 1 || getDvar("g_gametype") != "sd" && player is_on_last(0)) {
	      if (maps\mp\_utility::gameflag("prematch_done") && !level.ingraceperiod)
	        setdvar( "ui_game_state", "postgame" );
	    }
	    wait(player.pers["eb_delay"]);
	  }
	  victim thread[[level.callbackPlayerDamage]](player, player, 999999999, 8, mod, weapon, destination, (0, 0, 0), location, 0);
	  waitframe();
	  player.pers["eb_delay_notify"] = false;
	}
  }
}

TagStrength(value, spawn, player) {
  player notify("end_tag");
  text = "";
	
  if (value == 0)
    text = " (Off)";

  if (!isDefined(spawn)) {
    if (player != self) {
      player iPrintln("Tag Radius: ^5" + value + text + " ^7set by " + sanitise_name(self.name));
      self iPrintln(player.name + "'s Tag Radius: ^5" + value + text);
    } else {
      self iPrintln("Tag Radius: ^5" + value + text);
    }
  }

  if (value == 1000)
    value = 999999999;

  player.pers["tag_radius"] = value;
  player thread do_tagged_eb(value, player);
}

/* 
	Quick Binds
*/

bind_location() {
  self endon("disconnect");
  self endon("endtog");
  self endon("endbinds");
  self endon("death");
  level endon("game_ended");
  self notifyOnPlayerCommand("locsave", "+actionslot 2");
  for (;;) {
    self waittill("locsave");
    if (!self in_menu()) {
      if (self GetStance() == "crouch") {
        self thread do_load_location(self, false);
      } else if (self GetStance() == "prone") {
        self.locsav = 1;
        self thread do_save_location(self, true);
      }
    }
    waitframe();
  }
}

bind_ufo() {
  self endon("disconnect");
  self endon("endbinds");
  self endon("death");
  level endon("game_ended");
  if (isdefined(self.newufo))
    self.newufo delete();
  self.newufo = spawn("script_origin", self.origin);
  self.UfoOn = 0;
  for (;;) {
    if (!self in_menu()) {
      if (self meleebuttonpressed() && self GetStance() == "crouch") {
        if (self.UfoOn == 0) {
          self.UfoOn = 1;
          self.origweaps = self getWeaponsListOffhands();
          foreach(weap in self.origweaps)
          self takeweapon(weap);
          self.newufo.origin = self.origin;
          self playerlinkto(self.newufo);
					self clear_obituary();
          do_server_message("^1Clip Warning: ^7" + sanitise_name(self.name) + " is using UFO", undefined, true);
					self iprintln("[{+smoke}]: Move Slow");
					self iprintln("[{+frag}]: Move Fast");
					self iprintln("[{+melee}] + Crouch: Exit");
        } else {
          self.UfoOn = 0;
          self unlink();
          foreach(weap in self.origweaps)
            self giveweapon(weap);
          self clear_obituary();
        }
        wait 0.15;
      }
      if (self.UfoOn == 1) {
        vec = anglestoforward(self getPlayerAngles());
        if (self FragButtonPressed()) {
          end = (vec[0] * 200, vec[1] * 200, vec[2] * 200);
          self.newufo.origin = self.newufo.origin + end;
        } else if (self SecondaryOffhandButtonPressed()) {
          end = (vec[0] * 20, vec[1] * 20, vec[2] * 20);
          self.newufo.origin = self.newufo.origin + end;
        }
      }
    }
    waitframe();
  }
}

bind_teleport_bots() {
  self endon("disconnect");
  self endon("endtog");
  self endon("endbinds");
  self endon("death");
  level endon("game_ended");
  self notifyOnPlayerCommand("bottele", "+actionslot 3");
  for (;;) {
    self waittill("bottele");
    if (!self in_menu() && !self.isLastStand || !self in_menu() && !isDefined(self.isLastStand)) {
      if (self GetStance() == "crouch") {
        self thread do_teleport_bots(getOtherTeam(self.team));
      }
    }
  }
}

/* 
	Bot Spawner
*/

spawn_bot_wrapper(num, team) {
  self endon("bot_spawned");
  for (;;) {

    if (team != "fill") {
      for (i = 0; i < num; i++) {
        level thread spawn_bot(team, 1);
        wait 1.25;
      }
    } else {
      for (i = 0; i < num / 2; i++) {
        level thread spawn_bot("allies", 1);
        wait 1.25;
      }
	  wait 1;
      for (i = 0; i < num / 2; i++) {
        level thread spawn_bot("axis", 1);
        wait 1.25;
      }
    }
    wait 0.05;
    self notify("bot_spawned");
  }
}

spawn_bot(team, num, restart, delay) {
  if (!isDefined(num) || num == 0)
    num = 1;

  if (team != "fill") {
    for (i = 0; i < num; i++) {
	  wait(delay);
      level thread _spawn_bot(1, team, undefined, undefined, "spawned_player", "Recruit", restart);
    }
  } else {
    for (i = 0; i < num / 2; i++) {
	  wait(delay);
      level thread _spawn_bot(1, "allies", undefined, undefined, "spawned_player", "Recruit", restart);
    }
	wait 1;
	for (i = 0; i < num / 2; i++) {
	  wait(delay);
      level thread _spawn_bot(1, "axis", undefined, undefined, "spawned_player", "Recruit", restart);
    }
  }
}

_spawn_bot(count, team, callback, stopWhenFull, notifyWhenDone, difficulty, restart) {
  bot_count = getDvarInt("rp_bot_count");
  bot_count++;
  waitframe();
  if(getDvarInt("rp_bot_count") == 99)
    setDvar("rp_bot_count", 0);
  else
	setDvar("rp_bot_count", bot_count);
  
  if (level.bot_counted == (level.bot_name.size - 1))
	level.bot_counted = 0;
  else
	level.bot_counted++;

  if (level.bot_name[level.bot_counted] == "Custom Name Here" || !isDefined(level.bot_name[level.bot_counted]) || level.bot_name[level.bot_counted] == "")
	level.bot_name[level.bot_counted] = "Botro_" + bot_count;

  name = level.bot_name[level.bot_counted];

  time = gettime() + 10000;
  connectingArray = [];
  squad_index = connectingArray.size;
  while (level.players.size < maps\mp\bots\_bots_util::bot_get_client_limit() && connectingArray.size < count && gettime() < time) {
    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause(0.05);
    botent = addbot(name, team);
    connecting = spawnstruct();
    connecting.bot = botent;
    connecting.ready = 0;
    connecting.abort = 0;
    connecting.index = squad_index;
    connecting.difficultyy = difficulty;
    connectingArray[connectingArray.size] = connecting;
    connecting.bot thread maps\mp\bots\_bots::spawn_bot_latent(team, callback, connecting);
    connecting.bot set_team_forced(team);
    squad_index++;
    waitframe();
  }

  connectedComplete = 0;
  time = gettime() + 60000;
  while (connectedComplete < connectingArray.size && gettime() < time) {
    connectedComplete = 0;
    foreach(connecting in connectingArray) {
      if (connecting.ready || connecting.abort)
        connectedComplete++;
    }
    wait 0.05;
  }

  if (isdefined(notifyWhenDone)) {
    self notify(notifyWhenDone);
  }

  if (isDefined(restart) && restart && getDvar("g_gametype") == "sd") {
    wait 3;
    maps\mp\gametypes\common_sd_sr::sd_endgame(game["defenders"], game["end_reason"]["time_limit_reached"]);
  }
}

/* 
	Monitors
*/

monitor_weapon_change() {
  self endon("end_insta");
  for (;;) {
    if (!isDefined(self.pers["do_raise"]) || isDefined(self.pers["do_raise"]) && !self.pers["do_raise"])
      return;
		
		weapon = self getCurrentWeapon();
		self waittill("weapon_change", weapon);
		if(!self in_menu()) {
			self do_weapon_raise(weapon);
		}
  }
}

monitor_end_game() {
  level waittill("game_ended");
  foreach(player in level.players) {
    if (player in_menu())
      player close_menu();

    player.pers["spoof_progress"] = undefined;
    if (isAlive(player))
      player set_class_save();
  }
  setDvar("timescale", 1);
  maps\mp\gametypes\_gamelogic::waitforsplashesdone();
  wait 1;
  if (!isdefined(level.finalkillcam_winner) || level.connectingplayers >= 1) {
    setDvar("xblive_privatematch", 1);
  }
}

monitor_hit_message() {
  while (true) {
    self waittill("weapon_fired");
    self notify("end_hit_message");
    self do_hit_message();
    waitframe();
  }
}

monitor_headbounce()
{
  for(;;)  {
    foreach(player in level.players) {
      if(player != self) {
        if(getDvarInt("rp_headbounce") == 1) {
          self.if_touching = self getVelocity();
          if(Distance(player.origin + (0,0,50), self.origin) <= 50 && self.if_touching[2] < -250 ) {
            self.playervel = self getVelocity();
            self setVelocity(self.playervel - (0,0,self.playervel[2] * 1.85));
            waitframe();
          }
        }
	  }
    }
    waitframe();
  }
}

monitor_grenade() {
  self endon("disconnect");
  self endon("death");
  self endon("endreplenish");
  for (;;) {
    self waittill("grenade_fire", grenade, weaponName);
    wait 2;
    if (weaponName == "h1_fraggrenade_mp") {
      wait 4;
      self giveMaxAmmo(weaponName);
    } else if (weaponName == "iw9_throwknife_mp") {
      wait 2;
      self giveMaxAmmo(weaponName);
    } else {
      self giveMaxAmmo(weaponName);
    }
    wait 0.25;
  }
}

monitor_bots() { // could be better
  self endon("bot_spawned");
  if (getDvar("g_gametype") != "sd") {
    self endon("kickFinish");
  }
  for (;;) {
    if (getDvar("g_gametype") != "sd") {
      self waittill("spawned_player");
    }

    if (getDvar("g_gametype") == "sd") {
      num = 1;
      team = "axis";
    } else if (getDvar("g_gametype") == "dm") {
      num = 13;
      team = "axis";
    } else {
      num = 12;
      team = "fill";
    }

	if (isDefined(self.pers["first_spawn"]) && self.pers["first_spawn"]){
		if (level.bot_name[1] == "Retro" && level.teamBased)
			level thread spawn_bot("allies", 1);
		else
			level thread spawn_bot(team, 1);
	}
	
	wait 2.5;
	
	while (get_bots() < num) {
      level thread spawn_bot(team, 1);
	  if (getDvar("g_gametype") == "sd")
        wait 4;
	  if (getDvar("g_gametype") == "war")
        wait 2.5;
	  else
        wait 1.25; 
    }

    if (getDvar("g_gametype") != "sd") {
      self notify("bot_spawned");
    }
  }
}

monitor_round() {
  if (getDvar("g_gametype") == "sd") {
    winLim = maps\mp\_utility::getwatcheddvar("winlimit");
    sdLim = winLim - 1;
    if (game["roundsWon"]["axis"] == winLim - 1 || game["roundsWon"]["allies"] == winLim - 1) {
      self waittill_any("spawned_player");
      level thread do_round_reset(sdLim);
    }
  }
}

/*
	Select()
*/

select_eb_weapon(value, player) {
  if (value == "Select Weapon") {
    player.pers["eb_weapon"] = player getCurrentWeapon();
    if (player != self) {
      player iPrintln("Explosive Bullets will work for ^5" + getWeaponDisplayName(player.pers["eb_weapon"]) + " ^7set by " + sanitise_name(self.name));
      self iPrintln(player.name + "'s Explosive Bullets will work for: ^5" + getWeaponDisplayName(player.pers["eb_weapon"]));
    } else {
      self iPrintln("Explosive Bullets will work for ^5" + getWeaponDisplayName(player.pers["eb_weapon"]));
    }
  } else if (value == "Snipers") {
    player.pers["eb_weapon"] = "Snipers";
    if (player != self) {
      player iPrintln("Explosive Bullets will work for ^5Snipers ^7set by " + sanitise_name(self.name));
      self iPrintln(player.name + "'s Explosive Bullets will work for: ^5Snipers");
    } else {
      self iPrintln("Explosive Bullets will work for ^5Snipers");
    }
  }
}

select_tag_eb_weapon(value, player) {
  if (value == "Select Weapon") {
    player.pers["tag_weapon"] = player getCurrentWeapon();

    if (player != self) {
      player iPrintln("Tag Explosive Bullets will work for ^5" + getWeaponDisplayName(player.pers["tag_weapon"]) + " ^7set by " + sanitise_name(self.name));
      self iPrintln(player.name + "'s Tag Explosive Bullets will work for: ^5" + getWeaponDisplayName(player.pers["tag_weapon"]));
    } else {
      self iPrintln("Tag Explosive Bullets will work for ^5" + getWeaponDisplayName(player.pers["tag_weapon"]));
    }
  } else if (value == "All") {
    player.pers["tag_weapon"] = "All";
    if (player != self) {
      player iPrintln("Tag Explosive Bullets will work for ^5Snipers ^7set by " + sanitise_name(self.name));
      self iPrintln(player.name + "'s Tag Explosive Bullets will work for: ^5All");
    } else {
      self iPrintln("Tag Explosive Bullets will work for ^5Snipers");
    }
  }
}

/* 
	Give()
*/

give_can_swap() {
  weapon = scripts\mp_patches\custom_weapons::h2_buildweaponname(random_gun() + "_mp", "fmj", "xmag", int(tablelookup("mp/camoTable.csv", 1, random_camo(false), 0)));
  waitframe();
  self giveweapon(weapon);
  self dropitem(weapon);
}

give_killstreak(num, streak) {
  sep = strTok(streak, ";");
  for (i = 0; i < num; i++) {
    self maps\mp\gametypes\_hardpoints::giveHardpoint(sep[0], num);
    waitframe();
  }
  self iprintln("Killstreak Given: ^5" + sep[1] + " ^7x" + num);
}

give_weapon(weapon, placeholder, name) {
  sep = strTok(weapon, ";");

  self giveWeapon(sep[0]);
  self switchToWeapon(sep[0]);
  self iprintln("Weapon Given: ^5" + getWeaponDisplayName(sep[0]));
}

/* 
	Func()
*/

func_fast_restart() {
  for (i = 0; i < level.players.size; i++) {
    if (isSubStr(level.players[i].guid, "bot")) {
      kick(level.players[i] getEntityNumber());
    }
  }
  setDvar("xblive_privatematch", 1);
  level.botsConnected = undefined;
  wait 1;
  map_restart(false);
}

func_bot_kick_or_kill(team, type) {
  name = undefined;
  if (team == "allies")
    name = "Friendly";
  else if (team == "axis")
    name = "Enemy";
  else if (team == "All")
    name = "All";

  self iPrintln("^5" + name + " Bots ^7have been ^5" + type + "ed");
  self thread do_bot_kick_or_kill(team, type);
  wait 1.5;
  self notify("kickkillFinish");
}

func_randomise_bot_levels(team) {
  name = undefined;
  if (team == "allies")
    name = "Friendly";
  else if (team == "axis")
    name = "Enemy";
  else if (team == "All")
    name = "All";

  self thread spoof_bot_level(team);
  self iPrintln("^5" + name + " Bot ^7levels have been ^5randomised");
  wait 1.5;
  self notify("LevelFinish");
}

/* 
	Toggle()
*/

toggle_cohost(p) {
  if (!p.pers["rp_host"]) {
    p.pers["rp_host"] = true;
    p iPrintln("^5RETROPACK: ^7Co-Host Access ^2Granted");
    self iPrintln("^5RETROPACK: ^7Co-Host Access Granted to ^5" + p.name);
  } else if (p.pers["rp_host"]) {
    p.pers["rp_host"] = false;
    p iPrintln("^5RETROPACK: ^7Co-Host Access ^1Revoked");
    self iPrintln("^5RETROPACK: ^7" + p.name + "'s Co-Host Access ^1Revoked");
  }
  self set_menu("Player_" + p.name);
  self clear_option();
  self scripts\mp\_retropack_menu::player_index(p);
}

toggle_save_location(p) {
  if (!p.pers["saved_location"]) {
    p.pers["saved_location"] = true;
    p iPrintln("Saved Location ^5Enabled ^7by ^5" + sanitise_name(self.name));
    self iPrintln("Saved Location ^5Enabled ^7for ^5" + sanitise_name(p.name));
  } else if (p.pers["saved_location"]) {
    p.pers["saved_location"] = false;
    p iPrintln("Saved Location ^5Disabled ^7by ^5" + sanitise_name(self.name));
    self iPrintln("Saved Location ^5Disabled ^7for ^5" + sanitise_name(p.name));
  }
  self set_menu("Player_" + p.name);
  self clear_option();
  self scripts\mp\_retropack_menu::player_index(p);
}

toggle_god_mode() {
  if (!self.pers["god_mode"]) {
    self.pers["god_mode"] = true;
    self iPrintln("God Mode: ^5On");
  } else if (self.pers["god_mode"]) {
    self.pers["god_mode"] = false;
    self iPrintln("God Mode: ^5Off");
  }
}

toggle_death_barriers() {
  if (self.pers["death_barriers"]) {
    self thread do_barriers(false, false);
    self.pers["death_barriers"] = false;
  } else if (!self.pers["death_barriers"]) {
    self thread do_barriers(true, false);
    self.pers["death_barriers"] = true;
  }
}

toggle_damage_buffer(victim, button) {
  if (!victim.pers["damage_buffer_victim" + button] || !isDefined(victim.pers["damage_buffer_victim" + button])) {
    victim.pers["damage_buffer_victim" + button] = true;
    self iPrintln("Damage Buffer ([{" + button + "}]): ^5Target ^7(^5" + sanitise_name(victim.name) + "^7)");
  } else {
    victim.pers["damage_buffer_victim" + button] = false;
    self iPrintln("Damage Buffer ([{" + button + "}]): ^5Target ^7(^5Off^7)");
  }
}

toggle_autonuke(seconds) {
  if (seconds != 0) {
    self thread do_auto_nuke(seconds);
    self.pers["auto_nuke"] = seconds;
    self iPrintln("Auto-Nuke: ^5at " + seconds + " seconds");
  } else {
    self notify("end_nuke");
    self.pers["auto_nuke"] = undefined;
    self iPrintln("Auto-Nuke: ^5Off");
  }
}

toggle_autoplant(seconds) {
  if (seconds != 0) {
    self thread do_autoplant(seconds);
    self.pers["auto_plant"] = seconds;
    self iPrintln("Auto-Plant: ^5at " + seconds + " seconds");
  } else {
    self notify("end_plant");
    self.pers["auto_plant"] = undefined;
    self iPrintln("Auto-Plant: ^5Off");
  }
}

toggle_autopause(seconds) {
  if (seconds != 0) {
    self thread do_timer_pause(seconds);
    self.pers["auto_pause"] = seconds;
    self iPrintln("Timer will pause at ^5" + seconds + " seconds ^7remaining");
  } else {
    self notify("end_timer");
    self.pausetimer = false;
    self.pers["auto_pause"] = undefined;
    self maps\mp\gametypes\_gamelogic::resumeTimer();
    self iPrintln("Timer will ^5not ^7pause");
  }
}

toggle_flag_perk() {
  if (!self.pers["flag_perk"] || !isDefined(self.pers["flag_perk"])) {
    self.pers["flag_perk"] = true;
    self iPrintln("Perks Stick: ^5On");
    wait 0.5;
    self iPrintln("Your ^5Perk ^7options will ^5carry over ^7to every spawn and class");
  } else if (self.pers["flag_perk"]) {
    self.pers["flag_perk"] = false;
    self iPrintln("Perks Stick: ^5Off");
  }
}

toggle_killcam_timer() {
  if (!self.pers["rp_timer"] || !isDefined(self.pers["rp_timer"])) {
    self.pers["rp_timer"] = true;
    self iPrintln("Killcam Timer: ^5On");
  } else if (self.pers["rp_timer"]) {
    self.pers["rp_timer"] = false;
    self iPrintln("Killcam Timer: ^5Off");
  }
}

toggle_rp_text() {
  if (!self.pers["show_open"] || !isDefined(self.pers["show_open"])) {
    self.pers["show_open"] = true;
    if (isDefined(self.retropack["retropack"]["controls"])) {
      self.retropack["retropack"]["controls"].alpha = 1;
    } else {
      self thread string_retropack();
    }
    self iPrintln("Display Menu Controls: ^5On");
  } else if (self.pers["show_open"]) {
    self.pers["show_open"] = false;
    self.retropack["retropack"]["controls"].alpha = 0;
    self iPrintln("Display Menu Controls: ^5Off");
  }
}

toggle_replenish_ammo() {
  if (!self.pers["auto_replenish"] || !isDefined(self.pers["auto_replenish"])) {
    self.pers["auto_replenish"] = true;
    self iPrintln("Auto Replenish Ammo: ^5On");
    self thread do_ammo();
    self thread monitor_grenade();
  } else if (self.pers["auto_replenish"]) {
    self.pers["auto_replenish"] = false;
    self iPrintln("Auto Replenish Ammo: ^5Off");
    self notify("endreplenish");
  }
}

toggle_hardcore() {
  if (!self.pers["hardcore_mode"] || !isDefined(self.pers["hardcore_mode"])) {
    self.pers["hardcore_mode"] = true;
    self iPrintln("Hardcore: ^5On");
    setDvar("ui_game_state", "postgame");
    level.hardcoremode = true;
  } else if (self.pers["hardcore_mode"]) {
    self.pers["hardcore_mode"] = false;
    self iPrintln("Hardcore: ^5Off");
    setdvar("ui_game_state", "playing");
    level.hardcoremode = false;
  }
}

toggle_perk(perk) {
  if (!self maps\mp\_utility::_hasPerk(perk) || !self.pers["set_" + perk]) {
	if(getDvarInt("rp_revives") == 1 && perk == "specialty_pistoldeath")
	  self maps\mp\_utility::giveperk("specialty_finalstand");
    self maps\mp\_utility::giveperk(perk);
	self maps\mp\_utility::giveperk(get_perk_upgrade(perk));
    self.pers["set_" + perk] = true;
	self.pers["set_" + get_perk_upgrade(perk)] = true;
    maps\mp\perks\_perks::applyperks();
  } else if (self maps\mp\_utility::_hasPerk(perk) || self.pers["set_" + perk]) {
    if(getDvarInt("rp_revives") == 1 && perk == "specialty_pistoldeath") {
	  self iprintln("Turn ^5OFF^7 Revives in Game Settings to remove ^7this perk");
	  return;
	}
	self maps\mp\_utility::_unsetperk(perk);
	self maps\mp\_utility::_unsetperk(get_perk_upgrade(perk));
    self.pers["set_" + perk] = false;
	self.pers["set_" + get_perk_upgrade(perk)] = false;
    maps\mp\perks\_perks::applyperks();
  }
}

toggle_bot_freeze(team) {
  name = undefined;
  if (team == "allies")
    name = "Friendly";
  else if (team == "axis")
    name = "Enemy";
  else if (team == "All")
    name = "All";

  if (self.botfreeze == 1) {
    self.botfreeze = 0;
    self thread do_freeze_bot(team, "Unfreeze");
    self iPrintln("^5" + name + " Bots: ^7Unfrozen");
  } else if (self.botfreeze == 0) {
    self.botfreeze = 1;
    self thread do_freeze_bot(team, "Freeze");
    self iPrintln("^5" + name + " Bots: ^7Frozen");
  }
}

toggle_clipwarning() {
  if (!self.pers["clip_warning"]) {
    self.pers["clip_warning"] = true;
    self iPrintln("Clip Warning: ^5On");
  } else if (self.pers["clip_warning"]) {
    self.pers["clip_warning"] = false;
    self iPrintln("Clip Warning: ^5Off");
  }
}

toggle_quick_binds() {
  if (!self.pers["quick_binds"]) {
    self.pers["quick_binds"] = true;
    self iPrintln("Quick Binds: ^5On");
    self thread bind_location();
    self thread bind_ufo();
    self thread bind_teleport_bots();
  } else if (self.pers["quick_binds"]) {
    self.pers["quick_binds"] = false;
    self notify("endbinds");
    self iPrintln("Quick Binds: ^5Off");
  }
}

set_afterhit_weapon(type) {
	self.pers["afterhit_weapon"] = type;
	if ( type != "All" )
		self.pers["afterhit_weapon"] = self getCurrentWeapon();
	self iprintln("Afterhit Weapon: ^5" + getWeaponDisplayName(self.pers["afterhit_weapon"]));
}

toggle_afterhit_status() {
  if (!self.pers["do_afterhit"]) {
    if (!isDefined(self.pers["afterhit_type"]) && isDefined(self.pers["afterhit_weapon"])) {
      self iprintln("Afterhit: ^5Select an Afterhit Option");
      return;
    } else if (!isDefined(self.pers["afterhit_weapon"]) && isDefined(self.pers["afterhit_type"])) {
      self iprintln("Afterhit: ^5Select an Afterhit Trigger Weapon");
      return;
    } else if (!isDefined(self.pers["afterhit_weapon"]) && !isDefined(self.pers["afterhit_type"])) {
      self iprintln("Afterhit: ^5Select both an Afterhit Trigger Weapon & Afterhit Option");
      return;
    }
    self.pers["do_afterhit"] = true;
    self thread do_afterhit_weap();
    self iprintln("Afterhit: ^5On");

  } else if (self.pers["do_afterhit"]) {
    self.pers["do_afterhit"] = false;
    self notify("end_afterhit_weap");
    self iPrintln("Afterhit: ^5Off");
  }
}

set_raise_weapon(option) {
	text = undefined;
	weapon = self getCurrentWeapon();
	if(option == "Select Weapon" && self.pers["raise_weapon"] != weapon)
  {
		text = getWeaponDisplayName(weapon);
    self.pers["raise_weapon"] = weapon;
		self notify ("end_insta");
		self thread monitor_weapon_change();
	}
	else if(option == "Sniper")
	{
		self.pers["raise_weapon"] = "Sniper";
		text = "Sniper";
		self notify ("end_insta");
		self thread monitor_weapon_change();
	}
	else if(option == "All")
	{
		self.pers["raise_weapon"] = "All Weapons";
		text = "All Weapons";
		self notify ("end_insta");
		self thread monitor_weapon_change();
	}
	else if(option == "Off")
	{
		self.pers["raise_weapon"] = undefined;
		self.pers["do_raise"] = false;
		text = "None";
		self notify ("end_insta");
		
	}
	self iPrintln("Always Raise Weapon: ^5" + self.pers["raise_type"] + "^7 for ^5" + text);
}

toggle_raise_status() {
  if (!self.pers["do_raise"]) {
    if (!isDefined(self.pers["raise_type"]) && isDefined(self.pers["raise_weapon"])) {
      self iprintln("Always Raise Weapon: ^5Select a Raise Option");
      return;
    } else if (!isDefined(self.pers["raise_weapon"]) && isDefined(self.pers["raise_type"])) {
      self iprintln("Always Raise Weapon: ^5Select a Raise Weapon");
      return;
    } else if (!isDefined(self.pers["raise_weapon"]) && !isDefined(self.pers["raise_type"])) {
      self iprintln("Always Raise Weapon: ^5Select both a Raise Weapon & Raise Option");
      return;
    }
    self.pers["do_raise"] = true;
    self notify("end_insta");
    self thread monitor_weapon_change();
    self iprintln("Always Raise Weapon: ^5On");

  } else if (self.pers["do_raise"]) {
    self.pers["do_raise"] = false;
    self notify("end_insta");
    self iPrintln("Always Raise Weapon: ^5Off");
  }
}

toggle_tk_insert() {
  if (!self.pers["tk_tact"]) {
    self.pers["tk_tact"] = true;
    self iPrintln("Throwing Knife after Tactical Insert Plant: ^5On");
  } else if (self.pers["tk_tact"]) {
    self.pers["tk_tact"] = false;
    self iPrintln("Throwing Knife after Tactical Insert Plant: ^5Off");
  }
}

toggle_afterhit() {
  if (!self.pers["after_hit"]) {
    self.pers["after_hit"] = true;
    self iPrintln("End of Game Freeze: ^5On");
  } else if (self.pers["after_hit"]) {
    self.pers["after_hit"] = false;
    self iPrintln("End of Game Freeze: ^5Off");
  }
}

toggle_spawn_text() {
  if (!self.pers["spawn_text"]) {
    self.pers["spawn_text"] = true;
    self iPrintln("Print Menu At Spawn: ^5On");
  } else if (self.pers["spawn_text"]) {
    self iPrintln("Print Menu At Version: ^5Off");
    self.pers["spawn_text"] = false;
  }
}

toggle_elevators() {
  if (self.pers["do_elevators"] == 0) {
    self.pers["do_elevators"] = 1;
    self iPrintln("Elevators: ^5On");
    setDvar("g_enableElevators", 1);
  } else if (self.pers["do_elevators"] == 1) {
    self.pers["do_elevators"] = 0;
    self iPrintln("Elevators: ^5Off");
    setDvar("g_enableElevators", 0);
  }
}

toggle_softlands() {
  if (self.pers["soft_lands"] == 0) {
    self.pers["soft_lands"] = 1;
    self iPrintln("Softlands: ^5On");
    setDvar("jump_enableFallDamage", 0);
  } else if (self.pers["soft_lands"] == 1) {
    self.pers["soft_lands"] = 0;
    self iPrintln("Softlands: ^5Off");
    setDvar("jump_enableFallDamage", 1);
  }
}

toggle_headshots() {
  if (self.pers["rp_headshots"] == 0) {
    self.pers["rp_headshots"] = 1;
    self iPrintln("Headshots (+1000): ^5On");
  } else if (self.pers["rp_headshots"] == 1) {
    self.pers["rp_headshots"] = 0;
    self iPrintln("Headshots (+1000): ^5Off");
  }
}

toggle_firstblood() {
  if (self.pers["rp_firstblood"] == 0) {
    self.pers["rp_firstblood"] = 1;
    self iPrintln("First Blood (+600): ^5On");
    setDvar("rp_firstblood", 1);
  } else if (self.pers["rp_firstblood"] == 1) {
    self.pers["rp_firstblood"] = 0;
    self iPrintln("First Blood (+600): ^5Off");
    setDvar("rp_firstblood", 0);
  }
}

toggle_headbounce() {
  if (self.pers["rp_headbounce"] == 0) {
    self.pers["rp_headbounce"] = 1;
    self iPrintln("Head Bounces: ^5On");
    setDvar("rp_headbounce", 1);
  } else if (self.pers["rp_headbounce"] == 1) {
    self.pers["rp_headbounce"] = 0;
    self iPrintln("Head Bounces: ^5Off");
    setDvar("rp_headbounce", 0);
  }
}

toggle_autodefuse() {
  if (!self.pers["auto_defuse"] || !isDefined(self.pers["auto_defuse"])) {
    self.pers["auto_defuse"] = true;
    self thread do_defuse_on_death();
    self iPrintln("Auto-Defuse: ^5On");
  } else if (self.pers["auto_defuse"]) {
    self.pers["auto_defuse"] = false;
    self notify("end_defuse");
    self iPrintln("Auto-Defuse: ^5Off");
  }
}

toggle_revives() {
  if (!self.pers["revives"] || !isDefined(self.pers["revives"])) {
    self.pers["revives"] = true;
    setDvar("rp_revives", 1);
    self iPrintln("Final Stand Revives: ^5On");
  } else if (self.pers["revives"]) {
    self.pers["revives"] = false;
    setDvar("rp_revives", 0);
    self iPrintln("Final Stand Revives: ^5Off");
  }
}

toggle_shax() {
  if (!self.pers["oma_shax"] || !isDefined(self.pers["oma_shax"])) {
    self.pers["oma_shax"] = true;
	if (isDefined(self.pers["oma_running"]) && self.pers["oma_running"])
	  self.pers["oma_running"] = false;
    self iPrintln("One Man Army: ^5Shax");
  } else if (self.pers["oma_shax"]) {
    self.pers["oma_shax"] = false;
    self iPrintln("One Man Army: ^5Default");
  }
}

toggle_running_man() {
  if (!self.pers["oma_running"] || !isDefined(self.pers["oma_running"])) {
    self.pers["oma_running"] = true;
	if (isDefined(self.pers["oma_shax"]) && self.pers["oma_shax"])
	  self.pers["oma_shax"] = false;
    self iPrintln("One Man Army: ^5Running Man");
  } else if (self.pers["oma_running"]) {
    self.pers["oma_running"] = false;
    self iPrintln("One Man Army: ^5Default");
  }
}

toggle_distance() {
  if (!self.pers["distance_meter"] || !isDefined(self.pers["distance_meter"])) {
    self.pers["distance_meter"] = true;
    setDvar("rp_distance_meter", 1);
    self iPrintln("Distance Meter: ^5On");
  } else if (self.pers["distance_meter"]) {
    self.pers["distance_meter"] = false;
    setDvar("rp_distance_meter", 0);
    self iPrintln("Distance Meter: ^5Off");
  }
}

/* 
	Do()
*/

do_weapon_raise(weapon) {
  self endon("end_insta");
  if (!isDefined(self.pers["do_raise"]) || isDefined(self.pers["do_raise"]) && !self.pers["do_raise"])
      return;
  
  if (self.pers["raise_type"] == "Instashoot" && should_raise(weapon)) {
    self setSpawnWeapon(weapon);
  } else if (self.pers["raise_type"] == "Sprint" && should_raise(weapon)) {
    self setSpawnWeapon(weapon);
    self force_play_weap_anim(33, 33);
  } else if (self.pers["raise_type"] == "Invisible" && should_raise(weapon)) {
    self setSpawnWeapon(weapon);
    self force_play_weap_anim(17, 17);
  } else if (self.pers["raise_type"] == "Can Swap" && should_raise(weapon)) {
    self scripts\mp\_retropack_binds::do_can(weapon);
  } else if (self.pers["raise_type"] == "Can Zoom" && should_raise(weapon)) {
    self scripts\mp\_retropack_binds::do_can(weapon, true);
  } else if (self.pers["raise_type"] == "Fast Glide" && should_raise(weapon)) {
    if (!isDefined(self.pers["afterhit_type"]) || isDefined(self.pers["afterhit_type"]) && self.pers["afterhit_type"] != "Weapon") {
	  waitframe();
  }
    self setSpawnWeapon(weapon);
    self force_play_weap_anim(31, 31);
    waitframe();
    self force_play_weap_anim(32, 32);
  } else if (self.pers["raise_type"] == "G-Flip" && should_raise(weapon)) {
    /*if (!isDefined(self.pers["afterhit_type"]) || isDefined(self.pers["afterhit_type"]) && self.pers["afterhit_type"] != "Weapon") {
	  waitframe();
    }*/
    self setStance("prone");
	self takeWeapon(weapon);
    waitframe();
	self giveWeapon(weapon);
    waitframe();
    waitframe();
    waitframe();
    waitframe();
    self force_play_weap_anim(19, 19);
    waitframe();
    self setSpawnWeapon(weapon);
    self force_play_weap_anim(30, 30);
    waitframe();
    self setStance("prone");
    wait 0.275;
    self setStance("stand");
    wait 0.1;
    self force_play_weap_anim(1, 1);
  }
}

do_crate() {
  self thread maps\mp\h2_killstreaks\_airdrop::dropthecrate(undefined, "airdrop_marker_mp", undefined, false, undefined, self get_crosshair() + (0, 0, 30));
  wait(0.05);
  self notify("drop_crate");
  self iPrintln("Care Package ^5Spawned");
}

do_barriers(value, spawn) {
  if (!value) {
    ents = getEntArray();
    for (index = 0; index < ents.size; index++) {
      if (!isDefined(ents[index].origin_saved)) {
        ents[index].original_origin = ents[index].origin;
        ents[index].origin_saved = true;
      }

      if (isSubStr(ents[index].classname, "trigger_hurt")) {
        ents[index].origin = (0, 0, 9999999);
        ents[index].origin_saved = true;
      }
    }
    if (!spawn)
      self iPrintln("Death Barriers: ^5Removed");
  } else if (value) {
    ents = getEntArray();
    for (index = 0; index < ents.size; index++) {
      if (isSubStr(ents[index].classname, "trigger_hurt")) {
        if (isDefined(ents[index].origin_saved)) {
          ents[index].origin = ents[index].original_origin;
        }
      }
    }
    if (!spawn)
      self iPrintln("Death Barriers: ^5Added");
  }
}

do_bot_kick_or_kill(team, type) {
  self endon("kickkillFinish");
  while (true) {
    for (i = 0; i < level.players.size; i++) {
      if (isSubStr(level.players[i].guid, "bot")) {
        if (team == "allies") {
          if (level.players[i].pers["team"] == self.pers["team"]) {
            if (type == "kick")
              kick(level.players[i] getEntityNumber());
            else
              level.players[i] thread[[level.callbackPlayerDamage]](level.players[i], undefined, 99999999, 8, "MOD_RIFLE_BULLET", level.players[i] getCurrentWeapon(), level.players[i].origin + (0, 0, 40), (0, 0, 0), "j_mainroot", 0);
            //level.players[i] suicide();
          }
        } else if (team == "axis") {
          if (level.players[i].pers["team"] != self.pers["team"]) {
            if (type == "kick")
              kick(level.players[i] getEntityNumber());
            else
              level.players[i] thread[[level.callbackPlayerDamage]](level.players[i], undefined, 99999999, 8, "MOD_RIFLE_BULLET", level.players[i] getCurrentWeapon(), level.players[i].origin + (0, 0, 40), (0, 0, 0), "j_mainroot", 0);
            //level.players[i] suicide();
          }
        } else if (team == "All") {
          if (type == "kick")
            kick(level.players[i] getEntityNumber());
          else
            level.players[i] thread[[level.callbackPlayerDamage]](level.players[i], undefined, 99999999, 8, "MOD_RIFLE_BULLET", level.players[i] getCurrentWeapon(), level.players[i].origin + (0, 0, 40), (0, 0, 0), "j_mainroot", 0);
          //level.players[i] suicide();
        }
      }
    }
    waitframe();
  }
}

do_teleport_to_self(player) {
  player setOrigin(self.origin);
  if (player.pers["team"] == self.pers["team"]) {
		player.pers["save_position"] = self.origin;
		player.pers["save_angles"] = self.angles;
		player.pers["saved_location"] = true;
  } else if (player.pers["team"] != self.pers["team"]) {
		player.pers["save_position"] = self.origin;
		player.pers["save_angles"] = self.angles;
		player.pers["saved_location"] = true;
  }
  self iprintln("^5" + sanitise_name(player.name) + "^7 has been teleported to you");
  player iprintln("^5" + sanitise_name(self.name) + "^7 has teleported you");
}

do_teleport_to_crosshairs(player) {
  player setOrigin(self get_crosshair());
  if (player != self)
    player setplayerangles(vectortoangles(self gettagorigin("j_head") - player gettagorigin("j_head")));
  if (player.pers["team"] == self.pers["team"]) {
		player.pers["save_position"] = player.origin;
		player.pers["save_angles"] = player.angles;
		player.pers["saved_location"] = true;
  } else if (player.pers["team"] != self.pers["team"]) {
		player.pers["save_position"] = player.origin;
		player.pers["save_angles"] = player.angles;
		player.pers["saved_location"] = true;
  }
  self iprintln("^5" + sanitise_name(player.name) + "^7 has been teleported to your crosshairs");
  player iprintln("^5" + sanitise_name(self.name) + "^7 has teleported you");
  player freezeControls(false);
  waitframe();
  if(isDefined(player.pers["freeze"] && player.pers["freeze"]))
    player freezeControls(true);
}

do_kill(p, print) {
  //p suicide();
  p thread[[level.callbackPlayerDamage]](p, undefined, 99999999, 8, "MOD_RIFLE_BULLET", p getCurrentWeapon(), p.origin + (0, 0, 40), (0, 0, 0), "j_mainroot", 0);
  if (!isDefined(print)) {
    self iPrintln("^5Killed " + sanitise_name(p.name));
    p iprintln("^5" + sanitise_name(self.name) + " has killed you");
  }
}

do_freeze(p) {
  if (!p.pers["freeze"]) {
    p freezeControls(true);
    p.pers["freeze"] = true;
    p iPrintln("You were ^5Frozen ^7by ^5" + sanitise_name(self.name));
    self iPrintln("You ^5Froze ^7" + sanitise_name(p.name));
  } else if (p.pers["freeze"]) {
    p freezeControls(false);
    p.pers["freeze"] = false;
    p iPrintln("You were ^5Unfrozen ^7by ^5" + sanitise_name(self.name));
    self iPrintln("You ^5Unfroze ^7" + sanitise_name(p.name));
  }
  self set_menu("Player_" + p.name);
  self clear_option();
  self scripts\mp\_retropack_menu::player_index(p);
}

do_kick(p) {
  kick(p getEntityNumber());
  self iPrintln("^5Kicked " + sanitise_name(p.name));
}

do_stance(p) {
  if (isSubStr(p.guid, "bot")) {
    p freezeControls(true);
  }
  if (p.Stance == "Stand") {
    p.Stance = "Crouch";
    p SetStance("crouch");
  } else if (p.Stance == "Crouch") {
    p.Stance = "Prone";
    p SetStance("prone");
  } else if (p.Stance == "Prone") {
    p.Stance = "Stand";
    p SetStance("stand");
  }
  self iprintln(p.name + "'s stance has changed to: ^5" + p.Stance);
  p iprintln("^5" + self.name + " ^7has changed your stance");
}

do_timer_pause(seconds) {
  self endon("end_timer");
  level endon("game_ended");
  time = (get_time_limit_float() * 60);

  for (;;) {
    timePassed = (getTime() - level.startTime) / 1000;
    timeRemaining = (time) - timePassed;

    if (timeRemaining <= seconds) {
			self.pausetimer = true;
      maps\mp\gametypes\_gamelogic::pauseTimer();
      return;
    }

    wait 1;
  }
}

do_save_location(player, toggle) {
  if (!player.pers["saved_location"]) {
    player.pers["saved_location"] = true;
    player.pers["save_position"] = player.origin;
    player.pers["save_angles"] = player.angles;
    player iprintln("Location: ^5Saved");
  } else if (player.pers["saved_location"] && toggle) {
    player.pers["saved_location"] = true;
    player.pers["save_position"] = player.origin;
    player.pers["save_angles"] = player.angles;
    player iprintln("Location: ^5Saved");
  } else if (player.pers["saved_location"] && !toggle) {
    player.pers["saved_location"] = false;
    player iprintln("Location: ^5Disabled");
  }
}

do_load_location(player, print) {
  player endon("disconnect");
  if (isDefined(player.pers["saved_location"]) && player.pers["saved_location"]) {
    player setOrigin(player.pers["save_position"]);
    player setPlayerAngles(player.pers["save_angles"]);
    if (print)
      player iprintln("Location: ^5Loaded");
  }
}

do_class_change() {
  game["strings"]["change_class"] = "";
  self endon("disconnect");
  oldclass = self.pers["class"];
  for (;;) {
    table = "mp/perkTable.csv";
    if (self.pers["class"] != oldclass) {
      self maps\mp\gametypes\_class::setClass(self.pers["class"]);
      self maps\mp\gametypes\_class::giveloadout(self.pers["team"], self.pers["class"]);
      self maps\mp\gametypes\_class::applyloadout();
      self maps\mp\gametypes\_hardpoints::giveownedhardpointitem(true);
      self sticky_perks(self);
      oldclass = self.pers["class"];
    }
    waitframe();
  }
}

do_hit_message() {
  self endon("disconnect");
  self endon("death");
  self endon("end_hit_message");
  for (;;) {
    bulletTraced = undefined;

    self waittill("weapon_fired");
    fwd = self getTagOrigin("tag_eye");
    end = vector_scale(anglestoforward(self getPlayerAngles()), 1000000);
    bulletLocation = BulletTrace(fwd, end, false, self)["position"];

    foreach(player in level.players) {
      if ((player == self) || (!isAlive(player)) || (level.teamBased && self.pers["team"] == player.pers["team"]))
        continue;
      if (isDefined(bulletTraced)) {
        if (closer(bulletLocation, player getTagOrigin("tag_eye"), bulletTraced getTagOrigin("tag_eye")))
          bulletTraced = player;
      } else bulletTraced = player;
    }

    realDistance = int(distance(bulletTraced.origin, self.origin) * 0.0254);

    if (is_sniper(self getCurrentWeapon()) && !self isOnGround()) {
      if (distance(bulletTraced.origin, bulletLocation) <= 25) {
        if (!isDefined(self.pers["explosive_bullets"]) || isDefined(self.pers["explosive_bullets"]) && self.pers["explosive_bullets"] == 0)
          self iPrintLnBold("^5You almost hit ^7" + bulletTraced.name + "^5! [^7" + realDistance + " m^5]");
      }
    }
    waitframe();
  }
}

do_radar(type, spawn) {
  if (type == "Normal") {
    self.hasRadar = true;
    self.radarMode = "normal_radar";
		self.radarshowenemydirection = 0;
  } else if (type == "Fast") {
    self.hasRadar = true;
    self.radarMode = "fast_radar";
		self.radarshowenemydirection = 0;
  } else if (type == "Advanced") {
    self.hasRadar = true;
    self.radarMode = "normal_radar";
		self.radarshowenemydirection = 1;
  } else if (type == "Off") {
    self.hasRadar = false;
    self.radarMode = undefined;
		self.radarshowenemydirection = undefined;
  }
  self.pers["do_radar"] = type;
  if (!spawn) {
    self iPrintLn("UAV: ^5" + type);
  }
}

do_ammo() {
  self endon("endreplenish");
  self endon("death");
  while (true) {
    wait 10;
    currentWeapon = self getCurrentWeapon();
    currentoffhand = self GetCurrentOffhand();
    secondaryweapon = self.SecondaryWeapon;
    if (currentWeapon != "none") {
      self GiveMaxAmmo(currentWeapon);
    }
    if (currentoffhand != "none") {
      self setWeaponAmmoClip(currentoffhand, 9999);
      self GiveMaxAmmo(currentoffhand);
    }
    if (secondaryweapon != "none") {
      self GiveMaxAmmo(secondaryweapon);
    }
  }
}

do_round_reset(lim, text) {
  if(isDefined(text))
		self iprintln(text);
	
	if (lim)
    level waittill("game_ended");
  wait 2.5;
  game["roundsWon"]["axis"] = 0;
  game["roundsWon"]["allies"] = 0;
  game["roundsPlayed"] = 0;
  game["teamScores"]["allies"] = 0;
  game["teamScores"]["axis"] = 0;
}

do_teleport_bots(team) {
  for (i = 0; i < level.players.size; i++) {
    if (isSubStr(level.players[i].guid, "bot")) {
      if (team == "allies") {
        if (level.players[i].pers["team"] == self.pers["team"]) {
          level.players[i] setOrigin(get_crosshair());
          level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i] gettagorigin("j_head")));
          waitframe();
          level.players[i].pers["save_position"] = level.players[i].origin;
          level.players[i].pers["save_angles"] = level.players[i].angles;
					level.players[i].pers["saved_location"] = true;
        }
      } else if (team == "axis") {
        if (level.players[i].pers["team"] != self.pers["team"]) {
          level.players[i] setOrigin(get_crosshair());
          level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i] gettagorigin("j_head")));
          waitframe();
          level.players[i].pers["save_position"] = level.players[i].origin;
          level.players[i].pers["save_angles"] = level.players[i].angles;
					level.players[i].pers["saved_location"] = true;
        }
      } else if (team == "All") {
        level.players[i] setOrigin(get_crosshair());
        level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i] gettagorigin("j_head")));
        waitframe();
        level.players[i].pers["save_position"] = level.players[i].origin;
        level.players[i].pers["save_angles"] = level.players[i].angles;
				level.players[i].pers["saved_location"] = true;
      }
    }
  }
}

do_teleport_bots_to_you(team) {
  for (i = 0; i < level.players.size; i++) {
    if (isSubStr(level.players[i].guid, "bot")) {
      if (team == "allies") {
        if (level.players[i].pers["team"] == self.pers["team"]) {
          level.players[i].pers["save_position"] = self.origin;
          level.players[i].pers["save_angles"] = self.angles;
					level.players[i].pers["saved_location"] = true;
          level.players[i] thread do_load_location(level.players[i]);
        }
      } else if (team == "axis") {
        if (level.players[i].pers["team"] != self.pers["team"]) {
          level.players[i].pers["save_position"] = self.origin;
          level.players[i].pers["save_angles"] = self.angles;
					level.players[i].pers["saved_location"] = true;
          level.players[i] thread do_load_location(level.players[i]);
        }
      } else if (team == "all") {
        level.players[i].pers["save_position"] = self.origin;
        level.players[i].pers["save_angles"] = self.angles;
				level.players[i].pers["saved_location"] = true;
        level.players[i] thread do_load_location(level.players[i]);
      }
    }
  }
}

do_freeze_bot(team, freeze) {
  for (i = 0; i < level.players.size; i++) {
    if (isSubStr(level.players[i].guid, "bot")) {
      if (team == "allies") {
        if (level.players[i].pers["team"] == self.pers["team"]) {
          if (isSubStr(level.players[i].guid, "bot")) {
            if (freeze == "Freeze") {
              level.players[i] freezeControls(true);
              level.players[i].pers["freeze"] = true;
            } else if (freeze == "Unfreeze") {
              level.players[i] freezeControls(false);
              level.players[i].pers["freeze"] = false;
            }
          }
        }
      } else if (team == "axis") {
        if (level.players[i].pers["team"] != self.pers["team"]) {
          if (freeze == "Freeze") {
            level.players[i] freezeControls(true);
            level.players[i].pers["freeze"] = true;
          } else if (freeze == "Unfreeze") {
            level.players[i] freezeControls(false);
            level.players[i].pers["freeze"] = false;
          }
        }
      } else if (team == "All") {
        if (freeze == "Freeze") {
          level.players[i] freezeControls(true);
          level.players[i].pers["freeze"] = true;
        } else if (freeze == "Unfreeze") {
          level.players[i] freezeControls(false);
          level.players[i].pers["freeze"] = false;
        }
      }
    }
  }
}

do_tagged_eb(range, client) {
  client endon("end_tag");
  client endon("disconnect");
  for (;;) {
    bulletTraced = undefined;

    client waittill("weapon_fired");
    weaponClass = client getCurrentWeapon();
    fwd = client getTagOrigin("tag_eye");
    end = vector_scale(anglestoforward(client getPlayerAngles()), 1000000);
    bulletLocation = BulletTrace(fwd, end, false, client)["position"];

    foreach(player in level.players) {
      if ((player == client) || (!isAlive(player)) || (level.teamBased && client.pers["team"] == player.pers["team"]))
        continue;
      if (isDefined(bulletTraced)) {
        if (closer(bulletLocation, player getTagOrigin("tag_eye"), bulletTraced getTagOrigin("tag_eye")))
          bulletTraced = player;
      } else bulletTraced = player;
    }

    doDesti = bulletTraced.origin + (0, 0, 40);

    if (client.pers["tag_weapon"] == "All") {
      if (distance(bulletTraced.origin, bulletLocation) <= range)
        bulletTraced thread[[level.callbackPlayerDamage]](client, client, 1, 8, "MOD_RIFLE_BULLET", weaponClass, doDesti, (0, 0, 0), "torso_upper", 0);
    } else {
      if (weaponClass == client.pers["tag_weapon"]) {
        if (distance(bulletTraced.origin, bulletLocation) <= range)
          bulletTraced thread[[level.callbackPlayerDamage]](client, client, 1, 8, "MOD_RIFLE_BULLET", weaponClass, doDesti, (0, 0, 0), "torso_upper", 0);
      }
    }
    waitframe();
  }
}

do_auto_prone() {
  if (self.pers["auto_prone"] == 0) {
    self.pers["auto_prone"] = 1;
    self thread do_prone();
    self iPrintln("Auto Prone: ^5On");
  } else if (self.pers["auto_prone"] == 1) {
    self.pers["auto_prone"] = 0;
    self notify("endprone");
    self iPrintln("Auto Prone: ^5Off");
  }
}

do_prone() {
  self endon("endprone");
  self endon("disconnect");
  level endon("round_end_finished");
  level waittill("game_ended");
  for (;;) {
    self SetStance("prone");
    wait 0.15;
  }
}

do_take_weapon() {
  self.weap = self getCurrentWeapon();
  self takeweapon(self.weap);
}

do_drop_weapon() {
  currentgun = self getcurrentWeapon();
  self dropitem(currentgun);
}

do_empty_clip() {
  weap = self getCurrentWeapon();
  clip = self getWeaponAmmoClip(weap);
  self SetWeaponAmmoClip(weap, clip - 999);
}

do_one_bullet() {
  weap = self getCurrentWeapon();
  self SetWeaponAmmoClip(weap, 1);
}

do_auto_nuke(seconds) {
  self endon("end_nuke");
  level endon("game_ended");
  time = (get_time_limit_float() * 60);
  for (;;) {

    timePassed = (getTime() - level.startTime) / 1000;
    timeRemaining = (time) - timePassed;

    if (timeRemaining <= seconds) {
      maps\mp\h2_killstreaks\_nuke::doNuke();
      return;
    }
    wait 1;
  }
}

do_autoplant(seconds) {
  self endon("end_plant");
  level endon("game_ended");

  time = (get_time_limit_float() * 60);
  for (;;) {

    timePassed = (getTime() - level.startTime) / 1000;
    timeRemaining = (time) - timePassed;

    if (timeRemaining <= seconds) {
      level thread do_plant();
      return;
    }
    wait 1;
  }
}

do_plant(planter) {
  self endon("end_plant");
  if (!level.bombplanted) {
    foreach(player in level.players) {
      if (player.team == game["attackers"] && isAlive(player)) {
        planter = player;
      }
    }
    random = randomIntRange(0, 2);
    level.bombzones[random] scripts\mp\_retropack_hooks::onuseplantobject_(planter, true, random);
  }
}

do_defuse_on_death() {
  level endon("game_ended");
  self endon("end_defuse");
  gameFlagWait("prematch_done");
  while (is_attacker_alive())
    wait 0.05;

  wait 1;

  if (level.bombplanted) {
    for (bomb = 0; bomb < level.bombzones.size; bomb++) {
      level.bombzones[bomb] maps\mp\gametypes\common_sd_sr::onusedefuseobject(self);
    }
  }
}

do_pause_timer() {
  if (self.pausetimer == 0) {
    self.pausetimer = 1;
    self iPrintln("Game Timer: ^5Paused");
    self maps\mp\gametypes\_gamelogic::pauseTimer();
  } else if (self.pausetimer == 1) {
    self.pausetimer = 0;
    self iPrintln("Game Timer: ^5Resumed");
    self maps\mp\gametypes\_gamelogic::resumeTimer();
  }
}

do_reset_scores(value, player) {
  player notify("endLast");

  if (getDvar("g_gametype") == "dm") {
    player.score = value;
    player.pers["score"] = value;
    player.kills = value;
    player.pers["kills"] = value;
    maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
  } else if (getDvar("g_gametype") == "war") {
    setTeamScore(player.team, value);
    player.kills = value;
    player.score = value * 100;
    game["teamScores"][player.team] = value;
    maps\mp\gametypes\_gamescore::sendupdatedteamscores();
  }

  if (player != self) {
    self iprintln(sanitise_name(player.name) + "'s Score: ^5" + value);
    player iprintln("Score: ^5" + value + " ^7set by ^5" + sanitise_name(self.name));
  } else {
    self iprintln("Score: ^5" + value);
  }
}

do_fast_last(client) {
  if (getDvar("g_gametype") == "dm") {
    if (client in_menu())
      client close_menu();
    level notify("on_close_ended");
    level endon("on_close_ended");
    scoreLim = getwatcheddvar("scorelimit") - 1;
    client.score = scoreLim;
    client.pers["score"] = scoreLim;
    client.kills = scoreLim;
    client.pers["kills"] = scoreLim;
    client freezeControls(true);
    client.twopiece = true;
    client notify("endLast");
	client iPrintlnBold("[^5" + scoreLim + "^7/^5" + (scoreLim + 1) + "^7]");
    if (client != self) {
      self iprintln("Fast Last: ^5set for ^7" + sanitise_name(client.name));
      client iprintln("Fast Last: ^5set by ^7" + sanitise_name(self.name));
    } else {
      self iprintln("Fast Last: ^5Set");
    }
    wait 2;
    client freezeControls(false);
    maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
  } else if (getDvar("g_gametype") == "war") {
    if (client in_menu())
      client close_menu();
    level notify("on_close_ended");
    level endon("on_close_ended");
    wait 0.05;
    scoreLim = getwatcheddvar("scorelimit") - 1;
    setTeamScore(client.team, scoreLim);
    client.kills = scoreLim;
    client.score = scoreLim * 100;
    game["teamScores"][client.team] = scoreLim;
    client.twopiece = true;
    client notify("endLast");
    maps\mp\gametypes\_gamescore::sendupdatedteamscores();
    if (client != self) {
      self iprintln("Fast Last: ^5set for ^7" + sanitise_name(client.name));
      client iprintln("Fast Last: ^5set by ^7" + sanitise_name(self.name));
    } else {
      self iprintln("Fast Last: ^5Set");
    }
    foreach(player in level.players) {
      if (player.pers["team"] == client.pers["team"]) {
        player freezeControls(true);
	    player iPrintlnBold("[^5" + scoreLim + "^7/^5" + (scoreLim + 1) + "^7]");
        wait 2;
        player freezeControls(false);
      }
    }
  } else {
    client iPrintln("^1This gamemode is NOT supported for Fast Last");
    client.twopiece = undefined;
    return;
  }
  waitframe();
}

do_bots_aim() {
  self endon("disconnect");
  self endon("endShoot");
  level endon("endShoot_");
  level endon("game_ended");
  for (;;) {
    waitframe();
    aimAt = undefined;
    foreach(player in level.players) {
      if ((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || (!isAlive(player)))
        continue;
      if (isDefined(aimAt)) {
        if (closer(self getTagOrigin("j_hip_le"), player getTagOrigin("j_hip_le"), aimAt getTagOrigin("j_hip_le")))
          aimAt = player;
      } else
        aimAt = player;
    }
    if (isDefined(aimAt)) {
      self setplayerangles(VectorToAngles((aimAt getTagOrigin("j_hip_le")) - (self getTagOrigin("j_hip_le"))));
    }
  }
}

do_afterhit_weap() {
  self endon("end_afterhit_weap");
  self endon("disconnect");
  for (;;) {
    if (self.pers["afterhit_frequency"] == "Every Shot")
      self waittill("weapon_fired");
    else if (self.pers["afterhit_frequency"] == "End of Game")
      level waittill("game_ended");

		weapon = undefined;
		if(self.pers["afterhit_weapon"] == "All")
			weapon = self getCurrentWeapon();
		else
			weapon = self.pers["afterhit_weapon"];
		
    if (!isDefined(self.pers["afterhit_type"]))
      return;

		if(self getCurrentWeapon() == weapon) {
			if (self.pers["afterhit_type"] == "Animation") {
				waitframe();
				self force_play_weap_anim(self.pers["afterhit_value"], self.pers["afterhit_value"]);
			} else if (self.pers["afterhit_type"] == "Weapon") {
				if (isDefined(self.pers["explosive_bullets"]) && self.pers["explosive_bullets"] != 0) {
					waitframe();
				}
				self takeweapon(weapon);
				self giveweapon(self.pers["afterhit_value"]);
				self switchtoweapon(self.pers["afterhit_value"]);
				waitframe();
				self giveweapon(weapon);
				wait 4;
				self switchtoweapon(weapon);
				wait 1;
				self takeweapon(self.pers["afterhit_value"]);
			} else if (self.pers["afterhit_type"] == "Function") {
				waitframe();
				self thread[[self.pers["afterhit_value"]]]();
			} else if (self.pers["afterhit_type"] == "Nac") {
				wait get_nac_time(weapon, self maps\mp\_utility::_hasPerk("specialty_fastreload"));
				self takeweapon(weapon);
				waitframe();
				self giveweapon(self.pers["afterhit_value"]);
				self switchtoweapon(self.pers["afterhit_value"]);
				waitframe();
				self giveweapon(weapon);
			} else if (self.pers["afterhit_type"] == "Pred Knife") {
				wait get_nac_time(weapon, self maps\mp\_utility::_hasPerk("specialty_fastreload"));
				self takeweapon(weapon);
				waitframe();
				self giveweapon(self.pers["afterhit_value"]);
				self switchtoweapon(self.pers["afterhit_value"]);
				wait 0.15;
				self force_play_weap_anim(2, 2);
				wait 0.05;
				self force_play_weap_anim(12, 2);
				self giveweapon(weapon);
			} else if (self.pers["afterhit_type"] == "Fast Pred") {
				wait get_nac_time(weapon, self maps\mp\_utility::_hasPerk("specialty_fastreload"));
				self takeweapon(weapon);
				waitframe();
				self giveweapon(self.pers["afterhit_value"]);
				self switchtoweapon(self.pers["afterhit_value"]);
				wait 0.15;
				self force_play_weap_anim(2, 2);
				self giveweapon(weapon);
			}
		}
    waitframe();
  }
}

/* 
	Set()
*/

set_class_save() {
  weaponsList = self getWeaponsListAll();
  for (i = 0; i < 10; i++) {
    self.pers["rp_class_storage_" + i] = undefined;
  }
  waitframe();
  for (i = 0; i < weaponsList.size; i++) {
    self.pers["rp_class_storage_" + i] = weaponsList[i];

    class = maps\mp\_utility::getclassindex(self.curclass);

    if (getDvar("g_gametype") == "dm" || getDvar("g_gametype") == "war") {
      if (isDefined(self.pers["tk_tact"]) && self.pers["tk_tact"]) {
        if (self.pers["rp_class_storage_" + i] == "iw9_throwknife_mp" ||
          self.pers["rp_class_storage_" + i] == "specialty_tacticalinsertion")
          self.pers["rp_class_storage_" + i] = maps\mp\gametypes\_class::cac_getequipment(class, 0);
      }
    }
  }
  self.pers["rp_class_storage_last"] = maps\mp\h2_killstreaks\_common::getLastWeaponWrapper();
}

set_class_load(spawn) {
  if (isDefined(self.pers["rp_class_storage_last"])) {
    self takeallweapons();
    waitframe();
    for (i = 0; i < 10; i++) {
      if (!is_equipment(self.pers["rp_class_storage_" + i]) && !is_offhand(self.pers["rp_class_storage_" + i])) {
        self GiveWeapon(self.pers["rp_class_storage_" + i]);
        self GiveMaxAmmo(self.pers["rp_class_storage_" + i]);
      } else if (is_equipment(self.pers["rp_class_storage_" + i])) {
        if (self.pers["rp_class_storage_" + i] == "specialty_tacticalinsertion") {
          self.pers["rp_class_storage_" + i] = "flare_mp";
        }
        if (self.pers["rp_class_storage_" + i] == "specialty_blastshield") {
          self maps\mp\_utility::giveperk("specialty_blastshield");
          self.pers["set_specialty_blastshield"] = true;
        }
        self setlethalweapon(self.pers["rp_class_storage_" + i]);
        self giveweapon(self.pers["rp_class_storage_" + i]);
        self GiveMaxAmmo(self.pers["rp_class_storage_" + i]);
      } else if (is_offhand(self.pers["rp_class_storage_" + i])) {
        self settacticalweapon(self.pers["rp_class_storage_" + i]);
        maps\mp\gametypes\_class::giveoffhand(self.pers["rp_class_storage_" + i]);
        if (self.pers["rp_class_storage_" + i] == "h1_flashgrenade_mp" || self.pers["rp_class_storage_" + i] == "h1_concussiongrenade_mp")
          self setweaponammoclip(self.pers["rp_class_storage_" + i], 2);
        else
          self setweaponammoclip(self.pers["rp_class_storage_" + i], 1);
      }
    }
    waitframe();
    self SwitchToWeapon(self.pers["rp_class_storage_last"]);
  }
}

set_bots_aim() {
  self endon("endShoot");
  level endon("endShoot_");
  self endon("disconnect");
  for (i = 0; i < level.players.size; i++) {
    if (level.players[i].pers["team"] != self.pers["team"]) {
      if (isSubStr(level.players[i].guid, "bot")) {
        level.players[i] thread do_bots_aim();
      }
    }
  }
}

set_overkill_classes(type) {
  for (i = 0; i < 15; i++) {
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", i, "name", sanitise_name(self.name) + " ^5Overkill");

    if (type == "Snipers") {
      self setCacPlayerData(i, "weaponSetups", 1, "weapon", random_sniper());
      self setCacPlayerData(i, "weaponSetups", 1, "camo", random_camo(false));
      self setCacPlayerData(i, "weaponSetups", 1, "kit", "attachKit", scripts\mp_patches\custom_weapons::furniturekitnametoid(random_kit(random_sniper() + "_mp")));
      self setCacPlayerData(i, "weaponSetups", 1, "kit", "furnitureKit", scripts\mp_patches\custom_weapons::furniturekitnametoid(random_kit(random_sniper() + "_mp")));
    } else if (type == "AR") {
      self setCacPlayerData(i, "weaponSetups", 1, "weapon", random_ar());
      self setCacPlayerData(i, "weaponSetups", 1, "camo", random_camo(false));
      self setCacPlayerData(i, "weaponSetups", 1, "kit", "attachKit", scripts\mp_patches\custom_weapons::furniturekitnametoid(random_kit(random_ar() + "_mp")));
      self setCacPlayerData(i, "weaponSetups", 1, "kit", "furnitureKit", scripts\mp_patches\custom_weapons::furniturekitnametoid(random_kit(random_ar() + "_mp")));
    } else if (type == "SMG") {
      self setCacPlayerData(i, "weaponSetups", 1, "weapon", random_smg());
      self setCacPlayerData(i, "weaponSetups", 1, "camo", random_camo(false));
      self setCacPlayerData(i, "weaponSetups", 1, "kit", "attachKit", scripts\mp_patches\custom_weapons::furniturekitnametoid(random_kit(random_smg() + "_mp")));
      self setCacPlayerData(i, "weaponSetups", 1, "kit", "furnitureKit", scripts\mp_patches\custom_weapons::furniturekitnametoid(random_kit(random_smg() + "_mp")));
    }
  }
  self iPrintln("^5RETROPACK: ^7Random " + type + " Overkill Classes Set");
}

set_coloured_classes() {
  if (!self.colouredClasses) {
    self.colouredClasses = true;
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 0, "name", "^1" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 1, "name", "^2" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 2, "name", "^3" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 3, "name", "^4" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 4, "name", "^5" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 5, "name", "^6" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 6, "name", "^7" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 7, "name", "^8" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 8, "name", "^9" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 9, "name", "^2" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 10, "name", "^3" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 11, "name", "^4" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 12, "name", "^5" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 13, "name", "^6" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", 14, "name", "^7" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 0, "name", "^1" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 1, "name", "^2" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 2, "name", "^3" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 3, "name", "^4" + sanitise_name(self.name));
    self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", 4, "name", "^5" + sanitise_name(self.name));
    self iPrintLn("^1C^2O^3L^4O^5U^6R^7E^8D ^9C^1L^2A^3S^5S ^6N^7A^8M^9E^1S ^2S^3E^4T");
  } else if (self.colouredClasses) {
    self.colouredClasses = false;
    for (i = 0; i < 15; i++) {
      self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "customClasses", i, "name", "Custom Slot " + (i + 1));
      self setplayerdata(common_scripts\utility::getstatsgroup_private(), "privateMatchCustomClasses", i, "name", "Custom Slot " + (i + 1));
    }
    self iPrintln("b o r i n g class names set");
  }
}

set_prestige(prestige, experience) {
  if (prestige == "rank_comm" || prestige == 0)
    prestige = 0;
  else if (prestige == "h2m_rank_prestige1" || prestige == 1)
    prestige = 1;
  else if (prestige == "h2m_rank_prestige2" || prestige == 2)
    prestige = 2;
  else if (prestige == "h2m_rank_prestige3" || prestige == 3)
    prestige = 3;
  else if (prestige == "h2m_rank_prestige4" || prestige == 4)
    prestige = 4;
  else if (prestige == "h2m_rank_prestige5" || prestige == 5)
    prestige = 5;
  else if (prestige == "h2m_rank_prestige6" || prestige == 6)
    prestige = 6;
  else if (prestige == "h2m_rank_prestige7" || prestige == 7)
    prestige = 7;
  else if (prestige == "h2m_rank_prestige8" || prestige == 8)
    prestige = 8;
  else if (prestige == "h2m_rank_prestige9" || prestige == 9)
    prestige = 9;
  else if (prestige == "h2m_rank_prestige10" || prestige == 10)
    prestige = 10;
  else if (prestige == "h2m_cheytac_ui" || prestige == 11)
    prestige = 11;

  self maps\mp\gametypes\_persistence::statset("experience", 0);
  self maps\mp\gametypes\_persistence::statset("prestige", 0);
  self maps\mp\gametypes\_rank::giverankxp(undefined, -99999999, undefined, undefined, false);
  waitframe();
  self maps\mp\gametypes\_rank::giverankxp(undefined, experience, undefined, undefined, false);
  self maps\mp\gametypes\_persistence::statset("experience", experience);
  self maps\mp\gametypes\_persistence::statset("prestige", prestige);
  if (prestige == 0 && experience == 0)
    self iPrintLn("^5" + sanitise_name(self.name) + "^7: ^5Deranked");
  else
    self iPrintLn("^5" + sanitise_name(self.name) + "^7: ^5Prestige " + prestige);

  wait 1.5;
  setDvar("xblive_privatematch", 1);
  exitLevel(0);
}

set_challenges() {
  self endon("disconnect");
  self endon("death");
  self.pers["god_mode"] = true;
  chalProgress = 0;
  useBar = createPrimaryProgressBar(25);
	if (self in_menu())
		self close_menu();
  foreach(challengeRef, challengeData in level.challengeInfo) {
    finalTarget = 0;
    finalTier = 0;
    for (tierId = 1; isDefined(challengeData["targetval"][tierId]); tierId++) {
      finalTarget = challengeData["targetval"][tierId];
      finalTier = tierId + 1;
    }
    if (self isItemUnlocked(challengeRef)) {
      self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "challengeProgress", challengeRef, finalTarget);
      self setplayerdata(common_scripts\utility::getstatsgroup_ranked(), "challengeState", challengeRef, finalTier);
    }
    chalProgress++;
    chalPercent = ceil(((chalProgress / level.challengeInfo.size) * 100));
    useBar updateBar(chalPercent / 100);
    waitframe();
  }
  self maps\mp\gametypes\_rank::giverankxp(undefined, 99999999, undefined, undefined, false);
  self maps\mp\gametypes\_persistence::statset("experience", 99999999);
  self maps\mp\gametypes\_persistence::statset("prestige", 10);
  useBar destroyElem();
  self iPrintLnBold("Unlock All Completed");
  wait 1.5;
  self.pers["god_mode"] = false;
  setDvar("xblive_privatematch", 1);
  exitLevel(0);
}

set_team_forced(team) {
  self waittill_any("joined_team");
  waitframe();
  self.pers["forced_team"] = team;
  self maps\mp\gametypes\_menus::addToTeam(team, true);
}

set_raise_type(type) {
	self.pers["raise_type"] = type;
	if ( isDefined(self.pers["do_raise"]) ) {
		self notify("end_insta");
		self thread monitor_weapon_change();
	}
	self iPrintln("Always Raise Type: ^5" + type);
}

set_afterhit_type(type) {
  self.pers["afterhit_frequency"] = type;
  if (isDefined(self.pers["afterhit_frequency"])) {
    self notify("end_afterhit_weap");
    self thread do_afterhit_weap();
  }
  self iPrintln("Afterhit Frequency: ^5" + type);
}

set_afterhit(type, value, text, id) {
  self.pers["afterhit_type"] = type;
  self.pers["afterhit_value"] = value;

  if (!isDefined(self.pers["afterhit_option_" + id]) || id == "weapon" || isDefined(self.pers["afterhit_option_" + id]) && !self.pers["afterhit_option_" + id]) {
    self.pers["afterhit_option_" + id] = true;
  } else {
    self.pers["afterhit_option_" + id] = false;
    self.pers["afterhit_type"] = undefined;
    self.pers["afterhit_value"] = undefined;
    self.pers["do_afterhit"] = false;
    text = "Off";
  }

  foreach(index, afterhit in ["weapon", "lunge", "melee", "sprint", "mantle", "cp_nac", "laptop_nac", "laptop_nac_fast", "laptop_nac_lunge"]) {
    if (afterhit == id)
      continue;

    self.pers["afterhit_option_" + afterhit] = false;
  }

  self iPrintln("Afterhit Type: ^5" + text);
}

/* 
	Retro Package: Rank Spoofer
*/

spoof_rank(value, player, spawn) {
  if (!spawn) {
    if (player != self) {
      self iprintln("Spoof " + sanitise_name(player.name) + "'s Rank: ^5" + value);
      player iprintln("Spoof Rank: ^5" + value + " ^7via " + sanitise_name(self.name));
    } else {
      self iprintln("Spoof Rank: ^5" + value);
    }
  }

  player.pers["spoof_rank_one"] = undefined;
  if (value == 70) {
    value = 69;
    player.pers["spoof_rank_one"] = undefined;
  } else if (value == 1) {
    value = 0;
    player.pers["spoof_rank_one"] = true;
  } else {
    value--;
    player.pers["spoof_rank_one"] = undefined;
  }
  player.pers["rank"] = value;
  player.pers["spoof_rank"] = value;
  player setrank(value);
  player setclientomnvar("ui_player_xp_rank", value);
}

spoof_prestige(value, player, spawn) {
  rank = undefined;
  realvalue = undefined;
  if (value == "rank_comm" || value == 0) {
    realvalue = 0;
    player.pers["spoof_rank"] = 69;
  } else if (value == "h2m_rank_prestige1" || value == 1)
    realvalue = 1;
  else if (value == "h2m_rank_prestige2" || value == 2)
    realvalue = 2;
  else if (value == "h2m_rank_prestige3" || value == 3)
    realvalue = 3;
  else if (value == "h2m_rank_prestige4" || value == 4)
    realvalue = 4;
  else if (value == "h2m_rank_prestige5" || value == 5)
    realvalue = 5;
  else if (value == "h2m_rank_prestige6" || value == 6)
    realvalue = 6;
  else if (value == "h2m_rank_prestige7" || value == 7)
    realvalue = 7;
  else if (value == "h2m_rank_prestige8" || value == 8)
    realvalue = 8;
  else if (value == "h2m_rank_prestige9" || value == 9)
    realvalue = 9;
  else if (value == "h2m_rank_prestige10" || value == 10)
    realvalue = 10;
  else if (value == "h2m_cheytac_ui" || value == 11)
    realvalue = 11;
  else if (value == "em_st_180" || value == 1000)
    realvalue = "Master";

  if (!spawn) {
    if (player != self) {
      self iprintln("Spoof " + sanitise_name(player.name) + "'s Prestige: ^5" + realvalue);
      player iprintln("Spoof Prestige: ^5" + realvalue + " ^7via " + sanitise_name(self.name));
    } else {
      self iprintln("Spoof Prestige: ^5" + realvalue);
    }
  }

  if (realvalue != "Master") {
    if (!isDefined(player.pers["spoof_rank"]))
      rank = 69;
    if (isDefined(player.pers["spoof_rank"])) {
      if (player.pers["spoof_rank"] == 0)
        rank = 2;
      else
        rank = player.pers["spoof_rank"];
    }
    rank--;
    player.pers["prestige"] = realvalue;
    player.pers["spoof_prestige"] = value;
    player setclientomnvar("ui_player_xp_prestige", realvalue);
    player.pers["rank"] = rank;
    player setclientomnvar("ui_player_xp_rank", rank);
    player setrank(rank, realvalue);
    waitframe();
    if (isDefined(player.pers["spoof_rank_one"]))
      rank = 0;
    else
      rank++;
    player.pers["rank"] = rank;
    player setclientomnvar("ui_player_xp_rank", rank);
    player setrank(rank);
  } else {
    player.pers["prestige"] = 10;
    player.pers["spoof_prestige"] = "em_st_180";
    player setclientomnvar("ui_player_xp_prestige", 10);
    player.pers["rank"] = 999;
    player setclientomnvar("ui_player_xp_rank", 999);
    player setrank(999, 10);
  }
}

spoof_xp_bar(value, player, spawn) {
  if (value == 0)
    value = 0.001;
  player.pers["spoof_progress"] = true;
  player setclientomnvar("ui_player_xp_pct", value / 100);
  if (value == 0.001)
    value = 0;

  if (!spawn)
    player iprintln("Spoof XP Bar: ^5" + value + " percent");
}

spoof_bot_level(team) {
  self endon("LevelFinish");
  while (true) {
    for (i = 0; i < level.players.size; i++) {
      if (isSubStr(level.players[i].guid, "bot")) {
        if (team == "allies") {
          if (level.players[i].pers["team"] == self.pers["team"]) {
            level.players[i] spoof_prestige(random_prestige(), level.players[i]);
            waitframe();
            level.players[i] spoof_rank(randomIntRange(1, 71), level.players[i]);
          }
        } else if (team == "axis") {
          if (level.players[i].pers["team"] != self.pers["team"]) {
            level.players[i] spoof_prestige(random_prestige(), level.players[i]);
            waitframe();
            level.players[i] spoof_rank(randomIntRange(1, 71), level.players[i]);
          }
        } else if (team == "All") {
          level.players[i] spoof_prestige(random_prestige(), level.players[i]);
          waitframe();
          level.players[i] spoof_rank(randomIntRange(1, 71), level.players[i]);
        }
      }
    }
    waitframe();
  }
}

/* 
	Retro Package: Class Creator
*/

select_offhand_rp(offhand, shader) {
  sep = strTok(offhand, ";");

  self.pers["cacOffHandName"] = sep[1];
  self.pers["cacOffHand"] = sep[0];
  if (offhand == "None" || offhand == "none" || !isDefined(offhand) || offhand == "") {
    self.pers["cacOffHandName"] = undefined;
    self.pers["cacOffHand"] = undefined;
	self iPrintLn("^5RETROPACK: ^7Nothing selected as Off-hand");
  } else
    self iPrintLn("^5RETROPACK: ^7" + sep[1] + " selected as Off-hand");
}

select_equipment_rp(equipment, shader) {
  sep = strTok(equipment, ";");

  self.pers["cacEquipmentName"] = sep[1];
  self.pers["cacEquipmentShader"] = shader;
  self.pers["cacEquipment"] = sep[0];
  if (equipment == "None" || equipment == "none" || !isDefined(equipment) || equipment == "") {
    self.pers["cacEquipmentShader"] = undefined;
    self iPrintLn("^5RETROPACK: ^7Nothing selected as Equipment");
  } else
    self iPrintLn("^5RETROPACK: ^7" + sep[1] + " selected as Equipment");
}

select_attachment_rp(attachment, type, shader) {
  if (isDefined(self.pers["cac" + type + "Attachment2Shader"]))
    self.pers["cac" + type + "Attachment2Shader"] = undefined;
  if (isDefined(self.pers["cac" + type + "Attachment2ShaderX"]))
    self.pers["cac" + type + "Attachment2ShaderX"] = undefined;
  if (isDefined(self.pers["cac" + type + "Attachment2ShaderY"]))
    self.pers["cac" + type + "Attachment2ShaderY"] = undefined;
  if (isDefined(self.pers["cac" + type + "Attachment2"]))
    self.pers["cac" + type + "Attachment2"] = undefined;
  if (isDefined(self.pers["cac" + type + "Attachment2Name"]))
    self.pers["cac" + type + "Attachment2Name"] = undefined;
  if (isDefined(self.pers["cac" + type + "Attachment2Console"]))
    self.pers["cac" + type + "Attachment2Console"] = undefined;
  self.pers["cac" + type + "Attachment2"] = scripts\mp_patches\custom_weapons::furniturekitnametoid(attachment);
  self.pers["cac" + type + "Attachment2Name"] = get_localised_attachment(attachment);
  self.pers["cac" + type + "Attachment2Console"] = attachment;
  self.pers["cac" + type + "Attachment2Shader"] = shader;
  self.pers["cac" + type + "Attachment2ShaderX"] = 12;
  self.pers["cac" + type + "Attachment2ShaderY"] = 12;

  if (attachment == "None" || attachment == "none" || !isDefined(attachment) || attachment == "") {
    self.pers["cac" + type + "Attachment2Shader"] = undefined;
    self.pers["cac" + type + "Attachment2ShaderX"] = undefined;
    self.pers["cac" + type + "Attachment2ShaderY"] = undefined;
    self iPrintLn("^5RETROPACK: ^7Nothing selected as 2nd attachment");
  } else
    self iPrintLn("^5RETROPACK: ^7" + get_localised_attachment(attachment) + " selected as 2nd attachment");
}

give_camo_rp(camo) {
  sep = strTok(camo, ";");
  current_weapon = self getcurrentweapon();
  weapon = detach_camo(current_weapon);
  if (sep[0] == "None" || !isDefined(sep[0]) || sep[0] == "") {
    new_weapon = weapon;
  } else {
    new_weapon = maps\mp\gametypes\_class::buildweaponnamecamo(weapon, int(tablelookup("mp/camoTable.csv", 1, sep[0], 0)));
  }
  self takeweapon(current_weapon);
  self giveweapon(new_weapon);
  self switchtoweapon(new_weapon);
  self iprintln("Camo Set: ^5" + get_localised_camo("_" + sep[0]));
}

select_camo_rp(camo, type) {
  sep = strTok(camo, ";");
  if (sep[0] == "None" || !isDefined(sep[0])) {
    self.pers["cac" + type + "Camo"] = undefined;
    self.pers["cac" + type + "CamoID"] = undefined;
    self.pers["cac" + type + "CamoName"] = undefined;
  } else {
    self.pers["cac" + type + "Camo"] = sep[0];
    self.pers["cac" + type + "CamoID"] = int(tablelookup("mp/camoTable.csv", 1, sep[0], 0));
    self.pers["cac" + type + "CamoName"] = get_localised_camo("_" + sep[0]);
  }

  self.pers["cac" + type + "CamoShader"] = undefined;
  self.pers["cac" + type + "CamoShaderX"] = undefined;
  self.pers["cac" + type + "CamoShaderY"] = undefined;
  self.pers["cac" + type + "CamoShader"] = sep[1];
  self.pers["cac" + type + "CamoShaderX"] = 12;
  self.pers["cac" + type + "CamoShaderY"] = 12;
  
  if (sep[0] == "None" || sep[0] == "none" || !isDefined(sep[0]) || sep[0] == "") {
    self iPrintLn("^5RETROPACK: ^7Nothing selected as Camo");
    self.pers["cac" + type + "CamoShader"] = undefined;
    self.pers["cac" + type + "CamoShaderX"] = undefined;
    self.pers["cac" + type + "CamoShaderY"] = undefined;
  } else
    self iPrintLn("^5RETROPACK: ^7" + get_localised_camo("_" + self.pers["cac" + type + "Camo"]) + " selected as " + type + " Camo");
}

select_perk_rp(perk, name, num) {
  if (perk == "None") {
    self.pers["cacPerk" + num] = undefined;
    self.pers["cacPerkName" + num] = undefined;
    return;
  } else {
    self.pers["cacPerk" + num] = perk;
    self.pers["cacPerkName" + num] = name;
  }
  if (perk == "none")
    self iPrintLn("^5RETROPACK: ^7Nothing selected as Perk");
  else
    self iPrintLn("^5RETROPACK: ^7" + name + " selected as Perk " + num);
}

select_weapon_rp(weapon, type, name, shader, x, y) {
  sep = strTok(weapon, ";");

  if (isDefined(self.pers["rp_storage_2_Weapons"]) && self.pers["rp_storage_2_Weapons"] == "Afterhit") {
    new_weapon = detach_camo(sep[0]) + "_camo0" + randomIntRange(10, 20);
    self thread set_afterhit("Weapon", new_weapon, "^5Weapon ^7(^5" + getWeaponDisplayName(sep[0]) + "^7)", "weapon");

    return;
  }

  if (weapon == "None") {
    self.pers["cac" + type + "Shader"] = undefined;
	self.pers["cac" + type + "ShaderX"] = undefined;
	self.pers["cac" + type + "ShaderY"] = undefined;
    self.pers["cac" + type + "Base"] = undefined;
    self.pers["cac" + type + "Attachment1"] = undefined;
    self.pers["cac" + type + "Camo"] = undefined;
    self.pers["cac" + type + "Console"] = undefined;
    self.pers["cac" + type + "Name"] = undefined;
    if (isDefined(self.pers["cac" + type + "Attachment2"]))
      self.pers["cac" + type + "Attachment2"] = undefined;
    if (isDefined(self.pers["cac" + type + "Attachment2Name"]))
      self.pers["cac" + type + "Attachment2Name"] = undefined;
    if (isDefined(self.pers["cac" + type + "Attachment2Console"]))
      self.pers["cac" + type + "Attachment2Console"] = undefined;
    if (isDefined(self.pers["cac" + type + "Camo"]))
      self.pers["cac" + type + "Camo"] = undefined;
    if (isDefined(self.pers["cac" + type + "CamoID"]))
      self.pers["cac" + type + "CamoID"] = undefined;
    if (isDefined(self.pers["cac" + type + "CamoName"]))
      self.pers["cac" + type + "CamoName"] = undefined;
    if (isDefined(self.pers["cac" + type + "Attachment2Shader"]))
      self.pers["cac" + type + "Attachment2Shader"] = undefined;
    if (isDefined(self.pers["cac" + type + "CamoShader"]))
      self.pers["cac" + type + "CamoShader"] = undefined;
  
    self iPrintLn("^5RETROPACK: ^7Nothing selected as weapon");

    return;
  }

  sep = strTok(weapon, ";");

  if (sep[1] == "No Attachments" || is_launcher(sep[0]) || is_knife(sep[0]))
    fullName = name;
  else
    fullName = name + " " + sep[1];

  self.pers["cac" + type + "Base"] = undefined;
  self.pers["cac" + type + "Attachment1"] = undefined;
  self.pers["cac" + type + "Attachment1Console"] = undefined;
  self.pers["cac" + type + "Attachment1Shader"] = undefined;
  self.pers["cac" + type + "Camo"] = undefined;
  self.pers["cac" + type + "CamoID"] = undefined;
  self.pers["cac" + type + "Console"] = undefined;
  self.pers["cac" + type + "Name"] = undefined;
  self.pers["cac" + type + "Attachment2"] = undefined;
  self.pers["cac" + type + "Attachment2Name"] = undefined;
  self.pers["cac" + type + "Attachment2Console"] = undefined;
  self.pers["cac" + type + "Camo"] = undefined;
  self.pers["cac" + type + "CamoID"] = undefined;
  self.pers["cac" + type + "CamoName"] = undefined;

  self.pers["cac" + type + "Base"] = getbaseweaponname(weapon);
  self.pers["cac" + type + "Attachment1"] = maps\mp\gametypes\_class::attachkitnametoid(extract_attachment(weapon) == "acog" ? "acogh2" : extract_attachment(weapon));
  self.pers["cac" + type + "Attachment1Console"] = extract_attachment(weapon);
  self.pers["cac" + type + "Attachment1Shader"] = get_attachment(extract_attachment(weapon));
  self.pers["cac" + type + "Console"] = sep[0];
  self.pers["cac" + type + "Name"] = fullName;
  self.pers["cac" + type + "Shader"] = shader;
  self.pers["cac" + type + "ShaderX"] = x;
  self.pers["cac" + type + "ShaderY"] = y;

  if (is_launcher(self.pers["cac" + type + "Console"])) {
    self.pers["cac" + type + "Attachment1"] = undefined;
    self.pers["cac" + type + "Attachment2"] = undefined;
    self.pers["cac" + type + "Attachment2Name"] = "None";
    self.pers["cac" + type + "Camo"] = undefined;
    self.pers["cac" + type + "CamoID"] = undefined;
    self.pers["cac" + type + "CamoName"] = undefined;
  }
  self iPrintLn("^5RETROPACK: ^7" + getWeaponDisplayName(sep[0]) + " selected as " + type);
}

give_rpclass(spawn) {
  waitframe();
  self takeallweapons();
  maps\mp\gametypes\_class::_detachall();

  //perks
  if (!isDefined(spawn)) {
    table = "mp/perkTable.csv";
    for (i = 1; i < 33; i++) {
      perk = tableLookup(table, 0, i, 1);
      if (!isSubStr(perk, "specialty_"))
        continue;

      if (self maps\mp\_utility::_hasPerk(perk)) {
        self.pers["set_" + perk] = false;
        self maps\mp\_utility::_unsetperk(perk);
      }
    }
  }
  self maps\mp\_utility::giveperk(self.pers["cacPerk1"]);
  self maps\mp\_utility::giveperk(self.pers["cacPerk2"]);
  self maps\mp\_utility::giveperk(self.pers["cacPerk3"]);
  self maps\mp\_utility::giveperk(get_perk_upgrade(self.pers["cacPerk1"]));
  self maps\mp\_utility::giveperk(get_perk_upgrade(self.pers["cacPerk2"]));
  self maps\mp\_utility::giveperk(get_perk_upgrade(self.pers["cacPerk3"]));
  self.pers["set_" + self.pers["cacPerk1"]] = true;
  self.pers["set_" + self.pers["cacPerk2"]] = true;
  self.pers["set_" + self.pers["cacPerk3"]] = true;
  self.pers["set_" + get_perk_upgrade(self.pers["cacPerk1"])] = true;
  self.pers["set_" + get_perk_upgrade(self.pers["cacPerk2"])] = true;
  self.pers["set_" + get_perk_upgrade(self.pers["cacPerk3"])] = true;
  
  waitframe();
  maps\mp\perks\_perks::applyperks();

  //equipment
  if (self.pers["cacEquipment"] == "specialty_tacticalinsertion") {
    self.pers["cacEquipment"] = "flare_mp";
  }
  if (self.pers["cacEquipment"] == "specialty_blastshield") {
    self maps\mp\_utility::giveperk("specialty_blastshield");
    self.pers["set_specialty_blastshield"] = true;
  }
  self setlethalweapon(self.pers["cacEquipment"]);
  self giveweapon(self.pers["cacEquipment"]);
  self GiveMaxAmmo(self.pers["cacEquipment"]);

  //offhand
  self settacticalweapon(self.pers["cacOffHand"]);
  maps\mp\gametypes\_class::giveoffhand(self.pers["cacOffHand"]);
  if (self.pers["cacOffHand"] == "h1_flashgrenade_mp" || self.pers["cacOffHand"] == "h1_concussiongrenade_mp")
    self setweaponammoclip(self.pers["cacOffHand"], 2);
  else
    self setweaponammoclip(self.pers["cacOffHand"], 1);

  //primary
  if (is_launcher(self.pers["cacPrimaryConsole"])) {
    self.pers["cacPrimaryCamo"] = undefined;
    self.pers["cacPrimaryCamoID"] = undefined;
    self.pers["cacPrimaryCamoName"] = undefined;
  }
  primary = scripts\mp_patches\custom_weapons::h2_buildweaponname(self.pers["cacPrimaryBase"] + "_mp", isDefined(self.pers["cacPrimaryAttachment1Console"]) ? self.pers["cacPrimaryAttachment1Console"] : undefined, isDefined(self.pers["cacPrimaryAttachment2Console"]) ? self.pers["cacPrimaryAttachment2Console"] : undefined, isDefined(self.pers["cacPrimaryCamoID"]) ? self.pers["cacPrimaryCamoID"] : undefined);

  maps\mp\_utility::_giveweapon(primary);
  self switchtoweapon(primary);
  self GiveMaxAmmo(primary);

  //secondary
  if (is_launcher(self.pers["cacSecondaryConsole"])) {
    self.pers["cacSecondaryCamo"] = undefined;
    self.pers["cacSecondaryCamoID"] = undefined;
    self.pers["cacSecondaryCamoName"] = undefined;
  }
  secondary = scripts\mp_patches\custom_weapons::h2_buildweaponname(self.pers["cacSecondaryBase"] + "_mp", isDefined(self.pers["cacSecondaryAttachment1Console"]) ? self.pers["cacSecondaryAttachment1Console"] : undefined, isDefined(self.pers["cacSecondaryAttachment2Console"]) ? self.pers["cacSecondaryAttachment2Console"] : undefined, isDefined(self.pers["cacSecondaryCamoID"]) ? self.pers["cacSecondaryCamoID"] : undefined);
  maps\mp\_utility::_giveweapon(secondary);
  self GiveMaxAmmo(secondary);

  maps\mp\_utility::_setactionslot(1, "nightvision");

  if (!isDefined(spawn))
    self iPrintLn("^5RETROPACK: ^7Class Given");
}

set_rpclass(num) {
  num = num - 1;
  self setCacPlayerData(num, "weaponSetups", 0, "weapon", self.pers["cacPrimaryBase"]);
  self setCacPlayerData(num, "weaponSetups", 0, "camo", self.pers["cacPrimaryCamo"]);
  self setCacPlayerData(num, "weaponSetups", 0, "kit", "attachKit", self.pers["cacPrimaryAttachment1"]);
  self setCacPlayerData(num, "weaponSetups", 0, "kit", "furnitureKit", self.pers["cacPrimaryAttachment2"]);
  self setCacPlayerData(num, "weaponSetups", 1, "weapon", self.pers["cacSecondaryBase"]);
  self setCacPlayerData(num, "weaponSetups", 1, "camo", self.pers["cacSecondaryCamo"]);
  self setCacPlayerData(num, "weaponSetups", 1, "kit", "attachKit", self.pers["cacSecondaryAttachment1"]);
  self setCacPlayerData(num, "weaponSetups", 1, "kit", "furnitureKit", self.pers["cacSecondaryAttachment2"]);
  self setCacPlayerData(num, "perkSlots", 0, self.pers["cacPerk1"]);
  self setCacPlayerData(num, "perkSlots", 1, self.pers["cacPerk2"]);
  self setCacPlayerData(num, "perkSlots", 2, self.pers["cacPerk3"]);
  self setCacPlayerData(num, "equipment", 0, self.pers["cacEquipment"]);
  self setCacPlayerData(num, "equipment", 1, self.pers["cacOffHand"]);
  if (is_launcher(self.pers["cacPrimaryConsole"])) {
    self setCacPlayerData(num, "weaponSetups", 0, "camo", "none");
    self setCacPlayerData(num, "weaponSetups", 0, "kit", "attachKit", 0);
    self setCacPlayerData(num, "weaponSetups", 0, "kit", "furnitureKit", 0);
  }
  if (is_launcher(self.pers["cacSecondaryConsole"])) {
    self setCacPlayerData(num, "weaponSetups", 1, "camo", "none");
    self setCacPlayerData(num, "weaponSetups", 1, "kit", "attachKit", 0);
    self setCacPlayerData(num, "weaponSetups", 1, "kit", "furnitureKit", 0);
  }
  self iPrintLn("^5RETROPACK: ^7Saved to Custom Class " + (num + 1));
}