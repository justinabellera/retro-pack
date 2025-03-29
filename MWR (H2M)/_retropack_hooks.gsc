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

initHooks() {
  if (getDvar("g_gametype") != "sd")
    replaceFunc(maps\mp\perks\_perkfunctions::monitorTIUse, ::monitorTIUse_);
  replaceFunc(maps\mp\_events::firstbloodevent, ::firstbloodevent_);
  replaceFunc(maps\mp\gametypes\_gamelogic::checkroundswitch, ::returnNull_);
  replaceFunc(maps\mp\gametypes\_gamelogic::displayroundswitch, ::returnNull_);
  replaceFunc(maps\mp\gametypes\_gamelogic::onForfeit, ::returnFalse_);
  replaceFunc(maps\mp\gametypes\_gamelogic::freezeplayerforroundend, ::freezeplayerforroundend_);
  replaceFunc(maps\mp\gametypes\_gamelogic::matchstarttimerwaitforplayers, maps\mp\gametypes\_gamelogic::matchStartTimerSkip); //SimonLFC
  replaceFunc(maps\mp\gametypes\_damage::dofinalkillcam, ::dofinalkillcam_);
  replaceFunc(maps\mp\gametypes\_rank::syncxpomnvars, ::syncxpomnvars_);
  replaceFunc(scripts\mp_patches\custom_teams::apply_iw4_costumes, ::apply_iw4_costumes_);
  replaceFunc(scripts\mp_patches\custom_weapons::h2_buildweaponname, ::h2_buildweaponname_);
  replaceFunc(scripts\mp_patches\custom_weapons::isvalidprimary, ::returnTrue_);
  replaceFunc(scripts\mp_patches\custom_weapons::isvalidsecondary, ::returnTrue_);
  replaceFunc(scripts\mp_patches\custom_weapons::isvalidweapon, ::returnTrue_);
  replaceFunc(scripts\mp_patches\custom_weapons::isvalidattachment, ::returnTrue_);
  replaceFunc(scripts\mp_patches\custom_weapons::isvalidcamo, ::returnTrue_);
  replaceFunc(maps\mp\gametypes\common_sd_sr::sd_endgame, ::sd_endgame_);
  replaceFunc(maps\mp\gametypes\common_sd_sr::onuseplantobject, ::onuseplantobject_);
  replaceFunc(maps\mp\gametypes\common_sd_sr::bombplanted, ::bombplanted_);
  replaceFunc(maps\mp\gametypes\_damage::laststandtimer, ::laststandtimer_);
  replaceFunc(maps\mp\gametypes\_damage::reviveholdthink, ::reviveholdthink_);
  replaceFunc(maps\mp\gametypes\_damage::revivetriggerthink, ::revivetriggerthink_);
  replaceFunc(maps\mp\gametypes\_playerlogic::laststandrespawnplayer, ::laststandrespawnplayer_);
  replaceFunc(maps\mp\perks\_perks::cac_modified_damage, ::cac_modified_damage_);
  level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage; //doktorSAS
  level.callbackPlayerDamage = ::CodeCallback_PlayerDamage;
  level.OnPlayerKilled = ::OnPlayerKilled_;
}

returnNull_(one, two, three, four, five, six) {
  return;
}

returnTrue_(one, two, three, four, five, six) {
  return true;
}

returnFalse_(one, two, three, four, five, six) {
  return false;
}

firstbloodevent_( var_0, var_1, var_2 )
{
  if(getDvarInt("rp_firstblood") == 1) {
    self.modifiers["firstblood"] = 1;
    maps\mp\_utility::incplayerstat( "firstblood", 1 );
    thread maps\mp\_utility::teamplayercardsplash( "callout_firstblood", self );
    level thread maps\mp\gametypes\_rank::awardgameevent( "firstblood", self, var_1, undefined, var_2 );
    thread maps\mp\_matchdata::logkillevent( var_0, "firstblood" );
  } else 
	  return;
	
  return;
}

h2_buildweaponname_(baseName, attachment1, attachment2, camo, perks) {
  weaponName = baseName;

  attachments = [];
  attachments[attachments.size] = attachment1;

  perk1 = "";
  if (isdefined(perks) && typeof (perks) == "array" && perks.size > 0) {
    perk1 = perks[0];
  }

  attachments[attachments.size] = attachment2;

  attachments = common_scripts\utility::array_remove(attachments, "none");

  if (IsDefined(attachments.size) && attachments.size) {
    attachments = common_scripts\utility::alphabetize(attachments);
  }

  foreach(attachment in attachments) {
    name = scripts\mp_patches\custom_weapons::get_attachment_name(baseName, attachment);
    if (isdefined(name) && name != "")
      attachment = name;

    if (issubstr(weaponName, "_" + attachment))
      weaponName = weaponName;
    else
      weaponName += "_" + attachment;

    if (attachment == "gl" || attachment == "glak47")
      weaponName += "_glpre";

    if (attachment == "sho")
      weaponName += "_shopre";
  }

  if (isSubStr(weaponName, "at4_") || isSubStr(weaponName, "stinger_") || isSubStr(weaponName, "javelin_") || IsSubStr(weaponName, "h2_") || IsSubStr(weaponName, "h1_")) {
    weaponName = maps\mp\gametypes\_class::buildweaponnamecamo(weaponName, camo);
  } else if (!scripts\mp_patches\custom_weapons::isValidWeapon(weaponName + "_mp", false)) {
    weaponName = baseName + "_mp";
  } else {
    weaponName = maps\mp\gametypes\_class::buildweaponnamecamo(weaponName, camo);
    weaponName += "_mp";
  }

  return weaponName;
}

syncxpomnvars_() {
  var_0 = self.pers["rankxp"];
  var_1 = self.pers["rank"];
  var_2 = self.pers["prestige"];
  var_3 = maps\mp\gametypes\_rank::getrankinfominxp(var_1);
  var_4 = maps\mp\gametypes\_rank::getrankinfomaxxp(var_1);
  var_5 = 0;

  if (var_4 - var_3 > 0) {
    var_5 = (var_0 - var_3) / (var_4 - var_3);
    var_5 = clamp(var_5, 0.0, 1.0);
  }

  if (var_2 == level.maxprestige && var_1 == level.maxrankformaxprestige)
    var_5 = 1.0;

  self setclientomnvar("ui_player_xp_pct", isdefined(self.pers["spoof_progress"]) ? 0 : var_5);
  self setclientomnvar("ui_player_xp_rank", var_1);
  self setclientomnvar("ui_player_xp_prestige", var_2);
}

OnPlayerKilled_(var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9) {
  if (isPlayer(self))
    self setclientomnvar("ui_carrying_bomb", 0);

  if (getDvarInt("rp_distance_meter") == 1) {
    if (self != var_1 && var_3 != "MOD_TRIGGER_HURT" &&
      var_3 != "MOD_FALLING" &&
      var_3 != "MOD_SUICIDE" &&
      var_3 != "MOD_EXPLOSIVE") {
      waitframe();
      if (var_1 is_on_last(0)) {
          realDistance = int(distance(self.origin, var_1.origin) * 0.0254);
          do_server_message("^5[^7" + realDistance + " m^5]");
      }
    }
  }

  thread maps\mp\gametypes\common_sd_sr::checkallowspectating();
}

freezeplayerforroundend_(var_0) {
  self endon("disconnect");
  maps\mp\_utility::clearlowermessages();

  if (!isdefined(var_0))
    var_0 = 0.05;

  self closepopupmenu();
  self closeingamemenu();
  wait(var_0);
  if (self is_bot() || isDefined(self.pers["after_hit"]) && self.pers["after_hit"])
    maps\mp\_utility::freezecontrolswrapper(1);
}

monitorTIUse_() {
  self endon("death");
  self endon("disconnect");
  self endon("end_monitorTIUse");
  level endon("game_ended");

  self thread maps\mp\perks\_perkfunctions::updateTISpawnPosition();
  self thread maps\mp\perks\_perkfunctions::clearPreviousTISpawnpoint();

  for (;;) {
    self waittill("grenade_fire", lightstick, weapName);

    if (weapName != "flare_mp")
      continue;

    lightstick delete();

    if (isDefined(self.setSpawnPoint))
      self maps\mp\perks\_perkfunctions::deleteTI(self.setSpawnPoint);

    if (!isDefined(self.TISpawnPosition))
      continue;

    if (self maps\mp\_utility::touchingBadTrigger())
      continue;

    TIGroundPosition = playerPhysicsTrace(self.TISpawnPosition + (0, 0, 16), self.TISpawnPosition - (0, 0, 2048)) + (0, 0, 1);

    glowStick = spawn("script_model", TIGroundPosition);
    glowStick.angles = self.angles;
    glowStick.team = self.team;
    glowStick.enemyTrigger = spawn("script_origin", TIGroundPosition);
    glowStick thread maps\mp\perks\_perkfunctions::GlowStickSetupAndWaitForDeath(self);
    glowStick.playerSpawnPos = self.TISpawnPosition;
    glowStick.notti = true;

    glowStick thread maps\mp\gametypes\_weapons::createBombSquadModel("weapon_light_stick_tactical_bombsquad", "tag_fire_fx", self);

    if (self.pers["tk_tact"]) {
      self setlethalweapon("iw9_throwknife_mp");
      self giveweapon("iw9_throwknife_mp");
    }

    self.setSpawnPoint = glowStick;
    self thread maps\mp\perks\_perkfunctions::tactical_respawn();
    return;
  }
}

dofinalkillcam_() {
  level waittill("round_end_finished");
  setDvar("xblive_privatematch", 0);
  level.showingfinalkillcam = 1;
  var_0 = "none";

  if (isdefined(level.finalkillcam_winner))
    var_0 = level.finalkillcam_winner;

  var_1 = level.finalkillcam_delay[var_0];
  var_2 = level.finalkillcam_victim[var_0];
  var_3 = level.finalkillcam_attacker[var_0];
  var_4 = level.finalkillcam_attackernum[var_0];
  var_5 = level.finalkillcam_killcamentityindex[var_0];
  var_6 = level.finalkillcam_killcamentitystarttime[var_0];
  var_7 = level.finalkillcam_usestarttime[var_0];
  var_8 = level.finalkillcam_sweapon[var_0];
  var_9 = level.finalkillcam_weaponindex[var_0];
  var_10 = level.finalkillcam_customindex[var_0];
  var_11 = level.finalkillcam_isalternate[var_0];
  var_12 = level.finalkillcam_deathtimeoffset[var_0];
  var_13 = level.finalkillcam_psoffsettime[var_0];
  var_14 = level.finalkillcam_timerecorded[var_0];
  var_15 = level.finalkillcam_timegameended[var_0];
  var_16 = level.finalkillcam_smeansofdeath[var_0];
  var_17 = level.finalkillcam_type[var_0];

  if (isdefined(var_3)) {
    var_3.finalkill = 1;
    var_0 = "none";

    if (level.teambased && isdefined(var_3.team))
      var_0 = var_3.team;

    switch (level.finalkillcam_sweapon[var_0]) {
    case "artillery_mp":
      var_3 maps\mp\gametypes\_missions::processchallenge("ch_finishingtouch");
      break;
    default:
      break;
    }
  }

  maps\mp\gametypes\_damage::waitforstream(var_3);
  var_18 = (gettime() - var_2.deathtime) / 1000;

  foreach(var_20 in level.players) {
    var_20.pers["spoof_progress"] = undefined;
    /*
	if(isDefined(var_20.retropack["retropack"]["controls"])){
      var_20.retropack["retropack"]["controls"].alpha = 0;
    }
	*/
    var_20 maps\mp\_utility::revertvisionsetforplayer(0);
    var_20 setblurforplayer(0, 0);
    var_20.killcamentitylookat = var_2 getentitynumber();

    if (isdefined(var_3) && isdefined(var_3.lastspawntime))
      var_21 = (gettime() - var_3.lastspawntime) / 1000.0;
    else
      var_21 = 0;

    var_20 thread maps\mp\gametypes\_killcam::killcam(var_3, var_4, var_5, var_6, var_8, var_9, var_10, var_11, var_18 + var_12, var_13, 0, 1, maps\mp\gametypes\_damage::getkillcambuffertime(), var_3, var_2, var_16, var_17, var_21, var_7);
  }

  wait 0.1;

  while (maps\mp\gametypes\_damage::anyplayersinkillcam())
    wait 0.05;

  setDvar("xblive_privatematch", 1);
  waitframe();
  maps\mp\gametypes\_damage::endfinalkillcam();
}

cac_modified_damage_(victim, attacker, damage, meansofdeath, weapon, impactPoint, impactDir, hitLoc) {
  if (isDefined(attacker.pers["bind_damagebuffer"]) && attacker.pers["bind_damagebuffer"]) {
    if (isDefined(victim.pers["damage_buffer_victim"]) && victim.pers["damage_buffer_victim"])
      attacker waittill("damage_buffer");
  }

  assert(isPlayer(victim));
  assert(isDefined(victim.team));

  if (!isDefined(victim) || !isDefined(attacker) || !isPlayer(attacker) || !maps\mp\_utility::invirtuallobby() && !isPlayer(victim))
    return damage;

  if (attacker.sessionstate != "playing" || !isDefined(damage) || !isDefined(meansofdeath))
    return damage;

  if (meansofdeath == "")
    return damage;

  damageAdd = 0;

  if (maps\mp\perks\_perks::isPrimaryDamage(meansofdeath)) {
    assert(isDefined(attacker));

    if (isPlayer(attacker) && weaponInheritsPerks(weapon) && attacker maps\mp\_utility::_hasPerk("specialty_bulletdamage") && victim maps\mp\_utility::_hasPerk("specialty_armorvest"))
      damageAdd += 0;
    else if (isPlayer(attacker) && weaponInheritsPerks(weapon) && attacker maps\mp\_utility::_hasPerk("specialty_bulletdamage"))
      damageAdd += damage * level.bulletDamageMod;
    else if (victim maps\mp\_utility::_hasPerk("specialty_armorvest"))
      damageAdd -= damage * (level.armorVestMod * -1);

    if (isPlayer(attacker) && attacker maps\mp\_utility::_hasPerk("specialty_fmj") && victim maps\mp\_utility::_hasPerk("specialty_armorvest"))
      damageAdd += damage * level.hollowPointDamageMod;
  } else if (maps\mp\perks\_perks::isExplosiveDamage(meansofdeath)) {
    if (isPlayer(attacker) && weaponInheritsPerks(weapon) && attacker maps\mp\_utility::_hasPerk("specialty_explosivedamage") && isDefined(victim.blastShielded))
      damageAdd += 0;
    else if (isPlayer(attacker) && weaponInheritsPerks(weapon) && attacker maps\mp\_utility::_hasPerk("specialty_explosivedamage"))
      damageAdd += damage * level.explosiveDamageMod;
    else if (isDefined(victim.blastShielded))
      damageAdd -= damage * (level.blastShieldMod * -1);
    else if (maps\mp\gametypes\_weapons::ingrenadegraceperiod())
      damageAdd *= level.juggernautmod;

    if (maps\mp\_utility::iskillstreakweapon(weapon) && isPlayer(attacker) && attacker maps\mp\_utility::_hasPerk("specialty_dangerclose"))
      damageAdd += damage * level.dangerCloseMod;
  } else if (meansofdeath == "MOD_FALLING") {
    if (victim maps\mp\_utility::_hasPerk("specialty_falldamage")) {
      damageAdd = 0;
      damage = 0;
    }
  }

  if (victim maps\mp\_utility::_hasPerk("specialty_combathigh")) {
    if (isDefined(self.damageBlockedTotal) && (!level.teamBased || (isDefined(attacker) && isDefined(attacker.team) && victim.team != attacker.team))) {
      damageTotal = damage + damageAdd;
      damageBlocked = (damageTotal - (damageTotal / 3));
      self.damageBlockedTotal += damageBlocked;

      if (self.damageBlockedTotal >= 101) {
        self notify("combathigh_survived");
        self.damageBlockedTotal = undefined;
      }
    }

    if (weapon != "iw9_throwknife_mp") {
      switch (meansOfDeath) {
      case "MOD_FALLING":
      case "MOD_MELEE":
        break;
      default:
        damage = damage / 3;
        damageAdd = damageAdd / 3;
        break;
      }
    }
  }

  return int(damage + damageAdd);
}

CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset) {
  self endon("disconnect");

  if (isDefined(self.pers["god_mode"]) && self.pers["god_mode"])
    return;

  if (sMeansOfDeath == "MOD_MELEE")
    iDamage = getDvarInt("rp_melee_damage");

  if (is_sniper(sWeapon))
    iDamage = getDvarInt("rp_sniper_damage");

  if (sMeansOfDeath == "MOD_IMPACT") {
    if (isDefined(eAttacker.pers["bind_damagebuffer"]) && eAttacker.pers["bind_damagebuffer"]) {
      eAttacker waittill("damage_buffer");
    }
  }

  if (!eAttacker is_bot()) {
    [
      [level.OriginalCallbackPlayerDamage]
    ](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
  } else {
    if (eAttacker is_on_last(1)) {
      if (getDvar("g_gametype") == "dm")
        eAttacker scripts\mp\_retropack_functions::do_reset_scores(randomIntRange(0, 10), eAttacker);
      else if (getDvar("g_gametype") == "war")
        iDamage = 0;
    } else {
      [
        [level.OriginalCallbackPlayerDamage]
      ](eInflictor, eAttacker, (iDamage * getDvarFloat("rp_bot_damage")), iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
    }
  }
}

onuseplantobject_(var_0, var_1, var_2) {
  if (!maps\mp\gametypes\_gameobjects::isfriendlyteam(var_0.pers["team"])) {
    level thread bombplanted_(self, var_0, var_1, var_2);

    for (var_1 = 0; var_1 < level.bombzones.size; var_1++) {
      if (level.bombzones[var_1] == self) {
        var_2 = level.bombzones[var_1] maps\mp\gametypes\_gameobjects::getlabel();
        maps\mp\_utility::setmlgicons(level.bombzones[var_1], "waypoint_esports_snd_planted" + var_2);
        continue;
      }

      level.bombzones[var_1] maps\mp\gametypes\_gameobjects::disableobject();
      maps\mp\_utility::setmlgicons(level.bombzones[var_1], undefined);
    }

    var_0 maps\mp\gametypes\common_bomb_gameobject::onplayerplantbomb(1, game["attackers"], game["defenders"]);

    if (isdefined(level.carrierloadouts) && isdefined(level.carrierloadouts[var_0.team])) {
      var_0 thread maps\mp\_utility::removecarrierclass();
      return;
    }
  } else
    self.bombplantedon = 0;
}

bombplanted_(var_0, var_1, auto, site) {
  level.bombplanted = 1;
  var_1.objective = 0;
  level.defuseendtime = int(gettime() + level.bombtimer * 1000);
  setgameendtime(level.defuseendtime);
  setomnvar("ui_bomb_timer", 1);

  if (!level.multibomb) {
    level.sdbomb maps\mp\gametypes\_gameobjects::allowcarry("none");
    level.sdbomb maps\mp\gametypes\_gameobjects::setvisibleteam("none");
    maps\mp\_utility::setmlgicons(level.sdbomb, undefined);
    level.sdbomb maps\mp\gametypes\_gameobjects::setdropped();
    level.sdbombmodel = level.sdbomb.visuals[0];
  } else {
    level.sdbombmodel = spawn("script_model", var_1.origin);
    level.sdbombmodel.angles = var_1.angles;
    level.sdbombmodel setmodel("wpn_h1_briefcase_bomb_npc");
  }

  if (isDefined(auto)) {
    if (isDefined(level.bombzones)) {
      level.sdbombmodel.origin = level.bombzones[site].trigger.origin + (randomIntRange(0, 40), randomIntRange(50, 100), -7.5);
      level.sdbombmodel.angles = level.sdbombmodel.angles + (randomIntRange(-10, 10), randomIntRange(0, 360), 0);
    }
  }

  var_0 maps\mp\gametypes\common_bomb_gameobject::onbombplanted(level.sdbombmodel.origin + (0, 0, 1));
  var_0 maps\mp\gametypes\_gameobjects::allowuse("none");
  var_0 maps\mp\gametypes\_gameobjects::setvisibleteam("none");
  var_2 = var_0 maps\mp\gametypes\_gameobjects::getlabel();
  var_3 = var_0.bombdefusetrig;
  var_3.origin = level.sdbombmodel.origin;
  var_4 = [];
  var_5 = maps\mp\gametypes\_gameobjects::createuseobject(game["defenders"], var_3, var_4, (0, 0, 32));
  var_5.label = var_2;
  var_5 maps\mp\gametypes\common_bomb_gameobject::setupzonefordefusing(1);
  var_5.onbeginuse = maps\mp\gametypes\common_sd_sr::onbeginuse;
  var_5.onenduse = maps\mp\gametypes\common_sd_sr::onenduse;
  var_5.onuse = maps\mp\gametypes\common_sd_sr::onusedefuseobject;
  var_5.nousebar = 1;
  var_5.id = "defuseObject";

  if (var_2 == "_a" || var_2 == "_A")
    setomnvar("ui_mlg_game_mode_status_1", 1);
  else if (var_2 == "_b" || var_2 == "_B")
    setomnvar("ui_mlg_game_mode_status_1", 2);

  maps\mp\gametypes\common_sd_sr::bombtimerwait(var_5 maps\mp\gametypes\common_sd_sr::isbombsiteb());
  setomnvar("ui_bomb_timer", 0);
  maps\mp\gametypes\common_sd_sr::setbombendtime(0, var_5 maps\mp\gametypes\common_sd_sr::isbombsiteb());
  var_0.tickingobject maps\mp\gametypes\common_bomb_gameobject::stoptickingsound();

  if (level.gameended || level.bombdefused)
    return;

  level.bombexploded = 1;
  setomnvar("ui_mlg_game_mode_status_1", 0);
  var_6 = level.sdbombmodel.origin;
  var_6 = var_6 + (0, 0, 10);
  level.sdbombmodel hide();
  var_0 maps\mp\gametypes\common_bomb_gameobject::onbombexploded(var_6, 300, var_1);

  for (var_7 = 0; var_7 < level.bombzones.size; var_7++)
    level.bombzones[var_7] maps\mp\gametypes\_gameobjects::disableobject();

  var_5 maps\mp\gametypes\_gameobjects::disableobject();
  setgameendtime(0);
  wait 3;
  sd_endgame_(game["attackers"], game["end_reason"]["target_destroyed"], isDefined(auto) ? true : undefined);
}

sd_endgame_(var_0, var_1, var_2) {
  level.finalkillcam_winner = var_0;

  if (var_0 == game["attackers"]) {
    if (!isdefined(game["attackerWinCount"]))
      game["attackerWinCount"] = 0;

    game["attackerWinCount"]++;
  } else if (var_0 == game["defenders"]) {
    if (!isdefined(game["defenderWinCount"]))
      game["defenderWinCount"] = 0;

    game["defenderWinCount"]++;
  }

  if (var_1 == game["end_reason"]["target_destroyed"] || var_1 == game["end_reason"]["bomb_defused"]) {
    setDvar("xblive_privatematch", 1);
    waitframe();
  }

  if (isDefined(var_2)) {
    wait 1.5;
  }

  maps\mp\gametypes\_gamescore::giveteamscoreforobjective(var_0, 1);
  thread scripts\mp\endgame_patch::endgame_stub(var_0, var_1);
}

apply_iw4_costumes_() {
  self endon("disconnect");
  level endon("game_ended");

  self waittill("player_model_set");

  if (!isdefined(self.primaryweapon)) {
    return;
  }

  weapon = self.primaryweapon;

  if (isdefined(weapon))
    weapon = maps\mp\_utility::getbaseweaponname(weapon);

  weaponClass = tablelookup("mp/statstable.csv", 4, weapon, 2);

  if (maps\mp\_utility::invirtuallobby() || level.virtuallobbyactive) {
    switch (weaponClass) {
    case "weapon_smg":
      scripts\mp_patches\custom_teams::rangers_smg_main();
      break;
    case "weapon_assault":
      scripts\mp_patches\custom_teams::rangers_assault_main();
      break;
    case "weapon_sniper":
      if (self.team == "allies")
        scripts\mp_patches\custom_teams::allies_ghillie_setviewmodel();
      else
        scripts\mp_patches\custom_teams::axis_ghillie_setviewmodel();
      break;
    case "weapon_lmg":
    case "weapon_heavy":
    case "default":
    default:
      scripts\mp_patches\custom_teams::rangers_lmg_main();
      break;
    }
    return;
  }

  if (isDefined(self.pers["viewhands"])) {
    self setviewmodel(self.pers["viewhands"]);
    return;
  }

  switch (weaponClass) {
  case "weapon_smg":
    [
      [game[self.team + "_model"]["SMG"]]
    ]();
    break;
  case "weapon_assault":
    [
      [game[self.team + "_model"]["ASSAULT"]]
    ]();
    break;
  case "weapon_sniper":
    if (self.team == "allies")
      scripts\mp_patches\custom_teams::allies_ghillie_setviewmodel();
    else
      scripts\mp_patches\custom_teams::axis_ghillie_setviewmodel();
    break;
  case "weapon_lmg":
  case "weapon_heavy":
    [
      [game[self.team + "_model"]["LMG"]]
    ]();
    break;
  default:
    self scripts\mp_patches\custom_teams::randomBotCostume();
    break;
  }
}

revivetriggerthink_(var_0) {
  self endon("death");
  level endon("game_ended");

  if (getDvarInt("rp_revives") != 1)
    return;

  for (;;) {
    self waittill("trigger", var_1);
    self.owner.beingrevived = 1;

    if (isdefined(var_1.beingrevived) && var_1.beingrevived) {
      self.owner.beingrevived = 0;
      continue;
    }

    self makeunusable();
    self.owner maps\mp\_utility::freezecontrolswrapper(1);
    var_2 = reviveholdthink_(var_1);
    self.owner.beingrevived = 0;

    if (!isalive(self.owner)) {
      self delete();
      return;
    }

    if (isDefined(self.owner.pers["freeze"]) && self.owner.pers["freeze"])
      self.owner maps\mp\_utility::freezecontrolswrapper(1);
    else
      self.owner maps\mp\_utility::freezecontrolswrapper(0);

    if (var_2) {
      level thread maps\mp\gametypes\_rank::awardgameevent("reviver", var_1);
      self.owner.laststand = undefined;
      self.owner maps\mp\_utility::clearlowermessage("last_stand");

      if (self.owner maps\mp\_utility::_hasperk("specialty_lightweight"))
        self.owner.moveSpeedScaler = maps\mp\_utility::lightweightscalar();
      else
        self.owner.moveSpeedScaler = 1;

      if (isDefined(self.owner.pers["freeze"]) && !self.owner.pers["freeze"])
        self.owner common_scripts\utility::_enableweapon();
      self.owner.maxhealth = self.owner.pers["max_health"];
      self.owner maps\mp\gametypes\_weapons::updatemovespeedscale("primary");
      self.owner laststandrespawnplayer_();
      self.owner.beingrevived = 0;
      self delete();
      return;
    }

    self makeusable();
    maps\mp\gametypes\_damage::updateusablebyteam(var_0);
  }
}

reviveholdthink_(var_0, var_1, var_2) {
  var_3 = 3000;
  var_4 = spawn("script_origin", self.origin + (0, 0, -25));
  var_4 hide();
  var_0 playerlinkto(var_4);
  var_0 playerlinkedoffsetenable();

  if (!isdefined(var_2))
    var_2 = 1;

  if (var_2)
    var_0 common_scripts\utility::_disableweapon();

  self.curprogress = 0;
  self.inuse = 1;
  self.userate = 0;

  if (isdefined(var_1))
    self.usetime = var_1;
  else
    self.usetime = var_3;

  var_0 thread personalusebarrevive(self, self.owner);

  thread maps\mp\gametypes\_damage::reviveholdthink_cleanup(var_0, var_2, var_4);
  var_5 = maps\mp\gametypes\_damage::reviveholdthinkloop(var_0);
  self.inuse = 0;
  var_4 delete();

  if (isdefined(var_5) && var_5) {
    self.owner thread maps\mp\gametypes\_hud_message::playercardsplashnotify("revived", var_0);
    self.owner.inlaststand = 0;
    return 1;
  }

  return 0;
}

personalusebarrevive(player, revivee) {
  self endon("disconnect");

  useBar = maps\mp\gametypes\_hud_util::createPrimaryProgressBar();
  useBarText = maps\mp\gametypes\_hud_util::createPrimaryProgressBarText();
  useBarText setText("Reviving " + scripts\utility::sanitise_name(revivee.name));

  lastRate = -1;
  while (maps\mp\_utility::isreallyalive(self) && isDefined(player) && player.inUse && !level.gameEnded) {
    if (lastRate != player.useRate) {
      if (player.curProgress > player.useTime)
        player.curProgress = player.useTime;

      useBar maps\mp\gametypes\_hud_util::updateBar(player.curProgress / player.useTime, (1000 / player.useTime) * player.useRate);

      if (!player.useRate) {
        useBar maps\mp\gametypes\_hud_util::hideElem();
        useBarText maps\mp\gametypes\_hud_util::hideElem();
      } else {
        useBar maps\mp\gametypes\_hud_util::showElem();
        useBarText maps\mp\gametypes\_hud_util::showElem();
      }
    }
    lastRate = player.useRate;
    wait(0.05);
  }

  useBar maps\mp\gametypes\_hud_util::destroyElem();
  useBarText maps\mp\gametypes\_hud_util::destroyElem();
}

laststandrespawnplayer_() {
  self laststandrevive();

  self.headicon = "";

  self setstance("crouch");
  self.revived = 1;
  self notify("revive");

  if (isdefined(self.standardmaxhealth))
    self.maxhealth = self.standardmaxhealth;

  self.health = self.pers["max_health"];

  common_scripts\utility::_enableusability();

  if (game["state"] == "postgame") {
    freezeplayerforroundend_();
  } else {
    wait .25;
    if (isDefined(self.pers["freeze"]) && self.pers["freeze"])
      self freezeControls(true);
  }
}

laststandtimer_(var_0, var_1) {
  self endon("death");
  self endon("disconnect");
  self endon("revive");
  level endon("game_ended");
  level notify("player_last_stand");
  thread maps\mp\gametypes\_damage::laststandwaittilldeath();
  self.laststand = 1;

  if (!var_1 && (!isdefined(self.inc4death) || !self.inc4death)) {
    thread maps\mp\gametypes\_damage::laststandallowsuicide();
    maps\mp\_utility::setlowermessage("last_stand", &"PLATFORM_COWARDS_WAY_OUT", undefined, undefined, undefined, undefined, undefined, undefined, 1);
    thread maps\mp\gametypes\_damage::laststandkeepoverlay();
  }

  if (getDvarInt("rp_revives") == 1) {
    var_2 = spawn("script_model", self.origin);
    var_2 setmodel("tag_origin");
    var_2 setcursorhint("HINT_NOICON");
    var_2 sethintstring( &"PLATFORM_REVIVE");
    var_2 maps\mp\gametypes\_damage::revivesetup(self);
    var_2 endon("death");
    var_3 = newteamhudelem(self.team);
    var_3 setshader("waypoint_revive", 8, 8);
    var_3 setwaypoint(1, 1);
    var_3 settargetent(self);
    var_3 thread maps\mp\gametypes\_damage::destroyonreviveentdeath(var_2);
    var_3.color = (0.33, 0.75, 0.24);
    maps\mp\_utility::playdeathsound();
    thread maps\mp\gametypes\_damage::laststandkeepoverlay();
	maps\mp\_utility::setlowermessage("last_stand_self_revive", "[{+usereload}] Self Revive", undefined, undefined, undefined, undefined, undefined, undefined, 1);
	thread laststandallow_selfrevive();
  } else {
    if (level.diehardmode == 1 && level.diehardmode != 2) {
      var_2 = spawn("script_model", self.origin);
      var_2 setmodel("tag_origin");
      var_2 setcursorhint("HINT_NOICON");
      var_2 sethintstring( &"PLATFORM_REVIVE");
      var_2 maps\mp\gametypes\_damage::revivesetup(self);
      var_2 endon("death");
      var_3 = newteamhudelem(self.team);
      var_3 setshader("waypoint_revive", 8, 8);
      var_3 setwaypoint(1, 1);
      var_3 settargetent(self);
      var_3 thread maps\mp\gametypes\_damage::destroyonreviveentdeath(var_2);
      var_3.color = (0.33, 0.75, 0.24);
      maps\mp\_utility::playdeathsound();

      if (var_1) {
        wait(var_0);

        if (self.infinalstand)
          thread maps\mp\gametypes\_damage::laststandbleedout(var_1, var_2);
      }

      return;
    } else if (level.diehardmode == 2) {
      thread maps\mp\gametypes\_damage::laststandkeepoverlay();
      var_2 = spawn("script_model", self.origin);
      var_2 setmodel("tag_origin");
      var_2 setcursorhint("HINT_NOICON");
      var_2 sethintstring( &"PLATFORM_REVIVE");
      var_2 maps\mp\gametypes\_damage::revivesetup(self);
      var_2 endon("death");
      var_3 = newteamhudelem(self.team);
      var_3 setshader("waypoint_revive", 8, 8);
      var_3 setwaypoint(1, 1);
      var_3 settargetent(self);
      var_3 thread maps\mp\gametypes\_damage::destroyonreviveentdeath(var_2);
      var_3.color = (0.33, 0.75, 0.24);
      maps\mp\_utility::playdeathsound();

      if (var_1) {
        wait(var_0);

        if (self.infinalstand)
          thread maps\mp\gametypes\_damage::laststandbleedout(var_1, var_2);
      }

      wait(var_0 / 3);
      var_3.color = (1.0, 0.64, 0.0);

      while (var_2.inuse)
        wait 0.05;

      maps\mp\_utility::playdeathsound();
      wait(var_0 / 3);
      var_3.color = (1.0, 0.0, 0.0);

      while (var_2.inuse)
        wait 0.05;

      maps\mp\_utility::playdeathsound();
      wait(var_0 / 3);

      while (var_2.inuse)
        wait 0.05;

      wait 0.05;
      thread maps\mp\gametypes\_damage::laststandbleedout(var_1);
      return;
    }
    thread maps\mp\gametypes\_damage::laststandkeepoverlay();
    wait(var_0);
    thread maps\mp\gametypes\_damage::laststandbleedout(var_1);
  }
}

laststandallow_selfrevive() {
    self endon("death");
    self endon("disconnect");
    self endon("game_ended");
    self endon("revive");

    for (;;) {
      if (self usebuttonpressed() && isDefined(self.inlaststand) && self.inlaststand) {
        var_0 = gettime();

        while (self usebuttonpressed()) {
          wait 0.05;

          if (gettime() - var_0 > 5500)
            break;
        }

        if (gettime() - var_0 > 5500)
          break;
      }

      wait 0.05;
    }
    maps\mp\_utility::freezecontrolswrapper(0);
    common_scripts\utility::_enableweapon();

    self.laststand = undefined;
    self.inlaststand = 0;
    self.beingrevived = 0;
	self.health = self.pers["max_health"];
    self.maxhealth = self.pers["max_health"];
    self.movespeedscaler = level.baseplayermovescale;

    if (self maps\mp\_utility::_hasperk("specialty_lightweight"))
      self.movespeedscaler = maps\mp\_utility::lightweightscalar();

    self maps\mp\gametypes\_weapons::updatemovespeedscale();

    maps\mp\_utility::clearlowermessage("last_stand_self_revive");
    self thread maps\mp\gametypes\_hud_message::playercardsplashnotify("survivor", self);

    self laststandrespawnplayer_();
}