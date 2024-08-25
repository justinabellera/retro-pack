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

initHooks()
{
	if(getDvar("g_gametype") != "sd")
		replaceFunc( maps\mp\perks\_perkfunctions::monitorTIUse, ::monitorTIUse_ ); //gives you throwing knife after placing down tac insert
	replaceFunc( maps\mp\_utility::rankingEnabled, ::returnTrue_ ); //return true function
	replaceFunc( maps\mp\_utility::privateMatch, ::returnFalse_ ); //return false function
	replaceFunc( maps\mp\_events::firstbloodevent, ::firstbloodevent_ ); //remove first blood
	replaceFunc( maps\mp\gametypes\_rank::awardgameevent, ::awardgameevent_ ); //in-game medal hook
	replaceFunc( maps\mp\gametypes\_gamelogic::checkroundswitch, ::checkroundswitch_ ); //h2m snd intermission lazy bypass
	replaceFunc( maps\mp\gametypes\_gamelogic::displayroundswitch, ::displayroundswitch_ ); //h2m snd intermission lazy bypass
	replaceFunc( maps\mp\gametypes\_gamelogic::matchstarttimerwaitforplayers, maps\mp\gametypes\_gamelogic::matchStartTimerSkip ); //pre-match countdown (credits to SimonLFC)
	replaceFunc( maps\mp\gametypes\_damage::dofinalkillcam, ::dofinalkillcam_ ); //final killcam hook
	replaceFunc( maps\mp\_utility::cac_getcustomclassloc, ::cac_getcustomclassloc_ ); //use online classes
	level.OriginalCallbackPlayerDamage = level.callbackPlayerDamage; //sniper damage (credits to doktorSAS)
    level.callbackPlayerDamage = ::CodeCallback_PlayerDamage;
	//replaceFunc( maps\mp\gametypes\_teams::getteamshortname, ::getteamshortname_ ); //custom team names, commented as clients are autoassigned teams now
}

returnTrue_( one, two, three, four, five, six )
{
	return true;
}

returnFalse_( one, two, three, four, six )
{
	return false;
}

monitorTIUse_()
{
	self endon ( "death" );
    self endon ( "disconnect" );
    self endon ( "end_monitorTIUse" );
	level endon ( "game_ended" );

    self thread maps\mp\perks\_perkfunctions::updateTISpawnPosition();
	self thread maps\mp\perks\_perkfunctions::clearPreviousTISpawnpoint();

    for ( ;; )
    {
        self waittill( "grenade_fire", lightstick, weapName );

        if ( weapName != "flare_mp" )
            continue;

        lightstick delete();

        if ( isDefined( self.setSpawnPoint ) )
            self maps\mp\perks\_perkfunctions::deleteTI( self.setSpawnPoint );

        if ( !isDefined( self.TISpawnPosition ) )
            continue;

        if ( self maps\mp\_utility::touchingBadTrigger() )
            continue;

        TIGroundPosition = playerPhysicsTrace( self.TISpawnPosition + (0,0,16), self.TISpawnPosition - (0,0,2048) ) + (0,0,1);

        glowStick = spawn( "script_model", TIGroundPosition );
        glowStick.angles = self.angles;
        glowStick.team = self.team;
        glowStick.enemyTrigger =  spawn( "script_origin", TIGroundPosition );
        glowStick thread maps\mp\perks\_perkfunctions::GlowStickSetupAndWaitForDeath( self );
        glowStick.playerSpawnPos = self.TISpawnPosition;
        glowStick.notti = true;

        glowStick thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_light_stick_tactical_bombsquad", "tag_fire_fx", self );

		self setlethalweapon( "iw9_throwknife_mp" );
        self giveweapon( "iw9_throwknife_mp" );

        self.setSpawnPoint = glowStick;	
        self thread maps\mp\perks\_perkfunctions::tactical_respawn();
        return;
    }
}

getteamshortname_( team )
{
	if (team == "axis")
		return "Bots";
	if (team == "allies")
		return "^5Players";
	else
		return maps\mp\gametypes\_teams::factiontableistringlookup( team, maps\mp\gametypes\_teams::getteamshortnamecol() );
}

awardgameevent_( var_0, var_1, var_2, var_3, var_4 )
{
    if ( maps\mp\_utility::invirtuallobby() )
		return;

    var_1 maps\mp\gametypes\_rank::giverankxp( var_0, undefined, var_2, var_4, undefined, var_3 );

    if ( maps\mp\gametypes\_rank::allowplayerscore( var_0 ) )
        var_1 maps\mp\gametypes\_gamescore::giveplayerscore( var_0, var_1, var_3 );
}

dofinalkillcam_()
{
    level waittill( "round_end_finished" );
	setDvar( "xblive_privatematch", 0 );
    level.showingfinalkillcam = 1;
    var_0 = "none";

    if ( isdefined( level.finalkillcam_winner ) )
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

    if ( !maps\mp\gametypes\_damage::finalkillcamvalid( var_2, var_3, var_15, var_14 ) )
    {
		setDvar( "xblive_privatematch", 1 );
		wait 0.01;
        maps\mp\gametypes\_damage::endfinalkillcam();
        return;
    }

    if ( isdefined( var_3 ) )
    {
        var_3.finalkill = 1;
        var_0 = "none";

        if ( level.teambased && isdefined( var_3.team ) )
            var_0 = var_3.team;

        switch ( level.finalkillcam_sweapon[var_0] )
        {
            case "artillery_mp":
                var_3 maps\mp\gametypes\_missions::processchallenge( "ch_finishingtouch" );
                break;
            default:
                break;
        }
    }

    maps\mp\gametypes\_damage::waitforstream( var_3 );
    var_18 = ( gettime() - var_2.deathtime ) / 1000;

    foreach ( var_20 in level.players )
    {
        var_20 maps\mp\_utility::revertvisionsetforplayer( 0 );
        var_20 setblurforplayer( 0, 0 );
        var_20.killcamentitylookat = var_2 getentitynumber();

        if ( isdefined( var_3 ) && isdefined( var_3.lastspawntime ) )
            var_21 = ( gettime() - var_3.lastspawntime ) / 1000.0;
        else
            var_21 = 0;

        var_20 thread maps\mp\gametypes\_killcam::killcam( var_3, var_4, var_5, var_6, var_8, var_9, var_10, var_11, var_18 + var_12, var_13, 0, 1, maps\mp\gametypes\_damage::getkillcambuffertime(), var_3, var_2, var_16, var_17, var_21, var_7 );
    }

    wait 0.1;

    while ( maps\mp\gametypes\_damage::anyplayersinkillcam() )
        wait 0.05;

	setDvar( "xblive_privatematch", 1 );
	wait 0.01;
    maps\mp\gametypes\_damage::endfinalkillcam();
}

CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	self endon("disconnect");
    
	if(sMeansOfDeath == "MOD_TRIGGER_HURT" || sMeansOfDeath == "MOD_HIT_BY_OBJECT" ||sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_FALLING" )
	{
        [[level.OriginalCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
    }

    if( scripts\mp\_retropack_functions::isSniper( sWeapon ) )
    {
        iDamage = 999; 
    }
	
	if( sMeansOfDeath == "MOD_MELEE") // Disable Melee damages
            iDamage = 0;
	
	[[level.OriginalCallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

cac_getcustomclassloc_()
{
	return "customClasses";
}

firstbloodevent_(){}

checkroundswitch_(){}

displayroundswitch_(){}