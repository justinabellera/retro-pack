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

Version: 1.0.3
Date: October 21, 2023
Compatibility: Modern Warfare 3
*/

#include maps\mp\retropack\_retropack_utility;
#include maps\mp\retropack\_retropack_functions;
#include maps\mp\retropack\_retropack;

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

init()
{
	self endon("disconnect");
	self endon("death");
	if ( getDvar( "bots_manage_fill" ) == "" )
		setDvar( "bots_manage_fill", 1 ); //amount of bots to maintain
	
	if ( getDvar( "bots_manage_add" ) == "" )
		setDvar( "bots_manage_add", 1 ); //amount of bots to add to the game
	
	level.numKills = 1; //disables first blood, change to 0 if u want to re-enable -retro
    level thread onplayerconnect();
	level thread addBots_();
	level.menuName = "Retro Package"; //spawn in text menu name	
	level.menuHeader = "RETRO PACK"; //in-game menu header	
	level.menuSubHeader = "^5Modern Warfare 3"; //in-game menu subheader	
	level.menuVersion = "1.0.2"; //menu version	
	level.developer = "@rtros";
	setDvar( "sv_enableBounces", 1 );
	setDvar( "g_TeamName_Allies", "^5Players");
	setDvar( "g_TeamName_Axis", "Bots");
}

onplayerconnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onplayerspawned();
        player thread initmenu();
        player thread watchDeath();
		player thread doBinds();
        player.spawnText = true;
		self.ebonlyfor = "Snipers";
    }
}

onplayerspawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
		if (isSubStr( self.guid, "bot" ))
		{
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
			self givePerk( "specialty_falldamage", false ); //mw2 giveperks moved to _class.gsc
			self givePerk( "specialty_quieter", false ); //mw2 giveperks moved to _class.gsc
			self thread doMatchBonus();
			self thread doClassChange();
			self setClientDvar( "cg_teamColor_MyTeam", "1 0.8 0.4 1" );
			self setClientDvar( "cg_teamColor_EnemyTeam", "0.999 0.45098 0.5 0.999" );
			if(self ishost())
			{
				self setClientDvar( "ui_myPartyColor", "0.999 0.45098 0.5 0.999" );
				self thread resetTeamColour();
			}
		}
		setDvar( "timescale", 1.0);
		setDvar( "sv_hostname", "^5" + level.menuName);
		setDvar( "sv_enabledoubletaps", 1);
		setDvar( "jump_slowdownEnable", 0 );
		setDvar( "jump_autoBunnyHop", 1 );
		setDvar( "jump_disableFallDamage", 0 );
		setDvar( "testClients_doAttack", 0 );
		setDvar( "testClients_doCrouch", 0 );
		setDvar( "testClients_doMove", 0 );
		setDvar( "testClients_doReload", 0 );
		setDvar( "testClients_watchKillcam", 0 );
		self thread monitorGrenade();
		self thread doAmmo();
		self thread removedeathbarrier();
		self thread doRandomTimerPause();
		if(game["roundsWon"]["axis"] == 3 || game["roundsWon"]["allies"] == 3 || game["roundsPlayed"] == 6)
		{
			self thread roundReset();
		}
    }
}

resetTeamColour()
{
	self waittill("begin_killcam");
	self setClientDvar( "ui_myPartyColor", "1 0.8 0.4 1" );
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
		else if ( weaponName == "throwingknife_mp" )
		{
			wait 2;
			self giveMaxAmmo( weaponName );
		}
		else
		{
			self giveMaxAmmo( weaponName );
		}
		
		/*
		if( weaponName == "flare_mp" ) 
		{
			wait 0.25;
			self maps\mp\perks\_perks::givePerk( "throwingknife_mp" );
		}
		*/
		wait 0.25;
	}
}

doRandomTimerPause()
{
	Time = randomInt(6);
    if (Time == 0) 
    {
		wait 110.65;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
    else if (Time == 1) 
    {
		wait 150.15;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
    else if (Time == 2) 
    {
		wait 99.52;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
    else if (Time == 3) 
    {
		wait 80.54;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
    else if (Time == 4) 
    {
		wait 130.32;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
	}
	else if (Time == 5) 
    {
		wait 107.23;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    } 
	else if (Time == 6) 
	{
		wait 128.32;
		self maps\mp\gametypes\_gamelogic::pauseTimer();
    }
}

addBots_()
{
	level endon( "game_ended" );
	self endon("disconnect");
	self endon("death");
	for ( ;; )
	{
		wait 0.5;
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

/*
	MW3 MATCH BONUS BY RETRO ~ START
*/
doMatchBonus()
{
	level endon( "game_ended" );
	self.timepassed = 1;
	for(;;)
	{
		self.timepassed++;
		wait 0.875;
		self getMatchBonus();
	}
}

getMatchBonus()
{
	self.calcbonus = (self.timepassed * 10);
	if(self.timepassed > 50)
	{
		self.calcbonus += 40;
	}
	self.matchbonus = self.calcbonus + randomInt(7);
	self thread doMatchBonusPopUp(self.matchbonus);
}
	
doMatchBonusPopUp(value)
{
	level waittill( "game_ended" );
	wait 2.5;
	color = (1,1,0.5);
	self.xpUpdateTotal = 0;	
	self thread maps\mp\gametypes\_rank::xpPointsPopup( value, 0, color, 0 );
}
/*
	MW3 MATCH BONUS BY RETRO ~ END
*/

doClassChange()
{
    self endon("disconnect");
    self endon("endclassmid");
    oldclass = self.pers["class"];
    for(;;)
    {
        if(self.pers["class"] != oldclass)
        {
            self maps\mp\gametypes\_class::giveloadout(self.pers["team"],self.pers["class"]);
            oldclass = self.pers["class"];
        }
        wait 0.05;
		self givePerk( "specialty_falldamage", false );
		self givePerk( "specialty_quieter", false );
    }
}

doBinds()
{
	self thread bindLocations();
	self thread bindUFO();	
	self thread bindTeleportBots();
}

bindTeleportBots() 
{
	self endon("disconnect");
	self endon("death");
	self endon("endtog"); 
	self endon ("endbinds");
	self notifyOnPlayerCommand("bottele", "+actionslot 3");
	for ( ;; )
	{
		self waittill("bottele");
		if ( self GetStance() == "crouch" )
		{
			self thread TeleportBotEnemy();
		} 
	}
}

bindLocations() 
{
	self endon("disconnect");
	self endon("death");
	self endon("endtog"); 
	self endon ("endbinds");
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

/*
	REAL AZZA CODE FROM HELIOS - BUT SHOWS "KILL CONFIRMED" ~ START
*/
/*
heliosAzza()
{
	if((game["roundsWon"]["axis"] == 0) || (game["roundsWon"]["allies"] == 0) || (game["roundsPlayed"] == 0) && (getDvar( "firstRound" ) != true))
	{
		level.onlineGame = 1;
		level.rankedMatch = 1;
		self setClientDvar( "xblive_privatematch", 0);
		self setClientDvar( "xblive_rankedmatch", "1" );
		self setClientDvar( "onlinegame", "1" );
		setDvar( "firstRound", true);
		wait 1.5;
		roundTimeAdd = getDvarInt( "scr_sd_timelimit" );
		roundTimeAdd  = roundTimeAdd - 2.25;
		setDvar( "scr_sd_timelimit", roundTimeAdd );
	}
	else if(getDvar( "firstRound" ) == true)
	{
		setDvar( "scr_sd_timelimit", 2.5 );
		self thread doXPBAR();
		self thread doXPBAR2();
	}
}
*/

/*
doXPBAR()
{
	self waittill("spawned_player");
	setDvar("ui_allow_teamchange", 1);
	wait 1;
	self setClientDvar("xblive_privatematch", 0);
	self setClientDvar( "xblive_rankedmatch", "1" );
	self setClientDvar( "onlinegame", "1" );
	wait 2;
	self setClientDvar("xblive_privatematch", 1);
	self setClientDvar( "xblive_rankedmatch", "0" );
	self setClientDvar( "onlinegame", "0" );
}
*/

/*
doXPBAR2()
{
	level waittill("game_ended");
	self setClientDvar("xblive_privatematch", 0);
	self setClientDvar( "xblive_rankedmatch", "1" );
	self setClientDvar( "onlinegame", "1" );
	wait 1;
	self setClientDvar("xblive_privatematch", 1);
	self setClientDvar( "xblive_rankedmatch", "0" );
	self setClientDvar( "onlinegame", "0" );
}
*/
/*
	REAL AZZA CODE FROM HELIOS - BUT SHOWS "KILL CONFIRMED" ~ END
*/