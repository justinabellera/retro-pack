/*
  _____  ______ _______ _____   ____    
 |  __ \|  ____|__   __|  __ \ / __ \   
 | |__) | |__     | |  | |__) | |  | |  
 |  _  /|  __|    | |  |  _  /| |  | |  
 | | \ \| |____   | |  | | \ \| |__| |  
 |_|__\_\______|__| | /|_| _\_\\____/__                   
 | '_ \ / _` |/ __| |/ / _` |/ _` |/ _ \
 | |_) | (_| | (__|   < (_| | (_| |  __/
 | .__/ \__,_|\___|_|\_\__,_|\__, |\___|
 | |                          __/ |     
 |_|                         |___/   

Version: 1.0.0
Date: May 27, 2022
Compatibility: Modern Warfare 3
*/

#include maps\mp\_utility;
#include scripts\_init_retropack;
#include common_scripts\utility;
#include maps\mp\retropack\_retropack;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\retropack\_retropack_utility;

init(){}

toggleBunnyhop()
{
	if(self.bhop == 0)
	{
		self.bhop = 1;
		self iPrintln("Bunnyhops: ^2[On]");
		setDvar( "jump_autoBunnyHop", "1" );
	}
    else if(self.bhop == 1)
	{
		self.bhop = 0;
		self iPrintln("Bunnyhops: ^1[Off]");
		setDvar( "jump_autoBunnyHop", "0" );
	}
}

Softlands()
{
	if(self.SoftLandsS == 0)
	{
		self.SoftLandsS = 1;
		self iPrintln("Softlands: ^2[On]");
		setDvar( "jump_disableFallDamage", "1" );
		self.softlandtext Destroy();
		self.SoftLandTextRetro = "^2Enabled";
	}
	else if(self.SoftLandsS == 1)
	{
		self.SoftLandsS = 0;
		self iPrintln("Softlands: ^1[Off]");
		setDvar( "jump_disableFallDamage", "0" );
		self.softlandtext Destroy();
		self.SoftLandTextRetro = "^1Disabled";
	}
	self.softlandtext = createFontString("DEFAULT", 1.0);
	self.softlandtext setPoint("LEFT", "CENTER", 80, -35);
	self.softlandtext setText("Softland: " + self.SoftLandTextRetro + " ");
	self.softlandtext.archived = self.NotStealth;
}

toggleScavenger() //by retro
{
    self notify("endScavenger");
    if(self.scavengerBind == 0)
    {
        self.scavengerBind = 1;
        self.scavengerDpad = "up";
        self thread pickupScavengerBag();
        self iPrintln("Scavenger Pick-Up Bind by ^5 Retro");
		self iPrintln("Pick-Up with [{+actionslot 1}]");
    }
    else if(self.scavengerBind == 1)
    {
        self.scavengerBind = 2;
        self.scavengerDpad = "down";
        self thread pickupScavengerBag();
        self iPrintln("Scavenger Pick-Up Bind by ^5 Retro");
		self iPrintln("Pick-Up with [{+actionslot 2}]");
    }
    else if(self.scavengerBind == 2)
    {
        self.scavengerBind = 3;
        self.scavengerDpad = "left";
        self thread pickupScavengerBag();
        self iPrintln("Scavenger Pick-Up Bind by ^5 Retro");
		self iPrintln("Pick-Up with [{+actionslot 3}]");
    }
    else if(self.scavengerBind == 3)
    {
        self.scavengerBind = 4;
        self.scavengerDpad = "right";
        self thread pickupScavengerBag();
        self iPrintln("Scavenger Pick-Up Bind by ^5 Retro");
		self iPrintln("Pick-Up with [{+actionslot 4}]");
    }
    else if(self.scavengerBind == 4)
    {
        self.scavengerBind = 0;
        self notify("endScavenger");
        self iPrintln("Scavenger Pick-Up Bind:^1 [Off]");
    }
}

pickupScavengerBag() //by retro
{
	self endon("endScavenger");
	self endon("disconnect");
    self notifyOnPlayerCommand(self.scavengerDpad, "+actionslot " + self.scavengerBind);
	for (;;)
	{
		self waittill(self.scavengerDpad);
		self playLocalSound( "scavenger_pack_pickup" );
		self maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "scavenger" );
		
		offhandWeapons = self getWeaponsListOffhands();
		foreach ( offhand in offhandWeapons )
		{		
			if ( offhand != "throwingknife_mp" )
				continue;
			
			currentClipAmmo = self GetWeaponAmmoClip( offhand );
			self SetWeaponAmmoClip( offhand, currentClipAmmo + 1);
		}
		
		primaryWeapons = self getWeaponsListPrimaries();	
		foreach ( primary in primaryWeapons )
		{
			if ( !isCACPrimaryWeapon( primary ) && !level.scavenger_secondary )
				continue;
				
			currentStockAmmo = self GetWeaponAmmoStock( primary );
			addStockAmmo = weaponClipSize( primary );
			
			self setWeaponAmmoStock( primary, currentStockAmmo + addStockAmmo );

			altWeapon = weaponAltWeaponName( primary );

			if ( !isDefined( altWeapon ) || (altWeapon == "none") || !level.scavenger_altmode )
				continue;

			currentStockAmmo = self GetWeaponAmmoStock( altWeapon );
			addStockAmmo = weaponClipSize( altWeapon );

			self setWeaponAmmoStock( altWeapon, currentStockAmmo + addStockAmmo );
		}
	}
}

doSaveLocation()
{
	self endon ( "disconnect" );
	self.pers["loc"] = true;
	self.pers["savePos"] = self.origin;
	self.pers["saveAng"] = self.angles;
	self iprintln("^2Saved location");
}

doLoadLocation()
{
	self endon ( "disconnect" );
	if (self.pers["loc"] == true) 
	{
		self setOrigin( self.pers["savePos"] );
		self setPlayerAngles( self.pers["saveAng"] );
	}
}

givetest(weapon)
{
	self giveWeapon(weapon);
	self switchToWeapon(weapon);
	self iprintln("Weapon Given: ^5" + weapon);
}

StanceBotsFriendly()
{
	botStance = undefined;
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				if(level.players[i] GetStance() == "crouch")
				{
					level.players[i] freezeControls(true);
					wait 0.02;
					level.players[i] SetStance( "prone" );
					botStance = "Proning";
				}
				else if(level.players[i] GetStance() == "prone")
				{
					level.players[i] freezeControls(true);
					wait 0.02;
					level.players[i] SetStance( "stand" );
					botStance = "Standing";
				}
				else if(level.players[i] GetStance() == "stand")
				{
					level.players[i] freezeControls(true);
					wait 0.02;
					level.players[i] SetStance( "crouch" );
					botStance = "Crouching";
				}
			}
		}
	}
	self iPrintln("^2Bots:^7 are now : ^5" + botStance);
}

StanceBotsEnemy()
{
	botStance = undefined;
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				if(level.players[i] GetStance() == "crouch")
				{
					level.players[i] freezeControls(true);
					wait 0.02;
					level.players[i] SetStance( "prone" );
					botStance = "Proning";
				}
				else if(level.players[i] GetStance() == "prone")
				{
					level.players[i] freezeControls(true);
					wait 0.02;
					level.players[i] SetStance( "stand" );
					botStance = "Standing";
				}
				else if(level.players[i] GetStance() == "stand")
				{
					level.players[i] freezeControls(true);
					wait 0.02;
					level.players[i] SetStance( "crouch" );
					botStance = "Crouching";
				}
			}
		}
	}
	self iPrintln("^1Bots:^7 are now : ^5" + botStance);
}

toggleTeamColours()
{
    if(self.TeamColour == "Non-Party (Colour Blind)")
    {
        self.TeamColour = "Party (Colour Blind)";
		self setClientDvar( "cg_teamColor_MyTeam", "0 0.45098 0.7 0.999" );
		self setClientDvar( "cg_teamColor_EnemyTeam", "0.999 0.5 0 0.999" );
        self iPrintln("Team Colours are now: ^4Party ^7(Colour Blind)");
    }
    else if(self.TeamColour == "Party (Colour Blind)")
    {
		self.TeamColour = "Party";
		self setClientDvar( "cg_teamColor_MyTeam", "1 0.8 0.4 1" );
		self setClientDvar( "cg_teamColor_EnemyTeam", "0.999 0.45098 0.5 0.999" );
        self iPrintln("Team Colours are now: ^3Party ^7(Regular)");
    }
	else if(self.TeamColour == "Party")
    {
		self.TeamColour = "Non-Party";
		self setClientDvar( "cg_ColorBlind_MyTeam", "0.6 0.8 0.6 0.999" );
		self setClientDvar( "cg_ColorBlind_EnemyTeam", "0.999 0.45098 0.5 0.999" );
        self iPrintln("Team Colours are now: ^2Non-Party ^7(Regular)");
		self iPrintln("^1[Turn on colour-blind mode to use this option]");
    }
	else if(self.TeamColour == "Non-Party")
    {
		self.TeamColour = "Non-Party (Colour Blind)";
		self setClientDvar( "cg_ColorBlind_MyTeam", "0.34902 0.999 0.9995 0.999" );
		self setClientDvar( "cg_ColorBlind_EnemyTeam", "0.999 0.5 0 0.999" );
        self iPrintln("Team Colours are now: ^5Non-Party ^7(Colour Blind)");
		self iPrintln("^1[Turn on colour-blind mode to use this option]");
    }
}

PauseTimer()
{
	if(self.pausetimer == 0)
	{
		self.pausetimer = 1;
		self iPrintln("Timer Paused: ^2[On]");
		self maps\mp\gametypes\_gamelogic::pauseTimer();
	}
	else if(self.pausetimer == 1)
	{
		self.pausetimer = 0;
		self iPrintln("Timer Paused: ^1[Off]");
		self maps\mp\gametypes\_gamelogic::resumeTimer();
	}
}

KickBotsFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				kick ( level.players[i] getEntityNumber() );
			}
		}
		wait 0.01;
	}
	self iprintln("^2Friendly ^7Bots have been kicked");
}

KickBotsEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				kick ( level.players[i] getEntityNumber() );
			}
			wait 0.01;
		}
	}
	self iprintln("^1Enemy ^7Bots have been kicked");
}

FastRestart()
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			kick ( level.players[i] getEntityNumber() );
		}
	}
	wait 1;
	map_restart(false);
}

removedeathbarrier()
{
	//self iPrintln("Death Barriers: ^1[Removed]");
	ents = getEntArray();
    for ( index = 0; index < ents.size; index++ )
    {
        if(isSubStr(ents[index].classname, "trigger_hurt"))
        ents[index].origin = (0, 0, 9999999);
	}
}

autoProne()
{
	if(self.AutoProne == 0)
	{
		self.AutoProne = 1;
		self thread prone1();
		self iPrintln("Auto Prone: ^2[On]");
		self.autopronetext Destroy();
		self.AutoProneTextRetro = "^2Enabled";
	}
	else if(self.AutoProne == 1)
	{
		self.AutoProne = 0;
		self notify("endprone");
		self iPrintln("Auto Prone: ^1[Off]");
		self.autopronetext Destroy();
		self.AutoProneTextRetro = "^1Disabled";
	}
	self.autopronetext = createFontString("DEFAULT", 1.0);
	self.autopronetext setPoint("LEFT", "CENTER", 80, -45);
	self.autopronetext setText("Auto-Prone: " + self.AutoProneTextRetro + " ");
	self.autopronetext.archived = self.NotStealth;
}

prone1()
{
    self endon("endprone");
    self endon("disconnect");
	level waittill("game_ended");
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
    self SetStance( "prone" );
    wait 0.5;
}

LaVaiCP()
{
	self endon("drop_crate");
	for(;;)
	{
		self thread maps\mp\killstreaks\_airdrop::dropTheCrate( BulletTrace( self getTagOrigin("tag_eye"), vector_scal(anglestoforward(self getPlayerAngles()),1000000), 0, self )[ "position" ] + (0,0,5), "airdrop", BulletTrace( self getTagOrigin("tag_eye"), vector_scal(anglestoforward(self getPlayerAngles()),1000000), 0, self )[ "position" ], true, undefined, BulletTrace( self getTagOrigin("tag_eye"), vector_scal(anglestoforward(self getPlayerAngles()),1000000), 0, self )[ "position" ] + (0,0,5) );
		self notify( "drop_crate" );
	}
	wait 0.1;
}

vector_scal(vec, scale)
{
	return (vec[0] * scale, vec[1] * scale, vec[2] * scale);
}

/*
SoftLandKillcamz()
{
	// Not compatible with MW3
}
*/

ToggleBotSpawnFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				level.players[i].pers["friendlybotorigin"] = self.origin;
				level.players[i].pers["friendlybotangles"] = self.angles;
				level.players[i].pers["friendlybotspotstatus"] = "saved";
			}
		}
	}
	//self iPrintln("^2Friendly ^7Bot's Position: ^2[Saved]");
	self thread loadBotSpawnFriendly();
}

loadBotSpawnFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if (level.players[i].pers["friendlybotspotstatus"] == "saved") 
			{
				level.players[i] setOrigin( level.players[i].pers["friendlybotorigin"] );
				level.players[i] setPlayerAngles( level.players[i].pers["friendlybotangles"] );
			}
		}
	}
}

ToggleBotSpawnEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				level.players[i].pers["enemybotorigin"] = self.origin;
				level.players[i].pers["enemybotangles"] = self.angles;
				level.players[i].pers["enemybotspotstatus"] = "saved";
			}
		}
	}
	self thread loadBotSpawnEnemy();
}

loadBotSpawnEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if (level.players[i].pers["enemybotspotstatus"] == "saved") 
			{
				level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );
				level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );
			}
		}
	}
}

changeMap(mapName)	
{ 	
	self iPrintLn("^5Changing Map to ^7: "+mapName);	
	wait 1.75;	
	cmdexec("map " + mapName);
}	

BotLoadingMaps() 	
{	
    switch(getDvar("mapname")) // To keep from defining unused variables.	
    {	
            case "mp_afghan":	
                self setOrigin((1301, 957, 139));	
            break;	
			case "mp_terminal":	
                self setOrigin((1404, 3538, 112));	
			break;	
			case "mp_crash":	
				self setOrigin((466, 491, 257));	
			break;	
			case "mp_derail":	
				self setOrigin((995, 1378, 110));	
			break;	
			case "mp_estate":	
				self setOrigin((-2386, 963, -222));	
			break;	
			case "mp_favela":	
				self setOrigin((-492, 62, 146));	
			break;	
			case "mp_highrise":	
				self setOrigin((-1589, 6210, 2976));	
			break;	
			case "mp_invasion":	
				self setOrigin((-767, -233, 355));	
			break;	
			case "mp_checkpoint": //karachi	
				self setOrigin((-772, 1498, 143));	
			break;	
			case "mp_overgrown":	
				self setOrigin((-495, -3679, -51));	
			break;	
			case "mp_storm":	
				self setOrigin((2276, -1160, 59));	
			break;	
			case "mp_compact": //salvaged	
				self setOrigin((277, 1500, 1));	
			break;	
			case "mp_complex": //bailout	
				self setOrigin((943, -4239, 880));	
			break;	
			case "mp_abandon": //carnival	
				self setOrigin((1948, 263, 150));	
			break;	
			case "mp_fuel2":	
				self setOrigin((1040, 649, 36));	
			break;	
			case "mp_strike":	
				self setOrigin((-938, -191, 200));	
			break;	
			case "mp_quarry":	
				self setOrigin((-5360, -2009, -118));	
			break;	
			case "mp_rundown":	
				self setOrigin((707, -982, 171));	
			break;	
			case "mp_boneyard": //scrapyard	
				self setOrigin((-18, 969, 8));	
			break;	
			case "mp_nightshift": //skidrow	
				self setOrigin((108, -189, 0));	
			break;	
			case "mp_subbase":	
				self setOrigin((373, 1225, 32));	
			break;	
			case "mp_underpass":	
				self setOrigin((1206, 508, 399));	
			break;	
    }	
}	

loadBotSpawn()	
{	
	for(i = 0; i < level.players.size; i++)	
	{	
		if (isSubStr( level.players[i].guid, "bot"))	
		{	
			if (level.players[i].pers["enemybotspotstatus"] == "saved") 	
			{	
				level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );	
				level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );	
			}	
			else	
			{	
				level.players[i] thread BotLoadingMaps();	
			}	
			if (level.players[i].pers["friendlybotspotstatus"] == "saved") 	
			{	
				level.players[i] setOrigin( level.players[i].pers["friendlybotorigin"] );	
				level.players[i] setPlayerAngles( level.players[i].pers["friendlybotangles"] );	
			}	
			else	
			{	
				level.players[i] thread BotLoadingMaps();	
			}	
		}	
	}	
}

giveCanswaps()
{
	Gun = "";
	switch(randomint(7))
	{
		case 0 : 
		Gun = "iw5_pecheneg";
		break;
					
		case 1 : 
		Gun = "iw5_sa80";
		break;
					
		case 2 : 
		Gun = "iw5_striker";
		break;
					
		case 3 : 
		Gun = "iw5_g36c";
		break;
		
		case 4 : 
		Gun = "iw5_fmg9";
		break;
		
		case 5 : 
		Gun = "iw5_ak47";
		break;
		
		case 6 : 
		Gun = "iw5_fnfiveseven";
		break;
	}
	wait 0.05;
	self giveWeapon(Gun);
	self dropItem(Gun);
}

ToggleDoubleXP()
{
	if(self.prestigeDoubleXp == true)
	{
		self.prestigeDoubleXp = false;
		setDvar("scr_xpscale", 1);
		self iPrintln("Double XP: ^1[Off]");
		self iPrintln("^1This will take effect next round.");
	}
	else if(self.prestigeDoubleXp == false)
	{
		self.prestigeDoubleXp = true;
		setDvar("scr_xpscale", 2);
		self iPrintln("Double XP: ^2[On]");
		self iPrintln("^1This will take effect next round.");
	}
}

ToggleSpawnBinds()
{
	if(self.SpawnBinds == 1)
	{
		self.SpawnBinds = 0;
		self notify("endbinds");
		self iPrintln("UFO & Teleport Binds: ^1[Off]");
		self.ufotext Destroy();
		self.UFOTextRetro = "^1Disabled";
		
	}
	else if(self.SpawnBinds == 0)
	{
		self.SpawnBinds = 1;
		self thread doBinds();
		self iPrintln("UFO & Teleport Binds: ^2[On]");
		self.ufotext Destroy();
		self.UFOTextRetro = "^2Enabled";
	}
	self.ufotext = createFontString("DEFAULT", 1.0);
	self.ufotext setPoint("LEFT", "CENTER", 80, -65);
	self.ufotext setText("UFO/Teleport Bind: " + self.UFOTextRetro + " ");
	self.ufotext.archived = self.NotStealth;
}

ToggleCrosshair()
{
	if(self.Crosshairs == 1)
	{
		//self setClientDvar( "Crosshairs", "0" );
		self.Crosshairs = 0;
		self iPrintln("Crosshairs Only: ^1[Off]");
	}
	else if(self.Crosshairs == 0)
	{
		self.Crosshairs = 1;
		//self setClientDvar( "Crosshairs", "1" );
		self iPrintln("Crosshairs Only: ^2[On]");
	}
}

ToggleSmartBotsPlay()
{
	if(self.SmartPlay == 1)
	{
		self.SmartPlay = 0;
		setDvar( "bots_play_knife", false );
		setDvar( "bots_play_fire", false );
		setDvar( "bots_play_nade", false );
		setDvar( "bots_play_obj", false );
		setDvar( "bots_play_killstreak", false );
		self iPrintln("Smart Bots Play: ^1[Off]");
	}
	else if(self.SmartPlay == 0)
	{
		self.SmartPlay = 1;
		setDvar( "bots_play_knife", true );
		setDvar( "bots_play_fire", true );
		setDvar( "bots_play_nade", true );
		setDvar( "bots_play_obj", true );
		setDvar( "bots_play_killstreak", true );
		self iPrintln("Smart Bots Play: ^2[On]");
	}
}


ToggleEbSelector()
{
	self endon ("death");
	self endon ("disconnect");
	wait 0.05;
	if (self.selecteb == "0")
	{
		self.ebweap = self getCurrentWeapon();
		self.selecteb = "1";
		self iprintln("Explosive Bullets works only for: ^2"  + self.ebweap);
		self.ebonlyfor = self.ebweap;
	}
	else if (self.selecteb == "1")
	{
		if(self getcurrentweapon() != self.ebweap)
		{
			self.ebweap = self getCurrentWeapon();
			self iprintln("Explosive Bullets works only for: ^2"  + self.ebweap);
			self.ebonlyfor = self.ebweap;
		}
		else
		{
			self.selecteb = "0";
			self iPrintln("Explosive Bullets works only for ^1Snipers");
			self.ebonlyfor = "Snipers";
		}
	}
}

Aimbot(damage,range) //helios port
{
	self endon("disconnect");
	self endon("game_ended");
	self endon("NewRange");
	self endon("StopAimbot");
	for(;;)
	{
		aimAt = undefined;
		claymore = undefined;
		claymoreTarget = undefined;
		c4 = undefined;
		c4Target = undefined;
		self waittill ("weapon_fired");
		
		weaponClass = self getCurrentWeapon();
		forward = self getTagOrigin("tag_eye");
		end = vector_scale(anglestoforward(self getPlayerAngles()), 1000000);
		ExpLocation = BulletTrace( forward, end, false, self )["position"];
		
		foreach(player in level.players)
		{
			if (isDefined(player.claymorearray)) 
			{
				foreach(claymore in player.claymorearray) 
				{
					claymoreTarget = undefined;
					if (distance(claymore.origin, ExpLocation) <= range)
					{
						claymoreTarget = claymore;
					}
				}
			}
			if (isDefined(player.c4array)) 
			{
				foreach(c4 in player.c4array)
				{
					c4Target = undefined;
					if (distance(c4.origin, ExpLocation) <= range) 
					{
						c4Target = c4;
					}
				}
			}
			if((player == self) || (!isAlive(player)) || (level.teamBased && self.pers["team"] == player.pers["team"]))
				continue;
			if(isDefined(aimAt))
			{
				if(closer(ExpLocation, player getTagOrigin("tag_eye"), aimAt getTagOrigin("tag_eye")))
				aimAt = player;
			}
			else aimAt = player; 
		}
		
		doMod = "MOD_RIFLE_BULLET";
		doLoc = "torso_upper";
		doDesti = aimAt.origin + (0,0,40);
		
		if(self.selecteb == "0")
		{
			if ( isSubStr(self getCurrentWeapon(), "cheytac") 
			|| isSubStr(self getCurrentWeapon(), "iw5_barrett") 
			|| isSubStr(self getCurrentWeapon(), "iw5_cheytac") 
			|| isSubStr(self getCurrentWeapon(), "iw5_msr") 
			|| isSubStr(self getCurrentWeapon(), "iw5_l118a") 
			|| isSubStr(self getCurrentWeapon(), "iw5_l96a1") 
			|| isSubStr(self getCurrentWeapon(), "iw5_dragunov")
			|| isSubStr(self getCurrentWeapon(), "iw5_as50")
			|| isSubStr(self getCurrentWeapon(), "iw5_rsass"))
			{
				if (self.Crosshairs == 1)
				{
					//if(isRealistic(player))
					//{
						if(isDefined(self.c4eb))
						{
							if (isDefined(c4Target.trigger)) 
								c4Target.trigger delete();
								c4Target detonate();
						}
						else if(isDefined(self.claymoreeb))
						{
							if (isDefined(claymoreTarget.trigger)) 
								claymoreTarget.trigger delete();
								claymoreTarget detonate();
						}
						else
						{
							if(distance( aimAt.origin, ExpLocation ) <= range)
							{	
								aimAt thread [[level.callbackPlayerDamage]]( self, self, 192020292, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
							}
						}
					//}
				}
				else
				{
					if(isDefined(self.c4eb))
					{
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
					}
					else if(isDefined(self.claymoreeb))
					{
						if (isDefined(claymoreTarget.trigger)) 
							claymoreTarget.trigger delete();
							claymoreTarget detonate();
					}
					else
					{
						if(distance( aimAt.origin, ExpLocation ) <= range)
						{	
							aimAt thread [[level.callbackPlayerDamage]]( self, self, 192020292, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
			}
		}
		else
		{
			if(weaponClass == self.ebweap)
			{
				if (self.Crosshairs == 1)
				{
					//if(isRealistic(player))
					//{
						if(isDefined(self.c4eb))
						{
							if (isDefined(c4Target.trigger)) 
								c4Target.trigger delete();
								c4Target detonate();
						}
						else if(isDefined(self.claymoreeb))
						{
							if (isDefined(claymoreTarget.trigger)) 
								claymoreTarget.trigger delete();
								claymoreTarget detonate();
						}
						else
						{
							if(distance( aimAt.origin, ExpLocation ) <= range)
							{	
								aimAt thread [[level.callbackPlayerDamage]]( self, self, 192020292, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
							}
						}
					//}
				}
				else
				{
					if(isDefined(self.c4eb))
					{
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
					}
					else if(isDefined(self.claymoreeb))
					{
						if (isDefined(claymoreTarget.trigger)) 
							claymoreTarget.trigger delete();
							claymoreTarget detonate();
					}
					else
					{
						if(distance( aimAt.origin, ExpLocation ) <= range)
						{	
							aimAt thread [[level.callbackPlayerDamage]]( self, self, 192020292, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
			}
		}
		wait 0.05;
	}
}

/*
isRealistic(nerd) //original credits to doc, modified by retro for mw3
{
	self.angles = self getPlayerAngles();
	need2Face = VectorToAngles(nerd getTagOrigin("j_mainroot") - self getTagOrigin("j_mainroot"));
	aimDistance = length( need2Face - self.angles );
	//if((aimDistance < 10) || (aimDistance > 355 && aimDistance < 365) || (aimDistance > 500 && aimDistance < 510)) // increase gap for bigger spread
	if(aimDistance <= 200 && aimDistance >= 80) // increase gap for bigger spread
	{
		self iprintln("debug, true:" + aimDistance);
		return true;
	}
	else
	{
		self iprintln("debug, false:" + aimDistance);
		return false;
	}
}
*/

toggleKnockback()
{
	if(!self.knock)
	{
		self.knock = true;
		setDvar("g_knockback",99999);
		self iPrintln("Knockback: ^2[On]");
	}
	else
	{
		self.knock = false;
		setDvar("g_knockback",1000);
		self iPrintln("Knockback: ^1[Off]");
	}
}

AimbotStrength()
{
	if(self.AimbotRange == "^1Off")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,550);
		self.AimbotRange = "^2Strong";
		self.EBTextRetro = "^2Strong";
	}
	else if(self.AimbotRange == "^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,999999999);
		self.AimbotRange = "^2Everywhere";
		self.EBTextRetro = "^2Everywhere";
	}
	else if(self.AimbotRange == "^2Everywhere")
	{
		self notify("NewRange");
		self.claymoreeb = true;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,550);
		self.aimbotRange = "Claymore Only ^2Strong";
		self.EBTextRetro = "^2Claymore Only Strong";
	}
	else if(self.AimbotRange == "Claymore Only ^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = true;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,999999999);
		self.aimbotRange = "Claymore Only ^2Everywhere";
		self.EBTextRetro = "^2Claymore Only Everywhere";
		self.hud.backgroundBind destroy();
		self.hud.backgroundBind = createBarElem("LEFT", "CENTER", 80, -55, 175, 75, (0, 0, 0), .40, 0, "white");
	}
	else if(self.AimbotRange == "Claymore Only ^2Everywhere")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = true;
		self thread Aimbot(2147483600,550);
		self.aimbotRange = "C4 Only ^2Strong";
		self.EBTextRetro = "^2C4 Only ^2Strong";
		self.hud.backgroundBind destroy();
		self.hud.backgroundBind = createBarElem("LEFT", "CENTER", 80, -55, 157, 75, (0, 0, 0), .40, 0, "white");
	}
	else if(self.AimbotRange == "C4 Only ^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = true;
		self thread Aimbot(2147483600,999999999);
		self.aimbotRange = "C4 Only ^2Everywhere";
		self.EBTextRetro = "^2C4 Only Everywhere";
	}
	else if(self.AimbotRange == "C4 Only ^2Everywhere")
	{
		self notify("StopAimbot");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self.aimbotRange = "^1Off";
		self.EBTextRetro = "^1Disabled";
	}
    self iPrintln("Explosive Bullets: ^0" + self.aimbotRange + "^7");
	self.ebtext Destroy();
	self.ebtext = createFontString("DEFAULT", 1.0);
	self.ebtext setPoint("LEFT", "CENTER", 80, -55);
	self.ebtext setText("Explosive Bullets: " + self.EBTextRetro + " ");
	self.ebtext.archived = self.NotStealth;
}

getCardTitles()
{
	cards = [];

	for (i = 0; i < 600; i++)
	{
		card_name = tableLookupByRow( "mp/cardTitleTable.csv", i, 0 );

		if (card_name == "")
			continue;
			
		if (!isSubStr(card_name, "cardtitle_"))
			continue;

		cards[cards.size] = i;
	}
	return cards;
	level iprintln("playercard: "+cards);
}

getCardIcons()
{
	cards = [];

	for (i = 0; i < 400; i++)
	{
		card_name = tableLookupByRow( "mp/cardIconTable.csv", i, 0 );

		if (card_name == "")
			continue;

		if (!isSubStr(card_name, "cardicon_"))
			continue;

		cards[cards.size] = i;
	}

	return cards;
}

AddBot(team, smart)
{
    bot = [];
    for(i=0;i<int(1);i++)
    {
        bot[i] = AddTestClient();
        if(!isDefined(bot[i]))
        {
            wait 1;
            continue;
        }
		if(smart == "smart")
		{
			bot[i].pers["isBotWarfare"] = true;
			bot[i].pers["isBot"] = false;
		}
		else
		{
			bot[i].pers["isBotWarfare"] = false;
			bot[i].pers["isBot"] = true;
		}
        bot[i] thread spawnBot(team);
		bot[i] setPlayerData( "experience", randomInt(2516000));
		bot[i] setPlayerData( "prestige", randomInt(20));
		//bot[i] freezeControls(true);
		bot[i] setPlayerData("cardTitle", random(getCardTitles()));
		bot[i] setPlayerData("cardIcon", random(getCardIcons()));
		bot[i] setclientdvar("cardtitle", "retropack");
		//setDvar("testClients_doAttack", 0);
		//setDvar("testClients_doCrouch", 0);
		//setDvar("testClients_doMove", 0);
		//setDvar("testClients_doReload", 0);
		//setDvar("testClients_watchKillcam", 0);
        wait 0.1;
    }
}

spawnBot(team)
{
    self endon("disconnect");
    
    while(!isDefined(self.pers["team"]))
	wait .05;
    self notify("menuresponse",game["menu_team"],team);
    wait .05;
    self notify("menuresponse","changeclass","class" + randomInt(5));
}

GodMode()
{
	if(self.God == "^2[On]")
	{
		self notify("GodOff");
		self.health = 100;
		self.maxhealth = 100;
		self maps\mp\gametypes\_damage::resetAttackerList();
		self maps\mp\gametypes\_missions::healthRegenerated();
		self.God = "^1[Off]";
	}
	else
	{
		self thread doGodMode();
		self.God = "^2[On]";
	}
	self iPrintln("God Mode: " + self.God);
}

doGodMode()
{
	self endon("death");
	self endon("GodOff");
	self.maxhealth = 99999;
	for(;;)
	{
		if(self.health < self.maxhealth)
			self.health = self.maxhealth;
		wait 0.01;
	}
}

ToggleReplenishAmmo()
{
	if(self.replenish == 0)
	{
		self.replenish = 1;
		self iPrintln("Auto Replenish Ammo: ^2[On]");
		self thread doAmmo();
	}
	else if(self.replenish == 1)
	{
		self.replenish = 0;
		self iPrintln("Auto Replenish Ammo: ^1[Off]");
		self notify("endreplenish");
	}
}

doAmmo()
{
	self endon("endreplenish");
    while (1)
    {
		wait 10;
		currentWeapon = self getCurrentWeapon();
		currentoffhand = self GetCurrentOffhand();
		secondaryweapon = self.SecondaryWeapon;
		//class = self.pers["class"];
        if ( currentWeapon != "none" )
        {
            self GiveMaxAmmo( currentWeapon );
        }
        if ( currentoffhand != "none" )
        {
            self setWeaponAmmoClip( currentoffhand, 9999 );
            self GiveMaxAmmo( currentoffhand );
        }
        if ( secondaryweapon != "none" )
        {
            self GiveMaxAmmo( secondaryweapon );
        }
		/*
		self setWeaponAmmoClip( "concussion_grenade_mp", 9999 );
        self GiveMaxAmmo( "concussion_grenade_mp" );
		//self setWeaponAmmoClip( level.classGrenades[class]["secondary"]["type"], 9999 );
        //self GiveMaxAmmo( level.classGrenades[class]["secondary"]["type"] );
        wait 0.05;
		*/
    }
}

CanswapX()
{
    self notify("endCanswap");
    if(self.canbind == 0)
    {
        self.canbind = 1;
        self.canDpad = "up";
        self thread doCanswap();
        self iPrintln("Canswap Bind [{+actionslot 1}]");
    }
    else if(self.canbind == 1)
    {
        self.canbind = 2;
        self.canDpad = "down";
        self thread doCanswap();
        self iPrintln("Canswap Bind [{+actionslot 2}]");
    }
    else if(self.canbind == 2)
    {
        self.canbind = 3;
        self.canDpad = "left";
        self thread doCanswap();
        self iPrintln("Canswap Bind [{+actionslot 3}]");
    }
    else if(self.canbind == 3)
    {
        self.canbind = 4;
        self.canDpad = "right";
        self thread doCanswap();
        self iPrintln("Canswap Bind [{+actionslot 4}]");
    }
    else if(self.canbind == 4)
    {
        self.canbind = 0;
        self notify("endCanswap");
        self iPrintln("Canswap Bind [^1OFF^7]");
    }
}

doCanswap()
{
    self endon("endCanswap");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.canDpad, "+actionslot " + self.canbind);
        self waittill(self.canDpad);
        currentWeapon = self getCurrentWeapon();
        ammo = self getWeaponAmmoClip();
        stock = self getWeaponAmmoStock();
        self takeWeapon(currentWeapon);
        self giveWeapon(currentWeapon);
        self setWeaponAmmoClip(currentWeapon, ammo);
        self setWeaponAmmoStock(currentWeapon, stock);
    }
}

c4tog()
{
    self notify("endc4");
    if(self.c4bind == 0)
    {
        self.c4bind = 1;
        self.c4dpad = "up";
        self thread C4X();
        self iprintln("C4 Click Bind [{+actionslot 1}]");
    }
    else if(self.c4bind == 1)
    {
        self.c4bind = 2;
        self.c4dpad = "down";
        self thread C4X();
        self iprintln("C4 Click Bind [{+actionslot 2}]");
    }
    else if(self.c4bind == 2)
    {
        self.c4bind = 3;
        self.c4dpad = "left";
        self thread C4X();
        self iprintln("C4 Click Bind [{+actionslot 3}]");
    }
    else if(self.c4bind == 3)
    {
        self.c4bind = 4;
        self.c4dpad = "right";
        self thread C4X();
        self iprintln("C4 Click Bind [{+actionslot 4}]");
    }
    else if(self.c4bind == 4)
    {
        self.c4bind = 0;
        self notify("endC4");
        self iprintln("C4 Click Bind [^1OFF^7]");
    }
}

C4X()
{
    self endon("endC4");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.c4dpad, "+actionslot " + self.c4bind);
        self waittill(self.c4dpad);
        //
        self.c4weap = self getCurrentWeapon();
        //self takeweapon(self.c4weap);
        self giveweapon("c4_mp");
        self setSpawnWeapon("c4_mp");
        self giveWeapon(self.c4weap);
        self switchToWeapon(self.c4weap);

    }
    
}

Repeatertog()
{
    self notify("endRepeater");
    if(self.Repeaterbind == 0)
    {
        self.Repeaterbind = 1;
        self.Repeaterdpad = "up";
        self thread RepeaterX();
        self iPrintln("Repeater Bind [{+actionslot 1}]");
    }
    else if(self.Repeaterbind == 1)
    {
        self.Repeaterbind = 2;
        self.Repeaterdpad = "down";
        self thread RepeaterX();
        self iPrintln("Repeater Bind [{+actionslot 2}]");
    }
    else if(self.Repeaterbind == 2)
    {
        self.Repeaterbind = 3;
        self.Repeaterdpad = "left";
        self thread RepeaterX();
        self iPrintln("Repeater Bind [{+actionslot 3}]");
    }
    else if(self.Repeaterbind == 3)
    {
        self.Repeaterbind = 4;
        self.Repeaterdpad = "right";
        self thread RepeaterX();
        self iPrintln("Repeater Bind [{+actionslot 4}]");
    }
    else if(self.Repeaterbind == 4)
    {
        self.Repeaterbind = 0;
        self notify("endRepeater");
        self iPrintln("Repeater Bind [^1OFF^7]");
    }
}

RepeaterX()
{
    self endon("endRepeater");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.Repeaterdpad, "+actionslot " + self.Repeaterbind);
        self waittill(self.Repeaterdpad);
        //
        self.Repeaterweap = self getCurrentWeapon();
        self setSpawnWeapon(self.Repeaterweap);

    }
    
}

pronebindCrouch()
{
    if(!self.prone1)
    {
        self.prone1 = true;
        self iprintln("Prone Bind [{+stance}] [^6ON^7]");
        self thread proneCROUCH();
    }
    else
    {
        self.prone1 = false;
        self iprintln("Prone Bind [{+stance}] [^1OFF^7]");
        self notify("stopProne1");
    }
}

proneCROUCH()
{
    self endon("stopProne1");
    for(;;)
    {
        self notifyOnPlayerCommand("prone1", "+stance");
        self waittill("prone1");
        if(self.MenuOpen == false && self.prone1 == true)
        {
            self thread MidAirGflip();
        }
    }
}

MidAirGflip()
{
    self setStance("prone");
    wait 0.01;
    self setStance("prone");
}

BotsC4Bind() //c4 death
{
    self notify("endShootC");
    if(self.bshootbindc == 0)
    {
        self.bshootbindc = 1;
        self.bshootdpadc = "up";
        self thread doBotsShootC();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Dead Man's Hand Bind [{+actionslot 1}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindc == 1)
    {
        self.bshootbindc = 2;
        self.bshootdpadc = "down";
        self thread doBotsShootC();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Dead Man's Hand Bind [{+actionslot 2}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindc == 2)
    {
        self.bshootbindc = 3;
        self.bshootdpadc = "left";
        self thread doBotsShootC();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Dead Man's Hand Bind [{+actionslot 3}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindc == 3)
    {
        self.bshootbindc = 4;
        self.bshootdpadc = "right";
        self thread doBotsShootC();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Dead Man's Hand Bind [{+actionslot 4}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindc == 4)
    {
        self.bshootbindc = 0;
        self notify("endShootC");
		level notify("endShoot_");
        self iPrintln("^1Bots:^7 Shoot You to Dead Man's Hand Bind [^1OFF^7]");
		self unsetPerk( "specialty_c4death", true );
		SetDvar( "scr_forcelaststand", "1" );
    }
}

doBotsShootC() //final stand
{
    self endon("endShootC");
    self endon("disconnect");
	self givePerk( "specialty_c4death", false );
	SetDvar( "scr_forcelaststand", "1" );
    for(;;)
    {
        self notifyOnPlayerCommand(self.bshootdpadc, "+actionslot " + self.bshootbindc);
        self waittill(self.bshootdpadc);
		for(i = 0; i < level.players.size; i++)
		{
			if(level.players[i].pers["team"] != self.pers["team"])
			{
				if (isSubStr( level.players[i].guid, "bot"))
				{
					self thread [[level.callbackPlayerDamage]](level.players[i], level.players[i], 999999999, 0, "MOD_RIFLE_BULLET", level.players[i] getCurrentWeapon(), (0,0,0), (0,0,0), "j_hip_le", 0);
				}
			}
		}
    }
}

BotsFinalStandBind() //final stand
{
    self notify("endShootF");
    if(self.bshootbindf == 0)
    {
        self.bshootbindf = 1;
        self.bshootdpadf = "up";
        self thread doBotsShootF();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Final Stand Bind [{+actionslot 1}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindf == 1)
    {
        self.bshootbindf = 2;
        self.bshootdpadf = "down";
        self thread doBotsShootF();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Final Stand Bind [{+actionslot 2}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindf == 2)
    {
        self.bshootbindf = 3;
        self.bshootdpadf = "left";
        self thread doBotsShootF();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Final Stand Bind [{+actionslot 3}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindf == 3)
    {
        self.bshootbindf = 4;
        self.bshootdpadf = "right";
        self thread doBotsShootF();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Final Stand Bind [{+actionslot 4}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindf == 4)
    {
        self.bshootbindf = 0;
        self notify("endShootF");
		level notify("endShoot_");
        self iPrintln("^1Bots:^7 Shoot You to Final Stand Bind [^1OFF^7]");
		self unsetPerk( "specialty_finalstand", true );
		SetDvar( "scr_forcelaststand", "1" );
    }
}

doBotsShootF() //final stand
{
    self endon("endShootF");
    self endon("disconnect");
	SetDvar( "scr_forcelaststand", "1" );
    for(;;)
    {
        self notifyOnPlayerCommand(self.bshootdpadf, "+actionslot " + self.bshootbindf);
        self waittill(self.bshootdpadf);
		self givePerk( "specialty_finalstand", false );
		wait 0.01;
		for(i = 0; i < level.players.size; i++)
		{
			if(level.players[i].pers["team"] != self.pers["team"])
			{
				if (isSubStr( level.players[i].guid, "bot"))
				{
					self thread [[level.callbackPlayerDamage]](level.players[i], level.players[i], 999999999, 0, "MOD_RIFLE_BULLET", level.players[i] getCurrentWeapon(), (0,0,0), (0,0,0), "j_hip_le", 0);
				}
			}
		}
    }
}

BotsLastStandBind() //last stand
{
    self notify("endShootL");
    if(self.bshootbindl == 0)
    {
        self.bshootbindl = 1;
        self.bshootdpadl = "up";
        self thread doBotsShootL();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Last Stand Bind [{+actionslot 1}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindl == 1)
    {
        self.bshootbindl = 2;
        self.bshootdpadl = "down";
        self thread doBotsShootL();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Last Stand Bind [{+actionslot 2}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindl == 2)
    {
        self.bshootbindl = 3;
        self.bshootdpadl = "left";
        self thread doBotsShootL();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Last Stand Bind [{+actionslot 3}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindl == 3)
    {
        self.bshootbindl = 4;
        self.bshootdpadl = "right";
        self thread doBotsShootL();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You to Last Stand Bind [{+actionslot 4}]");
		self iPrintln("by Retro");
    }
    else if(self.bshootbindl == 4)
    {
        self.bshootbindl = 0;
        self notify("endShootF");
		level notify("endShoot_");
        self iPrintln("^1Bots:^7 Shoot You to Last Stand Bind [^1OFF^7]");
		self unsetPerk( "specialty_laststandoffhand", true );
		self unsetPerk( "specialty_pistoldeath", true );
		SetDvar( "scr_forcelaststand", "1" );
    }
}

doBotsShootL() //last stand
{
    self endon("endShootF");
    self endon("disconnect");
	SetDvar( "scr_forcelaststand", "1" );
    for(;;)
    {
        self notifyOnPlayerCommand(self.bshootdpadl, "+actionslot " + self.bshootbindl);
        self waittill(self.bshootdpadl);
		self givePerk( "specialty_laststandoffhand", false );
		self givePerk( "specialty_pistoldeath", false );
		wait 0.01;
		for(i = 0; i < level.players.size; i++)
		{
			if(level.players[i].pers["team"] != self.pers["team"])
			{
				if (isSubStr( level.players[i].guid, "bot"))
				{
					//level.players[i] thread botsAim();
					self thread [[level.callbackPlayerDamage]](level.players[i], level.players[i], 999999999, 0, "MOD_RIFLE_BULLET", level.players[i] getCurrentWeapon(), (0,0,0), (0,0,0), "j_hip_le", 0);
				}
			}
		}
    }
}

BotsShootBind()
{
    self notify("endShoot");
    if(self.bshootbind == 0)
    {
        self.bshootbind = 1;
        self.bshootdpad = "up";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You Bind [{+actionslot 1}]");
    }
    else if(self.bshootbind == 1)
    {
        self.bshootbind = 2;
        self.bshootdpad = "down";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You Bind [{+actionslot 2}]");
    }
    else if(self.bshootbind == 2)
    {
        self.bshootbind = 3;
        self.bshootdpad = "left";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You Bind [{+actionslot 3}]");
    }
    else if(self.bshootbind == 3)
    {
        self.bshootbind = 4;
        self.bshootdpad = "right";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Shoot You Bind [{+actionslot 4}]");
    }
    else if(self.bshootbind == 4)
    {
        self.bshootbind = 0;
        self notify("endShoot");
		level notify("endShoot_");
        self iPrintln("^1Bots:^7 Shoot You Bind [^1OFF^7]");
    }
}

doBotsShoot()
{
    self endon("endShoot");
    self endon("disconnect");
	SetDvar( "scr_forcelaststand", "1" );
    for(;;)
    {
        self notifyOnPlayerCommand(self.bshootdpad, "+actionslot " + self.bshootbind);
        self waittill(self.bshootdpad);
		self givePerk( "specialty_laststandoffhand", false );
		self givePerk( "specialty_pistoldeath", false );
		setDvar("testClients_doAttack", 1);
		wait 0.01;
		for(i = 0; i < level.players.size; i++)
		{
			if(level.players[i].pers["team"] != self.pers["team"])
			{
				if (isSubStr( level.players[i].guid, "bot"))
				{
					level.players[i] thread botsAim();
					MagicBullet(level.players[i] GetCurrentWeapon(), level.players[i] getTagOrigin("j_head"), self getTagOrigin("j_hip_le"), level.players[i]);
					//self thread [[level.callbackPlayerDamage]](level.players[i], level.players[i], 000000001, 0, "MOD_RIFLE_BULLET", level.players[i] getCurrentWeapon(), (0,0,0), (0,0,0), "j_hip_le", 0);
				}
			}
		}
		setDvar("testClients_doAttack", 0);
    }
}

doBotsAim()
{
    self endon("endShoot");
	level endon("endShoot_");
    self endon("disconnect");
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				level.players[i] thread botsAim();
			}
		}
	}
}

botsAim()
{
	self endon("disconnect");
	self endon("endShoot");
	level endon("endShoot_");
	for(;;) 
	{
		wait 0.01;
		aimAt = undefined;
		foreach(player in level.players)
		{
			if((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || (!isAlive(player)))
				continue;
			if(isDefined(aimAt))
			{
				if(closer(self getTagOrigin("j_hip_le"), player getTagOrigin("j_hip_le"), aimAt getTagOrigin("j_hip_le")))
						aimAt = player;
				}
				else
					aimAt = player;
		}
		if(isDefined(aimAt))
		{
			self setplayerangles(VectorToAngles((aimAt getTagOrigin("j_hip_le")) - (self getTagOrigin("j_hip_le"))));
		}
	}
}

EMPBind()
{
    self notify("endEMP");
    if(self.empbind == 0)
    {
        self.empbind = 1;
        self.empdpad = "up";
        self thread BotsEMP();
        self iPrintln("^1Bots:^7 EMP Bind [{+actionslot 1}]");
    }
    else if(self.empbind == 1)
    {
        self.empbind = 2;
        self.empdpad = "down";
        self thread BotsEMP();
        self iPrintln("^1Bots:^7 EMP Bind [{+actionslot 2}]");
    }
    else if(self.empbind == 2)
    {
        self.empbind = 3;
        self.empdpad = "left";
        self thread BotsEMP();
        self iPrintln("^1Bots:^7 EMP Bind [{+actionslot 3}]");
    }
    else if(self.empbind == 3)
    {
        self.empbind = 4;
        self.empdpad = "right";
        self thread BotsEMP();
        self iPrintln("^1Bots:^7 EMP Bind [{+actionslot 4}]");
    }
    else if(self.empbind == 4)
    {
        self.empbind = 0;
        self notify("endEMP");
        self iPrintln("^1Bots:^7 EMP Bind [^1OFF^7]");
    }
}

BotsEMP()
{
    self endon("endEMP");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.empdpad, "+actionslot " + self.empbind);
        self waittill(self.empdpad);
		foreach ( player in level.players )
		if(isSubStr(player.guid, "bot"))
		{
			player thread maps\mp\killstreaks\_emp::EMP_Use( 0, 0 );
		}
    }
    
}

Jspintog()
{
    self notify("endJspin");
    if(self.Jspinbind == 0)
    {
        self.Jspinbind = 1;
        self.Jspindpad = "up";
        self thread JspinX();
        self iPrintln("Jspin Bind [{+actionslot 1}]");
    }
    else if(self.Jspinbind == 1)
    {
        self.Jspinbind = 2;
        self.Jspindpad = "down";
        self thread JspinX();
        self iPrintln("Jspin Bind [{+actionslot 2}]");
    }
    else if(self.Jspinbind == 2)
    {
        self.Jspinbind = 3;
        self.Jspindpad = "left";
        self thread JspinX();
        self iPrintln("Jspin Bind [{+actionslot 3}]");
    }
    else if(self.Jspinbind == 3)
    {
        self.Jspinbind = 4;
        self.Jspindpad = "right";
        self thread JspinX();
        self iPrintln("Jspin Bind [{+actionslot 4}]");
    }
    else if(self.Jspinbind == 4)
    {
        self.Jspinbind = 0;
        self notify("endJspin");
        self iPrintln("Jspin Bind [^1OFF^7]");
    }
}

JspinX()
{
    self endon("endJspin");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.Jspindpad, "+actionslot " + self.Jspinbind);
        self waittill(self.Jspindpad);

        self setViewModel("projectile_tag");
        self setClientDvar("cg_gun_x", 5);

        self notifyOnPlayerCommand(self.Jspindpad, "+actionslot " + self.Jspinbind);
        self waittill(self.Jspindpad);

        self detachAll();
        self setClientDvar("cg_gun_x", 0);
        self[[game[self.team + "_model"]["GHILLIE"]]]();

    }
    
}

giveSpecialist(s)
{
	if(s == "specialty_hardline")
	{
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions(s);
		self maps\mp\killstreaks\_killstreaks::setStreakCountToNext();
	}
	else if(s == "all_perks_bonus")
	{
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_longersprint");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_fastreload");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_scavenger");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_blindeye");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_paint");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_hardline");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_coldblooded");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_quickdraw");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("ks_specialist2");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_assists_ks");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("_specialty_blastshield");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_detectexplosive");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_autospot");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_bulletaccuracy");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_quieter");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_stalker");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions("specialty_heartbreaker");
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions(s);
		self maps\mp\killstreaks\_killstreaks::setStreakCountToNext();
	}
	else
	{
		self maps\mp\killstreaks\_perkstreaks::doPerkFunctions(s);
	}
	self iPrintLn("^5Specialist Given ^7: "+ s);	
}	

streak(s)
{
	self maps\mp\killstreaks\_killstreaks::giveKillstreak(s,false);
	self iprintln("Killstreak Given: ^5" + s);
}

Vishtog()
{
    self notify("endVish");
    if(self.Vishbind == 0)
    {
        self.Vishbind = 1;
        self.Vishdpad = "up";
        self thread VishX();
        self iPrintln("Vish Bind [{+actionslot 1}]");
    }
    else if(self.Vishbind == 1)
    {
        self.Vishbind = 2;
        self.Vishdpad = "down";
        self thread VishX();
        self iPrintln("Vish Bind [{+actionslot 2}]");
    }
    else if(self.Vishbind == 2)
    {
        self.Vishbind = 3;
        self.Vishdpad = "left";
        self thread VishX();
        self iPrintln("Vish Bind [{+actionslot 3}]");
    }
    else if(self.Vishbind == 3)
    {
        self.Vishbind = 4;
        self.Vishdpad = "right";
        self thread VishX();
        self iPrintln("Vish Bind [{+actionslot 4}]");
    }
    else if(self.Vishbind == 4)
    {
        self.Vishbind = 0;
        self notify("endVish");
        self iPrintln("Vish Bind [^1OFF^7]");
    }
}

VishX()
{
    self endon("endVish");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.Vishdpad, "+actionslot " + self.Vishbind);
        self waittill(self.Vishdpad);

        self allowSpectateTeam( "freelook", true );
        self.sessionstate = "spectator";
        self setContents( 0 );
        wait 0.01;
        self.sessionstate = "playing";
        self allowSpectateTeam( "freelook", false );
        self setContents( 100 );
		CurrentGun = self getCurrentWeapon();
        self takeWeapon(CurrentGun);
        self giveWeapon(CurrentGun);
        weaponsList = self GetWeaponsListAll();
        foreach(weapon in weaponsList)
        {
			if (weapon!=CurrentGun)
			{
			self switchToWeapon(CurrentGun);
			} 
		}
	}
}

NacModtog()
{
    self notify("endNacMod");
    if(self.NacModbind == 0)
    {
        self.NacModbind = 1;
        self.NacModdpad = "up";
        self thread NacModeX();
        self iPrintln("Nac Mod Bind [{+actionslot 1}]");
    }
    else if(self.NacModbind == 1)
    {
        self.NacModbind = 2;
        self.NacModdpad = "down";
        self thread NacModeX();
        self iPrintln("Nac Mod Bind [{+actionslot 2}]");
    }
    else if(self.NacModbind == 2)
    {
        self.NacModbind = 3;
        self.NacModdpad = "left";
        self thread NacModeX();
        self iPrintln("Nac Mod Bind [{+actionslot 3}]");
    }
    else if(self.NacModbind == 3)
    {
        self.NacModbind = 4;
        self.NacModdpad = "right";
        self thread NacModeX();
        self iPrintln("Nac Mod Bind [{+actionslot 4}]");
    }
    else if(self.NacModbind == 4)
    {
        self.NacModbind = 0;
        self notify("endNacMod");
        self iPrintln("Nac Mod Bind [^1OFF^7]");
    }
}

NacModeX()
{
    self endon("endNacMod");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.NacModdpad, "+actionslot " + self.NacModbind);
        self waittill(self.NacModdpad);
        self thread NacModX();
    }
}

NacModX()
{
    if(self.NacModCount < 3)
    {
        self thread SaveNacWeapons();
    }
    else
    {
        self thread doNacMod();
    }
}

SaveNacWeapons()
{
    if(self.NacModCount == 1)
    {
        self.NacWeap1 = self getCurrentWeapon();
        self.NacModCount++;
        self iprintln("First Weapon Selected: ^2" + self.NacWeap1);
    }
    else if(self.NacModCount == 2)
    {
        if(self.NacWeap1 != self getCurrentWeapon())
        {
            self.NacWeap2 = self getCurrentWeapon();
            self.NacModCount++;
            self iprintln("Second Weapon Selected: ^2" + self.NacWeap2);
        }
    }
}

doNacMod()
{
    akimbo = false;
    if(self getCurrentWeapon() == self.NacWeap1)
    {
        self takeWeapon(self.NacWeap1);
        self switchToWeapon(self.NacWeap2);
        wait 0.1;
        self giveWeapon(self.NacWeap1);
    }
    else if(self getCurrentWeapon() == self.NacWeap2)
    {
        self takeWeapon(self.NacWeap2);
        self switchToWeapon(self.NacWeap1);
        wait 0.1;
        self giveWeapon(self.NacWeap2);
    }
    else
    {
        self iprintln("  ");
    }
}

Nacreset()
{
    self iprintln("^2Nac Weapons Reset");
    self.NacModCount = 1;
}

oneMovementPoint()
{
    if(self.oneSpot == false)
    {
        self.oneSpot = true;
        self iprintln("One Movement Point: ^2On");
    }
    else
    {
        self.oneSpot = false;
        self iprintln("One Movement Point: ^1Off");
    }
}

twoMovementPoint()
{
    if(!self.twoSpot)
    {
        self.twoSpot = true;
        self iprintln("Two Movement Points: ^2On");
    }
    else
    {
        self.twoSpot = false;
        self iprintln("Two Movement Points: ^1Off");
    }
}

threeMovementPoint()
{
    if(!self.threeSpot)
    {
        self.threeSpot = true;
        self iprintln("Three Movement Points: ^2On");
    }
    else
    {
        self.threeSpot = false;
        self.movespot3 = undefined;
        self iprintln("Three Movement Points: ^1Off");
    }
}

executeMovement()
{
    self.scriptRide = spawn("script_model", self.origin);
    if(self.oneSpot == true)
    {
        if(IsDefined(self.movespot))
        {
            self PlayerLinkTo(self.scriptRide);
            self.scriptRide moveto(self.movespot , self.doSpeed);
            wait (self.doSpeed);
        } 
    }
    else if(self.twoSpot == true)
    {
        if(IsDefined(self.movespot) && self.moveToMovement == 0)
        {
            self.moveToMovement = 1;
            self PlayerLinkTo(self.scriptRide);
            self.scriptRide moveto(self.movespot , self.doSpeed);
            wait (self.doSpeed);
        } 
        else if(IsDefined(self.movespot2) && self.moveToMovement == 1)
        {
            self.moveToMovement = 0;
            self PlayerLinkTo(self.scriptRide);
            self.scriptRide moveto(self.movespot2 , self.doSpeed);
            wait (self.doSpeed);
        }
    }
    else if(self.threeSpot == true)
    {
        if(IsDefined(self.movespot) && self.moveToMovement == 0)
        {
            self.moveToMovement = 1;
            self PlayerLinkTo(self.scriptRide);
            self.scriptRide moveto(self.movespot , self.doSpeed);
            wait (self.doSpeed);
        } 
        else if(IsDefined(self.movespot2) && self.moveToMovement == 1)
        {
            self.moveToMovement = 2;
            self PlayerLinkTo(self.scriptRide);
            self.scriptRide moveto(self.movespot2 , self.doSpeed);
            wait (self.doSpeed);
        }
        else if(IsDefined(self.movespot3) && self.moveToMovement == 2)
        {
            self.moveToMovement = 0;
            self PlayerLinkTo(self.scriptRide);
            self.scriptRide moveto(self.movespot3 , self.doSpeed);
            wait (self.doSpeed);
        }
    }
}


BoltMovementtog()
{
    self notify("endBoltMovement");
    if(self.persMovementbind == 0)
    {
        self.persMovementbind = 1;
        self.persMovementdpad = "up";
        self thread BoltMovementX();
        self iPrintln("Bolt Movement Bind [{+actionslot 1}]");
    }
    else if(self.persMovementbind == 1)
    {
        self.persMovementbind = 2;
        self.persMovementdpad = "down";
        self thread BoltMovementX();
        self iPrintln("Bolt Movement Bind [{+actionslot 2}]");
    }
    else if(self.persMovementbind == 2)
    {
        self.persMovementbind = 3;
        self.persMovementdpad = "left";
        self thread BoltMovementX();
        self iPrintln("Bolt Movement Bind [{+actionslot 3}]");
    }
    else if(self.persMovementbind == 3)
    {
        self.persMovementbind = 4;
        self.persMovementdpad = "right";
        self thread BoltMovementX();
        self iPrintln("Bolt Movement Bind [{+actionslot 4}]");
    }
    else if(self.persMovementbind == 4)
    {
        self.persMovementbind = 0;
        self notify("endBoltMovement");
        self unlink(self.scriptRide);
        self iPrintln("Bolt Movement Bind [^1OFF^7]");
    }
}

BoltMovementX()
{
    self endon("endBoltMovement");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.persMovementdpad, "+actionslot " + self.persMovementbind);
        self waittill(self.persMovementdpad); 

        self thread executeMovement();
        self thread setMoveSpeed();
        wait (self.doSpeed);
        wait 0.01; 
}
}

getmovementSpot()
{
    if(self.movement1 == 0)
    {
        self.movement1 = 1;
        self.movespot  = self.origin;
        self iprintln("Movement Spot 1: ^2Set");
    }
    else if(self.movement1 == 1)
    {
        self.movement1 = 2;
        self.movespot2 = self.origin;
        self iprintln("Movement Spot 2: ^2Set");
    }
    else if(self.movement1 == 2)
    {
        self.movement1 = 0;
        self.movespot3 = self.origin;
        self iprintln("Movement Spot 3: ^2Set");
    }
}

resetMovementSpot()
{
    self.movespot  = undefined;
    self.movespot2 = undefined;
    self.movespot3 = undefined;
    self.movement1 = 0;
    self iprintln("All Movement Spots ^1Reset");
}

setMoveSpeed()
{
    if(self.setMSpeed == 1)
    {
        wait 10;
        self unlink(self.scriptRide);
    }
    else if(self.setMSpeed == 2)
    {
        wait 7;
        self unlink(self.scriptRide);
    }
    else if(self.setMSpeed == 3)
    {
        wait 5;
        self unlink(self.scriptRide);
    }
    else if(self.setMSpeed == 4)
    {
        wait 2.1;
        self unlink(self.scriptRide);
    }
    else if(self.setMSpeed == 5)
    {
        wait 1.1;
        self unlink(self.scriptRide);
        //self iprintln("pretty fast unlink");
    }
    else if(self.setMSpeed == 6)
    {
        wait 1;
        self unlink(self.scriptRide);
    }
    else if(self.setMSpeed == 7)
    {
        wait 0.8;
        self unlink(self.scriptRide);
    }
    else if(self.setMSpeed == 0)
    {
        wait 0.25;
        self unlink(self.scriptRide);
    }
}

getSpeed2()
{
    if(self.setMSpeed == 0)
    {
        self.setMSpeed = 1;
        self iprintln("Movement Speed: ^2Very Slow");
        self.doSpeed = Int( 10 );
    }
    else if(self.setMSpeed == 1)
    {
        self.setMSpeed = 2;
        self iprintln("Movement Speed:^2 Slow");
        self.doSpeed = Int( 7.5 );
    }
    else if(self.setMSpeed == 2)
    {
        self.setMSpeed = 3;
        self iprintln("Movement Speed:^2 Normal");
        self.doSpeed = Int( 5 );
    }
    else if(self.setMSpeed == 3)
    {
        self.setMSpeed = 4;
        self iprintln("Movement Speed:^2 Fast");
        self.doSpeed = Int( 2 );
    }
    else if(self.setMSpeed == 4)
    {
        self.setMSpeed = 5;
        self iprintln("Movement Speed:^2 Pretty Fast");
        self.doSpeed = Int( 1.5 );
    }
    else if(self.setMSpeed == 5)
    {
        self.setMSpeed = 6;
        self iprintln("Movement Speed:^2 Very Fast");
        self.doSpeed = Int( 1 );
    }
    else if(self.setMSpeed == 6)
    {
        self.setMSpeed = 7;
        self iprintln("Movement Speed:^2 Super Fast");
        self.doSpeed = 0.75;
    }
    else if(self.setMSpeed == 7)
    {
        self.setMSpeed = 0;
        self iprintln("Movement Speed:^2 Super Super Fast");
        self.doSpeed = 0.2;
    }
}

ToggleFPS()
{
    self notify("endFPS");
    if(self.fpsbind == 0)
    {
        self.fpsbind = 1;
        self.fpsdpad = "up";
        self thread TogFPS();
        self iPrintln("Toggle 57/333 FPS with [{+actionslot 1}]");
    }
    else if(self.fpsbind == 1)
    {
        self.fpsbind = 2;
        self.fpsdpad = "down";
        self thread TogFPS();
        self iPrintln("Toggle 57/333 FPS with [{+actionslot 2}]");
    }
    else if(self.fpsbind == 2)
    {
        self.fpsbind = 3;
        self.fpsdpad = "left";
        self thread TogFPS();
        self iPrintln("Toggle 57/333 FPS with [{+actionslot 3}]");
    }
    else if(self.fpsbind == 3)
    {
        self.fpsbind = 4;
        self.fpsdpad = "right";
        self thread TogFPS();
        self iPrintln("Toggle 57/333 FPS with [{+actionslot 4}]");
    }
    else if(self.fpsbind == 4)
    {
        self.fpsbind = 0;
        self notify("endFPS");
        self iPrintln("Toggle 57/333 FPS:^1 [Off]");
    }
}

TogFPS()
{
	self endon("endFPS");
	self endon("disconnect");
    self notifyOnPlayerCommand(self.fpsdpad, "+actionslot " + self.fpsbind);
	for (;;)
	{
		self waittill(self.fpsdpad);
		if ( self.togfps == false )
		{
			self.togfps = true;
			setDvar( "com_maxfps", 333);
		}
		else if ( self.togfps == true )
		{
			self.togfps = false;
			setDvar( "com_maxfps", 57);
		}
	}
}

ToggleFPS60()
{
    self notify("endFPS60");
    if(self.fpsbind60 == 0)
    {
        self.fpsbind60 = 1;
        self.fpsdpad60 = "up";
        self thread TogFPS60();
        self iPrintln("Toggle 60/333 FPS with [{+actionslot 1}]");
    }
    else if(self.fpsbind60 == 1)
    {
        self.fpsbind60 = 2;
        self.fpsdpad60 = "down";
        self thread TogFPS60();
        self iPrintln("Toggle 60/333 FPS with [{+actionslot 2}]");
    }
    else if(self.fpsbind60 == 2)
    {
        self.fpsbind60 = 3;
        self.fpsdpad60 = "left";
        self thread TogFPS60();
        self iPrintln("Toggle 60/333 FPS with [{+actionslot 3}]");
    }
    else if(self.fpsbind60 == 3)
    {
        self.fpsbind60 = 4;
        self.fpsdpad60 = "right";
        self thread TogFPS60();
        self iPrintln("Toggle 60/333 FPS with [{+actionslot 4}]");
    }
    else if(self.fpsbind60 == 4)
    {
        self.fpsbind60 = 0;
        self notify("endFPS60");
        self iPrintln("Toggle 60/333 FPS:^1 [Off]");
    }
}

TogFPS60()
{
	self endon("endFPS60");
	self endon("disconnect");
    self notifyOnPlayerCommand(self.fpsdpad60, "+actionslot " + self.fpsbind60);
	for (;;)
	{
		self waittill(self.fpsdpad60);
		if ( self.togfps60 == false )
		{
			self.togfps60 = true;
			setDvar( "com_maxfps", 333);
		}
		else if ( self.togfps60 == true )
		{
			self.togfps60 = false;
			setDvar( "com_maxfps", 60);
		}
	}
}

ToggleFPS85()
{
    self notify("endFPS85");
    if(self.fpsbind85 == 0)
    {
        self.fpsbind85 = 1;
        self.fpsdpad85 = "up";
        self thread TogFPS85();
        self iPrintln("Toggle 85/333 FPS with [{+actionslot 1}]");
    }
    else if(self.fpsbind85 == 1)
    {
        self.fpsbind85 = 2;
        self.fpsdpad85 = "down";
        self thread TogFPS85();
        self iPrintln("Toggle 85/333 FPS with [{+actionslot 2}]");
    }
    else if(self.fpsbind85 == 2)
    {
        self.fpsbind85 = 3;
        self.fpsdpad85 = "left";
        self thread TogFPS85();
        self iPrintln("Toggle 85/333 FPS with [{+actionslot 3}]");
    }
    else if(self.fpsbind85 == 3)
    {
        self.fpsbind85 = 4;
        self.fpsdpad85 = "right";
        self thread TogFPS85();
        self iPrintln("Toggle 85/333 FPS with [{+actionslot 4}]");
    }
    else if(self.fpsbind85 == 4)
    {
        self.fpsbind85 = 0;
        self notify("endFPS85");
        self iPrintln("Toggle 85/333 FPS:^1 [Off]");
    }
}

TogFPS85()
{
	self endon("endFPS85");
	self endon("disconnect");
    self notifyOnPlayerCommand(self.fpsdpad85, "+actionslot " + self.fpsbind85);
	for (;;)
	{
		self waittill(self.fpsdpad85);
		if ( self.togfps85 == false )
		{
			self.togfps85 = true;
			setDvar( "com_maxfps", 333);
		}
		else if ( self.togfps85 == true )
		{
			self.togfps85 = false;
			setDvar( "com_maxfps", 85);
		}
	}
}

execCFGBind(num)
{
	if(num == 0)
	{
		self notify("endCFG1");
		self notify("endCFG2");
		self notify("endCFG3");
		self notify("endCFG4");
		self.CFGBind = 0;
		self.CFGBind2 = 0;
		self.CFGBind3 = 0;
		self.CFGBind4 = 0;
		self iPrintln("All CFG Scripts: [^1OFF^7]");
		self notify("endCFGall");
	}
	if(num == 1)
	{
		self notify("endCFG1");
		if(self.CFGBind == 0)
		{
			self.CFGBind = 1;
			self.CFGDpad = "up";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 1: [{+actionslot 1}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind == 1)
		{
			self.CFGBind = 2;
			self.CFGDpad = "down";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 1: [{+actionslot 2}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind == 2)
		{
			self.CFGBind = 3;
			self.CFGDpad = "left";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 1: [{+actionslot 3}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind == 3)
		{
			self.CFGBind = 4;
			self.CFGDpad = "right";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 1: [{+actionslot 4}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind == 4)
		{
			self.CFGBind = 0;
			self notify("endCFG1");
			self iPrintln("Execute CFG Script 1: [^1OFF^7]");
		}
	}
	if(num == 2)
	{
		self notify("endCFG2");
		if(self.CFGBind2 == 0)
		{
			self.CFGBind2 = 1;
			self.CFGDpad2 = "up";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 2: [{+actionslot 1}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind2 == 1)
		{
			self.CFGBind2 = 2;
			self.CFGDpad2 = "down";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 2: [{+actionslot 2}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind2 == 2)
		{
			self.CFGBind2 = 3;
			self.CFGDpad2 = "left";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 2: [{+actionslot 3}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind2 == 3)
		{
			self.CFGBind2 = 4;
			self.CFGDpad2 = "right";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 2: [{+actionslot 4}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind2 == 4)
		{
			self.CFGBind2 = 0;
			self notify("endCFG2");
			self iPrintln("Execute CFG Script 2: [^1OFF^7]");
		}
	}
	if(num == 3)
	{
		self notify("endCFG3");
		if(self.CFGBind3 == 0)
		{
			self.CFGBind3 = 1;
			self.CFGDpad3 = "up";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 3: [{+actionslot 1}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind3 == 1)
		{
			self.CFGBind3 = 2;
			self.CFGDpad3 = "down";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 3: [{+actionslot 2}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind3 == 2)
		{
			self.CFGBind3 = 3;
			self.CFGDpad3 = "left";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 3: [{+actionslot 3}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind3 == 3)
		{
			self.CFGBind3 = 4;
			self.CFGDpad3 = "right";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 3: [{+actionslot 4}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind3 == 4)
		{
			self.CFGBind3 = 0;
			self notify("endCFG3");
			self iPrintln("Execute CFG Script 3: [^1OFF^7]");
		}
	}
	if(num == 4)
	{
		self notify("endCFG4");
		if(self.CFGBind4 == 0)
		{
			self.CFGBind4 = 1;
			self.CFGDpad4 = "up";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 4: [{+actionslot 1}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind4 == 1)
		{
			self.CFGBind4 = 2;
			self.CFGDpad4 = "down";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 4: [{+actionslot 2}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind4 == 2)
		{
			self.CFGBind4 = 3;
			self.CFGDpad4 = "left";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 4: [{+actionslot 3}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind4 == 3)
		{
			self.CFGBind4 = 4;
			self.CFGDpad4 = "right";
			self thread execCFGScript(num);
			self iPrintln("Execute CFG Script 4: [{+actionslot 4}]");
			self iPrintln("^1Add your script to ^7'_retropack_cfg'");
		}
		else if(self.CFGBind4 == 4)
		{
			self.CFGBind4 = 0;
			self notify("endCFG4");
			self iPrintln("Execute CFG Script 4: [^1OFF^7]");
		}
	}
}

execCFGScript(num)
{
	if(num == 1)
	{
		self endon("endCFG1");
		self endon("disconnect");
		self notifyOnPlayerCommand(self.CFGDpad, "+actionslot " + self.CFGBind);
		for (;;)
		{
			self waittill(self.CFGDpad); 
			cmdexec(level.script_1);
		}
	}
	if(num == 2)
	{
		self endon("endCFG2");
		self endon("disconnect");
		self notifyOnPlayerCommand(self.CFGDpad2, "+actionslot " + self.CFGBind2);
		for (;;)
		{
			self waittill(self.CFGDpad2); 
			cmdexec(level.script_2);
		}
	}
	if(num == 3)
	{
		self endon("endCFG3");
		self endon("disconnect");
		self notifyOnPlayerCommand(self.CFGDpad3, "+actionslot " + self.CFGBind3);
		for (;;)
		{
			self waittill(self.CFGDpad3); 
			cmdexec(level.script_3);
		}
	}
	if(num == 4)
	{
		self endon("endCFG4");
		self endon("disconnect");
		self notifyOnPlayerCommand(self.CFGDpad4, "+actionslot " + self.CFGBind4);
		for (;;)
		{
			self waittill(self.CFGDpad4); 
			cmdexec(level.script_4);
		}
	}
}

Bombtog()
{
    self notify("endBomb");
    if(self.Bombbind == 0)
    {
        self.Bombbind = 1;
        self.Bombdpad = "up";
        self thread BombX();
        self iPrintln("Bomb Bind [{+actionslot 1}]");
    }
    else if(self.Bombbind == 1)
    {
        self.Bombbind = 2;
        self.Bombdpad = "down";
        self thread BombX();
        self iPrintln("Bomb Bind [{+actionslot 2}]");
    }
    else if(self.Bombbind == 2)
    {
        self.Bombbind = 3;
        self.Bombdpad = "left";
        self thread BombX();
        self iPrintln("Bomb Bind [{+actionslot 3}]");
    }
    else if(self.Bombbind == 3)
    {
        self.Bombbind = 4;
        self.Bombdpad = "right";
        self thread BombX();
        self iPrintln("Bomb Bind [{+actionslot 4}]");
    }
    else if(self.Bombbind == 4)
    {
        self.Bombbind = 0;
        self notify("endBomb");
        self iPrintln("Bomb Bind [^1OFF^7]");
    }
}



BombX()
{
	self endon("endBomb");
	self endon("disconnect");
    self notifyOnPlayerCommand(self.Bombdpad, "+actionslot " + self.Bombbind);
	for (;;)
	{
        self waittill(self.Bombdpad); 
		equipmentmod = "briefcase_bomb_defuse_mp";
		CurrentGun=self getCurrentWeapon();
		self giveWeapon("briefcase_bomb_defuse_mp");
		self takeWeapon(CurrentGun);
		self switchToWeapon("briefcase_bomb_defuse_mp");
		wait 0.1;
		self giveweapon(CurrentGun);
	}
}

IllusionReloadtog()
{
    self notify("endIllusionReload");
    if(self.IllusionReloadbind == 0)
    {
        self.IllusionReloadbind = 1;
        self.IllusionReloaddpad = "up";
        self thread IllusionReloadX();
        self iprintln("Illusion Reload Bind [{+actionslot 1}]");
    }
    else if(self.IllusionReloadbind == 1)
    {
        self.IllusionReloadbind = 2;
        self.IllusionReloaddpad = "down";
        self thread IllusionReloadX();
        self iprintln("Illusion Reload Bind [{+actionslot 2}]");
    }
    else if(self.IllusionReloadbind == 2)
    {
        self.IllusionReloadbind = 3;
        self.IllusionReloaddpad = "left";
        self thread IllusionReloadX();
        self iprintln("Illusion Reload Bind [{+actionslot 3}]");
    }
    else if(self.IllusionReloadbind == 3)
    {
        self.IllusionReloadbind = 4;
        self.IllusionReloaddpad = "right";
        self thread IllusionReloadX();
        self iprintln("Illusion Reload Bind [{+actionslot 4}]");
    }
    else if(self.IllusionReloadbind == 4)
    {
        self.IllusionReloadbind = 0;
        self notify("endIllusionReload");
        self iprintln("Illusion Reload Bind [^1OFF^7]");
    }
}

IllusionReloadX()
{
    self endon("endC4");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.IllusionReloaddpad, "+actionslot " + self.IllusionReloadbind);
        self waittill(self.IllusionReloaddpad);
        
		currentWeapon = self getCurrentWeapon();
		self setWeaponAmmoClip(currentWeapon, 0);
		wait 0.000001;
		self setSpawnWeapon(currentWeapon);
		self setWeaponAmmoClip(currentWeapon, 100);

    }
    
}

IllusionSprinttog()
{
    self notify("endIllusionSprint");
    if(self.IllusionSprintbind == 0)
    {
        self.IllusionSprintbind = 1;
        self.IllusionSprintdpad = "up";
        self thread IllusionSprintX();
        self iprintln("Illusion Sprint Bind [{+actionslot 1}]");
    }
    else if(self.IllusionSprintbind == 1)
    {
        self.IllusionSprintbind = 2;
        self.IllusionSprintdpad = "down";
        self thread IllusionSprintX();
        self iprintln("Illusion Sprint Bind [{+actionslot 2}]");
    }
    else if(self.IllusionSprintbind == 2)
    {
        self.IllusionSprintbind = 3;
        self.IllusionSprintdpad = "left";
        self thread IllusionSprintX();
        self iprintln("Illusion Sprint Bind [{+actionslot 3}]");
    }
    else if(self.IllusionSprintbind == 3)
    {
        self.IllusionSprintbind = 4;
        self.IllusionSprintdpad = "right";
        self thread IllusionSprintX();
        self iprintln("Illusion Sprint Bind [{+actionslot 4}]");
    }
    else if(self.IllusionSprintbind == 4)
    {
        self.IllusionSprintbind = 0;
        self notify("endIllusionSprint");
        self iprintln("Illusion Sprint Bind [^1OFF^7]");
    }
}

IllusionSprintX()
{
    self endon("endC4");
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand(self.IllusionSprintdpad, "+actionslot " + self.IllusionSprintbind);
        self waittill(self.IllusionSprintdpad);
        
		currentWeapon = self getCurrentWeapon();
		self takeWeapon(currentWeapon);
		wait 0.5;
		self giveWeapon(currentWeapon);
		self setSpawnWeapon(currentWeapon);

    }
    
}


pickupradius()
{
	if ( self.puradius == true )
	{
		self.puradius = true;
		setDvar( "player_useRadius", 9999 );
		self iPrintln("Pickup Radius: ^2[9999]");
	}
    else if ( self.puradius == true )
	{
		self.puradius = false;
		setDvar( "player_useRadius", 150 );
		self iPrintln("Pickup Radius: ^1[Default]");
	}
}

doubletapstog()
{
	if ( self.doubletaps == false )
	{
		self.doubletaps = true;
		setDvar( "sv_enabledoubletaps", 1);
		self iPrintln("Double Taps: ^2On");
		//self.doubletaptext Destroy();
		//self.DoubleTapTextRetro = "^2Enabled";
	}
    else if ( self.doubletaps == true )
	{
		self.doubletaps = false;
		setDvar( "sv_enabledoubletaps", 0);
		self iPrintln("Double Taps: ^1Off");
		//self.doubletaptext Destroy();
		//self.DoubleTapTextRetro = "^1Disabled";
	}
	//self.doubletaptext = createFontString("DEFAULT", 1.0);
	//self.doublexptext setPoint("LEFT", "CENTER", 80, -15);
	//self.doubletaptext setText("Double Tap: " + self.DoubleTapTextRetro + " ");
	//self.doubletaptext.archived = self.NotStealth;
}

TeleportBotFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot" ))
			{
				level.players[i] setOrigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
				level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i]gettagorigin("j_head")));
				wait 0.01;
				level.players[i].pers["friendlybotorigin"] = level.players[i].origin;
				level.players[i].pers["friendlybotangles"] = level.players[i].angles;
				level.players[i].pers["friendlybotspotstatus"] = "saved";
				//self iPrintln("Bots have been teleported to Crosshair");
			}
		}
	}
}

TeleportBotEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] != self.pers["team"])
		{
			if (isSubStr( level.players[i].guid, "bot" ))
			{
				level.players[i] setOrigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
				level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i]gettagorigin("j_head")));
				wait 0.01;
				level.players[i].pers["enemybotorigin"] = level.players[i].origin;
				level.players[i].pers["enemybotangles"] = level.players[i].angles;
				level.players[i].pers["enemybotspotstatus"] = "saved";
				//self iPrintln("Bots have been teleported to Crosshair");
			}
		}
	}
}

roundReset()
{
	level.resetscores = true;
	allies = 0;
	game["roundsWon"]["axis"] = 0;
	game["roundsWon"]["allies"] = 0;
	game["roundsPlayed"] = 0;
	game["teamScores"]["allies"] = 0;
	game["teamScores"]["axis"] = 0;	
	maps\mp\gametypes\_gamescore::updateTeamScore( "axis" );
	maps\mp\gametypes\_gamescore::updateTeamScore( "allies" );
	//self iPrintln("Rounds Reset");
}

reverseladders()
{
	if ( getdvar( "jump_ladderPushVel" ) == "128" )
	{
		setDvar("jump_ladderPushVel", 90);
		self iPrintln("Reverse Ladder Bounces: ^2[On]");
	}
    else
	{
		setDvar("jump_ladderPushVel", 128);
		self iPrintln("Reverse Ladder Bounces: ^1[Off]");
	}
}


EmptyDaClip()
{
    weap = self getCurrentWeapon();
    clip = self getWeaponAmmoClip(weap);
    self SetWeaponAmmoClip(weap, clip - 100);
}

OneBulletClip()
{
    weap = self getCurrentWeapon();
    self SetWeaponAmmoClip( weap, 1 );
}

SpawnCrate()
{
    self.GreenCrate = spawn("script_model", self.origin);
    self.GreenCrate setModel( "com_plasticcase_friendly" );
    self.GreenCrate.angles = self.angles;
    self.GreenCrate.angle = self.angle;
    self.GreenCrate CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
    self setOrigin(self.origin + (0, 0, 30));
}

CordsX()
{
    self.cords = self.origin;
    self iprintln(self.origin);
}

takeweap()
{
    self.weap = self getCurrentWeapon();
    self takeweapon(self.weap);
}

dropweap()
{
	currentgun = self getcurrentWeapon();
	self dropitem(currentgun);
}


//////////////////////////////////////////////////////// BOLT STUFF ////////////////////////////////////////////////////////
boltRetro()
{
	self endon("death");
    self endon("disconnect");
	self endon("dudestopbolt");
	if ( !isDefined( self.pers["poscountBolt"] ) ) //so it saves for next spawn leshgo -retro
	{
		self.pers["poscountBolt"] = 0;
	}
	if ( !isDefined( self.pers["boltTime"] ) ) //so it saves for next spawn leshgo -retro
	{
		self.pers["boltTime"] = 3;
	}
	self thread RetroBoltSave();
	self thread boltTextThread();
}

boltTextThread()
{
	self endon("dudestopbolt");
	while(1)
	{
		self iPrintln("^4Press [{+reload}] to +saveBolt, [{weapnext}] to +delBolt");
		self iPrintln("^4Press [{+actionslot 1}] to disable tool");
		wait 1;
	}
	wait 0.01;
}

RetroBoltSave()
{
	destroyHud();
	destroyMenuText();
	self.menu.isOpen = false;
	self notify("stopmenu_up");
	self notify("stopmenu_down");
	wait 1;
	self thread retroDelBolt();
	self thread retroSaveBolt();
	self thread retroDisableBolt();
}

retroSaveBolt()
{
	        self endon("dudestopbolt");
            self notifyOnPlayerCommand("retrowannaboltsave", "+usereload");
			for (;;)
			{
				self waittill("retrowannaboltsave");
				self thread boltSave();
			}
}

boltSave()
{
		self.pers["poscountBolt"] += 1;
		self.pers["originBolt"][self.pers["poscountBolt"]] = self GetOrigin();
		self.pers["anglesBolt"][self.pers["poscountBolt"]] = self GetPlayerAngles();
		if(self.pers["poscountBolt"] == 1) //saves first bolt location as spawn too
		{
			self.pers["loc"] = true;
			self.pers["savePos"] = self.origin;
			self.pers["saveAng"] = self.angles;
		}
		self iPrintLn("^0Position ^5#" + self.pers["poscountBolt"] + " saved : ^7" + self.origin );
}

boltDel()
{
	{
		if( self.pers["poscountBolt"] == 0 )
		{
			self IPrintLn("^1There's no bolt positions to delete");
		}
		else
		{
			self.pers["originBolt"][self.pers["poscountBolt"]] = undefined;
			self.pers["anglesBolt"][self.pers["poscountBolt"]] = undefined;
			self IPrintLn( "^0Position ^5#" + self.pers["poscountBolt"] + " ^1deleted" );
			self.pers["poscountBolt"] -= 1;
		}
	}
}

retroDelBolt()
{
			self endon("dudestopbolt");
			self notifyOnPlayerCommand("retrowannadelbolt", "weapnext");
			for (;;)
			{
			self waittill("retrowannadelbolt");
			self thread boltDel();
			}
}



retroDisableBolt()
{
			self endon("dudestopbolt");
			self notifyOnPlayerCommand("boltretro3", "+actionslot 1");
			for (;;)
			{
			self waittill("boltretro3");
			self iPrintln("^5Bolt Movement Tool: ^1[Disabled]");
			self notify ("dudestopbolt");
			wait 1;
			self thread fullydisablebolt();
			}
}

fullyDisableBolt()
{
	self notifyOnPlayerCommand("emptynessnothingretro", "+actionslot 1");
	for (;;)
	{
	self waittill("emptynessnothingretro");
	self notify ("dudestopbolt");
	}
}

startBoltUp()
{
    if(!self.sb1)
    {
        self.sb1 = true;
		self.boltdpad = 1;
		self.boltbind = "up";
        self thread bindNonLoop();
        self iPrintln("^5Press [{+actionslot 1}] to activate Bolt Movement");
		self.boltmtext Destroy();
		self.BoltTextRetro = "[{+actionslot 1}]";
		self.boltmtext = createFontString("DEFAULT", 1.0);
		self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
		self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
		self.boltmtext.archived = self.NotStealth;
    }
    else
    {
        self.sb1 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
		self.boltmtext Destroy();
		self.BoltTextRetro = "^1Disabled";
		self.boltmtext = createFontString("DEFAULT", 1.0);
		self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
		self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
		self.boltmtext.archived = self.NotStealth;
    }
}

startBoltDown()
{
    if(!self.sb2)
    {
        self.sb2 = true;
		self.boltdpad = 2;
		self.boltbind = "down";
        self thread bindNonLoop();
        self iPrintln("^5Press [{+actionslot 2}] to activate Bolt Movement");
		self.boltmtext Destroy();
		self.BoltTextRetro = "[{+actionslot 2}]";
		self.boltmtext = createFontString("DEFAULT", 1.0);
		self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
		self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
		self.boltmtext.archived = self.NotStealth;
    }
    else
    {
        self.sb2 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
		self.boltmtext Destroy();
		self.BoltTextRetro = "^1Disabled";
		self.boltmtext = createFontString("DEFAULT", 1.0);
		self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
		self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
		self.boltmtext.archived = self.NotStealth;
    }
}


startBoltLeft()
{
    if(!self.sb3)
    {
        self.sb3 = true;
		self.boltdpad = 3;
		self.boltbind = "left";
        self thread bindNonLoop();
        self iPrintln("^5Press [{+actionslot 3}] to activate Bolt Movement");
		self.boltmtext Destroy();
		self.BoltTextRetro = "[{+actionslot 3}]";
		self.boltmtext = createFontString("DEFAULT", 1.0);
		self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
		self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
		self.boltmtext.archived = self.NotStealth;
    }
    else
    {
        self.sb3 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
		self.boltmtext Destroy();
		self.BoltTextRetro = "^1Disabled";
		self.boltmtext = createFontString("DEFAULT", 1.0);
		self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
		self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
		self.boltmtext.archived = self.NotStealth;
    }
}

startBoltRight()
{
    if(!self.sb4)
    {
        self.sb4 = true;
		self.boltdpad = 4;
		self.boltbind = "right";
        self thread bindNonLoop();
        self iPrintln("^5Press [{+actionslot 4}] to activate Bolt Movement");
		self.boltmtext Destroy();
		self.BoltTextRetro = "[{+actionslot 4}]";
		self.boltmtext = createFontString("DEFAULT", 1.0);
		self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
		self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
		self.boltmtext.archived = self.NotStealth;
    }
    else
    {
        self.sb4 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
		self.boltmtext Destroy();
		self.BoltTextRetro = "^1Disabled";
		self.boltmtext = createFontString("DEFAULT", 1.0);
		self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
		self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
		self.boltmtext.archived = self.NotStealth;
    }
}

bindNonLoop()
{
    self endon("stopboltbind");
    for(;;)
    {
		self notifyOnPlayerCommand( self.boltbind, "+actionslot " + self.boltdpad );
		self waittill(self.boltbind);
		if(self.boltdpad != "")
		{
			self thread BoltStart();
		}
		wait 0.01;
	}
}

BoltStart()
{
	self notify ("stopboltbind");
    self endon("disconnect");
    self endon("detachBolt");

        if (self.pers["poscountBolt"] == 0)
        {
            self IPrintLn("^1There is no bolt point to travel to");
        }
        
        boltModel = spawn( "script_model", self.origin );
        boltModel SetModel( "tag_origin" );
        boltModel EnableLinkTo();
        self PlayerLinkTo(boltModel);
        self thread WatchJumping(boltModel);

        for (i=1 ; i < self.pers["poscountBolt"] + 1 ; i++)
        {
            boltModel MoveTo( self.pers["originBolt"][i],  self.pers["boltTime"] / self.pers["poscountBolt"], 0, 0 );
            wait ( self.pers["boltTime"] / self.pers["poscountBolt"] );
        }
        self Unlink();
        boltModel delete();
		self thread bindNonLoop();
		
}

WatchJumping(model)
{
    self endon("disconnect");
    self notifyOnplayerCommand( "detachBolt", "+gostand" );

    for(;;)
    {
        self waittill("detachBolt");
        self Unlink();
        model delete();
    }
}

changeBoltTime(time)
{
		//setDvar( "boltTime", time );
		//self setClientDvar(  "boltTime", time );
		//self.bolt_time = time;
		self.pers["boltTime"] = time;
		if(time == 1)
		{
			self iPrintln("^5Bolt Time Set to:^0 " + time + " second");
		}
		else
		{
			self iPrintln("^5Bolt Time Set to:^0 " + time + " seconds");
		}
}
//////////////////////////////////////////////////////// BOLT STUFF ////////////////////////////////////////////////////////

//////////////////////////////////////////////////////// OBELISK STUFF ////////////////////////////////////////////////////////
secretmultimala()
{
	self endon("cameq2");
	self endon("death");
	self endon("disconnect");
	self iPrintln("^5Press [{+actionslot 4}] for Glitch, do not have any Equipment while using.");
	self notifyOnPlayerCommand("cameqz", "+actionslot 4");
	for (;;)
	{
	
	self waittill("cameqz");
	TestMala = self getCurrentWeapon();
	equipmentmod = "claymore_mp";
	self giveWeapon("claymore_mp");
	self switchToWeapon("claymore_mp");
	wait 1.5;
	equipmentmod = "specialty_tacticalinsertion";
	self giveWeapon("specialty_tacticalinsertion");
	self switchToWeapon("specialty_tacticalinsertion");
	wait 1.0;
	equipmentmod = "c4_mp";
	self giveWeapon("c4_mp");
	self switchToWeapon("c4_mp");
	wait 1.0;
	self switchToWeapon("TestMala");
	self notify("cameq2");
	}
}

nacmreset()
{
	self.npr = false;
	self.nacpronto = 0;
	weapa = "";
	weapb = "";
	self iprintln("Weapons Reset");
}

tVishBind(button)
{	
	self.Vishdpad = undefined;
	self notify("VishBind0");
	switch(button)
	{
		case "1":
			self.Vishdpad = 1;
			if(!self.pers["VishBindU"])
			{
				self.pers["VishBindU"] = 1;
				self.pers["VishBindD"] = 0;
				self.pers["VishBindL"] = 0;
				self.pers["VishBindR"] = 0;
				self.pers["Vishb"] = self.Vishdpad;
				self.pers["Vishd"] = "Vish1";
				self iprintln("Vish Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] To Vish");
				self thread VishBind();
			}
			else
			{
				self.pers["VishBindU"] = 0;
				self iprintln("Vish Bind: ^1Off");
				self notify("VishBind0");
			}
			break;
		case "2":
			self.Vishdpad = 2;
			if(!self.pers["VishBindD"])
			{
				self.pers["VishBindU"] = 0;
				self.pers["VishBindD"] = 1;
				self.pers["VishBindL"] = 0;
				self.pers["VishBindR"] = 0;
				self.pers["Vishb"] = self.Vishdpad;
				self.pers["Vishd"] = "Vish2";
				self iprintln("Vish Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] To Vish");
				self thread VishBind();
			}
			else
			{
				self.pers["VishBindD"] = 0;
				self iprintln("Vish Bind: ^1Off");
				self notify("VishBind0");
			}
			break;
		case "3":
			self.Vishdpad = 3;
			if(!self.pers["VishBindL"])
			{
				self.pers["VishBindU"] = 0;
				self.pers["VishBindD"] = 0;
				self.pers["VishBindL"] = 1;
				self.pers["VishBindR"] = 0;
				self.pers["Vishb"] = self.Vishdpad;
				self.pers["Vishd"] = "Vish3";
				self iprintln("Vish Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] To Vish");
				self thread VishBind();
			}
			else
			{
				self.pers["VishBindL"] = 0;
				self iprintln("Vish Bind: ^1Off");
				self notify("VishBind3");
			}
			break;
		case "4":
			self.Vishdpad = 4;
			if(!self.pers["VishBindR"])
			{
				self.pers["VishBindU"] = 0;
				self.pers["VishBindD"] = 0;
				self.pers["VishBindL"] = 0;
				self.pers["VishBindR"] = 1;
				self.pers["Vishb"] = self.Vishdpad;
				self.pers["Vishd"] = "Vish4";
				self iprintln("Vish Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] To Vish");
				self thread VishBind();
			}
			else
			{
				self.pers["VishBindR"] = 0;
				self iprintln("Vish Bind: ^1Off");
				self notify("VishBind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With Vish Bind");
			break;
	}
}
vishbind()
{
	self endon("disconnect");
	self endon("death");
	self endon ("VishBind0");
	for(;;)
	{
		self notifyOnPlayerCommand(self.pers["Vishd"], "+actionslot " + self.pers["Vishb"]);
		self waittill (self.pers["Vishd"]);	  
		self allowSpectateTeam( "freelook", true );
		self.sessionstate = "spectator";
		self setContents( 0 );
		wait 0.01;
		self.sessionstate = "playing";
		self allowSpectateTeam( "freelook", false );
		self setContents( 100 );
		CurrentGun = self getCurrentWeapon();
		self takeWeapon(CurrentGun);
		self giveWeapon(CurrentGun);
		weaponsList = self GetWeaponsListAll();
		foreach(weapon in weaponsList)
		{
			if (weapon!=CurrentGun)
			{
				self switchToWeapon(CurrentGun);
			}
		}
	}
	wait 0.1;
}

tnacBind(button)
{	
	self.nacdpad = undefined;
	self notify("nacBind0");
	switch(button)
	{
		case "1":
			self.nacdpad = 1;
			if(!self.pers["nacBindU"])
			{
				self.pers["nacBindU"] = 1;
				self.pers["nacBindD"] = 0;
				self.pers["nacBindL"] = 0;
				self.pers["nacBindR"] = 0;
				self.pers["nacb"] = self.nacdpad;
				self.pers["nacd"] = "nac1";
				self iprintln("Nac Mod Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] To Nac");
				self thread nacBind();
			}
			else
			{
				self.pers["nacBindU"] = 0;
				self iprintln("Nac Mod Bind: ^1Off");
				self notify("nacBind0");
			}
			break;
		case "2":
			self.nacdpad = 2;
			if(!self.pers["nacBindD"])
			{
				self.pers["nacBindU"] = 0;
				self.pers["nacBindD"] = 1;
				self.pers["nacBindL"] = 0;
				self.pers["nacBindR"] = 0;
				self.pers["nacb"] = self.nacdpad;
				self.pers["nacd"] = "nac2";
				self iprintln("nac Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] To Nac");
				self thread nacBind();
			}
			else
			{
				self.pers["nacBindD"] = 0;
				self iprintln("Nac Mod Bind: ^1Off");
				self notify("nacBind0");
			}
			break;
		case "3":
			self.nacdpad = 3;
			if(!self.pers["nacBindL"])
			{
				self.pers["nacBindU"] = 0;
				self.pers["nacBindD"] = 0;
				self.pers["nacBindL"] = 1;
				self.pers["nacBindR"] = 0;
				self.pers["nacb"] = self.nacdpad;
				self.pers["nacd"] = "nac3";
				self iprintln("Nac Mod Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] To Nac");
				self thread nacBind();
			}
			else
			{
				self.pers["nacBindL"] = 0;
				self iprintln("Nac Mod Bind: ^1Off");
				self notify("nacBind0");
			}
			break;
		case "4":
			self.nacdpad = 4;
			if(!self.pers["nacBindR"])
			{
				self.pers["nacBindU"] = 0;
				self.pers["nacBindD"] = 0;
				self.pers["nacBindL"] = 0;
				self.pers["nacBindR"] = 1;
				self.pers["nacb"] = self.nacdpad;
				self.pers["nacd"] = "nac4";
				self iprintln("Nac Mod Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] To Nac");
				self thread nacBind();
			}
			else
			{
				self.pers["nacBindR"] = 0;
				self iprintln("Nac Mod Bind: ^1Off");
				self notify("nacBind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With Nac Mod Bind");
			break;
	}
}
nacBind()
{
	self.npr = false;
	self.nacpronto = 0;
	pw = self getCurrentWeapon();
	sw = self getCurrentWeapon();
	self endon("nacBind0");
	self endon("death");
	self endon("disconnect");
	self endon("stopna");
	self notifyOnPlayerCommand(self.pers["nacd"], "+actionslot " + self.pers["nacb"]);
	for(;;)
	{
		self waittill(self.pers["nacd"]);
		if(!self.npr)
		{
			if(self.nacpronto==0)
			{
				self.nacpronto = 1;
				pw = self getCurrentWeapon();
				self iprintln("Weapon 1: " + pw);
				wait 1;
			}
			else if(self.nacpronto==1)
			{
				self.nacpronto = 2;
				sw = self getCurrentWeapon();
				self iprintln("Weapon 2: " + sw);
				self.npr = true;
			}
		}
		else
		{
			currentWeapon = self getCurrentWeapon();
			
			if (currentWeapon==pw)
			self vainac(pw, sw);
			
			else if (currentWeapon==sw)
			
			self vainac(sw, pw);
			
			else
			{
			self stopnac();
			}
			wait 0.1;
		}
	wait .05;
	}
}
stopnac()
{
	self notify("nacBind0");
	self thread nacBind();
}
vainac(weapa, weapb)
{
	if(self.pers["nacinstant"] == 1)
	{
		myclip = self getWeaponAmmoClip(weapa);
		mystock = self getWeaponAmmoStock(weapa);
		//self takeweapon(weapa);
		self switchtoweaponimmediate(weapb);
		wait 0.15;
		self giveWeapon(weapa);
		self setweaponammoclip( weapa, myclip );
		self setweaponammostock( weapa, mystock );
	}
	else
	{
		myclip = self getWeaponAmmoClip(weapa);
		mystock = self getWeaponAmmoStock(weapa);
		//self takeweapon(weapa);
		self switchtoweaponimmediate(weapb);
		wait 0.15;
		self giveWeapon(weapa);
		self setweaponammoclip( weapa, myclip );
		self setweaponammostock( weapa, mystock );
	}
}
toginstantnac()
{
	if(!self.pers["nacinstant"])
	{
		self.pers["nacinstant"]=1;
		self iprintln("Instant Swap: ^5On");
	}
	else
	{
		self.pers["nacinstant"]=0;
		self iprintln("Instant Swap: ^1Off");
	}
}

trapidfireBind(button)
{	
	self.rapidfiredpad = undefined;
	self notify("rapidfireBind0");
	switch(button)
	{
		case "1":
			self.rapidfiredpad = 1;
			if(!self.pers["rapidfireBindU"])
			{
				self.pers["rapidfireBindU"] = 1;
				self.pers["rapidfireBindD"] = 0;
				self.pers["rapidfireBindL"] = 0;
				self.pers["rapidfireBindR"] = 0;
				self.pers["rapidfireb"] = self.rapidfiredpad;
				self.pers["rapidfired"] = "rapidfire1";
				self iprintln("Rapid Fire Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] To Rapid Fire");
				self thread rapidfireBind();
			}
			else
			{
				self.pers["rapidfireBindU"] = 0;
				self iprintln("Rapid Fire Bind: ^1Off");
				self notify("rapidfireBind0");
			}
			break;
		case "2":
			self.rapidfiredpad = 2;
			if(!self.pers["rapidfireBindD"])
			{
				self.pers["rapidfireBindU"] = 0;
				self.pers["rapidfireBindD"] = 1;
				self.pers["rapidfireBindL"] = 0;
				self.pers["rapidfireBindR"] = 0;
				self.pers["rapidfireb"] = self.rapidfiredpad;
				self.pers["rapidfired"] = "rapidfire2";
				self iprintln("rapidfire Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] To Rapid Fire");
				self thread rapidfireBind();
			}
			else
			{
				self.pers["rapidfireBindD"] = 0;
				self iprintln("Rapid Fire Bind: ^1Off");
				self notify("rapidfireBind0");
			}
			break;
		case "3":
			self.rapidfiredpad = 3;
			if(!self.pers["rapidfireBindL"])
			{
				self.pers["rapidfireBindU"] = 0;
				self.pers["rapidfireBindD"] = 0;
				self.pers["rapidfireBindL"] = 1;
				self.pers["rapidfireBindR"] = 0;
				self.pers["rapidfireb"] = self.rapidfiredpad;
				self.pers["rapidfired"] = "rapidfire3";
				self iprintln("Rapid Fire Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] To Rapid Fire");
				self thread rapidfireBind();
			}
			else
			{
				self.pers["rapidfireBindL"] = 0;
				self iprintln("Rapid Fire Bind: ^1Off");
				self notify("rapidfireBind0");
			}
			break;
		case "4":
			self.rapidfiredpad = 4;
			if(!self.pers["rapidfireBindR"])
			{
				self.pers["rapidfireBindU"] = 0;
				self.pers["rapidfireBindD"] = 0;
				self.pers["rapidfireBindL"] = 0;
				self.pers["rapidfireBindR"] = 1;
				self.pers["rapidfireb"] = self.rapidfiredpad;
				self.pers["rapidfired"] = "rapidfire4";
				self iprintln("Rapid Fire Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] To Rapid Fire");
				self thread rapidfireBind();
			}
			else
			{
				self.pers["rapidfireBindR"] = 0;
				self iprintln("Rapid Fire Bind: ^1Off");
				self notify("rapidfireBind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With Rapid Fire Bind");
			break;
	}
}
rapidfireBind()
{
	self endon("disconnect");
	self endon("death");
	self endon("rapidfireBind0");
	self notifyOnPlayerCommand(self.pers["rapidfired"], "+actionslot " + self.pers["rapidfireb"]);
	for(;;)
	{
		self waittill(self.pers["rapidfired"]);
		cw = self getcurrentweapon();
		wait 0.01;
		self giveweapon(self.pers["houweap"]);
		wait 0.01;
		self switchtoweapon(self.pers["houweap"]);
		wait 0.01;
		self takeweapon(self.pers["houweap"]);
		//wait 0.1;
		//self switchtoweapon(cw);
	}
	wait 0.5;
}

tbombBind(button)
{	
	self.bombdpad = undefined;
	self notify("bombBind0");
	switch(button)
	{
		case "1":
			self.bombdpad = 1;
			if(!self.pers["bombBindU"])
			{
				self.pers["bombBindU"] = 1;
				self.pers["bombBindD"] = 0;
				self.pers["bombBindL"] = 0;
				self.pers["bombBindR"] = 0;
				self.pers["bombb"] = self.bombdpad;
				self.pers["bombd"] = "bomb1";
				self iprintln("Bomb Plant Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] To Do Bomb Plant");
				self thread bombBind();
			}
			else
			{
				self.pers["bombBindU"] = 0;
				self iprintln("Bomb Plant Bind: ^1Off");
				self notify("bombBind0");
			}
			break;
		case "2":
			self.bombdpad = 2;
			if(!self.pers["bombBindD"])
			{
				self.pers["bombBindU"] = 0;
				self.pers["bombBindD"] = 1;
				self.pers["bombBindL"] = 0;
				self.pers["bombBindR"] = 0;
				self.pers["bombb"] = self.bombdpad;
				self.pers["bombd"] = "bomb2";
				self iprintln("bomb Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] To Do Bomb Plant");
				self thread bombBind();
			}
			else
			{
				self.pers["bombBindD"] = 0;
				self iprintln("Bomb Plant Bind: ^1Off");
				self notify("bombBind0");
			}
			break;
		case "3":
			self.bombdpad = 3;
			if(!self.pers["bombBindL"])
			{
				self.pers["bombBindU"] = 0;
				self.pers["bombBindD"] = 0;
				self.pers["bombBindL"] = 1;
				self.pers["bombBindR"] = 0;
				self.pers["bombb"] = self.bombdpad;
				self.pers["bombd"] = "bomb3";
				self iprintln("Bomb Plant Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] To Do Bomb Plant");
				self thread bombBind();
			}
			else
			{
				self.pers["bombBindL"] = 0;
				self iprintln("Bomb Plant Bind: ^1Off");
				self notify("bombBind0");
			}
			break;
		case "4":
			self.bombdpad = 4;
			if(!self.pers["bombBindR"])
			{
				self.pers["bombBindU"] = 0;
				self.pers["bombBindD"] = 0;
				self.pers["bombBindL"] = 0;
				self.pers["bombBindR"] = 1;
				self.pers["bombb"] = self.bombdpad;
				self.pers["bombd"] = "bomb4";
				self iprintln("Bomb Plant Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] To Do Bomb Plant");
				self thread bombBind();
			}
			else
			{
				self.pers["bombBindR"] = 0;
				self iprintln("Bomb Plant Bind: ^1Off");
				self notify("bombBind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With Bomb Plant Bind");
			break;
	}
}
bombbind()
{
	self endon("disconnect");
	self endon("death");
	self endon("bombBind0");
	self notifyOnPlayerCommand(self.pers["bombd"], "+actionslot " + self.pers["bombb"]);
	for(;;)
	{
		self waittill(self.pers["bombd"]);
		self thread bombplant();
		wait .01;
	}
}
bombplant()
{
	cw = self getcurrentweapon();
	curclip = self getweaponammoclip(cw);
	curstock = self getweaponammostock(cw);
	self takeweapon(cw);
	self giveweapon("briefcase_bomb_mp");
	self switchtoweapon("briefcase_bomb_mp");

	wduration = 5.0;
	NSB = createPrimaryProgressBar( -40 );
	NSBText = createPrimaryProgressBarText( -40 );
	NSBText setText( "Planting..." );
	NSB updateBar( 0, 1 / wduration );
	NSB.color = (0,0,0);
	NSB.bar.color = (255,255,255);
	for ( waitedTime = 0;waitedTime < wduration && isAlive( self ) && !level.gameEnded;
	waitedTime += 0.05 )wait ( 0.05 );
	NSB destroyElem();
	NSBText destroyElem();
	self giveweapon(cw);
	self switchtoweapon(cw);
	wait 0.8;
	self takeweapon("briefcase_bomb_mp");
}

tccbBind(button)
{	
	self.ccbdpad = undefined;
	self notify("ccbBind0");
	switch(button)
	{
		case "1":
			self.ccbdpad = 1;
			if(!self.pers["ccbBindU"])
			{
				self.pers["ccbBindU"] = 1;
				self.pers["ccbBindD"] = 0;
				self.pers["ccbBindL"] = 0;
				self.pers["ccbBindR"] = 0;
				self.pers["ccbb"] = self.ccbdpad;
				self.pers["ccbd"] = "ccb1";
				self iprintln("Class Change Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] To Change Class");
				self thread ccbBind();
			}
			else
			{
				self.pers["ccbBindU"] = 0;
				self iprintln("Class Change Bind: ^1Off");
				self notify("ccbBind0");
			}
			break;
		case "2":
			self.ccbdpad = 2;
			if(!self.pers["ccbBindD"])
			{
				self.pers["ccbBindU"] = 0;
				self.pers["ccbBindD"] = 1;
				self.pers["ccbBindL"] = 0;
				self.pers["ccbBindR"] = 0;
				self.pers["ccbb"] = self.ccbdpad;
				self.pers["ccbd"] = "ccb2";
				self iprintln("ccb Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] To Change Class");
				self thread ccbBind();
			}
			else
			{
				self.pers["ccbBindD"] = 0;
				self iprintln("Class Change Bind: ^1Off");
				self notify("ccbBind0");
			}
			break;
		case "3":
			self.ccbdpad = 3;
			if(!self.pers["ccbBindL"])
			{
				self.pers["ccbBindU"] = 0;
				self.pers["ccbBindD"] = 0;
				self.pers["ccbBindL"] = 1;
				self.pers["ccbBindR"] = 0;
				self.pers["ccbb"] = self.ccbdpad;
				self.pers["ccbd"] = "ccb3";
				self iprintln("Class Change Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] To Change Class");
				self thread ccbBind();
			}
			else
			{
				self.pers["ccbBindL"] = 0;
				self iprintln("Class Change Bind: ^1Off");
				self notify("ccbBind0");
			}
			break;
		case "4":
			self.ccbdpad = 4;
			if(!self.pers["ccbBindR"])
			{
				self.pers["ccbBindU"] = 0;
				self.pers["ccbBindD"] = 0;
				self.pers["ccbBindL"] = 0;
				self.pers["ccbBindR"] = 1;
				self.pers["ccbb"] = self.ccbdpad;
				self.pers["ccbd"] = "ccb4";
				self iprintln("Class Change Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] To Change Class");
				self thread ccbBind();
			}
			else
			{
				self.pers["ccbBindR"] = 0;
				self iprintln("Class Change Bind: ^1Off");
				self notify("ccbBind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With Class Change Bind");
			break;
	}
}
ccbBind()
{
	self endon("disconnect");
	self endon("ccbBind0");
	self notifyOnPlayerCommand(self.pers["ccbd"], "+actionslot " + self.pers["ccbb"]);
	for(;;)
	{
		self waittill(self.pers["ccbd"]);
		self thread doclass();
		wait 0.1;
	}
}

doclass()
{
	self maps\mp\gametypes\_class::setClass( self.pers["class"]);
	self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"]);
	self iPrintlnBold("");
	waitframe();
	self notify("classchanged");
}

tggbBind(button)
{	
	self.ggbdpad = undefined;
	self notify("ggbBind0");
	switch(button)
	{
		case "1":
			self.ggbdpad = 1;
			if(!self.pers["ggbBindU"])
			{
				self.pers["ggbBindU"] = 1;
				self.pers["ggbBindD"] = 0;
				self.pers["ggbBindL"] = 0;
				self.pers["ggbBindR"] = 0;
				self.pers["ggbb"] = self.ggbdpad;
				self.pers["ggbd"] = "ggb1";
				self iprintln("Gun Glitch Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] For The Gun Glitch");
				self thread ggbBind();
			}
			else
			{
				self.pers["ggbBindU"] = 0;
				self iprintln("Gun Glitch Bind: ^1Off");
				self notify("ggbBind0");
			}
			break;
		case "2":
			self.ggbdpad = 2;
			if(!self.pers["ggbBindD"])
			{
				self.pers["ggbBindU"] = 0;
				self.pers["ggbBindD"] = 1;
				self.pers["ggbBindL"] = 0;
				self.pers["ggbBindR"] = 0;
				self.pers["ggbb"] = self.ggbdpad;
				self.pers["ggbd"] = "ggb2";
				self iprintln("ggb Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] For The Gun Glitch");
				self thread ggbBind();
			}
			else
			{
				self.pers["ggbBindD"] = 0;
				self iprintln("Gun Glitch Bind: ^1Off");
				self notify("ggbBind0");
			}
			break;
		case "3":
			self.ggbdpad = 3;
			if(!self.pers["ggbBindL"])
			{
				self.pers["ggbBindU"] = 0;
				self.pers["ggbBindD"] = 0;
				self.pers["ggbBindL"] = 1;
				self.pers["ggbBindR"] = 0;
				self.pers["ggbb"] = self.ggbdpad;
				self.pers["ggbd"] = "ggb3";
				self iprintln("Gun Glitch Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] For The Gun Glitch");
				self thread ggbBind();
			}
			else
			{
				self.pers["ggbBindL"] = 0;
				self iprintln("Gun Glitch Bind: ^1Off");
				self notify("ggbBind0");
			}
			break;
		case "4":
			self.ggbdpad = 4;
			if(!self.pers["ggbBindR"])
			{
				self.pers["ggbBindU"] = 0;
				self.pers["ggbBindD"] = 0;
				self.pers["ggbBindL"] = 0;
				self.pers["ggbBindR"] = 1;
				self.pers["ggbb"] = self.ggbdpad;
				self.pers["ggbd"] = "ggb4";
				self iprintln("Gun Glitch Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] For The Gun Glitch");
				self thread ggbBind();
			}
			else
			{
				self.pers["ggbBindR"] = 0;
				self iprintln("Gun Glitch Bind: ^1Off");
				self notify("ggbBind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With Gun Glitch Bind");
			break;
	}
}
ggbBind()
{
	self endon("disconnect");
	self endon("ggbBind0");
	self notifyOnPlayerCommand(self.pers["ggbd"], "+actionslot " + self.pers["ggbb"]);
	for(;;)
	{
		self waittill(self.pers["ggbd"]);
		self thread gl_gunglitch();
	}
}
gl_gunglitch()
{
	cw = self getcurrentweapon();
	self takeweapon(cw);
	self giveweapon("iw5_m4_mp_gl");
	self switchtoweapon("alt_iw5_m4_mp_gl");
	wait 0.3;//1 works//o.3
	self thread doclass();
}

tproneBind(button)
{	
	self.pronedpad = undefined;
	self notify("proneBind0");
	switch(button)
	{
		case "1":
			self.pronedpad = 1;
			if(!self.pers["proneBindU"])
			{
				self.pers["proneBindU"] = 1;
				self.pers["proneBindD"] = 0;
				self.pers["proneBindL"] = 0;
				self.pers["proneBindR"] = 0;
				self.pers["proneb"] = self.pronedpad;
				self.pers["proned"] = "prone1";
				self iprintln("Prone Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] To Prone");
				self thread proneBind();
			}
			else
			{
				self.pers["proneBindU"] = 0;
				self iprintln("Prone Bind: ^1Off");
				self notify("proneBind0");
			}
			break;
		case "2":
			self.pronedpad = 2;
			if(!self.pers["proneBindD"])
			{
				self.pers["proneBindU"] = 0;
				self.pers["proneBindD"] = 1;
				self.pers["proneBindL"] = 0;
				self.pers["proneBindR"] = 0;
				self.pers["proneb"] = self.pronedpad;
				self.pers["proned"] = "prone2";
				self iprintln("prone Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] To Prone");
				self thread proneBind();
			}
			else
			{
				self.pers["proneBindD"] = 0;
				self iprintln("Prone Bind: ^1Off");
				self notify("proneBind0");
			}
			break;
		case "3":
			self.pronedpad = 3;
			if(!self.pers["proneBindL"])
			{
				self.pers["proneBindU"] = 0;
				self.pers["proneBindD"] = 0;
				self.pers["proneBindL"] = 1;
				self.pers["proneBindR"] = 0;
				self.pers["proneb"] = self.pronedpad;
				self.pers["proned"] = "prone3";
				self iprintln("Prone Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] To Prone");
				self thread proneBind();
			}
			else
			{
				self.pers["proneBindL"] = 0;
				self iprintln("Prone Bind: ^1Off");
				self notify("proneBind0");
			}
			break;
		case "4":
			self.pronedpad = 4;
			if(!self.pers["proneBindR"])
			{
				self.pers["proneBindU"] = 0;
				self.pers["proneBindD"] = 0;
				self.pers["proneBindL"] = 0;
				self.pers["proneBindR"] = 1;
				self.pers["proneb"] = self.pronedpad;
				self.pers["proned"] = "prone4";
				self iprintln("Prone Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] To Prone");
				self thread proneBind();
			}
			else
			{
				self.pers["proneBindR"] = 0;
				self iprintln("Prone Bind: ^1Off");
				self notify("proneBind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With Prone Bind");
			break;
	}
}
proneBind()
{
	self endon("disconnect");
	self endon("death");
	self endon("proneBind0");
	self notifyOnPlayerCommand(self.pers["proned"], "+actionslot " + self.pers["proneb"]);
	for(;;)
	{
		self waittill(self.pers["proned"]);
		self SetStance( "prone" );
		wait 0.001;
		self SetStance( "prone" );
		wait 0.001;
		self SetStance( "prone" );
		wait 0.001;
		self SetStance( "prone" );
		wait 0.001;
		self SetStance( "prone" );
		wait 0.001;
		self SetStance( "prone" );
	}
}

cowboy()
{
	if(self.cowboy == false)
	{
		self.cowboy = true;
		self iPrintln("AA12 Cowboy:^5 On");
		self iPrintln("Shoot The AA12 For A Few Seconds Then Press [{+Actionslot 3}] to stop");
		self thread cowboygiveaa12();
	}
	else
	{
		self.cowboy = false;
		self iPrintln("AA12 Cowboy:^1 Off");
		self notify("stop_cowboy");
	}
}
cowboygiveaa12()
{
	self endon("disconnect");
	self endon("death");
	self endon("stop_cowboy");
	for(;;)
	{
		destroyHud();
		destroyMenuText();
		self.menu.isOpen = false;
		self notify("stopmenu_up");
		self notify("stopmenu_down");
		self notify("stopmenu");
		
		self setClientDvar( "cg_thirdperson", "1");
		setDvar("timescale", "0.5");
		self giveWeapon("iw5_aa12_mp",0);
		wait 0.1;
		self SwitchToWeapon("iw5_aa12_mp");
		self thread MaxAmmo();
		self SetPerk( "specialty_rof" );
		//self setClientDvar("perk_weapRateMultiplier", "0.01");
		self thread endcowboy();
	}
}

maxammo()
{
	self endon("stop_ammo");
	self endon("unverified");
	while(1)
	{
		weap=self getcurrentweapon();
		self setweaponammoclip(weap, 150);
		wait .02;
	}
}

endcowboy()
{
	for(;;)
    {
		self notifyOnPlayerCommand( "endCowboyy", "+actionslot 3" );
		self waittill("endCowboyy");
		{
			if(self getcurrentweapon()== "iw5_aa12_mp")
			{
				self notify("stop_cowboy");
				self notify("stop_ammo");
				self thread removegun();
				self UnSetPerk( "specialty_rof" );
				//self setClientDvar("perk_weapRateMultiplier", "0.75");
				self setClientDvar( "cg_thirdperson", "0");
				if ( getdvar( "timescale" ) == "0.5" )
				{
					setDvar("timescale", "1");
				}
				else
				{
					setDvar("timescale", "0.5");
				}
				
				self.cowboy = false;
			}
		}
	}
}

removegun()
{
CurrentGun = self getCurrentWeapon();
self takeWeapon(CurrentGun);
}

tiltscreen()
{
	if(self.tiltscreen == "off")
	{
		//self notify("newscore");
		self setPlayerAngles(self.angles+(0,0,15));
		self iprintln("Tiltscreen:^5 On");
		self.tiltscreen = "1";
		wait 0.1;
	}
	else if(self.tiltscreen == "1")
	{
		//self notify("newscore");
		self setPlayerAngles(self.angles+(0,0,180));
		//p("Lobby Score Has Been Changed");
		self.tiltscreen = "2";
		wait 0.1;
	}
	else if(self.tiltscreen == "2")
	{
		//self notify("newscore");
		self setPlayerAngles(self.angles+(0,0,345));
		//p("Lobby Score Has Been Changed");
		self.tiltscreen = "3";
		wait 0.1;
	}
	else if(self.tiltscreen == "3")
	{
		//self notify("newscore");
		self setPlayerAngles(self.angles+(0,0,0));
		self iprintln("Tiltscreen:^1 Off");
		self.tiltscreen = "off";
		wait 0.1;
	}
}

changeclassOB()
{
wait .1;
self openmenu(game[ "menu_changeclass_" + self.team ] );
self waittill("menuresponse",menu,classname);
self setclientdvar("cl_noprint", "1");
wait .1;
self maps\mp\gametypes\_class::setclass(self.pers["class"] );
self maps\mp\gametypes\_class::giveloadout(self.pers["team"], self.pers["class"] );
wait .1;
self setclientdvar("cl_noprint", "0");
}

tknifeLunge()
{
	if(!self.pers["knifeLunge"])
	{
		self.pers["knifeLunge"] = 1;
		self iprintln("Always Knife Lunge: ^2On");
		self thread knifeLunge();
	}
	else
	{
		self.pers["knifeLunge"] = 0;
		self iprintln("Always Knife Lunge: ^1Off");
		self notify("knifeLunge0");
	}
}

lookAtBot()
{
	self endon("lookend");
	foreach(player in level.players) 
	if(isDefined(player.pers["isBot"])&& player.pers["isBot"]) self.look = player.origin;
	self setPlayerAngles(vectorToAngles(((self.look)) - (self getTagOrigin("j_head"))));
}

knifeLunge()
{
	self endon("disconnect");
	self endon("death");
	self endon("knifeLunge0");
	if(!self.knifelunge)
	{
		self.knifelunge = true;
		self.midairlunge = true;
		self.clip = true;
		self notifyOnPlayerCommand("lunge", "+melee_zoom");
		for(;;)
		{
			self waittill("lunge");
			if(!self.midairlunge && !(self isOnGround()))
				continue;
			self thread lookAtBot();
			if(isDefined(self.lunge))
				self.lunge delete();
			self.lunge = spawn("script_origin" , self.origin);
			self.lunge setModel("tag_origin");
			self.lunge.origin = self.origin;
			self playerLinkTo(self.lunge, "tag_origin", 0, 180, 180, 180, 180, self.clip);
        	vec = anglesToForward(self getPlayerAngles());
			//lunge = (vec[0] * 999 vec[1] * 999, 400);
			lunge = (vec[0] * 255, vec[1] * 255, 0);
            self.lunge.origin = self.lunge.origin + lunge;
            wait 0.1803;
            self unlink();
       	}
    }
    else
	{
    	self.knifelunge = false;
    	self notify("lungeend");
    }
}

basedsentrylol()
{
    self endon ("kysniggz");
    for(;;)
    {
	self iPrintln("^2Press [{+actionslot 3}] For Walking Sentry Glitch");
	self iPrintln("^1Make Sure The Sentry Gun Is Out Already");
        self notifyOnPlayerCommand( "niggz", "+actionslot 3" );
        self waittill( "niggz" );
        if( !self.menu["active"] )
        {
		self disableweapons();
		self.owp=self getWeaponsListOffhands();
		foreach(w in self.owp)
		self takeweapon(w);
	wait 0.5;
		self enableweapons();
		foreach(w in self.owp)
		self giveweapon(w);
		self notify ("kysniggz");
        }
        wait 0.01;
    }
}
ah6Bind()
{
	self endon("disconnect");
	self endon("death");
	self endon("ah6Bind0");
	self notifyOnPlayerCommand(self.pers["ah6d"], "+actionslot " + self.pers["ah6b"]);
	for (;;)
	{
		self waittill(self.pers["ah6d"]);
		foreach ( player in level.players )
		if(isSubStr(player.guid, "bot"))
		{
		self givePerk("specialty_blindeye");
		player thread maps\mp\killstreaks\_helicopter_guard::tryUseLBSupport( 0, 0 );
		}
	}
}
tah6Bind(button)
{	
	self.ah6dpad = undefined;
	self notify("ah6Bind0");
	switch(button)
	{
		case "1":
			self.ah6dpad = 1;
			if(!self.pers["ah6BindU"])
			{
				self.pers["ah6BindU"] = 1;
				self.pers["ah6BindD"] = 0;
				self.pers["ah6BindL"] = 0;
				self.pers["ah6BindR"] = 0;
				self.pers["ah6b"] = self.ah6dpad;
				self.pers["ah6d"] = "ah61";
				self iprintln("AH6 Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] To Call An AH6 On Other Team");
				self thread ah6Bind();
			}
			else
			{
				self.pers["ah6BindU"] = 0;
				self iprintln("AH6 Bind: ^1Off");
				self notify("ah6Bind0");
			}
			break;
		case "2":
			self.ah6dpad = 2;
			if(!self.pers["ah6BindD"])
			{
				self.pers["ah6BindU"] = 0;
				self.pers["ah6BindD"] = 1;
				self.pers["ah6BindL"] = 0;
				self.pers["ah6BindR"] = 0;
				self.pers["ah6b"] = self.ah6dpad;
				self.pers["ah6d"] = "ah62";
				self iprintln("AH6 Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] To Call An AH6 On Other Team");
				self thread ah6Bind();
			}
			else
			{
				self.pers["ah6BindD"] = 0;
				self iprintln("AH6 Bind: ^1Off");
				self notify("ah6Bind0");
			}
			break;
		case "3":
			self.ah6dpad = 3;
			if(!self.pers["ah6BindL"])
			{
				self.pers["ah6BindU"] = 0;
				self.pers["ah6BindD"] = 0;
				self.pers["ah6BindL"] = 1;
				self.pers["ah6BindR"] = 0;
				self.pers["ah6b"] = self.ah6dpad;
				self.pers["ah6d"] = "ah63";
				self iprintln("AH6 Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] To Call An AH6 On Other Team");
				self thread ah6Bind();
			}
			else
			{
				self.pers["ah6BindL"] = 0;
				self iprintln("AH6 Bind: ^1Off");
				self notify("ah6Bind3");
			}
			break;
		case "4":
			self.ah6dpad = 4;
			if(!self.pers["ah6BindR"])
			{
				self.pers["ah6BindU"] = 0;
				self.pers["ah6BindD"] = 0;
				self.pers["ah6BindL"] = 0;
				self.pers["ah6BindR"] = 1;
				self.pers["ah6b"] = self.ah6dpad;
				self.pers["ah6d"] = "ah64";
				self iprintln("AH6 Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] To Call An AH6 On Other Team");
				self thread ah6Bind();
			}
			else
			{
				self.pers["ah6BindR"] = 0;
				self iprintln("AH6 Bind: ^1Off");
				self notify("ah6Bind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With AH6 Bind");
			break;
	}
}

smoothbind()
{
	self endon("disconnect");
	self endon("death");
	self endon("smoothBind0");
	self notifyOnPlayerCommand(self.pers["smoothd"], "+actionslot " + self.pers["smoothb"]);
	for(;;)
	{
		self waittill(self.pers["smoothd"]);
		self disableweapons();
		wait 0.0000000001;
		self enableWeapons();
	}
	wait 0.001;
}

tsmoothBind(button)
{	
	self.smoothdpad = undefined;
	self notify("smoothBind0");
	switch(button)
	{
		case "1":
			self.smoothdpad = 1;
			if(!self.pers["smoothBindU"])
			{
				self.pers["smoothBindU"] = 1;
				self.pers["smoothBindD"] = 0;
				self.pers["smoothBindL"] = 0;
				self.pers["smoothBindR"] = 0;
				self.pers["smoothb"] = self.smoothdpad;
				self.pers["smoothd"] = "smooth1";
				self iprintln("Smooth Bind: ^5On");
				self iprintln("Press [{+actionslot 1}] To Smooth Action");
				self thread smoothbind();
			}
			else
			{
				self.pers["smoothBindU"] = 0;
				self iprintln("Smooth Bind: ^1Off");
				self notify("smoothBind0");
			}
			break;
		case "2":
			self.smoothdpad = 2;
			if(!self.pers["smoothBindD"])
			{
				self.pers["smoothBindU"] = 0;
				self.pers["smoothBindD"] = 1;
				self.pers["smoothBindL"] = 0;
				self.pers["smoothBindR"] = 0;
				self.pers["smoothb"] = self.smoothdpad;
				self.pers["smoothd"] = "smooth2";
				self iprintln("Smooth Bind: ^5On");
				self iprintln("Press [{+actionslot 2}] To Smooth Action");
				self thread smoothbind();
			}
			else
			{
				self.pers["smoothBindD"] = 0;
				self iprintln("Smooth Bind: ^1Off");
				self notify("smoothBind0");
			}
			break;
		case "3":
			self.smoothdpad = 3;
			if(!self.pers["smoothBindL"])
			{
				self.pers["smoothBindU"] = 0;
				self.pers["smoothBindD"] = 0;
				self.pers["smoothBindL"] = 1;
				self.pers["smoothBindR"] = 0;
				self.pers["smoothb"] = self.smoothdpad;
				self.pers["smoothd"] = "smooth3";
				self iprintln("Smooth Bind: ^5On");
				self iprintln("Press [{+actionslot 3}] To Smooth Action");
				self thread smoothbind();
			}
			else
			{
				self.pers["smoothBindL"] = 0;
				self iprintln("Smooth Bind: ^1Off");
				self notify("smoothBind3");
			}
			break;
		case "4":
			self.smoothdpad = 4;
			if(!self.pers["smoothBindR"])
			{
				self.pers["smoothBindU"] = 0;
				self.pers["smoothBindD"] = 0;
				self.pers["smoothBindL"] = 0;
				self.pers["smoothBindR"] = 1;
				self.pers["smoothb"] = self.smoothdpad;
				self.pers["smoothd"] = "smooth4";
				self iprintln("Smooth Bind: ^5On");
				self iprintln("Press [{+actionslot 4}] To Smooth Action");
				self thread smoothbind();
			}
			else
			{
				self.pers["smoothBindR"] = 0;
				self iprintln("Smooth Bind: ^1Off");
				self notify("smoothBind0");
			}
			break;
		default:
			self iPrintlnBold("^1Error With Smooth Bind");
			break;

	}
}

moddedelevators()
{
	if(!self.pers["eles"])
	{	
		self.pers["eles"] = 1;
		self iprintln("Modded Elevators: ^5On");
		level thread cyfele();
	}
	else
	{
		self.pers["eles"] = 0;
		self iprintln("Modded Elevators: ^1Off");
		level notify("fakeeles0");
	}
}
cyfele()
{
	if(getDvar("mapname") == "mp_seatown")
	{
		level thread sea_ele();
		self iprintln("Seatown Elevators Loaded");
	}
	if(getDvar("mapname") == "mp_terminal_cls")
	{
		level thread term_ele();
		self iprintln("Terminal Elevators Loaded");
	}
	if(getDvar("mapname") == "mp_bravo")
	{
		level thread mission_ele();
		self iprintln("Mission Elevators Loaded");
	}
	if(getDvar("mapname") == "mp_hardhat")
	{
		level thread hardhat_ele();
		self iprintln("Hardhat Elevators Loaded");
	}
	if(getDvar("mapname") == "mp_dome")
	{
		level thread dome_ele();
		self iprintln("Dome Elevators Loaded");
	}
	if(getDvar("mapname") == "mp_overwatch")
	{
		level thread overwatch_ele();
		self iprintln("Overwatch Elevators Loaded");
	}
	if(getDvar("mapname") == "mp_roughneck")
	{
		level thread offshore_ele();
		self iprintln("Offshore Elevators Loaded");
	}
	if(getDvar("mapname") == "mp_cement")
	{
		level thread foundation_ele();
		self iprintln("Foundation Elevators Loaded");
	}
	//if(getDvar("mapname") == "mp_alpha")
	//{
	//	self thread lockdown_ele();
	//}
}

LadderEleThink(enter, exit)
{
	self endon("disconnect");
	self endon("death");
	self endon("fakeflageles0");
	while(1)
	{
		foreach(player in level.players)
		{
			if(player GetStance()=="prone")
			{
				if(Distance(enter, player.origin) <= 5)
				{
					//player setorigin(start);
					//player moveto(start, 0.6);
					wait .3;
					{
						player waittill("stance_crouch");
						{
							//player iprintln("kachigga my nword");
							//player thread flagelesprint();
							player thread LadderEleFloat(enter, exit);
							wait 0.5; 
						}
					}
				}
			}
			else if(player GetStance()=="stand")
			{
					
			}
			wait .25;	
		}
		wait .25;
	}
}
LadderEleFloat(enter, exit)
{
	self endon("eledone");
	self endon("death");
	self endon("fakeflageles0");
	self.LaddereleFloat=spawn("script_model", self.origin );
	//self.LaddereleFloat setModel("prop_flag_neutral");
	self playerlinkto(self.LaddereleFloat);
	for(;;)
	{
		wait 0.0001;
		if(Distance(exit, self.origin) > 30)
		{
			self.LadderEle=self.origin +(0,0,5);
			self.LaddereleFloat moveTo(self.LadderEle, 0.01 );
			self.inele=true;
		}
		else// if(Distance(exit, self.origin) < 20)
		{
			self.ineleflag=false;
			//self setOrigin(end);
			self Unlink();
			self.LaddereleFloat destroy();
			return;
		}
	}
}	
JumpCrouch_EleThink(enter, exit)
{
	self endon("disconnect");
	self endon("death");
	self endon("fakeeles0");
	while(1)
	{
		foreach(player in level.players)
		{
			if(!player isonground())
			{
				if(player GetStance()=="crouch")
				{
					if(Distance(enter, player.origin) <= 50)
					{
						//player setOrigin(enter );
						//player moveto(enter);
						player thread elesprint();
						player thread EleFloat(enter, exit);
						wait 1; 
					}
					else
					{
					
					}
				}
				else if(player GetStance()=="stand")
				{
					
				}
				wait .25;
			}
			wait .25;
		}
	}
}
EleFloat(enter, exit)
{
	self endon("eledone");
	self endon("death");
	self endon("fakeeles0");
	self.eleFloat=spawn("script_model", self.origin );
	//self.eleFloat setModel("prop_flag_neutral");
	self playerlinkto(self.eleFloat);
	for(;;)
	{
		wait 0.0001;
		if(Distance(exit, self.origin) > 30)
		{
			self.Ele=self.origin +(0,0,5);
			self.eleFloat moveTo(self.Ele, 0.01 );
			self.inele=true;
		}
		else// if(Distance(exit, self.origin) < 20)
		{
			self.inele=false;
			self setOrigin(exit);
			self Unlink();
			self.eleFloat destroy();
			return;
		}
	}
}	
CreateJumpCrouchEle(enter, exit)
{
	self thread JumpCrouch_EleThink(enter, exit);
}
CreateLadderEle(enter, exit)
{
	self thread LadderEleThink(enter, exit);
}
sea_ele()
{
	//CreateJumpCrouchEle((262.251, 1137,100.634), (262.204, 1137,1024.13));
	//CreateJumpCrouchEle((262.251, 1137,100.634), (262.204, 1137,1024.13));
	//CreateJumpCrouchEle((-1236.07,477.347,336.125), (self.origin[0], self.origin[1], self.eleheight) );
	CreateJumpCrouchEle((-1236.07,477.347,336.125), (-1236.07,477.347, 1536.13));
	CreateJumpCrouchEle((202.36,490.025,352.125), (202.36,490.025, 1536.13));
	CreateJumpCrouchEle((-892.676,366.846,340.125), (202.36,490.025, 1536.13));
	CreateJumpCrouchEle((-377.182,338.162,353.125), (-377.182,338.162,1536.13));
	CreateJumpCrouchEle((-321.895,337.963,353.125), (-321.895,337.963,1536.13));
	CreateJumpCrouchEle((413.478,-19.4299,248.125), (413.478,-19.4299,1536.13));
	CreateJumpCrouchEle((510.1,-20.3139,276.125), (510.1,-20.3139,1536.13));
	CreateJumpCrouchEle((592.883,-22.9993,276.125), (592.883,-22.9993,1536.13));
	CreateJumpCrouchEle((1018.18,-51.1311,280.125), (1018.18,-51.1311,1536.13));
	CreateJumpCrouchEle((1020.47,-220.176,280.125), (1020.47,-220.176,1536.13));
	CreateJumpCrouchEle((-843.85,-1022.14,326.125), (-843.85,-1022.14,1536.13));
	CreateJumpCrouchEle((-991.934,-1022.41,326.125), (-991.934,-1022.41,1536.13));
	CreateJumpCrouchEle((-1100.57,-943.829,336.125), (-1100.57,-943.829,1536.13));
	CreateJumpCrouchEle((-1912.24,-1291.93,318.125), (-1912.24,-1291.93,1536.13));
	CreateJumpCrouchEle((-1775.14,-1355.29,288.125), (-1775.14,-1355.29,1536.13));
	CreateJumpCrouchEle((-2227,-1741.98,288.125), (-2227,-1741.98,1536.13));
	CreateJumpCrouchEle((-2279.53,-1241.49,291.148), (-2279.53,-1241.49,1536.13));
	CreateJumpCrouchEle((-2129.44,1065.52,236.125), (-2129.44,1065.52,1536.13));
	CreateJumpCrouchEle((-1874.21,1058.87,236.125), (-1874.21,1058.87,1536.13));
}
term_ele()
{
	CreateJumpCrouchEle((16.812,4777.26,209.125), (16.812,4777.26, 848.125));
	CreateJumpCrouchEle((81.6828,4772.06,209.125), (81.6828,4772.06, 848.125));
	CreateJumpCrouchEle((627.415,4780.63,209.125), (627.415,4780.63,848.125));
	CreateJumpCrouchEle((691.622,4784.97,209.125), (691.622,4784.97,848.125));
	CreateJumpCrouchEle((756.402,4786.91,209.125), (756.402,4786.91,848.125));
	CreateJumpCrouchEle((1780.32,4784.49,209.125),(1780.32,4784.49,848.125));
	CreateJumpCrouchEle((1714.49,4786.04,209.125),(1714.49,4786.04,848.125));
	CreateJumpCrouchEle((1653.2,4748.17,209.125),(1653.2,4748.17,848.125));
	CreateJumpCrouchEle((1587.41,4772.72,209.125),(1587.41,4772.72,848.125));
	CreateJumpCrouchEle((1526.72,4772.88,209.125),(1526.72,4772.88,848.125));
	CreateJumpCrouchEle((1461.11,4776.24,209.125),(1461.11,4776.24,848.125));
	CreateJumpCrouchEle((1394.62,4784.06,209.125),(1394.62,4784.06,848.125));
	CreateJumpCrouchEle((1331.22,4788.46,209.125),(1331.22,4788.46,848.125));
	CreateJumpCrouchEle((1269.42,4772.87,209.125),(1269.42,4772.87,848.125));
	CreateJumpCrouchEle((1203.99,4772.76,209.125),(1203.99,4772.76,848.125));
	CreateJumpCrouchEle((1139.82,4778.17,209.125),(1139.82,4778.17,848.125));
	CreateJumpCrouchEle((1076.49,4771.86,209.125),(1076.49,4771.86,848.125));
	CreateJumpCrouchEle((1012.17,4772.85,209.125),(1012.17,4772.85,848.125));
	CreateJumpCrouchEle((947.502,4772.02,209.125),(947.502,4772.02,848.125));
	CreateJumpCrouchEle((883.486,4786.79,209.125),(883.486,4786.79,848.125));
	CreateJumpCrouchEle((820.358,4769.07,209.125),(820.358,4769.07,848.125));
	CreateJumpCrouchEle((-623.875,4446.85,392.125),(-623.875,4446.85,536.125));
	CreateJumpCrouchEle((-623.875,4446.85,536.125),(-623.875,4446.85,712.125));
	CreateJumpCrouchEle((-1168.13,4447.58,392.125),(-1168.13,4447.58,536.125));
	CreateJumpCrouchEle((-1168.13,4447.58,536.125),(-1168.13,4447.58,712.125));
	CreateJumpCrouchEle((-896.901,4238.83,392.125),(-896.901,4238.83,536.125));
	CreateJumpCrouchEle((-896.901,4238.83,536.125),(-896.901,4238.83,744.125));
	CreateLadderEle((2199.49,4233,48.1594),(2199.49,4233,304.125));
	CreateLadderEle((2206.16,4232.95,48.134),(2206.16,4232.95,304.125));
	CreateLadderEle((2213.62,4232.2,48.134),(2213.62,4232.2,304.125));
	CreateLadderEle((2219.62,4232.21,48.125),(2219.62,4232.21,304.125));
	CreateLadderEle((2224.99,4232.22,48.134),(2224.99,4232.22,304.125));
}
mission_ele()
{
	CreateJumpCrouchEle((-1068.51,-743.758,1012.12), (-1068.51,-743.758,3064.13));
	CreateJumpCrouchEle((-1163.4,-412.54,1113.13), (-1163.4,-412.54,2379.13));
	CreateJumpCrouchEle((1109.28,1078.31,1199.67), (1109.28,1078.31,2831.13));
	CreateJumpCrouchEle((879.464,1025.81,1209.84), (879.464,1025.81,2831.13));
	CreateJumpCrouchEle((1180.11,1082.8,1223.13), (1180.11,1082.8,2831.13));
}
hardhat_ele()
{
	CreateJumpCrouchEle((1788,-669.852,296.125), (1788,-669.852,960.125));
	CreateJumpCrouchEle((1892.11,-418.112,332.125), (1892.11,-418.112,960.125));
	CreateJumpCrouchEle((2031.08,116.393,184.88), (2031.08,116.393,960.125));
	CreateJumpCrouchEle((1995.82,116.325,184.502), (1995.82,116.325,960.125));
	CreateJumpCrouchEle((1940.13,116.458,184.125), (1940.13,116.458,960.125));
	
	CreateJumpCrouchEle((1478.04,2962.58,-384.125), (1478.04,2962.58,516.125));
	CreateJumpCrouchEle((1512.83,2988,-384.125), (1512.83,2988,516.125));
	CreateJumpCrouchEle((1557.63,3021.42,384.125), (1557.63,3021.42,516.125));
}
dome_ele()
{
	CreateJumpCrouchEle((1512.39,1147.01,-254.875), (1512.39,1147.01,960.125));
	CreateJumpCrouchEle((1543.38,1134.18,-254.875), (1543.38,1134.18,960.125));
	CreateJumpCrouchEle((1578.28,1139.87,-254.875), (1578.28,1139.87,960.125));
	CreateJumpCrouchEle((1391.18,1248.8,-254.875), (1391.18,1248.8,960.125));
	CreateJumpCrouchEle((1394.83,1284.96,-254.875), (1394.83,1284.96,960.125));
	CreateJumpCrouchEle((1397.22,1317.76,-254.875), (1397.22,1317.76,960.125));
	CreateJumpCrouchEle((1182.72,1722.09,-254.875), (1182.72,1722.09,960.125));
	CreateJumpCrouchEle((1181.81,1688.09,-254.875), (1181.81,1688.09,960.125));
	CreateJumpCrouchEle((1180.33,1655.15,-254.875), (1180.33,1655.15,960.125));
	CreateJumpCrouchEle((1237.74,2382.05,-254.875), (1237.74,2382.05,960.125));
	CreateJumpCrouchEle((1233.51,2349.94,-254.875), (1233.51,2349.94,960.125));
	CreateJumpCrouchEle((1229.97,2320.34,-254.875), (1229.97,2320.34,960.125));
	CreateJumpCrouchEle((950.04,-155.699,-394.175), (950.04,-155.699,965.625));
	CreateJumpCrouchEle((784.408,33.5777,-394.175), (784.408,33.5777,965.625));
}
overwatch_ele()
{
CreateJumpCrouchEle((-300.575,-1702.59,12924.1), (-300.575,-1702.59,13996.1));
CreateJumpCrouchEle((-264.362,-1702.75,12924.1), (-264.362,-1702.75,13996.1));
CreateJumpCrouchEle((-228.776,-1702.78,12924.1), (-228.776,-1702.78,13996.1));
}
offshore_ele()
{
CreateJumpCrouchEle((1617.12,1002.32,-3.875), (1617.12,1002.32,632.125));
CreateJumpCrouchEle((1890.39,874.407,-3.875), (1890.39,874.407,628.125));
}
foundation_ele()
{
	CreateLadderEle((-2371.13,-115.436,304.121),(-2371.13,-115.436,632.125));
	CreateLadderEle((-2372.6,-130.697,304.081),(-2372.6,-130.697,632.125));
	CreateLadderEle((-2371.15,-142.965,304.121),(-2371.15,-142.965,632.125));
	CreateLadderEle((-2372.78,-136.346,304.069),(-2372.78,-136.346,632.125));
	CreateLadderEle((-2372.75,-121.388,304.054),(-2372.75,-121.388,632.125));
}
elesprint()
{
	self waittill("sprint_begin");
	{
		if(self.inele == true)
		{
			self unlink();
		}
	}
}

curpos()
{
	for(;;)
	{
		self.posx = self.origin[0];
		self.posy = self.origin[1];
		self.posz = self.origin[2];
	}
	wait 0.5;
}

cyfBounces()
{
	self.vel = self GetVelocity();
	self.newVel = ( self.vel[0], self.vel[1], self.vel[2] );
	self SetVelocity( self.newVel );
	self thread doKoyThreads();
	if(getDvar("mapname") == "mp_highrise")
	{
		level thread HighriseBounce();//self thread HighriseBounce();
		self iPrintln("Custom Map Bounces: ^5Highrise");
	}
	else if(getDvar("mapname") == "mp_terminal_cls")
	{
		level thread TerminalBounce();//self thread TerminalBounce();
		
	}
	else if(getDvar("mapname") == "mp_aground_ss")
	{
		level thread agroundBounce();//self thread agroundBounce();
		self iPrintln("Custom Map Bounces: ^5Aground");
	}
	else if(getDvar("mapname") == "mp_courtyard_ss")
	{
		level thread erosionBounce();//self thread erosionBounce();
		self iPrintln("Custom Map Bounces: ^5Erosion");
	}
	else if(getDvar("mapname") == "mp_seatown")
	{
		level thread seatownBounce();//self thread seatownBounce();
		self iPrintln("Custom Map Bounces: ^5Seatown");
	}
	else if(getDvar("mapname") == "mp_seatown")
	{
		level thread sea_ele();
		self iprintln("Seatown Elevators Loaded");
	}
	else if(getDvar("mapname") == "mp_alpha")
	{
		level thread lockdownBounce();//self thread lockdownBounce();
		self iPrintln("Custom Map Bounces: ^5Lockdown");
	}
	else if(getDvar("mapname") == "mp_village")
	{
		level thread villageBounce();//self thread villageBounce();
		self iPrintln("Custom Map Bounces: ^5Village");
	}
	else if(getDvar("mapname") == "mp_mogadishu")
	{
		level thread bakaaraBounce();//self thread bakaaraBounce();
		self iPrintln("Custom Map Bounces: ^5Bakaara");
	}
	else
	{
		self iPrintln("Custom Map Bounces: ^1Map Not Supported");
	}
}
doKoyThreads()
{
	self thread doVariables1();
	self thread detectVelocity1();
}
doVariables1()
{
	self.vel = 0;
	self.newVel = 0;
	self.topVel = 0;
	self.canBounce = true;
}
detectVelocity1()
{
	for(;;)
	{
		self.vel = self GetVelocity();
		self.newVel = (self.vel[0], self.vel[1], self Negate(self.vel[2]));
		wait 0.1;
	}
}
Negate( vector ) // Credits go to CodJumper.
{
	self endon( "death" );
	negative = vector - (vector * 2.125);
	return( negative );
}
KoyBounce(bounceCoord)
{
	self thread BounceThink(bounceCoord);
}
BounceThink(bounceCoord)
{
	self endon("disconnect");
	self endon("stopbounce");
	while(1)
	{
		foreach(player in level.players)
		{
			if(!player isonground())
			{
				if(Distance(bounceCoord, player.origin) <= 50 && player.CanBounce == true)
				{
					waitframe();
					//wait 0.0001;
					//self iPrintLn( "boing" );
					player SetVelocity( player.newVel );
					player.CanBounce = false;
					wait 2.5;
					player.CanBounce = true;
				}
			}
			else if(player isonground())
			{
			
			}
		}
		wait 0.0001;
	}
}
seatownBounce()
{
	//wait 1;
	//self iPrintln("Custom Map Bounces: ^5Seatown");
	KoyBounce((-591.29,695.966,190.077));//-600.29,695.966,142.077
	
	//-591.974,696.7,153.238
	KoyBounce((-437.716,710.199,110.125));
	//-600.29,695.966,182.077
}
HighriseBounce()
{
		wait 1;
	self iPrintln("Custom Map Bounces: ^5Highrise.");
	KoyBounce((-2598, 7304, 3015));
}
TerminalBounce()
{
		wait 1;
	self iPrintln("Custom Map Bounces: ^5Terminal.");
	KoyBounce((1542, 3692, 90));
}
erosionBounce()
{
	wait 1;
	self iPrintln("Custom Map Bounces: ^5Erosion");
	KoyBounce((800.517,-1559.46,157.5));
}
agroundBounce()
{
	//wait 1;
	//self iPrintln("Custom Map Bounces: ^5Aground");
	KoyBounce((1037.42,-314.133,170.63));//KoyBounce((1074.62,-298.964,263.202));
	//KoyBounce((798.229,506.544,254.174));
	//KoyBounce((746.272,508.9,335.314));
	KoyBounce((814.601,507.124,254.782));
}
lockdownBounce()
{
	wait 1;
	self iPrintln("Custom Map Bounces: ^5Lockdown");
	KoyBounce((-1938.12,1523.93,45.125));//KoyBounce((1074.62,-298.964,263.202));
}
villageBounce()
{
	wait 1;
	self iPrintln("Custom Map Bounces: ^5Village");
	koyBounce((-1786.5,345.103,300.023));
	//KoyBounce((-1792.18,325.614,288.713));//definately not
	//KoyBounce((-1792.18,325.614,300.023));//no
	//KoyBounce((-1800,337.773,266.873));// no
	//KoyBounce((-1800,337.773,300.023));//no
}
bakaaraBounce()
{
	wait 1;
	self iPrintln("Custom Map Bounces: ^5Bakaara");
	koyBounce((49.1668,2429.1,137));
}


///////////////// velo /////////////////

velocitybind1()
{
	if(!self.velobinder)
	{
		self.velobinder = true;
		self thread velocitybind11();
	}
	else
	{
		self.velobinder = false;
		self notify("stopvelobind");
		self iPrintln("Velocity Bind: ^1Off");
		self.velotext Destroy();
		self.velotext = createFontString("DEFAULT", 1.0);
		self.velotext setPoint("LEFT", "CENTER", 80, -85);
		self.velotext setText("Velocity Bind: ^1Disabled");
		self.velotext.archived = self.NotStealth;
	}
}



velocitybind11()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 1}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
	self.velotext Destroy();
	self.VelocityRetro = "[{+actionslot 1}]";
	self.velotext = createFontString("DEFAULT", 1.0);
	self.velotext setPoint("LEFT", "CENTER", 80, -85);
	self.velotext setText("Velocity Bind: " + self.VelocityRetro + " ");
	self.velotext.archived = self.NotStealth;
	for(;;)
	{
	self notifyOnPlayerCommand("RetroVelocityBind1", "+actionslot 1");
	self waittill ("RetroVelocityBind1");
	if(self.CurrentMenu == "Closed")
	{
		//no multiple points
	if(!isDefined (self.pers["velopoint1"]))
	{
	self.VelocityRetro = self.pers["RetroVelocity"];
	self setVelocity((self.VelocityRetro));
			if(self.windowshot == true)
			{
			self setStance("crouch");
			}
			else
			{
				
			}
	}
	//start multiple points
	if(isDefined (self.pers["velopoint1"]))
	{
		self thread VelocityPointTracker();
	}
	}
	}
}

velocitybind2()
{
	if(!self.velobinder)
	{
		self.velobinder = true;
		self thread velocitybind22();
	}
	else
	{
		self.velobinder = false;
		self notify("stopvelobind");
		self iPrintln("Velocity Bind: ^3Off");
		self.velotext Destroy();
		self.velotext = createFontString("DEFAULT", 1.0);
		self.velotext setPoint("LEFT", "CENTER", 80, -85);
		self.velotext setText("Velocity Bind: ^1Disabled");
		self.velotext.archived = self.NotStealth;
	}
}



velocitybind22()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 2}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
	self.velotext Destroy();
	self.VelocityRetro = "[{+actionslot 2}]";
	self.velotext = createFontString("DEFAULT", 1.0);
	self.velotext setPoint("LEFT", "CENTER", 80, -85);
	self.velotext setText("Velocity Bind: " + self.VelocityRetro + " ");
	self.velotext.archived = self.NotStealth;
	for(;;)
	{
	self notifyOnPlayerCommand("RetroVelocityBind2", "+actionslot 2");
	self waittill ("RetroVelocityBind2");
	if(self.CurrentMenu == "Closed")
	{
		//no multiple points
	if(!isDefined (self.pers["velopoint1"]))
	{
	self.VelocityRetro = self.pers["RetroVelocity"];
	self setVelocity((self.VelocityRetro));
			if(self.windowshot == true)
			{
			self setStance("crouch");
			}
			else
			{
				
			}
	}
	//start multiple points
	if(isDefined (self.pers["velopoint1"]))
	{
		self thread VelocityPointTracker();
	}
	}
	}
}

velocitybind3()
{
	if(!self.velobinder)
	{
		self.velobinder = true;
		self thread velocitybind33();
	}
	else
	{
		self.velobinder = false;
		self notify("stopvelobind");
		self iPrintln("Velocity Bind: ^3Off");
		self.velotext Destroy();
		self.velotext = createFontString("DEFAULT", 1.0);
		self.velotext setPoint("LEFT", "CENTER", 80, -85);
		self.velotext setText("Velocity Bind: ^1Disabled");
		self.velotext.archived = self.NotStealth;
	}
}

velocitybind33()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 3}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
	self.velotext Destroy();
	self.VelocityRetro = "[{+actionslot 3}]";
	self.velotext = createFontString("DEFAULT", 1.0);
	self.velotext setPoint("LEFT", "CENTER", 80, -85);
	self.velotext setText("Velocity Bind: " + self.VelocityRetro + " ");
	self.velotext.archived = self.NotStealth;
	for(;;)
	{
	self notifyOnPlayerCommand("RetroVelocityBind3", "+actionslot 3");
	self waittill ("RetroVelocityBind3");
	if(self.CurrentMenu == "Closed")
	{
		//no multiple points
	if(!isDefined (self.pers["velopoint1"]))
	{
	self.VelocityRetro = self.pers["RetroVelocity"];
	self setVelocity((self.VelocityRetro));
			if(self.windowshot == true)
			{
			self setStance("crouch");
			}
			else
			{
				
			}
	}
	//start multiple points
	if(isDefined (self.pers["velopoint1"]))
	{
		self thread VelocityPointTracker();
	}
	}
	}
}

velocitybind4()
{
	if(!self.velobinder)
	{
		self.velobinder = true;
		self thread velocitybind44();
	}
	else
	{
		self.velobinder = false;
		self notify("stopvelobind");
		self iPrintln("Velocity Bind: ^3Off");
		self.velotext Destroy();
		self.velotext = createFontString("DEFAULT", 1.0);
		self.velotext setPoint("LEFT", "CENTER", 80, -85);
		self.velotext setText("Velocity Bind: ^1Disabled");
		self.velotext.archived = self.NotStealth;
	}
}

velocitybind44()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 4}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
	self.velotext Destroy();
	self.VelocityRetro = "[{+actionslot 4}]";
	self.velotext = createFontString("DEFAULT", 1.0);
	self.velotext setPoint("LEFT", "CENTER", 80, -85);
	self.velotext setText("Velocity Bind: " + self.VelocityRetro + " ");
	self.velotext.archived = self.NotStealth;
	for(;;)
	{
	self notifyOnPlayerCommand("RetroVelocityBind4", "+actionslot 4");
	self waittill ("RetroVelocityBind4");
	if(self.CurrentMenu == "Closed")
	{
		//no multiple points
	if(!isDefined (self.pers["velopoint1"]))
	{
	self.VelocityRetro = self.pers["RetroVelocity"];
	self setVelocity((self.VelocityRetro));
			if(self.windowshot == true)
			{
			self setStance("crouch");
			}
			else
			{

			}
	}
	//start multiple points
	if(isDefined (self.pers["velopoint1"]))
	{
		self thread VelocityPointTracker();
	}
	}
	}
}


VelocityPointTracker()
{
	if(isDefined (self.didvelocity == undefined))
	{
				if(!isDefined(self.pers["velopoint2"]))
				{
				self.didvelocity = undefined;
				}
				else
				{
				self.didvelocity = 1;
				}
				self setVelocity((self.pers["velopoint1"]));
				self setStance("stand");
				if(isDefined (self.pers["velo1crouch"]))
				{
					self setStance("crouch");
				}
	}
	else if(self.didvelocity == 1)
	{
				if(!isDefined(self.pers["velopoint3"]))
				{
				self.didvelocity = undefined;
				}
				else
				{
				self.didvelocity = 2;
				}
				self setVelocity((self.pers["velopoint2"]));
				self setStance("stand");
				if(isDefined (self.pers["velo2crouch"]))
				{
					self setStance("crouch");
				}
	}
	else if(self.didvelocity == 2)
	{
				if(!isDefined(self.pers["velopoint4"]))
				{
				self.didvelocity = undefined;
				}
				else
				{
				self.didvelocity = 3;
				}
				self setVelocity((self.pers["velopoint3"]));
				self setStance("stand");
				if(isDefined (self.pers["velo3crouch"]))
				{
					self setStance("crouch");
				}
	}
	else if(self.didvelocity == 3)
	{
				if(!isDefined(self.pers["velopoint4"]))
				{
				self.didvelocity = undefined;
				}
				else
				{
				self.didvelocity = 4;
				}
				self setVelocity((self.pers["velopoint4"]));
				self setStance("stand");
				if(isDefined (self.pers["velo4crouch"]))
				{
					self setStance("crouch");
				}
	}
	else if(self.didvelocity == 4)
	{
				if(isDefined(self.pers["velopoint5"]))
				{
				self.didvelocity = undefined;
				self setVelocity((self.pers["velopoint5"]));
				self setStance("stand");
				if(isDefined (self.pers["velo5crouch"]))
				{
					self setStance("crouch");
				}
	}
	}
}

printVeloPoints()
{	if(isDefined(self.pers["velopoint1"]))
	{
	self iPrintLn(" Point 1:" + self.pers["velopoint1"] + " ");
	}
	if(isDefined(self.pers["velopoint2"]))
	{
	self iPrintLn("Point 2 " + self.pers["velopoint2"] + " ");
	}
	if(isDefined(self.pers["velopoint3"]))
	{
	self iPrintLn("Point 3 " + self.pers["velopoint3"] + " ");
	}
	if(isDefined(self.pers["velopoint4"]))
	{
	self iPrintLn("Point 4 " + self.pers["velopoint4"] + " ");
	}
	if(isDefined(self.pers["velopoint5"]))
	{
	self iPrintLn("Point 5 " + self.pers["velopoint5"] + " ");
	}
}

oneVelocity() 
{
	for(;;)
	{
	self notifyOnPlayerCommand("oneVelocity", "+oneVelocity");
	self waittill ("oneVelocity");
	self setVelocity((self.pers["velopoint1"])); 
	}
}

twoVelocity()
{
	for(;;)
	{
	self notifyOnPlayerCommand("twoVelocity", "+twoVelocity");
	self waittill ("twoVelocity");
	self setVelocity((self.pers["velopoint2"])); 
	}
}

threeVelocity()
{
	for(;;)
	{
	self notifyOnPlayerCommand("threevelo", "+threevelocity");
	self waittill ("threevelo");
	self setVelocity((self.pers["velopoint3"])); 
	}
}

fourVelocity()
{
	for(;;)
	{
	self notifyOnPlayerCommand("fourvelo", "+fourvelocity");
	self waittill ("fourvelo");
	self setVelocity((self.pers["velopoint4"]));
	}
}

fiveVelocity()
{
	for(;;)
	{
	self notifyOnPlayerCommand("fiveVelo", "+fiveVelocity");
	self waittill ("fiveVelo");
	self setVelocity((self.pers["velopoint5"]));
	}
}

playRetroVelocity()
{
	self setVelocity((self.VelocityRetro));
}

settingSpeedVelo( retroSpeed )
{
	self.VelocityRetro = (self.VelocityRetro * retroSpeed);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

settingSpeedVelodivide( retroSpeed )
{
	self.VelocityRetro = (self.VelocityRetro / retroSpeed);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
northmomentum()
{
	self.VelocityRetro = (200, 0, 5);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
southmomentum()
{
	self.VelocityRetro = (-200, 0, 5);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
eastmomentum()
{
	self.VelocityRetro = ((0, -200, 5));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
westmomentum()
{
	self.VelocityRetro = ((0, 200, 5));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
northeastmomentum()
{
	self.VelocityRetro = ((200, -200, 5));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
southeastmomentum()
{	
	self.VelocityRetro = ((-200, -200, 5));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
northwestmomentum()
{
	self.VelocityRetro = ((200, 200, 5));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
southwestmomentum()
{
	self.VelocityRetro = ((-200, 200, 5));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}


northladder()
{
	self.VelocityRetro = (130, 0, -200);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

southladder()
{
	self.VelocityRetro = (-130, 0, -200);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

eastladder()
{
	self.VelocityRetro = ((0, -130, -200));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

westladder()
{
	self.VelocityRetro = ((0, 130, -200));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

NorthWindow()
{
	self.windowshot = true;
	self.VelocityRetro = ((300, 0, 260));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

southWindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( -300, 0, 260));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}


eastWindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( 0, -300, 260));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}


WestWindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( 0, 300, 260));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
lowNorthWindow()
{
	self.windowshot = true;
	self.VelocityRetro = ( 300, 0, 200);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

lowsouthWindow()
{
	self.windowshot = true;
	self.VelocityRetro = ((-300, 0, 200));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}


loweastWindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( 0, -300, 200));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}


lowWestWindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( 0, 300, 200));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

newindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( 250, -250, 250));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

sewindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( -250, -250, 250));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

nwwindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( 250, 250, 250));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

swwindow()
{
	self.windowshot = true;
	self.VelocityRetro = (( -250, 250, 250));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

stopwindowvelocity()
{
	self.windowshot = false;
}

//custom momentum
velospeed0()
{
self thread settingSpeedVelo( 1.05 );
}
velospeed1()
{
self thread settingSpeedVelo( 1.10 );
}
velospeed2()
{
self thread settingSpeedVelo( 1.15 );
}
velospeed3()
{
self thread settingSpeedVelo( 1.20 );
}
velospeed4()
{
self thread settingSpeedVelo( 1.25 );
}
velospeed5()
{
self thread settingSpeedVelo( 1.30 );
}
velospeed6()
{
self thread settingSpeedVelo( 1.35 );
}
velospeed7()
{
self thread settingSpeedVelo( 1.40 );
}
velospeed8()
{
self thread settingSpeedVelo( 1.50 );
}
velospeed9()
{
self thread settingSpeedVelo( 2.00 );
}

velodivide0()
{
self thread settingSpeedVelodivide( 1.05 );
}

velodivide1()
{
self thread settingSpeedVelodivide( 1.10 );
}
velodivide2()
{
self thread settingSpeedVelodivide( 1.15 );
}
velodivide3()
{
self thread settingSpeedVelodivide( 1.20 );
}
velodivide4()
{
self thread settingSpeedVelodivide( 1.25 );
}
velodivide5()
{
self thread settingSpeedVelodivide( 1.30 );
}
velodivide6()
{
self thread settingSpeedVelodivide( 1.35 );
}

cfgVelo() 
{
	for(;;)
	{
	self notifyOnPlayerCommand("Velocity123", "+velo");
	self waittill ("Velocity123");
	self.momentum1 = getDvarFloat("cg_hudproneY");
	self.momentum2 = getDvarFloat("ui_altscene");
	self.momentum3 = getDvarFloat("ui_browserfriendlyfire");
	waitframe();
	//self setVelocity(self.pers["newvelocity"]);
	self setVelocity(((self.momentum1),(self.momentum2),(self.momentum3)));
	//self setStance ("crouch");
	}
}

cfgTele() 
{
	for(;;)
	{
	self notifyOnPlayerCommand("cfgtele", "+tele");
	self waittill ("cfgtele");
	self.teleport1 = getDvarFloat("cg_hudproneY");
	self.teleport2 = getDvarFloat("ui_altscene");
	self.teleport3 = getDvarFloat("ui_browserfriendlyfire");
	waitframe();
	self setOrigin(((self.teleport1),(self.teleport2),(self.teleport3)));
	}
}

cfgAngles() 
{
	for(;;)
	{
	self notifyOnPlayerCommand("cfgangles", "+angles");
	self waittill ("cfgangles");
	self.angles1 = getDvarFloat("cg_hudproneY");
	self.angles2 = getDvarFloat("ui_altscene");
	waitframe();
	self setPlayerAngles(((self.angles1),(self.angles2), 0));
	}
}


NorthEdit(number)
{
	self.VelocityRetro = ((self.VelocityRetro[0] + number), self.VelocityRetro[1], self.VelocityRetro[2]);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

SouthEdit(number)
{
	self.VelocityRetro = ((self.VelocityRetro[0] - number), self.VelocityRetro[1], self.VelocityRetro[2]);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

WestEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], (self.VelocityRetro[1] + number), self.VelocityRetro[2]);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}


EastEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], (self.VelocityRetro[1] - number), self.VelocityRetro[2]);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

UpEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], self.VelocityRetro[1], (self.VelocityRetro[2] + number));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

DownEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], self.VelocityRetro[1], (self.VelocityRetro[2] - number));
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

ResetNS()
{
	self.VelocityRetro = ( 0, self.VelocityRetro[1], self.VelocityRetro[2]);
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

ResetEW()
{
	self.VelocityRetro = (self.VelocityRetro[0], 0, self.VelocityRetro[2]);
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

ResetUD()
{
	self.VelocityRetro = (self.VelocityRetro[0], self.VelocityRetro[1], 0);
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

constantTracker()
{
	if(!self.tracktoggle)
	{
		self.tracktoggle = true;
		self thread constantTrack();
		self iPrintln("Constant Tracker: ^3On");
	}
	else
	{
		self.tracktoggle = false;
		self notify("stopTracking");
		self iPrintln("Constant Tracker: ^3Off");
	}
}

constantTrack()
{
	self endon ("stopTracking");
	for(;;)
	{
	self.sayvelocity =  self getVelocity();
	self iPrintLn ("Momentum Value: " + self.sayvelocity + " ");
	wait .3;
	}
}


setsomeVelo()
{
	self.VelocityRetro = self getVelocity();
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
	self iPrintLn ("Velocity Tracked: " + self.VelocityRetro + " ");
}

getVeloBind()
{
	self endon ("stopvelocity");
	self iprintLn ("^3 Press [{+actionslot 1}] to Set Momentum");
	
	for(;;) //Loop
	{
	self notifyOnPlayerCommand("velocity5", "+actionslot 1");
	self waittill ("velocity5");
	if(self.CurrentMenu == "Closed")
	{
		self.pers["newvelocity"] = self getVelocity();
		wait .1;
		self.sayvelocity = self.pers["newvelocity"];
		self iPrintLn ("Momentum: " + self.sayvelocity + " ");
	}
	}
	wait .1;
}

ResetVELOAxis()
{
	self.VelocityRetro = ((0,0,0));
	self.pers["RetroVelocity"] = self.VelocityRetro;
	self.velotext Destroy();
	self.velotext = createFontString("DEFAULT", 1.0);
	self.velotext setPoint("LEFT", "CENTER", 80, -85);
	self.velotext setText("Velocity Bind: ^1Disabled");
	self.velotext.archived = self.NotStealth;
}