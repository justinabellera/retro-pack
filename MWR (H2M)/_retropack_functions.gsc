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

Version: 0.9.7
Date: August 25, 2024
Compatibility: Modern Warfare Remastered (HM2 Mod)
*/
#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\mp\_retropack;
#include scripts\mp\_retropack_utility;

testfunction1()
{
	self iPrintLn("^5RETRO^7PACK");
}

doSaveLocation()
{
	self endon ( "disconnect" );
	self.pers["loc"] = true;
	self.pers["savePos"] = self.origin;
	self.pers["saveAng"] = self.angles;
	self iprintln("^2Saved Location");
	if (isDefined(self.pers["delloc"]) && self.pers["delloc"] == true)
	{
		self iprintln("^1Re-enable Load Location to auto-spawn here");
	}
}

doLoadLocation()
{
	self endon ( "disconnect" );
	if (!isDefined(self.pers["delloc"]) || self.pers["delloc"] == false)
	{
		if (self.pers["loc"] == true) 
		{
			self setOrigin( self.pers["savePos"] );
			self setPlayerAngles( self.pers["saveAng"] );
		}
	}
}

doDeleteLocation()
{
	if(!isDefined( self.pers["delloc"] ) || self.pers["delloc"] == false)
	{
		self.pers["delloc"] = true;
		self iPrintln("Load Location: ^1[Disabled]");
	}
	else if(self.pers["delloc"] == true)
	{
		self.pers["delloc"] = false;
		self iPrintln("Load Location: ^2[Enabled]");
	}
}


doClassChange()
{
	game["strings"]["change_class"] = "";
    self endon("disconnect");
 	oldclass = self.pers["class"];
 	for(;;)
 	{
  		if(self.pers["class"] != oldclass)
		{
			self maps\mp\gametypes\_class::setClass( self.pers["class"]);
			self maps\mp\gametypes\_class::giveloadout(self.pers["team"],self.pers["class"]);
			self maps\mp\gametypes\_class::applyloadout();
			self maps\mp\gametypes\_hardpoints::giveownedhardpointitem( true );
			if(self.tsperk == 1)
			{
				self maps\mp\_utility::giveperk("specialty_longersprint");
				self maps\mp\_utility::giveperk("specialty_fastsprintrecovery");
				self maps\mp\_utility::giveperk("specialty_falldamage");
			}
			oldclass = self.pers["class"];
		}
  		wait 0.1;
 	}
}

doHitMessage()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	for(;;)
	{
		bulletTraced = undefined;
		
		self waittill ("weapon_fired");
		fwd = self getTagOrigin("tag_eye");
		end = vector_scale(anglestoforward(self getPlayerAngles()), 1000000);
		bulletLocation = BulletTrace( fwd, end, false, self )["position"];
		
		
		foreach(player in level.players)
		{
			if((player == self) || (!isAlive(player)) || (level.teamBased && self.pers["team"] == player.pers["team"]))
				continue;
			if(isDefined(bulletTraced))
			{
				if(closer(bulletLocation, player getTagOrigin("tag_eye"), bulletTraced getTagOrigin("tag_eye")))
				bulletTraced = player;
			}
			else bulletTraced = player; 
		}
		
		bulletDistance = int(distance(bulletLocation.origin, bulletTraced.origin) * 0.0254);
		realDistance = int(distance(bulletTraced.origin, self.origin) * 0.0254);
		
		if ( isSniper( self getCurrentWeapon() ) && !self isOnGround() )
		{
			if(distance( bulletTraced.origin, bulletLocation ) <= 40)
			{
				if ( !isDefined ( self.aimbotRange ) ||  isDefined ( self.aimbotRange ) && self.aimbotRange == "^1Off" )
					self iPrintLnBold("^5You almost hit ^7" + bulletTraced.name + "^5 from ^7" + realDistance + " metres ^5away!");
			}
			/*
			else //debug stuff
				self iPrintLn("bulletTraced: " + bulletTraced.origin + ", bulletLocation: " + bulletLocation + ", value: " + distance( bulletTraced.origin, bulletLocation ));
			*/
		}
		wait 0.05;
	}
}

doAmmo()
{
	self endon("endreplenish");
	self endon("death");
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
	self iPrintln("Death Barriers: ^1[Removed]");
}

monitorRounds()
{
	if(getDvar("g_gametype") == "sd")
	{
		if(game["roundsWon"]["axis"] == 3 || game["roundsWon"]["allies"] == 3 || game["roundsPlayed"] == 6)
		{
			level thread roundReset();
		}
	}
}

roundReset()
{
	game["roundsWon"]["axis"] = 0;
	game["roundsWon"]["allies"] = 0;
	game["roundsPlayed"] = 0;
	game["teamScores"]["allies"] = 0;
	game["teamScores"]["axis"] = 0;	
}

loadBotSpawn()	
{	
	for(i = 0; i < level.players.size; i++)	
	{	
		if (isSubStr( level.players[i].guid, "bot"))	
		{	
			level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );	
			level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );	
			level.players[i] setOrigin( level.players[i].pers["friendlybotorigin"] );	
			level.players[i] setPlayerAngles( level.players[i].pers["friendlybotangles"] );	
		}	
	}	
}

KickBots(team)
{
	name = undefined;
	if (team == "allies")
		name = "^2Friendly^7 ";
	else if (team == "axis")
		name = "^1Enemy^7 ";
	else if (team == "all")
		name = "^1All^7 ";
	
	self thread KickBot(team);
	self iPrintln(name + "^1Bots ^7have been ^2kicked");
	wait 1.5;
	self notify("kickFinish");
}

KickBot(botteam)
{
	self endon("kickFinish");
	while(1)
	{
		for(i = 0; i < level.players.size; i++)
		{
			if (isSubStr( level.players[i].guid, "bot"))
			{
				if(botteam == "allies")
				{
					if(level.players[i].pers["team"] == self.pers["team"])
					{
						kick ( level.players[i] getEntityNumber() );
					}
				}
				else if(botteam == "axis")
				{
					if(level.players[i].pers["team"] != self.pers["team"])
					{
						kick ( level.players[i] getEntityNumber() );
					}
				}
				else if(botteam == "all")
				{
					kick ( level.players[i] getEntityNumber() );
				}
			}
		}
		wait 0.01;
	}
}

TeleportBots(team)
{
	name = undefined;
	if (team == "allies")
		name = "^2Friendly^7 ";
	else if (team == "axis")
		name = "^1Enemy^7 ";
	else if (team == "all")
		name = "^1All^7 ";
	self thread TeleportBot(team);
}

TeleportBot(botteam)
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if(botteam == "allies")
			{
				if(level.players[i].pers["team"] == self.pers["team"])
				{
					level.players[i] setOrigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
					level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i]gettagorigin("j_head")));
					wait 0.01;
					level.players[i].pers["friendlybotorigin"] = level.players[i].origin;
					level.players[i].pers["friendlybotangles"] = level.players[i].angles;
					level.players[i].pers["friendlybotspotstatus"] = "saved";
				}
			}
			else if(botteam == "axis")
			{
				if(level.players[i].pers["team"] != self.pers["team"])
				{
					level.players[i] setOrigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
					level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i]gettagorigin("j_head")));
					wait 0.01;
					level.players[i].pers["enemybotorigin"] = level.players[i].origin;
					level.players[i].pers["enemybotangles"] = level.players[i].angles;
					level.players[i].pers["enemybotspotstatus"] = "saved";
				}
			}
			else if(botteam == "all")
			{
				level.players[i] setOrigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
				level.players[i] setplayerangles(vectortoangles(self gettagorigin("j_head") - level.players[i]gettagorigin("j_head")));
				wait 0.01;
				level.players[i].pers["enemybotorigin"] = level.players[i].origin;
				level.players[i].pers["enemybotangles"] = level.players[i].angles;
				level.players[i].pers["enemybotspotstatus"] = "saved";
				level.players[i].pers["friendlybotorigin"] = level.players[i].origin;
				level.players[i].pers["friendlybotangles"] = level.players[i].angles;
				level.players[i].pers["friendlybotspotstatus"] = "saved";
			}
		}
	}
}

TeleportBotsToYou(team)
{
	name = undefined;
	if (team == "allies")
		name = "^2Friendly^7 ";
	else if (team == "axis")
		name = "^1Enemy^7 ";
	else if (team == "all")
		name = "^1All^7 ";
	self thread TeleBotToYou(team);
}

TeleBotToYou(botteam)
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if(botteam == "allies")
			{
				if(level.players[i].pers["team"] == self.pers["team"])
				{
					level.players[i].pers["friendlybotorigin"] = self.origin;
					level.players[i].pers["friendlybotangles"] = self.angles;
					level.players[i].pers["friendlybotspotstatus"] = "saved";
				}
			}
			else if(botteam == "axis")
			{
				if(level.players[i].pers["team"] != self.pers["team"])
				{
					level.players[i].pers["enemybotorigin"] = self.origin;
					level.players[i].pers["enemybotangles"] = self.angles;
					level.players[i].pers["enemybotspotstatus"] = "saved";
				}
			}
			else if(botteam == "all")
			{
				level.players[i].pers["friendlybotorigin"] = self.origin;
				level.players[i].pers["friendlybotangles"] = self.angles;
				level.players[i].pers["friendlybotspotstatus"] = "saved";
				level.players[i].pers["enemybotorigin"] = self.origin;
				level.players[i].pers["enemybotangles"] = self.angles;
				level.players[i].pers["enemybotspotstatus"] = "saved";
			}
			self thread setBotSpawn(botteam);
		}
	}
}

setBotSpawn(team)
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if(team == "allies")
			{
				if (level.players[i].pers["friendlybotspotstatus"] == "saved") 
				{
					level.players[i] setOrigin( level.players[i].pers["friendlybotorigin"] );
					level.players[i] setPlayerAngles( level.players[i].pers["friendlybotangles"] );
				}
			}
			else if(team == "axis")
			{
				if (level.players[i].pers["enemybotspotstatus"] == "saved") 
				{
					level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );
					level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );
				}
			}
			else if(team == "all")
			{
				if (level.players[i].pers["enemybotspotstatus"] == "saved" || level.players[i].pers["friendlybotspotstatus"] == "saved") 
				{
					level.players[i] setOrigin( level.players[i].pers["friendlybotorigin"] );
					level.players[i] setPlayerAngles( level.players[i].pers["friendlybotangles"] );
					level.players[i] setOrigin( level.players[i].pers["enemybotorigin"] );
					level.players[i] setPlayerAngles( level.players[i].pers["enemybotangles"] );
				}
			}
		}
	}
}
		
ToggleTSPerks()
{
	if(self.tsperk == 1)
	{
		self.tsperk = 0;
		self maps\mp\_utility::_unsetperk("specialty_longersprint");
		self maps\mp\_utility::_unsetperk("specialty_fastsprintrecovery");
		self maps\mp\_utility::_unsetperk("specialty_falldamage");
		self iPrintln("^5Commando ^7& ^5Marathon ^7Perks: ^1[Removed]");
		
	}
	else if(!isDefined(self.tsperk) || self.tsperk == 0)
	{
		self.tsperk = 1;
		self maps\mp\_utility::giveperk("specialty_longersprint");
		self maps\mp\_utility::giveperk("specialty_fastsprintrecovery");
		self maps\mp\_utility::giveperk("specialty_falldamage");
		self iPrintln("^5Commando ^7& ^5Marathon ^7Perks: ^2[Given]");
	}
}

ToggleBotFreeze(team)
{
	name = undefined;
	if (team == "allies")
		name = "^2Friendly^7 ";
	else if (team == "axis")
		name = "^1Enemy^7 ";
	else if (team == "all")
		name = "^1All^7 ";
	
	if(self.botfreeze == 1)
	{
		self.botfreeze = 0;
		self thread FreezeBot(team, "Unfreeze");
		self iPrintln(name + "^1Bots: ^2[Unfrozen]");
	}
	else if(self.botfreeze == 0)
	{
		self.botfreeze = 1;
		self thread FreezeBot(team, "Freeze");
		self iPrintln(name + "^1Bots: ^1[Frozen]");
	}
}

FreezeBot(botteam, freeze)
{
	for(i = 0; i < level.players.size; i++)
	{
		if (isSubStr( level.players[i].guid, "bot"))
		{
			if(botteam == "allies")
			{
				if(level.players[i].pers["team"] == self.pers["team"])
				{
					if (isSubStr( level.players[i].guid, "bot"))
					{
						if (freeze == "Freeze")
						{
							level.players[i] freezeControls(true);
							level.players[i].pers["freeze"] = true;
						}
						else if (freeze == "Unfreeze")
						{
							level.players[i] freezeControls(false);
							level.players[i].pers["freeze"] = false;
						}
					}
				}
			}
			else if(botteam == "axis")
			{
				if(level.players[i].pers["team"] != self.pers["team"])
				{
					if (freeze == "Freeze")
					{
						level.players[i] freezeControls(true);
						level.players[i].pers["freeze"] = true;
					}
					else if (freeze == "Unfreeze")
					{
						level.players[i] freezeControls(false);
						level.players[i].pers["freeze"] = false;
					}
				}
			}
			else if(botteam == "all")
			{
				if (freeze == "Freeze")
				{
					level.players[i] freezeControls(true);
					level.players[i].pers["freeze"] = true;
				}
				else if (freeze == "Unfreeze")
				{
					level.players[i] freezeControls(false);
					level.players[i].pers["freeze"] = false;
				}
			}
		}
	}
}

ToggleSpawnBinds()
{
	if(self.pers["quickBinds"] == false)
	{
		self.pers["quickBinds"] = true;
		self iPrintln("Quick Binds: ^2[On]");
		self thread bindLocations();
		self thread bindUFO();	
		self thread bindTeleportBots();
	}
	else if(self.pers["quickBinds"] == true)
	{
		self.pers["quickBinds"] = false;
		self notify("endbinds");
		self iPrintln("Quick Binds: ^1[Off]");
	}
}

bindLocations() 
{
	self endon("disconnect");
	self endon("endtog"); 
	self endon ("endbinds");
	self endon ("death");
	level endon("game_ended");
	self notifyOnPlayerCommand("locsave", "+actionslot 2");
	for ( ;; )
	{
		self waittill("locsave");
		if ( self GetStance() == "crouch" )
		{
			self thread doLoadLocation();
		} 
		else if(self GetStance() == "prone" )
		{
			self.locsav = 1;
			self setClientDvar("location_saver", 1);
			self thread doSaveLocation();
		}
		wait 0.01;
	}
}

bindUFO()
{
        self endon("disconnect");
		self endon ("endbinds");
		self endon ("death");
		level endon ("game_ended");
        if(isdefined(self.newufo))
        self.newufo delete();
        self.newufo = spawn("script_origin", self.origin);
        self.UfoOn = 0;
        for(;;)
        {
			if(self meleebuttonpressed() && self GetStance() == "crouch")
			{
				if(self.UfoOn == 0)
				{
					self.UfoOn = 1;
					foreach(player in level.players)
					{
						player setClientDvar("con_gameMsgWindow0MsgTime", "1");
						player iprintln("^1Clip Warning: ^7" + self.name + "^7 is using UFO");
						wait 0.02;
						player setClientDvar("con_gameMsgWindow0MsgTime", "5");
					}
					self.origweaps = self getWeaponsListOffhands();
					foreach(weap in self.origweaps)
						self takeweapon(weap);
					self.newufo.origin = self.origin;
					self playerlinkto(self.newufo);
				}
				else
				{
					self.UfoOn = 0;
					self unlink();
					foreach(weap in self.origweaps)
							self giveweapon(weap);
				}
				wait 0.15;
			}
			if(self.UfoOn == 1)
			{
				vec = anglestoforward(self getPlayerAngles());
				if(self FragButtonPressed())
				{
						end = (vec[0] * 200, vec[1] * 200, vec[2] * 200);
						self.newufo.origin = self.newufo.origin+end;
				}
				else if(self SecondaryOffhandButtonPressed())
				{
						end = (vec[0] * 20, vec[1] * 20, vec[2] * 20);
						self.newufo.origin = self.newufo.origin+end;
				}
			}
			wait 0.01;
        }
}

bindTeleportBots() 
{
	self endon("disconnect");
	self endon("endtog"); 
	self endon ("endbinds");
	self endon ("death");
	level endon("game_ended");
	self notifyOnPlayerCommand("bottele", "+actionslot 3");
	for ( ;; )
	{
		self waittill("bottele");
		if ( self GetStance() == "crouch" )
		{
			self thread TeleportBots(getOtherTeam(self.team));
		} 
	}
}

ToggleEbSelector()
{
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

ToggleTagEbSelector()
{
	self endon ("disconnect");
	wait 0.05;
	if (self.tageb == "0")
	{
		self.taggedeb = self getCurrentWeapon();
		self.tageb = "1";
		self iPrintln("Tag Explosive Bullets: ^2"  + self.taggedeb);
		self thread doTaggedEB();
	}
	else if (self.tageb == "1")
	{
		if(self getcurrentweapon() != self.taggedeb)
		{
			self.taggedeb = self getCurrentWeapon();
			self iPrintln("Tag Explosive Bullets: ^2"  + self.taggedeb);
			self thread doTaggedEB();
		}
		else
		{
			self.tageb = "0";
			self notify("endTag");
			self iPrintln("Tag Explosive Bullets: ^1Disabled");
		}
	}
}

doTaggedEB()
{
	self endon ( "endTag" );
	self endon ( "death" );
	self endon ( "disconnect" );
	for(;;)
	{
		bulletTraced = undefined;
		
		self waittill ("weapon_fired");
		fwd = self getTagOrigin("tag_eye");
		end = vector_scale(anglestoforward(self getPlayerAngles()), 1000000);
		bulletLocation = BulletTrace( fwd, end, false, self )["position"];
		
		foreach(player in level.players)
		{
			if((player == self) || (!isAlive(player)) || (level.teamBased && self.pers["team"] == player.pers["team"]))
				continue;
			if(isDefined(bulletTraced))
			{
				if(closer(bulletLocation, player getTagOrigin("tag_eye"), bulletTraced getTagOrigin("tag_eye")))
				bulletTraced = player;
			}
			else bulletTraced = player; 
		}
		doDesti = bulletTraced.origin + (0,0,40);
		
		bulletDistance = int(distance(bulletLocation.origin, bulletTraced.origin) * 0.0254);
		realDistance = int(distance(bulletTraced.origin, self.origin) * 0.0254);
		
		if ( self getCurrentWeapon() == self.taggedeb )
		{
			if(distance( bulletTraced.origin, bulletLocation ) > 0)
			{
				bulletTraced thread [[level.callbackPlayerDamage]]( self, self, 1, 8, "MOD_RIFLE_BULLET", self.taggedeb, doDesti, (0,0,0), "torso_upper", 0 );
			}
		}
		wait 0.05;
	}
}

AimbotStrength()
{
	if(self.AimbotRange == "^1Off")
	{
		self notify("NewRange");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,200);
		self.AimbotRange = "^2Normal";
	}
	else if(self.AimbotRange == "^2Normal")
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
		self.aimbotRange = "Claymore Only ^2Strong";
	}
	else if(self.AimbotRange == "Claymore Only ^2Strong")
	{
		self notify("NewRange");
		self.claymoreeb = true;
		self.c4eb = undefined;
		self thread Aimbot(2147483600,999999999);
		//self.aimbotRange = "Claymore Only ^2Everywhere";
		self.aimbotRange = "Claymore Only ^2Everywhere";
	}
	/*
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
	*/
	else if(self.AimbotRange == "Claymore Only ^2Everywhere")
	{
		self notify("StopAimbot");
		self.claymoreeb = undefined;
		self.c4eb = undefined;
		self.aimbotRange = "^1Off";
	}
    self iPrintln("Explosive Bullets: ^0" + self.aimbotRange + "^7");
}

Aimbot(damage,range) //helios port
{
	self endon("disconnect");
	level endon ("game_ended");
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
			/*
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
			*/
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
			if ( isSniper( self getCurrentWeapon() ))
			{
				if (self.Crosshairs == 1)
				{
					if(isDefined(self.c4eb))
					{
						/*
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
							*/
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
							aimAt thread [[level.callbackPlayerDamage]]( self, self, damage, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
				else
				{
					if(isDefined(self.c4eb))
					{
						/*
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
							*/
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
							aimAt thread [[level.callbackPlayerDamage]]( self, self, damage, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
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
					if(isDefined(self.c4eb))
					{
						/*
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
							*/
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
							aimAt thread [[level.callbackPlayerDamage]]( self, self, damage, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
				else
				{
					if(isDefined(self.c4eb))
					{
						/*
						if (isDefined(c4Target.trigger)) 
							c4Target.trigger delete();
							c4Target detonate();
							*/
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
							aimAt thread [[level.callbackPlayerDamage]]( self, self, damage, 8, doMod, weaponClass, doDesti, (0,0,0), doLoc, 0 );
						}
					}
				}
			}
		}
		wait 0.05;
	}
}

isSniper( weapon )
{
    return ( 
        isSubstr( weapon, "h2_cheytac") 
        ||  isSubstr( weapon, "h2_barrett" ) 
        ||  isSubstr( weapon, "h2_wa2000" ) 
        ||  isSubstr( weapon, "h2_m21" ) 
        ||  isSubstr( weapon, "h2_m40a3" ) );
}

autoProne()
{
	if(self.AutoProne == 0)
	{
		self.AutoProne = 1;
		self thread prone1();
		self iPrintln("Auto Prone: ^2[On]");
	}
	else if(self.AutoProne == 1)
	{
		self.AutoProne = 0;
		self notify("endprone");
		self iPrintln("Auto Prone: ^1[Off]");
	}
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


doTimescale(timescale)
{
	setDvar("timescale", timescale);
	self.pers["timescale"] = timescale;	
	self iPrintln("Timescale: ^5" + timescale);
}

doGravity(gravity)
{
	setDvar("g_gravity", gravity);
	self.pers["gravity"] = gravity;	
	self iPrintln("Gravity: ^5" + gravity);
}

/*
doGravity(gravity)
{
	if(getDvarInt("g_gravity") != 900)
		setDvar("g_gravity",500);
	else
	{
		gv = (getDvarInt("g_gravity") + 10);
		setDvar("g_gravity", gv);
	}
	self.pers["gravity"] = getDvarInt("G_gravity");
	self.menutext[self.scroll] setSafeText("Gravity ^1" + getDvarInt("g_gravity"));
}
*/

togglespawntext()
{
	if(self.pers["spawnText"] == false)
	{
		self.pers["spawnText"] = true;
		self iPrintln("Menu Spawn Text: ^2[On]");
	}
	else if(self.pers["spawnText"] == true)
	{
		self.pers["spawnText"] = false;
		self iPrintln("Menu Spawn Text: ^1[Off]");
	}
}


Softlands()
{
	if(self.SoftLandsS == 0)
	{
		self.SoftLandsS = 1;
		self iPrintln("Softlands: ^2[On]");
		setDvar( "jump_enableFallDamage", "0");
	}
	else if(self.SoftLandsS == 1)
	{
		self.SoftLandsS = 0;
		self iPrintln("Softlands: ^1[Off]");
		setDvar( "jump_enableFallDamage", "1");
	}
}

dropcanswap()
{
	self giveweapon("h2_mp5k_mp_holo_camo034");
	self dropitem("h2_mp5k_mp_holo_camo034");
	wait 0.1;
}

streak(s)
{
	self maps\mp\gametypes\_hardpoints::giveHardpoint(s, ""); // "ffs" -retro
	self iprintln("Killstreak Given: ^5" + s);
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
	weapVar = weapon + randomcamo();
	self giveWeapon(weapVar);
	self switchToWeapon(weapVar);
	self iprintln("Weapon Given: ^5" + weapVar);
}

randomcamo()
{
	camoRandom = "";
	switch(randomIntRange(0, 30))
    {
		case 0 : 
		camoRandom = "";
		break;

		case 1 : 
		camoRandom = "_camo016";
		break;

		case 2 : 
		camoRandom = "_camo017";
		break;

		case 3 : 
		camoRandom = "_camo018";
		break;

		case 4 : 
		camoRandom = "_camo019";
		break;

		case 5 : 
		camoRandom = "_camo020";
		break;

		case 6 : 
		camoRandom = "_camo021";
		break;

		case 7 : 
		camoRandom = "_camo022";
		break;

		case 8 : 
		camoRandom = "_camo023";
		break;

		case 9 : 
		camoRandom = "_camo024";
		break;

		case 10 : 
		camoRandom = "_camo025";
		break;

		case 11 : 
		camoRandom = "_camo026";
		break;

		case 12 : 
		camoRandom = "_camo027";
		break;

		case 13 : 
		camoRandom = "_camo028";
		break;

		case 14 : 
		camoRandom = "_camo029";
		break;

		case 15 : 
		camoRandom = "_camo030";
		break;

		case 16 : 
		camoRandom = "_camo031";
		break;

		case 17 : 
		camoRandom = "_camo032";
		break;

		case 18: 
		camoRandom = "_camo033";
		break;

		case 19 : 
		camoRandom = "_camo034";
		break;

		case 20 : 
		camoRandom = "_camo035";
		break;

		case 21 : 
		camoRandom = "_camo036";
		break;

		case 22 : 
		camoRandom = "_camo037";
		break;

		case 23 : 
		camoRandom = "_camo038";
		break;

		case 24 : 
		camoRandom = "_camo039";
		break;

		case 25 : 
		camoRandom = "_camo040";
		break;

		case 26 : 
		camoRandom = "_camo041";
		break;

		case 27 : 
		camoRandom = "_camo042";
		break;

		case 28 : 
		camoRandom = "_camo043";
		break;

		case 29 : 
		camoRandom = "_camo044";
		break;

		case 30 : 
		camoRandom = "_camo045";
		break;
    }
	return camoRandom;
}


changeMap(mapName)
{ 	
	//
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

pickupradius()
{
	if ( self.puradius == false )
	{
		self.puradius = true;
		setDvar( "player_useRadius", 9999 );
		self iPrintln("Pickup Radius: ^5[9999]");
	}
    else if ( self.puradius == true )
	{
		self.puradius = false;
		setDvar( "player_useRadius", 128 );
		self iPrintln("Pickup Radius: ^5[Default]");
	}
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
	setDvar( "xblive_privatematch", 1 );
	wait 1;
	map_restart(false);
}

FastLast()
{
	if(getDvar("g_gametype") == "dm")
	{
		destroyHud();
		destroyMenuText();
		self.menu.isOpen = false;
		self notify("stopmenu_up");
		self notify("stopmenu_down");
		scoreLim = getwatcheddvar( "scorelimit" ) - 2;
		self.score = scoreLim;
		self.pers["score"] = scoreLim;		
		self.kills = scoreLim;
		self.pers["kills"] = scoreLim;
		self freezeControls(true);
		wait 1;
		self iPrintlnBold("^52 KILLS UNTIL LAST!");
		wait 1;
		self freezeControls(false);
	}
	else if(getDvar("g_gametype") == "war")
	{
		destroyHud();
		destroyMenuText();
		self.menu.isOpen = false;
		self notify("stopmenu_up");
		self notify("stopmenu_down");
		wait 0.05;
		scoreLim = getwatcheddvar( "scorelimit" ) - 2;
		setTeamScore( self.team, scoreLim );
		self.kills = scoreLim;
		self.score = scoreLim * 100;
		game["teamScores"][self.team] = scoreLim;
		self freezeControls(true);
		wait 1;
		self iPrintlnBold("^52 KILLS UNTIL LAST!");
		wait 1;
		self freezeControls(false);
	}
	else
	{
		self iPrintln("^1This gamemode is NOT supported for Fast Last");
	}
	wait 0.01;
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
	level endon ("game_ended");
    for(;;)
    {
        self notifyOnPlayerCommand(self.empdpad, "+actionslot " + self.empbind);
        self waittill(self.empdpad);
		foreach ( player in level.players )
		if(isSubStr(player.guid, "bot"))
		{
			player thread maps\mp\h2_killstreaks\_emp::h2_EMP_Use( 0, 0 );
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
        self iPrintln("^1Bots:^7 Final Stand Bind [{+actionslot 1}]");
    }
    else if(self.bshootbind == 1)
    {
        self.bshootbind = 2;
        self.bshootdpad = "down";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Final Stand Bind [{+actionslot 2}]");
    }
    else if(self.bshootbind == 2)
    {
        self.bshootbind = 3;
        self.bshootdpad = "left";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Final Stand Bind [{+actionslot 3}]");
    }
    else if(self.bshootbind == 3)
    {
        self.bshootbind = 4;
        self.bshootdpad = "right";
        self thread doBotsShoot();
		self thread doBotsAim();
        self iPrintln("^1Bots:^7 Final Stand Bind [{+actionslot 4}]");
    }
    else if(self.bshootbind == 4)
    {
        self.bshootbind = 0;
        self notify("endShoot");
		level notify("endShoot_");
        self iPrintln("^1Bots:^7 Final Stand Bind [^1OFF^7]");
    }
}

doBotsShoot()
{
    self endon("endShoot");
    self endon("disconnect");
	self notify("botsAim");
	level endon ("game_ended");
    for(;;)
    {
        self notifyOnPlayerCommand(self.bshootdpad, "+actionslot " + self.bshootbind);
        self waittill(self.bshootdpad);
		self givePerk( "specialty_laststandoffhand", false );
		self givePerk( "specialty_pistoldeath", false );
		self freezeControls(false);
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
    }
	self freezeControls(false);
}

RepeaterBind()
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
        self.Repeaterweap = self getCurrentWeapon();
        self setSpawnWeapon(self.Repeaterweap);
    }
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
	level endon ("game_ended");
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

randomTeam()
{
	team_names = [];
	team_names[0] = "allies";
	team_names[1] = "axis";
	coinflip = randomIntRange(0,1);
	return team_names[coinflip];
}

Spawn_Bot(team, num, restart) //ref: maps/mp/bots/_bots.gsc
{	
	if( !isDefined(num) && num == 0 )
		num = 1;
	
	if(team != "fill")
	{
		for(i = 0; i < num; i++)
		{
			level thread _spawn_bot(num , team, undefined, undefined, "spawned_player", "Recruit", restart);
		}
	}
	else
	{
		for(i = 0; i < (num/2); i++)
		{
			level thread _spawn_bot(num , "allies", undefined, undefined, "spawned_player", "Recruit", restart);
		}
		for(i = 0; i < (num/2); i++)
		{
			level thread _spawn_bot(num , "axis", undefined, undefined, "spawned_player", "Recruit", restart);
		}
	}
}

_spawn_bot(count, team, callback, stopWhenFull, notifyWhenDone, difficulty, restart)
{
	name = level.botName[level.botCount];
    if(level.botCount == (level.botName.size - 1))
        level.botCount = 0;
    else
        level.botCount++;
	
    time = gettime() + 10000;
    connectingArray = [];
    squad_index = connectingArray.size;
    while(level.players.size < maps\mp\bots\_bots_util::bot_get_client_limit() && connectingArray.size < count && gettime() < time)
    {
        maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause(0.05);
        botent                 = addbot(name,team);
        connecting             = spawnstruct();
        connecting.bot         = botent;
        connecting.ready       = 0;
        connecting.abort       = 0;
        connecting.index       = squad_index;
        connecting.difficultyy = difficulty;
        connectingArray[connectingArray.size] = connecting;
        connecting.bot thread maps\mp\bots\_bots::spawn_bot_latent(team,callback,connecting);
		connecting.bot forceTeam( team );
        squad_index++;
		wait 0.01;
    }

    connectedComplete = 0;
    time = gettime() + 60000;
    while(connectedComplete < connectingArray.size && gettime() < time)
    {
        connectedComplete = 0;
        foreach(connecting in connectingArray)
        {
            if(connecting.ready || connecting.abort)
                connectedComplete++;
        }
        wait 0.05;
    }

    if(isdefined(notifyWhenDone))
	{
        self notify(notifyWhenDone);
	}
	
	if ( isDefined(restart) && restart == true && getDvar("g_gametype") == "sd")
	{
		wait 1;
		maps\mp\gametypes\common_sd_sr::sd_endgame( game["attackers"], game["end_reason"]["objective_completed"] );
	}
}


forceTeam(team)
{
	self waittill_any( "joined_team" );
	wait 0.01;
	self.pers["forcedTeam"] = team;
	setDvar( "xblive_privatematch", 1 );
	self maps\mp\gametypes\_menus::addToTeam( team , true );
	wait 0.01;
	setDvar( "xblive_privatematch", 0 );
}


//////////////////////////////////////////////////////// BOLT STUFF ////////////////////////////////////////////////////////
boltRetro()
{
    self endon("disconnect");
	self endon("dudestopbolt");
	if ( !isDefined( self.pers["poscountBolt"] ) )
	{
		self.pers["poscountBolt"] = 0;
	}
	if ( !isDefined( self.pers["boltTime"] ) )
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
		self iPrintln("");
		self iPrintln("");
		self iPrintln("");
		self iPrintln("");
		self iPrintln("");
		self iPrintln("^4Press [{+reload}] to +saveBolt, [{weapnext}] to +delBolt");
		self iPrintln("^4Press [{+actionslot 1}] to disable tool");
		wait 7;
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
    }
    else
    {
        self.sb1 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
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
    }
    else
    {
        self.sb2 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
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
    }
    else
    {
        self.sb3 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
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
    }
    else
    {
        self.sb4 = false;
		self.boltdpad = "";
        self notify("stopboltbind");
        self iPrintln("^1+startBolt Off");
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

//////////////////////////////////////////////////////// VELO STUFF ////////////////////////////////////////////////////////
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
	}
}



velocitybind11()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 1}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
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
	}
}



velocitybind22()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 2}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
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
	}
}

velocitybind33()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 3}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
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
	}
}

velocitybind44()
{
	self endon("stopvelobind");
	self iPrintLn("Velocity Bind set to: [{+actionslot 4}]");
	self iPrintLn("Current Velocity Bind: " + self.pers["RetroVelocity"] + " ");
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

velopresetvalue(value, window, text)
{
	self.windowshot = window;
	self.VelocityRetro = (value);
	waitframe();
	self.pers["RetroVelocity"] = self.VelocityRetro;
	self iPrintln("^4Velocity Preset Value: ^2" + text);
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
}
//////////////////////////////////////////////////////// VELO STUFF ////////////////////////////////////////////////////////