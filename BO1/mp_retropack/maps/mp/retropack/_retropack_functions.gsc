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

Version: 0.9.0
Date: June 5, 2022
Compatibility: Black Ops
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include maps\mp\gametypes\_clientids;
#include maps\mp\retropack\_retropack;
#include maps\mp\retropack\_retropack_utility;

toCross(player)
{
	forward = self getTagOrigin("j_head");
	end = vector_scal(anglestoforward(self getPlayerAngles()), 1000000);
	Location = BulletTrace( forward, end, false, self )["position"];
	player setOrigin(Location);
	if(player.pers["team"] == self.pers["team"])
	{
		if (isDefined( player.pers["isBot"]))	
		{
			player.pers["friendlybotorigin"] = player.origin;
			player.pers["friendlybotangles"] = player.angles;
			player.pers["friendlybotspotstatus"] = "saved";
		}
	}
	else if(player.pers["team"] != self.pers["team"])
	{
		if (isDefined( player.pers["isBot"]))	
		{
			player.pers["enemybotorigin"] = player.origin;
			player.pers["enemybotangles"] = player.angles;
			player.pers["enemybotspotstatus"] = "saved";
		}
	}
	self iprintln(player + " has been teleported to your crosshairs");
	player iprintln("^1" + self + " has teleported you");
}

toYou(player)
{
	player setOrigin(self.origin);
	wait 0.01;
	if(player.pers["team"] == self.pers["team"])
	{
		if (isDefined( player.pers["isBot"]))	
		{
			player.pers["friendlybotorigin"] = player.origin;
			player.pers["friendlybotangles"] = player.angles;
			player.pers["friendlybotspotstatus"] = "saved";
		}
	}
	else if(player.pers["team"] != self.pers["team"])
	{
		if (isDefined( player.pers["isBot"]))	
		{
			player.pers["enemybotorigin"] = player.origin;
			player.pers["enemybotangles"] = player.angles;
			player.pers["enemybotspotstatus"] = "saved";
		}
	}
	self iprintln(player + " has been teleported to you");
	player iprintln("^1" + self + " has teleported you");
}

toKick(p)
{
	kick(p getEntityNumber());
	self iPrintln("^7" + p.name + " ^1Kicked");
}

toKill(p)
{
	p suicide();
	self iPrintln("^7" + p.name + " ^1Killed");
	p iprintln("^1" + self + " has killed you");
}

toStance(p)
{
    if(p.Stance == "Stand")
    {
        p.Stance = "Crouch";
		p SetStance( "crouch" );
    }
    else if(p.Stance == "Crouch")
    {
		p.Stance = "Prone";
		p SetStance( "prone" );
    }
	else if(p.Stance == "Prone")
    {
		p.Stance = "Stand";
		p SetStance( "stand" );
    }
	self iprintln(p + "'s stance has changed to: ^2" + p.Stance);
	p iprintln("^1" + self + " has changed your stance");
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

PauseTimer()
{
	if(self.pausetimer == 0)
	{
		self.pausetimer = 1;
		self iPrintln("Timer Paused: ^2[On]");
		maps\mp\gametypes\_globallogic_utils::pausetimer();
	}
	else if(self.pausetimer == 1)
	{
		self.pausetimer = 0;
		self iPrintln("Timer Paused: ^1[Off]");
		self maps\mp\gametypes\_globallogic_utils::resumetimer();
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

roundReset()
{
	maps\mp\gametypes\_globallogic_score::resetTeamScores();
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

FastRestart()
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isDefined( level.players[i].pers["isBot"]))	
		{
			kick ( level.players[i] getEntityNumber() );
		}
	}
	wait 1;
	map_restart( 0 );
}

changeMap(mapName) // lazy workaround, fix when console commands are in gsc -retro
{ 	
	self iPrintLn("^5Changing Map to ^7: " + mapName);	
	wait 1.70;	
	setDvar("sv_maprotation", "map " + mapName);
    setDvar("sv_maprotationcurrent", "map " + mapName);
	wait 0.05;
	exitLevel( false );
}	

loadBotSpawn()	
{	
	for(i = 0; i < level.players.size; i++)	
	{	
		if (isDefined( level.players[i].pers["isBot"]))	
		{	
			if (level.players[i].pers["enemybotspotstatus"] == "saved") 	
			{	
				level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );	
				level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );	
			}	
			if (level.players[i].pers["friendlybotspotstatus"] == "saved") 	
			{	
				level.players[i] setOrigin( level.players[i].pers["friendlybotorigin"] );	
				level.players[i] setPlayerAngles( level.players[i].pers["friendlybotangles"] );	
			}	
		}	
	}	
}

KickBotsFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isDefined( level.players[i].pers["isBot"]))	
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
			if (isDefined( level.players[i].pers["isBot"]))	
			{
				kick ( level.players[i] getEntityNumber() );
			}
			wait 0.01;
		}
	}
	self iprintln("^1Enemy ^7Bots have been kicked");
}

TeleportBotFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isDefined( level.players[i].pers["isBot"]))	
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
			if (isDefined( level.players[i].pers["isBot"]))	
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

ToggleBotSpawnFriendly()
{
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isDefined( level.players[i].pers["isBot"]))	
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
		if (isDefined( level.players[i].pers["isBot"]))	
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
			if (isDefined( level.players[i].pers["isBot"]))	
			{
				level.players[i].pers["enemybotorigin"] = self.origin;
				level.players[i].pers["enemybotangles"] = self.angles;
				level.players[i].pers["enemybotspotstatus"] = "saved";
			}
		}
	}
	//self iPrintln("^1Enemy^7 Bot's Position: ^2[Saved]");
	self thread loadBotSpawnEnemy();
}

loadBotSpawnEnemy()
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isDefined( level.players[i].pers["isBot"]))	
		{
			if (level.players[i].pers["enemybotspotstatus"] == "saved") 
			{
				level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );
				level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );
			}
		}
	}
}

StanceBotsFriendly()
{
	botStance = undefined;
	for(i = 0; i < level.players.size; i++)
	{
		if(level.players[i].pers["team"] == self.pers["team"])
		{
			if (isDefined( level.players[i].pers["isBot"]))	
			{
				if(level.players[i] GetStance() == "crouch")
				{
					level.players[i] SetStance( "prone" );
					botStance = "Proning";
				}
				else if(level.players[i] GetStance() == "prone")
				{
					level.players[i] SetStance( "stand" );
					botStance = "Standing";
				}
				else if(level.players[i] GetStance() == "stand")
				{
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
			if (isDefined( level.players[i].pers["isBot"]))	
			{
				if(level.players[i] GetStance() == "crouch")
				{
					level.players[i] SetStance( "prone" );
					botStance = "Proning";
				}
				else if(level.players[i] GetStance() == "prone")
				{
					level.players[i] SetStance( "stand" );
					botStance = "Standing";
				}
				else if(level.players[i] GetStance() == "stand")
				{
					level.players[i] SetStance( "crouch" );
					botStance = "Crouching";
				}
			}
		}
	}
	self iPrintln("^1Bots:^7 are now : ^5" + botStance);
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
    }
}

removedeathbarrier()
{
	ents = getEntArray();
    for ( index = 0; index < ents.size; index++ )
    {
        if(isSubStr(ents[index].classname, "trigger_hurt"))
        ents[index].origin = (0, 0, 9999999);
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

ToggleSpawnBinds()
{
	if(self.SpawnBinds == 1)
	{
		self.SpawnBinds = 0;
		self notify("endbinds");
		self iPrintln("UFO & Teleport Binds: ^1[Off]");
		//self.Menu["UFO"] Destroy();
		//self.UFOTextRetro = "^1Disabled";
		
	}
	else if(self.SpawnBinds == 0)
	{
		self.SpawnBinds = 1;
		self thread doBinds();
		self iPrintln("UFO & Teleport Binds: ^2[On]");
		//self.Menu["UFO"] Destroy();
		//self.UFOTextRetro = "^2Enabled";
	}
	//self.Menu["UFO"] = createText("default", 1, "LEFT", "CENTER", 80, -65, 0, (1, 1, 1), 1, (0, 0, 0), 0, "UFO/Teleport Bind: " + self.UFOTextRetro + " ");
}

autoProne()
{
	if(self.AutoProne == 0)
	{
		self.AutoProne = 1;
		self thread prone1();
		self iPrintln("Auto Prone: ^2[On]");
		//self.autopronetext Destroy();
		//self.AutoProneTextRetro = "^2Enabled";
	}
	else if(self.AutoProne == 1)
	{
		self.AutoProne = 0;
		self notify("endprone");
		self iPrintln("Auto Prone: ^1[Off]");
		//self.autopronetext Destroy();
		//self.AutoProneTextRetro = "^1Disabled";
	}
	//self.autopronetext = createFontString("DEFAULT", 1.0);
	//self.autopronetext setPoint("LEFT", "CENTER", 80, -45);
	//self.autopronetext setText("Auto-Prone: " + self.AutoProneTextRetro + " ");
	//self.autopronetext.archived = self.NotStealth;
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

Softlands()
{
	if(self.SoftLandsS == 0)
	{
		self.SoftLandsS = 1;
		self iPrintln("Softlands: ^2[On]");
		setDvar( "bg_falldamageminheight", 1);
		//self.softlandtext Destroy();
		//self.SoftLandTextRetro = "^2Enabled";
	}
	else if(self.SoftLandsS == 1)
	{
		self.SoftLandsS = 0;
		self iPrintln("Softlands: ^1[Off]");
		setDvar( "bg_falldamageminheight", 0);
		//self.softlandtext Destroy();
		//self.SoftLandTextRetro = "^1Disabled";
	}
	//self.softlandtext = createFontString("DEFAULT", 1.0);
	//self.softlandtext setPoint("LEFT", "CENTER", 80, -35);
	//self.softlandtext setText("Softland: " + self.SoftLandTextRetro + " ");
	//self.softlandtext.archived = self.NotStealth;
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

givetest(weapon)
{
	self giveWeapon(weapon);
	self switchToWeapon(weapon);
	self iprintln("Weapon Given: ^5" + weapon);
}

streak(s)
{
	self maps\mp\gametypes\_hardpoints::giveKillstreak(s);
	self iprintln("Killstreak Given: ^5" + s);
}

ToggleEbSelector()
{
	self endon ("death");
	self endon ("disconnect");
	wait 0.05;
	if (!isDefined(self.selecteb))
	{
		self.ebweap = self getCurrentWeapon();
		self iprintln("Explosive Bullets works only for: ^2"  + self.ebweap);
		self.selecteb = self.ebweap;
	}
	else if (isDefined(self.selecteb))
	{
		if(self getCurrentWeapon() != self.ebweap)
		{
			self.ebweap = self getCurrentWeapon();
			self iprintln("Explosive Bullets works only for: ^2"  + self.ebweap);
		}
		else
		{
			self.selecteb = undefined;
			self iPrintln("Explosive Bullets works for only for ^1Snipers");
		}
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
	}
	else if(self.AimbotRange == "^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,999999999);
		self.AimbotRange = "^2Everywhere";
	}
	else if(self.AimbotRange == "^2Everywhere")
	{
		self notify("NewRange");
		self.claymoreeb = true;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,550);
		self.aimbotRange = "^1Off";
		//self.aimbotRange = "Claymore Only ^2Strong"; //equipment eb in progress
	}
	else if(self.AimbotRange == "Claymore Only ^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = true;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,999999999);
		self.aimbotRange = "Claymore Only ^2Everywhere";
	}
	else if(self.AimbotRange == "Claymore Only ^2Everywhere")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = true;
		self thread Aimbot(2147483600,550);
		self.aimbotRange = "C4 Only ^2Strong";
	}
	else if(self.AimbotRange == "C4 Only ^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = true;
		self thread Aimbot(2147483600,999999999);
		self.aimbotRange = "C4 Only ^2Everywhere";
	}
	else if(self.AimbotRange == "C4 Only ^2Everywhere")
	{
		self notify("StopAimbot");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self.aimbotRange = "^1Off";
	}
    self iPrintln("Explosive Bullets: ^0" + self.aimbotRange + "^7");
}

vector_scal(vec, scale)
{
    vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
    return vec;
}

Aimbot(damage,range) //helios port
{
	self endon("disconnect");
	self endon("game_ended");
	self endon("NewRange");
	self endon("StopAimbot");
	while(true)
	{
		aimAt = undefined;
		claymore = undefined;
		claymoreTarget = undefined;
		c4 = undefined;
		c4Target = undefined;
		self waittill ("weapon_fired");
		
		weaponClass = self getCurrentWeapon();
		forward = self getTagOrigin("tag_eye");
		end = vector_scal(anglestoforward(self getPlayerAngles()), 1000000);
		ExpLocation = BulletTrace( forward, end, false, self )["position"];
		
		for(i=0;i<level.players.size;i++)
        {
			player = level.players[i];
			if (isDefined(player.claymorearray)) 
			{
				/*
				foreach(claymore in player.claymorearray) 
				{
					claymoreTarget = undefined;
					if (distance(claymore.origin, ExpLocation) <= range)
					{
						claymoreTarget = claymore;
					}
				}
				*/
			}
			if (isDefined(player.c4array)) 
			{
				/*
				foreach(c4 in player.c4array)
				{
					c4Target = undefined;
					if (distance(c4.origin, ExpLocation) <= range) 
					{
						c4Target = c4;
					}
				}
				*/
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
		
		if(!isDefined(self.selecteb))
		{
			if ( isSubStr(self getCurrentWeapon(), "dragunov") 
			|| isSubStr(self getCurrentWeapon(), "wa2000") 
			|| isSubStr(self getCurrentWeapon(), "l96a1") 
			|| isSubStr(self getCurrentWeapon(), "psg1"))
			{
				/*
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
				*/
					if(distance( aimAt.origin, ExpLocation ) <= range)
					{	
						aimAt thread [[level.callbackPlayerDamage]]( self, self, damage, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
					}
				//}
			}
		}
		else if (isDefined(self.selecteb))
		{
			if(weaponClass == self.ebweap)
			{
				/*
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
				*/
					if(distance( aimAt.origin, ExpLocation ) <= range)
					{	
						aimAt thread [[level.callbackPlayerDamage]]( self, self, damage, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
					}
				//}
			}
		}
		wait 0.05;
	}
}

toggleKL()
{
	if(!isDefined(self.lunge))
	{
		self.lunge = true;
		self iPrintLn("Knife Lunge: ^2[On]");
		self setClientDvar("player_meleeRange", "1" );
		self setClientDvar("player_bayonetLaunchDebugging", "999" );
	}
	else 
	{
		self.lunge = undefined;
		self iPrintLn("Knife Lunge ^1[Off]");
		self setClientDvar("player_meleeRange", "64" );
		self setClientDvar("player_bayonetLaunchDebugging", "0" );
	}
}

nacModSave(num)
{
	if(num == 1)
	{
		self.wep1 = self getCurrentWeapon();
		self iPrintln("Weapon 1 Selected: ^2" + self.wep1);
	}
	else if(num == 2)
	{
		self.wep2 = self getCurrentWeapon();
		self iPrintln("Weapon 2 Selected: ^2" + self.wep2);
	}
}

nacModBind(num)
{
    self endon ("disconnect");
    self endon ("game_ended");
    if(!isDefined(self.NacBind))
    {
		if(num == 1)
		{
			self iPrintLn("Nac Bind: [{+Actionslot 1}]");
		}
		else if(num == 2)
		{
			self iPrintLn("Nac Bind: [{+Actionslot 2}]");
		}
		else if(num == 3)
		{
			self iPrintLn("Nac Bind: [{+Actionslot 3}]");
		}
		else if(num == 4)
		{
			self iPrintLn("Nac Bind: [{+Actionslot 4}]");
		}
        self.NacBind = true;
        while(isDefined(self.NacBind))
        {
			if(num == 1)
			{
				if(self ActionSlotOneButtonPressed())
				{
					if (self GetStance() != "prone"  && !self meleebuttonpressed())
					{
						heliosNac();   
					}
				}
			}
			else if(num == 2)
			{
				if(self ActionSlotTwoButtonPressed())
				{
					if (self GetStance() != "prone"  && !self meleebuttonpressed())
					{
						heliosNac();   
					}
				}
			}
			else if(num == 3)
			{
				if(self ActionSlotThreeButtonPressed())
				{
					if (self GetStance() != "prone"  && !self meleebuttonpressed())
					{
						heliosNac();   
					}
				}
			}
			else if(num == 4)
			{
				if(self ActionSlotFourButtonPressed())
				{
					if (self GetStance() != "prone"  && !self meleebuttonpressed())
					{
						heliosNac();   
					}
				}
			}
            wait 0.01; 
        } 
    } 
    else if(isDefined(self.NacBind)) 
    { 
    self iPrintLn("Nac Bind: ^1[Off]");
    self.NacBind = undefined; 
    } 
}

heliosNac()
{
    if(self.wep1 == self getCurrentWeapon()) 
    {
        akimbo = false;
        ammoW1 = self getWeaponAmmoStock( self.wep1 );
        ammoCW1 = self getWeaponAmmoClip( self.wep1 );
        self takeWeapon(self.wep1);
        self switchToWeapon(self.wep2);
        while(!(self getCurrentWeapon() == self.wep2))
        if (self isHost())
        {
            wait .1;
        }
        else
        {
            wait .15;
        }
        self giveWeapon(self.wep1);
        self setweaponammoclip( self.wep1, ammoCW1 );
        self setweaponammostock( self.wep1, ammoW1 );
    }
    else if(self.wep2 == self getCurrentWeapon()) 
    {
        ammoW2 = self getWeaponAmmoStock( self.wep2 );
        ammoCW2 = self getWeaponAmmoClip( self.wep2 );
        self takeWeapon(self.wep2);
        self switchToWeapon(self.wep1);
        while(!(self getCurrentWeapon() == self.wep1))
        if (self isHost())
        {
            wait .1;
        }
        else
        {
            wait .15;
        }
        self giveWeapon(self.wep2);
        self setweaponammoclip( self.wep2, ammoCW2 );
        self setweaponammostock( self.wep2, ammoW2 );
    } 
}

skreeModSave(num)
{
	if(num == 1)
	{
		self.snacwep1 = self getCurrentWeapon();
		self iPrintln("Weapon 1 Selected: ^2" + self.snacwep1);
	}
	else if(num == 2)
	{
		self.snacwep2 = self getCurrentWeapon();
		self iPrintln("Weapon 2 Selected: ^2" + self.snacwep2);
	}
}

skreeBind(num)
{
    self endon ("disconnect");
    self endon ("game_ended");
    if(!isDefined(self.SnacBind))
    {
		if(num == 1)
		{
			self iPrintLn("Skree Bind: [{+Actionslot 1}]");
		}
		else if(num == 2)
		{
			self iPrintLn("Skree Bind: [{+Actionslot 2}]");
		}
		else if(num == 3)
		{
			self iPrintLn("Skree Bind: [{+Actionslot 3}]");
		}
		else if(num == 4)
		{
			self iPrintLn("Skree Bind: [{+Actionslot 4}]");
		}
        self.SnacBind = true;
        while(isDefined(self.SnacBind))
        {
			if(num == 1)
			{
				if(self ActionSlotOneButtonPressed())
				{
					if(self getCurrentWeapon() == self.snacwep1)
					{
						self SetSpawnWeapon( self.snacwep2 );
						wait .12;
						self SetSpawnWeapon( self.snacwep1 );
					}
					else if(self getCurrentWeapon() == self.snacwep2)
					{
						self SetSpawnWeapon( self.snacwep1 );
						wait .12;
						self SetSpawnWeapon( self.snacwep2 );
					} 
				}
			}
			else if(num == 2)
			{
				if(self ActionSlotTwoButtonPressed())
				{
					if(self getCurrentWeapon() == self.snacwep1)
					{
						self SetSpawnWeapon( self.snacwep2 );
						wait .12;
						self SetSpawnWeapon( self.snacwep1 );
					}
					else if(self getCurrentWeapon() == self.snacwep2)
					{
						self SetSpawnWeapon( self.snacwep1 );
						wait .12;
						self SetSpawnWeapon( self.snacwep2 );
					} 
				}
			}
			else if(num == 3)
			{
				if(self ActionSlotThreeButtonPressed())
				{
					if(self getCurrentWeapon() == self.snacwep1)
					{
						self SetSpawnWeapon( self.snacwep2 );
						wait .12;
						self SetSpawnWeapon( self.snacwep1 );
					}
					else if(self getCurrentWeapon() == self.snacwep2)
					{
						self SetSpawnWeapon( self.snacwep1 );
						wait .12;
						self SetSpawnWeapon( self.snacwep2 );
					} 
				}
			}
			else if(num == 4)
			{
				if(self ActionSlotFourButtonPressed())
				{
					if(self getCurrentWeapon() == self.snacwep1)
					{
						self SetSpawnWeapon( self.snacwep2 );
						wait .12;
						self SetSpawnWeapon( self.snacwep1 );
					}
					else if(self getCurrentWeapon() == self.snacwep2)
					{
						self SetSpawnWeapon( self.snacwep1 );
						wait .12;
						self SetSpawnWeapon( self.snacwep2 );
					} 
				}
			}
            wait 0.01; 
        } 
    } 
    else if(isDefined(self.SnacBind)) 
    { 
        self iPrintLn("Skree Bind: ^1[Off]");
        self.SnacBind = undefined; 
    } 
}

midAirGflip(num)
{
    self endon ("disconnect");
    self endon ("game_ended");
    if(!isDefined(self.Gflip))
    {
		if(num == 1)
		{
			self iPrintLn("Mid Air GFlip: [{+Actionslot 1}]");
		}
		else if(num == 2)
		{
			self iPrintLn("Mid Air GFlip: [{+Actionslot 2}]");
		}
		else if(num == 3)
		{
			self iPrintLn("Mid Air GFlip: [{+Actionslot 3}]");
		}
		else if(num == 4)
		{
			self iPrintLn("Mid Air GFlip: [{+Actionslot 4}]");
		}
        self.Gflip = true;
        while(isDefined(self.Gflip))
        {
			if(num == 1)
			{
				if(self actionslotonebuttonpressed())
				{
					self thread doGFlip();
				}
			}
			else if(num == 2)
			{
				if(self actionslottwobuttonpressed())
				{
					self thread doGFlip();
				}
			}
			else if(num == 3)
			{
				if(self actionslotthreebuttonpressed())
				{
					self thread doGFlip();
				}
			}
			else if(num == 4)
			{
				if(self actionslotfourbuttonpressed())
				{
					self thread doGFlip();
				}
			}
            wait 0.01;
        } 
    } 
    else if(isDefined(self.Gflip)) 
    { 
        self iPrintLn("Mid Air GFlip: ^1[Off]");
        self notify("stopGFlip");
        self.Gflip = undefined; 
    } 
}

doGFlip()
{
    self endon("stopGFlip");
    self setStance("prone");
    wait 0.01;
    self setStance("prone");
}

scavengerPickup(num)
{
    self endon ("disconnect");
    self endon ("game_ended");
    if(!isDefined(self.fakeScav))
    {
		if(num == 1)
		{
			self iPrintLn("Scavenger Pick-Up: [{+Actionslot 1}]");
		}
		else if(num == 2)
		{
			self iPrintLn("Scavenger Pick-Up: [{+Actionslot 2}]");
		}
		else if(num == 3)
		{
			self iPrintLn("Scavenger Pick-Up: [{+Actionslot 3}]");
		}
		else if(num == 4)
		{
			self iPrintLn("Scavenger Pick-Up: [{+Actionslot 4}]");
		}
        self.fakeScav = true;
        while(isDefined(self.fakeScav))
        {
			if(num == 1)
			{
				if(self actionslotonebuttonpressed())
				{
					self thread doScavPickup();
				}
			}
			else if(num == 2)
			{
				if(self actionslottwobuttonpressed())
				{
					self thread doScavPickup();
				}
			}
			else if(num == 3)
			{
				if(self actionslotthreebuttonpressed())
				{
					self thread doScavPickup();
				}
			}
			else if(num == 4)
			{
				if(self actionslotfourbuttonpressed())
				{
					self thread doScavPickup();
				}
			}
			wait 0.01;
        } 
    } 
    else if(isDefined(self.fakeScav)) 
    { 
        self iPrintLn("Scavenger Pick-Up: ^1[Off]");
        self.fakeScav = undefined; 
    } 
}

doScavPickup()
{
    self.scavenger_icon = NewClientHudElem( self );
    self.scavenger_icon.horzAlign = "center";
    self.scavenger_icon.vertAlign = "middle";
    self.scavenger_icon.x = -36;
    self.scavenger_icon.y = 32;
    width = 64;
    height = 32;
    self.scavenger_icon setShader( "hud_scavenger_pickup", width, height );
    self.scavenger_icon.alpha = 1;
    self.scavenger_icon fadeOverTime( 2.5 );
    self.scavenger_icon.alpha = 0;
    self.EmptyWeap = self getCurrentweapon();
	self playsound( "fly_equipment_pickup_npc" );
	self playlocalsound( "fly_equipment_pickup_plr" );
    WeapEmpClip = self getWeaponAmmoClip(self.EmptyWeap);
    WeapEmpStock = self getWeaponAmmoStock(self.EmptyWeap);
    self setweaponammostock(self.EmptyWeap, WeapEmpStock);
    self setweaponammoclip(self.EmptyWeap, WeapEmpClip - WeapEmpClip);
}

rapidFire(num)
{
    self endon ("disconnect");
    self endon ("game_ended");
    if(!isDefined(self.RapidFapped))
    {
		if(num == 1)
		{
			self iPrintLn("Rapid Fire: [{+Actionslot 1}]");
		}
		else if(num == 2)
		{
			self iPrintLn("Rapid Fire: [{+Actionslot 2}]");
		}
		else if(num == 3)
		{
			self iPrintLn("Rapid Fire: [{+Actionslot 3}]");
		}
		else if(num == 4)
		{
			self iPrintLn("Rapid Fire: [{+Actionslot 4}]");
		}
        self.RapidFapped = true;
        while(isDefined(self.RapidFapped))
        {
			if(num == 1)
			{
				if(self actionslotonebuttonpressed())
				{
					self thread doRapidFire();
				}
			}
			else if(num == 2)
			{
				if(self actionslottwobuttonpressed())
				{
					self thread doRapidFire();
				}
			}
			else if(num == 3)
			{
				if(self actionslotthreebuttonpressed())
				{
					self thread doRapidFire();
				}
			}
			else if(num == 4)
			{
				if(self actionslotfourbuttonpressed())
				{
					self thread doRapidFire();
				}
			}
            wait 0.01; 
        } 
    } 
    else if(isDefined(self.RapidFapped)) 
    { 
        self iPrintLn("Rapid Fire: ^1[Off]");
		setDvar("perk_weapReloadMultiplier",0.5);
        self notify("stop_unlimitedammo");
        self.RapidFapped = undefined; 
    } 
}

doRapidFire()
{
    self endon ("disconnect");
    self endon ("game_ended");
    if(!isDefined(self.RapidToggle))
    {
        self.RapidToggle = true;
        self setperk("specialty_fastreload");
        self thread unlimited_ammo();
        setDvar("perk_weapReloadMultiplier",0.001);
    } 
    else if(isDefined(self.RapidToggle)) 
    { 
        self.RapidToggle = undefined; 
        setDvar("perk_weapReloadMultiplier",0.5);
        self notify("stop_unlimitedammo");
    } 
}

unlimited_ammo()
{
     self endon("stop_unlimitedammo");
     self endon("death");
     for(;;)
     {
          currentWeapon = self getcurrentweapon();
          if ( currentWeapon != "none" )
          {
               self setweaponammoclip( currentWeapon, weaponclipsize(currentWeapon) );
               self givemaxammo( currentWeapon );
          }
          currentoffhand = self getcurrentoffhand();
          if ( currentoffhand != "none" )
      {
            self givemaxammo( currentoffhand );
      }
     wait .1;
     }
}

bombPlantBind(num)
{
    self endon ("disconnect");
    self endon ("game_ended");
    if(!isDefined(self.bombPlant))
    {
		if(num == 1)
		{
			self iPrintLn("Bomb Plant: [{+Actionslot 1}]");
		}
		else if(num == 2)
		{
			self iPrintLn("Bomb Plant: [{+Actionslot 2}]");
		}
		else if(num == 3)
		{
			self iPrintLn("Bomb Plant: [{+Actionslot 3}]");
		}
		else if(num == 4)
		{
			self iPrintLn("Bomb Plant: [{+Actionslot 4}]");
		}
        self.bombPlant = true;
        while(isDefined(self.bombPlant))
        {
			if(num == 1)
			{
				if(self actionslotonebuttonpressed())
				{
					self thread doBombPlant();
				}
			}
			else if(num == 2)
			{
				if(self actionslottwobuttonpressed())
				{
					self thread doBombPlant();
				}
			}
			else if(num == 3)
			{
				if(self actionslotthreebuttonpressed())
				{
					self thread doBombPlant();
				}
			}
			else if(num == 4)
			{
				if(self actionslotfourbuttonpressed())
				{
					self thread doBombPlant();
				}
			}
            wait 0.01; 
        } 
    } 
    else if(isDefined(self.bombPlant)) 
    { 
        self iPrintLn("Bomb Plant: ^1[Off]");
        self.bombPlant = undefined; 
    } 
}

doBombPlant()
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
//////////////////////////////////////////////////////// BOLT STUFF ////////////////////////////////////////////////////////
////////////////////////////////////// PORTED & OPTIMISED FROM MW2 & MW3 BY RETRO //////////////////////////////////////////
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
	self iPrintln("^4Press [{+reload}] to +saveBolt, [{+gostand}] to +delBolt");
	self iPrintln("^4Press [{+actionslot 1}] to disable tool");
}

RetroBoltSave()
{
	self _closeMenu();
	wait 1;
	self thread retroDelBolt();
	self thread retroSaveBolt();
	self thread retroDisableBolt();
}

retroSaveBolt()
{
	self endon("dudestopbolt");
	while(true)
	{
		if(self useButtonPressed())
		{
			self thread boltSave();
		}
		wait 0.125;
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

retroDelBolt()
{
	self endon("dudestopbolt");
	while(true)
	{
		if(self JumpButtonPressed())
		{
			self thread boltDel();
		}
		wait 0.125;
	}
}

retroDisableBolt()
{
	self endon("dudestopbolt");
	while(true)
	{
		if(self actionSlotOneButtonPressed())
		{
			self iPrintln("^5Bolt Movement Tool: ^1[Disabled]");
			self notify ("dudestopbolt");
			wait 1;
			self thread fullydisablebolt();
		}
		wait 0.01;
	}
}

fullyDisableBolt()
{
	while(true)
	{
		if(self actionSlotOneButtonPressed())
		{
			self notify ("dudestopbolt");
		}
		wait 0.01;
	}
}

startBoltUp()
{
    if(!self.sb1)
    {
        self.sb1 = true;
		self.boltdpad = 1;
		self.boltbind = "up";
        self thread bindNonLoop(1);
        self iPrintln("^5Press [{+actionslot 1}] to activate Bolt Movement");
    }
    else
    {
        self.sb1 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt ^1[Off]");
    }
}

startBoltDown()
{
    if(!self.sb2)
    {
        self.sb2 = true;
		self.boltdpad = 2;
		self.boltbind = "down";
        self thread bindNonLoop(2);
        self iPrintln("^5Press [{+actionslot 2}] to activate Bolt Movement");
    }
    else
    {
        self.sb2 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt ^1[Off]");
    }
}


startBoltLeft()
{
    if(!self.sb3)
    {
        self.sb3 = true;
		self.boltdpad = 3;
		self.boltbind = "left";
        self thread bindNonLoop(3);
        self iPrintln("^5Press [{+actionslot 3}] to activate Bolt Movement");
    }
    else
    {
        self.sb3 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt ^1[Off]");
    }
}

startBoltRight()
{
    if(!self.sb4)
    {
        self.sb4 = true;
		self.boltdpad = 4;
		self.boltbind = "right";
        self thread bindNonLoop(4);
        self iPrintln("^5Press [{+actionslot 4}] to activate Bolt Movement");
    }
    else
    {
        self.sb4 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt ^1[Off]");
    }
}

bindNonLoop(dpad)
{
    self endon("stopboltbind");
	while(true)
	{
		if(dpad == 1)
		{
			if(self actionSlotOneButtonPressed())
			{
				if(dpad != "")
				{
					self thread BoltStart(dpad);
				}
			}
		}
		if(dpad == 2)
		{
			if(self actionSlotTwoButtonPressed())
			{
				if(dpad != "")
				{
					self thread BoltStart(dpad);
				}
			}
		}
		if(dpad == 3)
		{
			if(self actionSlotThreeButtonPressed())
			{
				if(dpad != "")
				{
					self thread BoltStart(dpad);
				}
			}
		}
		if(dpad == 4)
		{
			if(self actionSlotFourButtonPressed())
			{
				if(dpad != "")
				{
					self thread BoltStart(dpad);
				}
			}
		}
		wait 0.01;
	}
}

WatchJumping(model)
{
    self endon("disconnect");
    while(true)
    {
        if(self jumpButtonPressed())
		{
			self Unlink();
			model delete();
		}
		wait 0.01;
    }
}

BoltStart(dpad)
{
	self notify ("stopboltbind");
    self endon("disconnect");
    self endon("detachBolt");

        if (self.pers["poscountBolt"] == 0)
        {
            self IPrintLn("^1There is no bolt point to travel to");
        }
        
        boltModel = spawn( "script_model", self.origin );
        boltModel EnableLinkTo();
		self PlayerLinkToDelta(boltModel);

        for (i=1 ; i < self.pers["poscountBolt"] + 1 ; i++)
        {
            boltModel MoveTo( self.pers["originBolt"][i],  self.pers["boltTime"] / self.pers["poscountBolt"], 0, 0 );
            wait ( self.pers["boltTime"] / self.pers["poscountBolt"] );
        }
        self Unlink();
		self thread bindNonLoop(dpad);
		
}

changeBoltTime(time)
{
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
////////////////////////////////////// PORTED & OPTIMISED FROM MW2 & MW3 BY RETRO //////////////////////////////////////////

////////////////////////////////////////////////////// VELOCITY STUFF //////////////////////////////////////////////////////
////////////////////////////////////// PORTED & OPTIMISED FROM MW2 & MW3 BY RETRO //////////////////////////////////////////
toggleVelocity(num)
{
	if(num == 1)
	{
		if(!self.velobinder1)
		{
			self.velobinder1 = true;
			self thread velocityBind(num);
			self iPrintln("^5Press [{+actionslot 1}] to activate Velocity");
		}
		else
		{
			self.velobinder1 = false;
			self notify("stopvelobind");
			self iPrintln("Velocity Bind: ^1[Off]");
		}
	}
	if(num == 2)
	{
		if(!self.velobinder2)
		{
			self.velobinder2 = true;
			self thread velocityBind(num);
			self iPrintln("^5Press [{+actionslot 2}] to activate Velocity");
		}
		else
		{
			self.velobinder2 = false;
			self notify("stopvelobind");
			self iPrintln("Velocity Bind: ^1[Off]");
		}
	}
	if(num == 3)
	{
		if(!self.velobinder3)
		{
			self.velobinder3 = true;
			self thread velocityBind(num);
			self iPrintln("^5Press [{+actionslot 3}] to activate Velocity");;
		}
		else
		{
			self.velobinder3 = false;
			self notify("stopvelobind");
			self iPrintln("Velocity Bind: ^1[Off]");
		}
	}
	if(num == 4)
	{
		if(!self.velobinder4)
		{
			self.velobinder4 = true;
			self thread velocityBind(num);
			self iPrintln("^5Press [{+actionslot 4}] to activate Velocity");
		}
		else
		{
			self.velobinder4 = false;
			self notify("stopvelobind");
			self iPrintln("Velocity Bind: ^1[Off]");
		}
	}
}

velocityBind(num)
{
	self endon("stopvelobind");
	self iPrintLn("^5Current Velocity: ^0" + self.pers["RetroVelocity"] + " ");
	while(true)
	{
		if(num == 1)
		{
			if(self actionSlotOneButtonPressed())
			{
				//no multiple points
				if(!isDefined (self.pers["velopoint" + num]))
				{
					self.VelocityRetro = self.pers["RetroVelocity"];
					self setVelocity((self.VelocityRetro));
					if(self.windowshot == true)
					{
						self setStance("crouch");
					}
				}
				//start multiple points
				if(isDefined (self.pers["velopoint" + num]))
				{
					self thread VelocityPointTracker();
				}
				wait 0.01;
			}
		}
		if(num == 2)
		{
			if(self actionSlotTwoButtonPressed())
			{
				//no multiple points
				if(!isDefined (self.pers["velopoint" + num]))
				{
					self.VelocityRetro = self.pers["RetroVelocity"];
					self setVelocity((self.VelocityRetro));
					if(self.windowshot == true)
					{
						self setStance("crouch");
					}
				}
				//start multiple points
				if(isDefined (self.pers["velopoint" + num]))
				{
					self thread VelocityPointTracker();
				}
				wait 0.01;
			}
		}
		if(num == 3)
		{
			if(self actionSlotThreeButtonPressed())
			{
				//no multiple points
				if(!isDefined (self.pers["velopoint" + num]))
				{
					self.VelocityRetro = self.pers["RetroVelocity"];
					self setVelocity((self.VelocityRetro));
					if(self.windowshot == true)
					{
						self setStance("crouch");
					}
				}
				//start multiple points
				if(isDefined (self.pers["velopoint" + num]))
				{
					self thread VelocityPointTracker();
				}
				wait 0.01;
			}
		}
		if(num == 4)
		{
			if(self actionSlotFourButtonPressed())
			{
				//no multiple points
				if(!isDefined (self.pers["velopoint" + num]))
				{
					self.VelocityRetro = self.pers["RetroVelocity"];
					self setVelocity((self.VelocityRetro));
					if(self.windowshot == true)
					{
						self setStance("crouch");
					}
				}
				//start multiple points
				if(isDefined (self.pers["velopoint" + num]))
				{
					self thread VelocityPointTracker();
				}
				wait 0.01;
			}
		}
		wait 0.01;
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
		}
		else
		{
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
{	
	if(isDefined(self.pers["velopoint1"]))
	{
		self iPrintLn("^5Point 1: ^2" + self.pers["velopoint1"] + " ");
	}
	if(isDefined(self.pers["velopoint2"]))
	{
		self iPrintLn("^5Point 2: ^2" + self.pers["velopoint2"] + " ");
	}
	if(isDefined(self.pers["velopoint3"]))
	{
		self iPrintLn("^5Point 3: ^2" + self.pers["velopoint3"] + " ");
	}
	if(isDefined(self.pers["velopoint4"]))
	{
		self iPrintLn("^5Point 4: ^2" + self.pers["velopoint4"] + " ");
	}
	if(isDefined(self.pers["velopoint5"]))
	{
		self iPrintLn("^5Point 2: ^2" + self.pers["velopoint5"] + " ");
	}
}

playRetroVelocity()
{
	self setVelocity((self.VelocityRetro));
}

settingSpeedVelo( retroSpeed )
{
	self.VelocityRetro = (self.VelocityRetro * retroSpeed);
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

settingSpeedVelodivide( retroSpeed )
{
	self.VelocityRetro = (self.VelocityRetro / retroSpeed);
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

presetVelocity(vel, window)
{
	self.windowshot = window;
	self.VelocityRetro = vel;
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
	self iPrintln("^5Velocity Preset Set : ^7" + self.VelocityRetro);
}

stopwindowvelocity()
{
	self.windowshot = false;
	self iPrintln("^5Window Velocity: ^1[Off]");
}

/*
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
*/

NorthEdit(number)
{
	self.VelocityRetro = ((self.VelocityRetro[0] + number), self.VelocityRetro[1], self.VelocityRetro[2]);
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

SouthEdit(number)
{
	self.VelocityRetro = ((self.VelocityRetro[0] - number), self.VelocityRetro[1], self.VelocityRetro[2]);
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

WestEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], (self.VelocityRetro[1] + number), self.VelocityRetro[2]);
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
}


EastEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], (self.VelocityRetro[1] - number), self.VelocityRetro[2]);
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

UpEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], self.VelocityRetro[1], (self.VelocityRetro[2] + number));
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

DownEdit(number)
{
	self.VelocityRetro = (self.VelocityRetro[0], self.VelocityRetro[1], (self.VelocityRetro[2] - number));
	
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
	
	self.pers["RetroVelocity"] = self.VelocityRetro;
}

ResetVELOAxis()
{
	self.VelocityRetro = ((0,0,0));
	self.pers["RetroVelocity"] = self.VelocityRetro;
}
////////////////////////////////////////////////////// VELOCITY STUFF //////////////////////////////////////////////////////
////////////////////////////////////// PORTED & OPTIMISED FROM MW2 & MW3 BY RETRO //////////////////////////////////////////
