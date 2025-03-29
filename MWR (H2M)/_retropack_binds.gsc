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

#include scripts\mp\_retropack_utility;

#include scripts\mp\_retropack_functions;

/* 
	Bind Utils()
*/

look_at_bot() {
  self endon("lookend");
  foreach(player in level.players)
  if (player is_bot()) {
    self.look = player.origin;
    self setPlayerAngles(vectorToAngles(((self.look)) - (self getTagOrigin("j_head"))));
  }
}

call_binds(player) {
  foreach(index, bind in [
    "damagebuffer",
    "obituary",
    "canswap",
    "zoom",
    "cpnac",
    "prednac",
    "smooth",
    "mantle",
    "running",
    "knifeanim",
    "inspect",
    "cockback",
    "emptymag",
	"emptymag_real",
	"lastbullet",
    "reload",
    "invisible",
    "fastglide",
    "gflip",
    "altswap",
    "doemp",
    "classchange",
    "damage",
    "scavenger",
    "hitmarker",
    "flash",
    "thirdeye",
    "laststand",
    "finalstand",
    "destroytac",
    "omashax",
    "bolt",
    "velocity",
    "stuck",
    "blastshield",
    "painkiller",
    "copycat",
    "vish",
    "repeater",
    "instaswap",
    "nacmod"
  ]) {
    player endon("stop" + bind);
    if (player.pers["bind_" + bind]) {
      player thread[[player.pers["bind_" + bind + "_function"]]](player.pers["bind_" + bind + "_button"], player.pers["bind_" + bind + "_bind"], isDefined(player.pers["bind_" + bind + "_arg"]) ? player.pers["bind_" + bind + "_arg"] : undefined);
    }
  }
}

/* 
	Toggle()
*/

toggle_instaplant() {
  if (self.pers["instaplant"] == 0) {
    self.pers["instaplant"] = 1;
    self thread do_instaplant();
    self iPrintln("Always Insta-Tact Plant: ^5On");
  } else if (self.pers["instaplant"] == 1) {
    self.pers["instaplant"] = 0;
    self notify("end_instaplant");
    self iPrintln("Always Insta-Tact Plant: ^5Off");
  }
}

toggle_reloadnac() {
  if (self.pers["reload_nac"] == 0) {
    self.pers["reload_nac"] = 1;
    self notify("end_reloadnac");
    self thread do_reloadnac();
    self iPrintln("Always Reload Nac: ^5On");
  } else if (self.pers["reload_nac"] == 1) {
    self.pers["reload_nac"] = 0;
    self notify("end_reloadnac");
    self iPrintln("Always Reload Nac: ^5Off");
  }
}

toggle_wildscope() {
  if (self.pers["wildscope"] == 0) {
    self.pers["wildscope"] = 1;
    self.pers["wildscope_lunge"] = 0;
    self notify("end_wildscope");
    self thread do_wildscope(10);
    self iPrintln("Always Wildscope: ^5On");
  } else if (self.pers["wildscope"] == 1) {
    self.pers["wildscope"] = 0;
    self notify("end_wildscope");
    self iPrintln("Always Wildscope: ^5Off");
  }
}

toggle_wildscopelunge() {
  if (self.pers["wildscope_lunge"] == 0) {
    self.pers["wildscope_lunge"] = 1;
    self.pers["wildscope"] = 0;
    self notify("end_wildscope");
    self thread do_wildscope(12);
    self iPrintln("Always Wildscope (Lunge): ^5On");
  } else if (self.pers["wildscope_lunge"] == 1) {
    self.pers["wildscope_lunge"] = 0;
    self notify("end_wildscope");
    self iPrintln("Always Wildscope (Lunge): ^5Off");
  }
}

toggle_rmala() {
  if (self.pers["rmala"] == 0) {
    self.pers["rmala"] = 1;
    self thread do_rmala();
    self iPrintln("Always R-Mala: ^5On");
  } else if (self.pers["rmala"] == 1) {
    self.pers["rmala"] = 0;
    self notify("end_rmala");
    self iPrintln("Always R-Mala: ^5Off");
  }
}

toggle_knife_lunge() {
  if (!isDefined(self.doknifelunge) || !self.doknifelunge) {
    self.doknifelunge = true;
    self.pers["knife_lunge"] = true;
    self thread do_knife_lunge_wrapper();
    self iPrintln("Always Knife Lunge: ^5On");
  } else if (self.doknifelunge) {
    self.doknifelunge = false;
    self.knifelunge = false;
    self.pers["knife_lunge"] = false;
    self notify("lungeend");
    self iPrintln("Always Knife Lunge: ^5Off");
  }
}

/* 
	Bind()
*/

bind_painkiller(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("painkiller", button);
    if (!self in_menu()) {
      self thread maps\mp\perks\_perkfunctions::setCombatHigh();
    }
  }
}

bind_blastshield(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("blastshield", button);
    if (!self in_menu()) {
      if (!isDefined(self.blastShielded)) {
        self.blastShielded = true;
        self scripts\utility::_visionsetnakedforplayer("black_bw", 0.15);
        wait(0.15);
        self thread maps\mp\perks\_perkfunctions::blastshield_overlay();
        self scripts\utility::_visionsetnakedforplayer("", 0);
        self playSoundToPlayer("item_blast_shield_on", self);
      } else {
        self.blastShielded = undefined;
        self scripts\utility::_visionsetnakedforplayer("black_bw", 0.15);
        wait(0.15);
        self notify("remove_blastshield");
        self scripts\utility::_visionsetnakedforplayer("", 0);
        self playSoundToPlayer("item_blast_shield_off", self);
      }
    }
  }
}

bind_fakenac(button, stop, weap) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("smooth", button);
    if (!self in_menu()) {
      current_weapon = self getCurrentWeapon();
      if (!is_sniper(current_weapon)) {
        self iPrintln("This Bind is for ^5Snipers Only");
      } else {
        waitframe();
        self force_play_weap_anim(20);
        wait get_nac_time(current_weapon, false);
        self takeweapon(current_weapon);
        self giveweapon(weap);
        self switchtoweapon(weap);
        waitframe();
        self giveweapon(current_weapon);
      }
    }
  }
}

bind_emptymag_real(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("emptymag_real", button);
    if (!self in_menu()) {
      weap = self getCurrentWeapon();
      clip = self getWeaponAmmoClip(weap);
      self SetWeaponAmmoClip(weap, clip - 999);
    }
  }
}

bind_lastbullet(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("lastbullet", button);
    if (!self in_menu()) {
      weap = self getCurrentWeapon();
      self SetWeaponAmmoClip(weap, 1);
    }
  }
}


bind_animation(button, stop, id) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind(stop, button);
    if (!self in_menu()) {
      self setSpawnWeapon(self getCurrentWeapon());
      self force_play_weap_anim(id, id);
    }
  }
}

bind_fastglide(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("fastglide", button);
    if (!self in_menu()) {
      self setSpawnWeapon(self getCurrentWeapon());
      self force_play_weap_anim(31, 31);
      waitframe();
      self force_play_weap_anim(32, 32);
    }
  }
}

bind_lunge(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("knifeanim", button);
    if (!self in_menu()) {
      self setSpawnWeapon(self getCurrentWeapon());
      self force_play_weap_anim(12, 2);
      waitframe();
      self setSpawnWeapon(self getCurrentWeapon());
    }
  }
}

bind_canzoom(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("zoom", button);
    weapon = self getCurrentWeapon();
    if (!self in_menu())
      self do_can(weapon, true);
  }
}

bind_canswap(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("canswap", button);
    weapon = self getCurrentWeapon();
    if (!self in_menu())
      self do_can(weapon);
  }
}

bind_emp(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("doemp", button);
    if (!self in_menu()) {
      foreach(player in level.players)
      if (isSubStr(player.guid, "bot")) {
        player thread maps\mp\h2_killstreaks\_emp::h2_EMP_Use(0, 0);
      }
    }
  }
}

bind_copycat(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("copycat", button);
    if (!self in_menu()) {
      self playsoundtoplayer("h2_copycat_steal_class", self);
      current_weapon = self getCurrentWeapon();
      self takeweapon(current_weapon);
      self giveweapon(current_weapon);

      if (isDefined(self.copycat_icon))
        self.copycat_icon destroy();

      self.copycat_icon = self maps\mp\gametypes\_hud_util::createIcon("specialty_copycat", 48, 48);
      self.copycat_icon maps\mp\gametypes\_hud_util::setPoint("CENTER", "CENTER", 70, 0);
      self.copycat_icon.archived = true;
	  self.copycat_icon.showinkillcam = 0;
      self.copycat_icon.sort = 1;
      self.copycat_icon.foreground = true;

      waitframe;

      self.copycat_icon fadeOverTime(0.25);
      self.copycat_icon scaleOverTime(0.25, 512, 512);
      self.copycat_icon.alpha = 0;

      wait .25;

      self.copycat_icon destroy();

    }

  }
}

bind_vish(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("vish", button);
    if (!self in_menu()) {
      self.sessionstate = "spectator";
      waitframe();
      self.sessionstate = "playing";
      current_weapon = self getCurrentWeapon();
      self take_weapon_with_ammo(current_weapon);
      self give_weapon_with_ammo();
      weaponsList = self getWeaponsListAll();
      foreach(weap in weaponsList) {
        if (weap != current_weapon)
          self switchToWeapon(current_weapon);
      }
    }
  }
}

bind_repeater(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("repeater", button);
    if (!self in_menu()) {
      self.sessionstate = "spectator";
      waitframe();
      self.sessionstate = "playing";
    }
  }
}

bind_stuck(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("stuck", button);
    if (!self in_menu()) {
      self thread maps\mp\gametypes\_hud_message::stucksplashnotify(false);
    }
  }
}

bind_classchange(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("classchange", button);
    if (!self in_menu()) {
      if (self.pers["class"] == "custom1")
        self do_class_change_bind(2);
      else if (self.pers["class"] == "custom2")
        self do_class_change_bind(3);
      else if (self.pers["class"] == "custom3")
        self do_class_change_bind(4);
      else
        self do_class_change_bind(1);
    }
  }
}

bind_altswap(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("altswap", button);
    if (!self in_menu()) {
      current_weapon = self get_next_weapon();
      usp = "h2_usp_mp";
      self giveWeapon(usp);
      self switchToWeapon(usp);
      wait 0.1;
      self switchToWeapon(current_weapon);
      waitframe();
      self takeWeapon(usp);
    }
  }
}

bind_damage(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("damage", button);
    if (!self in_menu()) {
      self.health = self.maxhealth;
      self thread[[level.OriginalCallbackPlayerDamage]](self, undefined, 1, 0, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0, 0, 0), (0, 0, 0), "j_mainroot", 0);
    }
  }
}

bind_scavenger(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("scavenger", button);
    if (!self in_menu()) {
      self thread maps\mp\gametypes\_weapons::hud_scavenger();
      self playsoundtoplayer("h2_scavenger_pack_pickup", self);
      self setWeaponAmmoClip(self getCurrentWeapon(), 0);
      self setWeaponAmmoStock(self getCurrentWeapon(), 999);
    }
  }
}

bind_hitmarker(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("hitmarker", button);
    if (!self in_menu()) {
      self scripts\mp\patches::updateDamageFeedback_stub("standard");
      self playsoundtoplayer("mp_hit_default", self);
    }
  }
}

bind_flash(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("flash", button);
    if (!self in_menu())
      self thread maps\mp\_flashgrenades::applyFlash(3, 1);
  }
}

bind_thirdeye(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("thirdeye", button);
    if (!self in_menu())
      self thread maps\mp\_flashgrenades::applyFlash(0, 0);
  }
}

bind_laststand(button, stop) {
  self.isLastStand = false;
  self.health = 100;
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("laststand", button);
    if (!self in_menu())
      self do_last_stand();
  }
}

bind_finalstand(button, stop) {
  self.isLastStand = false;
  self.health = 100;
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("finalstand", button);
    if (!self in_menu())
      self do_final_stand();
  }
}

bind_destroytac(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("destroytac", button);
    if (!self in_menu()) {
      foreach(player in level.players)
      if (isSubStr(player.guid, "bot")) {
        self thread maps\mp\_utility::leaderDialogOnPlayer("ti_destroyed");
        self thread maps\mp\gametypes\_hud_message::playerCardSplashNotify("flare_destroyed", player);
      }
    }
  }
}

bind_instaswap(button, stop) { // Project Helios <3 ( circa 2012 )
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("instaswap", button);
    if (!self in_menu()) {
      current_weapon = self getCurrentWeapon();
      next_weapon = self get_next_weapon();
	  waitframe();
      self takeweapon(current_weapon);
      self giveweapon(current_weapon);
      self setSpawnWeapon(next_weapon);
    }
  }
}

bind_nacmod(button, stop) { // Project Helios <3 ( circa 2012 )
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("nacmod", button);
    if (!self in_menu()) {
      current_weapon = self getCurrentWeapon();
      next_weapon = self get_next_weapon();
	  waitframe();
      self take_weapon_with_ammo(current_weapon);
      self switchtoweapon(next_weapon);
	  waitframe();
      self give_weapon_with_ammo();
    }
  }
}

bind_omashax(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("omashax", button);
    if (!self in_menu()) {
      weaponsList = self getWeaponsListAll();
      for (i = 0; i < weaponsList.size; i++) {
        self.shax[i] = weaponsList[i];
      }
      self playlocalsound("foly_onemanarmy_bag3_plr");
      self takeallweapons();
      self maps\mp\perks\_perkfunctions::omaUseBar(2);
      for (i = 0; i < 10; i++) {
        if (is_equipment(self.shax[i])) {
          if (self.shax[i] == "specialty_tacticalinsertion") {
            self.shax[i] = "flare_mp";
          }
          if (self.shax[i] == "specialty_blastshield") {
            self maps\mp\_utility::giveperk("specialty_blastshield");
            self.pers["set_specialty_blastshield"] = true;
          }
          self setlethalweapon(self.shax[i]);
          self giveweapon(self.shax[i]);
          self GiveMaxAmmo(self.shax[i]);
        } else if (is_offhand(self.shax[i])) {
          self settacticalweapon(self.shax[i]);
          maps\mp\gametypes\_class::giveoffhand(self.shax[i]);
          if (self.shax[i] == "h1_flashgrenade_mp" || self.shax[i] == "h1_concussiongrenade_mp")
            self setweaponammoclip(self.shax[i], 2);
          else
            self setweaponammoclip(self.shax[i], 1);
        } else {
          maps\mp\_utility::_giveweapon(self.shax[i]);
        }
      }
      self switchtoweapon(common_scripts\utility::getlastweapon());
      self do_can(common_scripts\utility::getlastweapon(), true);
    }
  }
}

bind_gflip(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("gflip", button);
    if (!self in_menu()) {
      self setStance("prone");
      wait 0.5;
      self setSpawnWeapon(self getCurrentWeapon());
      self force_play_weap_anim(30, 30);
      waitframe();
      self setStance("prone");
      wait 0.275;
      self setStance("stand");
      wait 0.1;
      self force_play_weap_anim(1, 1);
    }
  }
}

bind_damagebuffer(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("damagebuffer", button);
    if (!self in_menu()) {
      self notify("damage_buffer");
    }
  }
}

/* 
	Do()
*/

do_instaplant() {
  self endon("end_instaplant");
  for (;;) {
    self waittill("grenade_pullback", weaponName);
	current_weapon = self getCurrentWeapon();
    if (weaponName == "flare_mp") {
      self force_play_weap_anim(3);
      if (isDefined(self.setSpawnPoint))
        self maps\mp\perks\_perkfunctions::deleteTI(self.setSpawnPoint);

      TIGroundPosition = playerPhysicsTrace(self.TISpawnPosition + (0, 0, 16), self.TISpawnPosition - (0, 0, 2048)) + (0, 0, 1);
      glowStick = spawn("script_model", TIGroundPosition);
      glowStick.angles = self.angles;
      glowStick.team = self.team;
      glowStick.enemyTrigger = spawn("script_origin", TIGroundPosition);
      glowStick thread maps\mp\perks\_perkfunctions::GlowStickSetupAndWaitForDeath(self);
      glowStick.playerSpawnPos = self.TISpawnPosition;
      glowStick.notti = true;

      glowStick thread maps\mp\gametypes\_weapons::createBombSquadModel("weapon_light_stick_tactical_bombsquad", "tag_fire_fx", self);

      self.setSpawnPoint = glowStick;
      self thread maps\mp\perks\_perkfunctions::tactical_respawn();
      self setweaponammoclip("flare_mp", 0);
      wait 0.75;
	  self take_weapon_with_ammo("flare_mp");
      self setSpawnWeapon(current_weapon);
	  self give_weapon_with_ammo();
      self force_play_weap_anim(28, 28);
    }
  }
}

do_wildscope(value) {
  self endon("end_wildscope");
  for (;;) {
    current_weapon = self getCurrentWeapon();
    if (self PlayerADS()) {
      if (is_sniper(current_weapon)) {
        wait 0.2;
        self force_play_weap_anim(value);
        wait 1;
        self force_play_weap_anim(1);
      }
    }
    waitframe();
  }
}

do_rmala() {
  self endon("end_rmala");
  for (;;) {
    self waittill("grenade_pullback");
    self force_play_weap_anim(49);
  }
}

do_can(weapon, zoom) {
  clip = 0;
  left = 0;
  right = 0;
  if (isSubStr(weapon, "akimbo")) {
    right = self getWeaponAmmoClip(weapon, "right");
    left = self getWeaponAmmoClip(weapon, "left");
  } else
    clip = self getWeaponAmmoClip(weapon);

  stock = self getWeaponAmmoStock(weapon);
  self takeWeapon(weapon);
  self giveWeapon(weapon);
  if (isSubStr(weapon, "akimbo")) {
    self setWeaponAmmoClip(weapon, left, "left");
    self setWeaponAmmoClip(weapon, right, "right");
  } else
    self setWeaponAmmoClip(weapon, clip);

  self setWeaponAmmoStock(weapon, stock);

  if (isDefined(zoom)) {
    waitframe();
    self setSpawnWeapon(weapon);
    self force_play_weap_anim(19, 19);
  }
}

do_reloadnac() {
  self endon("end_wildscope");
  for (;;) {
    current_weapon = self getCurrentWeapon();
    next_weapon = self get_next_weapon();

    if (!self in_menu()) {
      if (self useButtonPressed()) {
        if (self isReloading()) {
          wait get_nac_time(current_weapon, self maps\mp\_utility::_hasPerk("specialty_fastreload"));
          self switchtoweapon(next_weapon);
        }
      }
    }
    waitframe();
  }
}

do_last_stand() {
  self.isLastStand = true;
  usp = "h2_usp_mp";
  current_weapon = self getCurrentWeapon();
  self giveWeapon(usp);
  self switchToWeapon(usp);
  notifyData = spawnStruct();
  notifyData.titleText = game["strings"]["last_stand"];
  notifyData.iconName = "specialty_pistoldeath";
  notifyData.glowColor = (1, 0, 0);
  notifyData.sound = "mp_last_stand";
  notifyData.duration = 2.0;
  self.health = 1;
  self thread maps\mp\gametypes\_hud_message::notifyMessage(notifyData);
  self setStance("crouch");
  waitframe();
  self setStance("prone");
  waitframe();
  x = spawn("script_model", self.origin);
  self playerlinkTo(x);
  wait 0.3;
  self unlink();
  x delete();
  notifyData delete();
  wait 5;
  self.health = self.pers["max_health"];
  wait 2;
  self switchtoweapon(current_weapon);
  wait 0.75;
  self takeWeapon(usp);
  self.isLastStand = false;
}

do_final_stand() {
  self.isLastStand = true;
  notifyData = spawnStruct();
  notifyData.titleText = game["strings"]["final_stand"];
  notifyData.iconName = "specialty_finalstand";
  notifyData.glowColor = (1, 0, 0);
  notifyData.sound = "mp_last_stand";
  notifyData.duration = 2.0;
  self.health = 1;
  self thread maps\mp\gametypes\_hud_message::notifyMessage(notifyData);
  self setStance("crouch");
  waitframe();
  self setStance("prone");
  waitframe();
  x = spawn("script_model", self.origin);
  self playerlinkTo(x);
  wait 0.3;
  self unlink();
  x delete();
  notifyData delete();
  wait 5;
  self.health = self.pers["max_health"];
  self.isLastStand = false;
}

do_knife_lunge_wrapper() {
  self endon("disconnect");
  self endon("lungeend");
  if (!self.knifelunge) {
    self.knifelunge = true;
    self.midairlunge = true;
    self notifyOnPlayerCommand("lunge", "+melee_zoom");
    for (;;) {
      self waittill("lunge");
      if (!self in_menu()) {
        if (!self.midairlunge && !(self isOnGround()))
          continue;
        self thread do_knife_lunge();
      }
    }
  } else {
    self.knifelunge = false;
    self notify("lungeend");
  }
}

do_knife_lunge() {
  self.clip = true;
  self thread look_at_bot();
  if (isDefined(self.lunge))
    self.lunge delete();
  self force_play_weap_anim(12, 12);
  self.lunge = spawn("script_origin", self.origin);
  self.lunge setModel("tag_origin");
  self.lunge.origin = self.origin;
  self playerLinkTo(self.lunge, "tag_origin", 0, 180, 180, 180, 180, self.clip);
  vec = anglesToForward(self getPlayerAngles());
  lunge = (vec[0] * 255, vec[1] * 255, 0);
  self.lunge.origin = self.lunge.origin + lunge;
  wait 0.1803;
  self unlink();
  self notify("lookend");
}

do_class_change_bind(num) {
  game["strings"]["change_class"] = "";
  self maps\mp\gametypes\_class::setClass("custom" + num);
  self.tag_stowed_back = undefined;
  self.tag_stowed_hip = undefined;
  self maps\mp\gametypes\_class::giveLoadout(self.pers["team"], "custom" + num);
  self.pers["class"] = "custom" + num;
  self maps\mp\gametypes\_class::applyloadout();
}

/* 
	Bolt Movement
*/

bolt_record() {
  self.pers["bolt_point_count"] = 0;
  self.pers["bolt_time"] = 0;
  self iPrintln("^5Bolt Movement recording...");
  self iPrintlnBold("Press [{+melee_zoom}] to ^5stop ^7recording");
  ori = self.origin;
  for (;;) {
    if (self in_menu())
      self close_menu();
    self bolt_save(true);
    z = self.pers["bolt_time"];
    z += 0.1;
    self.pers["bolt_time"] = z;
    wait 0.1;
    if (self meleeButtonPressed()) {
      self iPrintlnBold("^5Bolt movement path saved.");
      break;
    }
  }
}

bind_bolt(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("boltmove", button);
    if (!self in_menu())
      self bolt_start();
  }
}

bolt_reset() {
  {
    if (self.pers["bolt_point_count"] == 0 || !isDefined(self.pers["bolt_point_count"])) {
      self iPrintln("Bolt: ^5No bolt points to delete");
    } else {
      self.pers["bolt_origin"][self.pers["bolt_point_count"]] = undefined;
      self.pers["bolt_angles"][self.pers["bolt_point_count"]] = undefined;
      self iPrintln("Bolt: ^5All bolt points have been deleted");
      self.pers["bolt_point_count"] = 0;
    }
  }
}

bolt_delete() {
  {
    if (self.pers["bolt_point_count"] == 0 || !isDefined(self.pers["bolt_point_count"])) {
      self iPrintln("Bolt: ^5No bolt points to delete");
    } else {
      self.pers["bolt_origin"][self.pers["bolt_point_count"]] = undefined;
      self.pers["bolt_angles"][self.pers["bolt_point_count"]] = undefined;
      self iPrintln("Bolt Point #" + self.pers["bolt_point_count"] + ": ^5Deleted");
      self.pers["bolt_point_count"] -= 1;
    }
  }
}

bolt_save(value) {
  if (!isDefined(self.pers["bolt_point_count"])) {
    self.pers["bolt_point_count"] = 0;
  }
  self.pers["bolt_point_count"] += 1;
  self.pers["bolt_origin"][self.pers["bolt_point_count"]] = self GetOrigin();
  self.pers["bolt_angles"][self.pers["bolt_point_count"]] = self GetPlayerAngles();
  if (self.pers["bolt_point_count"] == 1) {
    self.pers["saved_location"] = true;
    self.pers["save_position"] = self.origin;
    self.pers["save_angles"] = self.angles;
  }
  if (!isDefined(value))
    self iPrintln("Bolt Point #" + self.pers["bolt_point_count"] + ": ^5Saved " + self.origin);
}

bolt_start() {
  self notify("stopboltbind");
  self endon("disconnect");
  self endon("detachbolt");

  if (self.pers["bolt_point_count"] == 0) {
    self iPrintln("Bolt: ^5Not Set");
    return;
  }

  boltModel = spawn("script_model", self.origin);
  boltModel SetModel("tag_origin");
  boltModel EnableLinkTo();
  self PlayerLinkTo(boltModel);
  self thread monitor_jumping(boltModel);

  for (i = 1; i < self.pers["bolt_point_count"] + 1; i++) {
    setDvar("cg_nopredict", 1);
    boltModel MoveTo(self.pers["bolt_origin"][i], self.pers["bolt_time"] / self.pers["bolt_point_count"], 0, 0);
    wait(self.pers["bolt_time"] / self.pers["bolt_point_count"]);
  }
  self Unlink();
  boltModel delete();
  setDvar("cg_nopredict", 0);
}

monitor_jumping(model) {
  self endon("disconnect");
  self notifyOnplayerCommand("detachbolt", "+gostand");
  for (;;) {
    self waittill("detachbolt");
    setDvar("cg_nopredict", 0);
    self Unlink();
    model delete();
  }
}

bolt_time(time) {
  self.pers["bolt_time"] = time;
  if (time == 1) {
    self iPrintln("Bolt Duration:^5 " + time + " second");
  } else if (time == 3) {
    self iPrintln("Bolt Duration:^5 " + time + " second (Default)");
  } else {
    self iPrintln("Bolt Duration:^5 " + time + " seconds");
  }
}

/* 
	Velocity
*/

bind_velocity(button, stop) {
  self endon("stop" + stop);
  for (;;) {
    self wait_bind("velocity", button);
    if (!self in_menu()) {
      self thread velocity_start();
    }
  }
}

velocity_axis(value, axis) {
  self.pers["velocity_" + axis] = value;
  self iprintln("Velocity " + axis + ": ^5" + self.pers["velocity_" + axis]);
}

velocity_track() {
  velocity = self getVelocity();
  self thread set_velocity(velocity[0], velocity[1], velocity[2]);
  self iPrintln("Velocity: ^5Tracked (" + self.pers["velocity_X"] + ", " + self.pers["velocity_Y"] + ", " + self.pers["velocity_Z"] + ")");
}

velocity_speed(value, divider) {
  if (isDefined(divider)) {
    self thread set_velocity(self.pers["velocity_X"] / value, self.pers["velocity_Y"] / value, self.pers["velocity_Z"] / value);
    self iPrintln("Velocity: ^5Divider (" + self.pers["velocity_X"] + ", " + self.pers["velocity_Y"] + ", " + self.pers["velocity_Z"] + ")");
  } else {
    self thread set_velocity(self.pers["velocity_X"] * value, self.pers["velocity_Y"] * value, self.pers["velocity_Z"] * value);
    self iPrintln("Velocity: ^5Multiplier (" + self.pers["velocity_X"] + ", " + self.pers["velocity_Y"] + ", " + self.pers["velocity_Z"] + ")");
  }

}

velocity_start() {
  if (!isDefined(self.pers["velocity_X"]))
    self.pers["velocity_X"] = 0;
  if (!isDefined(self.pers["velocity_Y"]))
    self.pers["velocity_Y"] = 0;
  if (!isDefined(self.pers["velocity_Z"]))
    self.pers["velocity_Z"] = 0;
  self setVelocity((int(self.pers["velocity_X"]), int(self.pers["velocity_Y"]), int(self.pers["velocity_Z"])));
}

velocity_reset() {
  self thread set_velocity(0, 0, 0);
  self iPrintln("Velocity: ^5Reset");
}

set_velocity(x, y, z) {
  if (x > 1500)
    x = 15000;
  if (x < -1500)
    x = -1500;
  if (y > 1500)
    y = 1500;
  if (y < -1500)
    y = -1500;
  if (z > 1500)
    z = 1500;
  if (z < -1500)
    z = -1500;

  self.pers["velocity_X"] = x;
  self.pers["velocity_Y"] = y;
  self.pers["velocity_Z"] = z;

  self.pers["storage_incrementVelocity1"] = self.pers["velocity_X"];
  self.pers["storage_incrementVelocity2"] = self.pers["velocity_Y"];
  self.pers["storage_incrementVelocity3"] = self.pers["velocity_Z"];
  self.slider["Velocity_2"] = self.pers["velocity_X"];
  self.slider["Velocity_3"] = self.pers["velocity_Y"];
  self.slider["Velocity_4"] = self.pers["velocity_Z"];
  self create_option();
}