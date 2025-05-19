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

#include maps\mp\retropack\_retropack;
#include maps\mp\retropack\_retropack_utility;
#include maps\mp\retropack\_retropack_functions;

init()
{
	precacheShader("hud_scavenger_pickup"); 
	if ( getDvar( "bots_manage_fill" ) == "" )
		setDvar( "bots_manage_fill", 1 ); //amount of bots to maintain
	
	if ( getDvar( "bots_manage_add" ) == "" )
		setDvar( "bots_manage_add", 1 ); //amount of bots to add to the game
		
	level.result = 0;
	level.numKills = 1; //disables first blood, change to 0 if u want to re-enable -retro
	level.player_out_of_playable_area_monitor = 0;
    level.prematchPeriod = 0;
	level thread onPlayerConnect();
	level thread addBots_();
	level.menuName = "Retro Package"; //spawn in text menu name	
	level.menuHeader = "RETRO PACK"; //in-game menu header	
	level.menuSubHeader = "^5Black Ops"; //in-game menu subheader	
	level.menuVersion = "0.9.0"; //menu version	
	level.developer = "@rtros";
	setDvar( "sv_cheats", 1);
	setDvar( "sv_enableBounces", 1 );
	setDvar( "g_TeamName_Allies", "^5Players");
	setDvar( "g_TeamName_Axis", "Bots");
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected",player);
		player thread _setUpMenu(player);
		player thread watchDeath();
		player thread doBinds();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	self.isFirstSpawn = true;
	for(;;)
	{
		self waittill("spawned_player");
		if(self.isFirstSpawn==true)
		{
			if(self isHost())
			{
				thread overflowfix();
			}
			self.isFirstSpawn = false;
		}
		if(isDefined(self.pers["isBot"]))
		{
			self ClearPerks();
			self setPerk("specialty_movefaster");
			self setPerk("specialty_fallheight");
			wait 0.01;
			self freezeControls(true);
			self thread loadBotSpawn();
		}
		else
		{
			self freezeControls(false);
			if (self.pers["loc"] == true) 
			{
				self setOrigin( self.pers["savePos"] );
				self setPlayerAngles( self.pers["saveAng"] );
			}
			wait 0.01;
			self iprintln("^5" + level.menuName + " " + level.menuVersion);
			self iprintln("^5To open menu press [{+speed_throw}] + [{+Actionslot 1}]");
			self setPerk("specialty_movefaster");
			self setPerk("specialty_fallheight");
			self setPerk("specialty_bulletaccuracy");
			self setPerk("specialty_sprintrecovery");
			self setPerk("specialty_fastmeleerecovery");
			level.onlineGame = 1;
			level.rankedMatch = 1;
			setDvar( "killcam_final", 1);
			setDvar( "xblive_privatematch", 0);
			setDvar( "xblive_rankedmatch", 1 );
			setDvar( "onlinegame", 1 );
			self thread doClassChange();
		}
		setDvar( "timescale", 1.0);
		setDvar( "sv_hostname", "^5" + level.menuName);
		self thread monitorGrenade();
		self thread doAmmo();
		self thread removedeathbarrier();
		self thread doRandomTimerPause();
		if(game["teamScores"]["axis"] == 3 || game["teamScores"]["allies"] == 3)
		{
			maps\mp\gametypes\_globallogic_score::resetTeamScores();
		}
	}
}

monitorGrenade() 
{
	self endon( "disconnect" );
	for(;;) 
	{
		self waittill( "grenade_fire", grenade, weaponName );
		wait 2;
		if ( weaponName == "frag_grenade_mp" )
		{
			wait 4;
			self giveMaxAmmo( weaponName );
		}
		else if ( weaponName == "knife_mp" )
		{
			wait 2;
			self giveMaxAmmo( weaponName );
		}
		else
		{
			self giveMaxAmmo( weaponName );
		}
		wait 0.25;
	}
}

doRandomTimerPause()
{
	Time = randomInt(6);
    if (Time == 0) 
    {
		wait 110.65;
		maps\mp\gametypes\_globallogic_utils::pausetimer();
    }
    else if (Time == 1) 
    {
		wait 150.15;
		maps\mp\gametypes\_globallogic_utils::pausetimer();
    }
    else if (Time == 2) 
    {
		wait 99.52;
		maps\mp\gametypes\_globallogic_utils::pausetimer();
    }
    else if (Time == 3) 
    {
		wait 80.54;
		maps\mp\gametypes\_globallogic_utils::pausetimer();
    }
    else if (Time == 4) 
    {
		wait 130.32;
		maps\mp\gametypes\_globallogic_utils::pausetimer();
	}
	else if (Time == 5) 
    {
		wait 107.23;
		maps\mp\gametypes\_globallogic_utils::pausetimer();
    } 
	else if (Time == 6) 
	{
		wait 128.32;
		maps\mp\gametypes\_globallogic_utils::pausetimer();
    }
}

doClassChange()
{
    self endon("disconnect");
    self endon("endclassmid");
    oldclass = self.pers["class"];
    for(;;)
    {
        self waittill( "changed_class");
        self thread maps\mp\gametypes\_class::giveLoadout( self.team, self.class );
        wait .05;
		self setperk("specialty_falldamage");
    }
}

addBots_()
{
	level endon ( "game_ended" );
	for ( ;; )
	{
		wait 1.5;
		addBots_loop_();
	}
}

addBots_loop_()
{
	botsToAdd = GetDvarInt( "bots_manage_add" );
	if ( botsToAdd > 0 )
	{
		SetDvar( "bots_manage_add", 0 );

		if ( botsToAdd > 64 )
			botsToAdd = 64;

		for ( ; botsToAdd > 0; botsToAdd-- )
		{
			level AddBot("axis", "");
			wait 0.25;
		}
	}
	
	fillAmount = getDvarInt( "bots_manage_fill" );
	players = 0;
	bots = 0;
	spec = 0;
	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[i];

		if ( player is_bot_() )
			bots++;
		else if ( !isDefined( player.pers["team"] ) || ( player.pers["team"] != "axis" && player.pers["team"] != "allies" ) )
			spec++;
		else
			players++;
	}
	amount = bots;
	if ( amount < fillAmount )
		setDvar( "bots_manage_add", 1 );
}

is_bot_()
{
	assert( isDefined( self ) );
	assert( isPlayer( self ) );

	return ( ( isDefined( self.pers["isBotDumb"] ) && self.pers["isBotDumb"] ) || ( isDefined( self.pers["isBot"] ) && self.pers["isBot"] ) || ( isDefined( self.pers["isBotWarfare"] ) && self.pers["isBotWarfare"] ) || isSubStr( self getguid() + "", "bot" ) );
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
    self notify("menuresponse",game["menu_changeclass"],"smg_mp");
	self freezeControls(true);
}

doBinds()
{
	self thread bindLocations();
	self thread bindUFO();	
	self thread bindTeleportBots();
}

bindLocations() 
{
	self endon("disconnect");
	self endon("death");
	self endon("endtog"); 
	self endon ("endbinds");
	while(true)
	{
		if(self ActionSlotTwoButtonPressed())
		{
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
		}
		wait 0.01;
	}
}

bindUFO() //Helios Port
{
	self endon("disconnect");
	self endon("death");
	self endon ("endbinds");
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
				self disableweapons();
				self.newufo.origin = self.origin;
				self linkto(self.newufo);
			}
			else
			{
				self.UfoOn = 0;
				self unlink();
				self enableweapons();
			}
			wait 0.5;
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
		wait 0.05;
	}
}

bindTeleportBots() 
{
	self endon("disconnect");
	self endon("death");
	self endon("endtog"); 
	self endon ("endbinds");
	while(true)
	{
		if(self ActionSlotThreeButtonPressed())
		{
			if ( self GetStance() == "crouch" )
			{
				self thread TeleportBotEnemy();
			} 
		}
		wait 0.05;
	}
}