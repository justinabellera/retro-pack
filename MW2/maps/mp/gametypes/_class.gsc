#include common_scripts\utility;
// check if below includes are removable
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.classMap["class0"] = 0;
	level.classMap["class1"] = 1;
	level.classMap["class2"] = 2;
	level.classMap["class3"] = 3;
	level.classMap["class4"] = 4;
	level.classMap["class5"] = 5;
	level.classMap["class6"] = 6;
	level.classMap["class7"] = 7;
	level.classMap["class8"] = 8;
	level.classMap["class9"] = 9;
	level.classMap["class10"] = 10;
	level.classMap["class11"] = 11;
	level.classMap["class12"] = 12;
	level.classMap["class13"] = 13;
	level.classMap["class14"] = 14;
	
	level.classMap["custom1"] = 0;
	level.classMap["custom2"] = 1;
	level.classMap["custom3"] = 2;
	level.classMap["custom4"] = 3;
	level.classMap["custom5"] = 4;
	level.classMap["custom6"] = 5;
	level.classMap["custom7"] = 6;
	level.classMap["custom8"] = 7;
	level.classMap["custom9"] = 8;
	level.classMap["custom10"] = 9;
	
	level.classMap["copycat"] = -1;
	
	/#
	// classes testclients may choose from.
	level.botClasses = [];
	level.botClasses[0] = "class0";
	level.botClasses[1] = "class0";
	level.botClasses[2] = "class0";
	level.botClasses[3] = "class0";
	level.botClasses[4] = "class0";
	#/
	
	level.defaultClass = "CLASS_ASSAULT";
	
	level.classTableName = "mp/classTable.csv";
	
	//precacheShader( "waypoint_bombsquad" );
	precacheShader( "specialty_pistoldeath" );
	precacheShader( "specialty_finalstand" );

	level thread onPlayerConnecting();
}

giveSameLoadout( class, equ )
{	
	primaryIndex = 0;
	
	// initialize specialty array
	self.specialty = [];

	primaryWeapon = undefined;

	// Banz - this guy is a fucking legend. <3

	currentWeap = self getCurrentWeapon();
	primaryTokens = strtok( currentWeap, "_" );

	// We'll throw some if-statements in here.

	pri = primaryTokens[0];

	if (primaryTokens[1] == "mp")
		priAtt = "none";
	else
		priAtt = primaryTokens[1];

	if (primaryTokens[2] == "mp")
		priAtt2 = "none";
	else
		priAtt2 = primaryTokens[2];


	weapList = self GetWeaponsListAll();
	weapListPrim = self GetWeaponsListPrimaries();

	self takeWeapon( self getCurrentWeapon() );

	while(self getCurrentWeapon() == "none")
	{
		if (weapListPrim.size)
			self switchToWeapon(weapListPrim[RandomInt(weapListPrim.size)]);
		else
			self switchToWeapon(weapList[RandomInt(weapList.size)]);
		wait .05; 
	}

	// Secondary.

	currentWeap = self getCurrentWeapon();
	secondaryTokens = strtok( currentWeap, "_" );

	// We'll throw some if-statements in here.

	sec = secondaryTokens[0];

	if (secondaryTokens[1] == "mp")
		secAtt = "none";
	else
		secAtt = secondaryTokens[1];

	if (secondaryTokens[2] == "mp")
		secAtt2 = "none";
	else
		secAtt2 = secondaryTokens[2];

	self takeAllWeapons();

	if ( isSubstr( class, "custom" ) )
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;

		loadoutPrimary = pri;
		loadoutPrimaryAttachment = priAtt;
		loadoutPrimaryAttachment2 = priAtt2;
		loadoutPrimaryCamo = "none";

		loadoutSecondary = sec;
		loadoutSecondaryAttachment = secAtt;
		loadoutSecondaryAttachment2 = secAtt2;
		loadoutSecondaryCamo = "none";

		loadoutEquipment = equ;
		loadoutPerk1 = cac_getPerk( class_num, 1 );
		loadoutPerk2 = cac_getPerk( class_num, 2 );
		loadoutPerk3 = cac_getPerk( class_num, 3 );
		loadoutOffhand = cac_getOffhand( class_num );
		loadoutDeathStreak = cac_getDeathstreak( class_num );
	}
	else
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;

		camos = [];
		camos[0] = "red_urban";
		camos[1] = "red_tiger";
		camos[2] = "blue_tiger";
		camos[3] = "orange_fall";

		if (class_num == 0)
		{

			loadoutPrimary = pri;
			loadoutPrimaryAttachment = priAtt;
			loadoutPrimaryAttachment2 = priAtt2;
			loadoutPrimaryCamo = camos[ randomInt( 4 )];

			loadoutSecondary = sec;
			loadoutSecondaryAttachment = secAtt;
			loadoutSecondaryAttachment2 = secAtt2;
			loadoutSecondaryCamo = "none";

			loadoutEquipment = equ;
			loadoutPerk1 = "specialty_fastreload";
			loadoutPerk2 = "specialty_bulletdamage";
			loadoutPerk3 = "specialty_bulletaccuracy";
			loadoutOffhand = "concussion_grenade";
			loadoutDeathstreak = "none";
		}
		else
		{
			loadoutPrimary = table_getWeapon( level.classTableName, class_num, 0 );
			loadoutPrimaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 0 , 0);
			loadoutPrimaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 0, 1 );
			loadoutPrimaryCamo = table_getWeaponCamo( level.classTableName, class_num, 0 );
			loadoutSecondaryCamo = table_getWeaponCamo( level.classTableName, class_num, 1 );
			loadoutSecondary = table_getWeapon( level.classTableName, class_num, 1 );
			loadoutSecondaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 1 , 0);
			loadoutSecondaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 1, 1 );;
			loadoutSecondaryCamo = table_getWeaponCamo( level.classTableName, class_num, 1 );
			loadoutEquipment = equ;
			loadoutPerk1 = table_getPerk( level.classTableName, class_num, 1 );
			loadoutPerk2 = table_getPerk( level.classTableName, class_num, 2 );
			loadoutPerk3 = table_getPerk( level.classTableName, class_num, 3 );
			loadoutOffhand = table_getOffhand( level.classTableName, class_num );
			loadoutDeathstreak = table_getDeathstreak( level.classTableName, class_num );
		}

	}

	if ( level.killstreakRewards )
	{
		loadoutKillstreak1 = self getPlayerData( "killstreaks", 0 );
		loadoutKillstreak2 = self getPlayerData( "killstreaks", 1 );
		loadoutKillstreak3 = self getPlayerData( "killstreaks", 2 );
	}
	else
	{
		loadoutKillstreak1 = "none";
		loadoutKillstreak2 = "none";
		loadoutKillstreak3 = "none";
	}
	
	secondaryName = buildWeaponName( loadoutSecondary, loadoutSecondaryAttachment, loadoutSecondaryAttachment2 );
	self _giveWeapon( secondaryName, int(tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ) ) );

	self.loadoutPrimaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadoutPrimaryCamo, 0 ));
	self.loadoutPrimary = loadoutPrimary;
	self.loadoutSecondary = loadoutSecondary;
	self.loadoutSecondaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ));
	
	self SetOffhandPrimaryClass( "other" );
	
	// Action Slots
	self _SetActionSlot( 1, "" );
	self _SetActionSlot( 3, "altMode" );
	self _SetActionSlot( 4, "" );

	// Perks
	self _clearPerks();
	self _detachAll();
	
	// these special case giving pistol death have to come before
	// perk loadout to ensure player perk icons arent overwritten
	if ( level.dieHardMode )
		self maps\mp\perks\_perks::givePerk( "specialty_pistoldeath" );
	
	// only give the deathstreak for the initial spawn for this life.
	if ( loadoutDeathStreak != "specialty_null" && getTime() == self.spawnTime )
	{
		deathVal = int( tableLookup( "mp/perkTable.csv", 1, loadoutDeathStreak, 6 ) );
		
		if ( self _hasPerk( "specialty_rollover" ) )
			deathVal -= 1;
		
		if ( self.pers["cur_death_streak"] == deathVal )
		{
			self thread maps\mp\perks\_perks::givePerk( loadoutDeathStreak );
			self thread maps\mp\gametypes\_hud_message::splashNotify( loadoutDeathStreak );
		}
		else if ( self.pers["cur_death_streak"] > deathVal )
		{
			self thread maps\mp\perks\_perks::givePerk( loadoutDeathStreak );
		}
	}
	
	self loadoutAllPerks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3 );
	
	self thread GivePerks();
	
	self setKillstreaks( loadoutKillstreak1, loadoutKillstreak2, loadoutKillstreak3 );
		
	if ( self hasPerk( "specialty_extraammo", true ) && getWeaponClass( secondaryName ) != "weapon_projectile" )
		self giveMaxAmmo( secondaryName );

	// Primary Weapon
	primaryName = buildWeaponName( loadoutPrimary, loadoutPrimaryAttachment, loadoutPrimaryAttachment2 );
	self _giveWeapon( primaryName, self.loadoutPrimaryCamo );
	
	// fix changing from a riotshield class to a riotshield class during grace period not giving a shield
	if ( primaryName == "riotshield_mp" && level.inGracePeriod )
		self notify ( "weapon_change", "riotshield_mp" );

	if ( self hasPerk( "specialty_extraammo", true ) )
		self giveMaxAmmo( primaryName );

	self setSpawnWeapon( primaryName );
	
	primaryTokens = strtok( primaryName, "_" );
	self.pers["primaryWeapon"] = primaryTokens[0];
	
	// Primary Offhand was given by givePerk (it's your perk1)
	
	// Secondary Offhand
	offhandSecondaryWeapon = loadoutOffhand + "_mp";

	if ( loadoutOffhand == "flash_grenade" )
		self SetOffhandSecondaryClass( "flash" );
	else
		self SetOffhandSecondaryClass( "smoke" );
	
	self giveWeapon( offhandSecondaryWeapon );
	if( loadOutOffhand == "smoke_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
	else if( loadOutOffhand == "flash_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else if( loadOutOffhand == "concussion_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
	
	primaryWeapon = primaryName;
	self.primaryWeapon = primaryWeapon;
	self.secondaryWeapon = secondaryName;

	self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["primaryWeapon"], getBaseWeaponName( secondaryName ) );
		
	self.isSniper = (weaponClass( self.primaryWeapon ) == "sniper");
	
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	// cac specialties that require loop threads
	self maps\mp\perks\_perks::cac_selector();
	
	self notify ( "changed_kit" );
	self notify ( "giveLoadout" );
}


getClassChoice( response )
{
	assert( isDefined( level.classMap[response] ) );
	
	return response;
}

getWeaponChoice( response )
{
	tokens = strtok( response, "," );
	if ( tokens.size > 1 )
		return int(tokens[1]);
	else
		return 0;
}


logClassChoice( class, primaryWeapon, specialType, perks )
{
	if ( class == self.lastClass )
		return;

	self logstring( "choseclass: " + class + " weapon: " + primaryWeapon + " special: " + specialType );		
	for( i=0; i<perks.size; i++ )
		self logstring( "perk" + i + ": " + perks[i] );
	
	self.lastClass = class;
}


cac_getWeapon( classIndex, weaponIndex )
{
	return self getPlayerData( "customClasses", classIndex, "weaponSetups", weaponIndex, "weapon" );
}

cac_getWeaponAttachment( classIndex, weaponIndex )
{
	return self getPlayerData( "customClasses", classIndex, "weaponSetups", weaponIndex, "attachment", 0 );
}

cac_getWeaponAttachmentTwo( classIndex, weaponIndex )
{
	return self getPlayerData( "customClasses", classIndex, "weaponSetups", weaponIndex, "attachment", 1 );
}

cac_getWeaponCamo( classIndex, weaponIndex )
{
	return self getPlayerData( "customClasses", classIndex, "weaponSetups", weaponIndex, "camo" );
}

cac_getPerk( classIndex, perkIndex )
{
	return self getPlayerData( "customClasses", classIndex, "perks", perkIndex );
}

cac_getKillstreak( classIndex, streakIndex )
{
	return self getPlayerData( "killstreaks", streakIndex );
}

cac_getDeathstreak( classIndex )
{
	return self getPlayerData( "customClasses", classIndex, "perks", 4 );
}

cac_getOffhand( classIndex )
{
	return self getPlayerData( "customClasses", classIndex, "specialGrenade" );
}



table_getWeapon( tableName, classIndex, weaponIndex )
{
	if ( weaponIndex == 0 )
		return tableLookup( tableName, 0, "loadoutPrimary", classIndex + 1 );
	else
		return tableLookup( tableName, 0, "loadoutSecondary", classIndex + 1 );
}

table_getWeaponAttachment( tableName, classIndex, weaponIndex, attachmentIndex )
{
	tempName = "none";
	
	if ( weaponIndex == 0 )
	{
		if ( !isDefined( attachmentIndex ) || attachmentIndex == 0 )
			tempName = tableLookup( tableName, 0, "loadoutPrimaryAttachment", classIndex + 1 );
		else
			tempName = tableLookup( tableName, 0, "loadoutPrimaryAttachment2", classIndex + 1 );
	}
	else
	{
		if ( !isDefined( attachmentIndex ) || attachmentIndex == 0 )
			tempName = tableLookup( tableName, 0, "loadoutSecondaryAttachment", classIndex + 1 );
		else
			tempName = tableLookup( tableName, 0, "loadoutSecondaryAttachment2", classIndex + 1 );
	}
	
	if ( tempName == "" || tempName == "none" )
		return "none";
	else
		return tempName;
	
	
}

table_getWeaponCamo( tableName, classIndex, weaponIndex )
{
	if ( weaponIndex == 0 )
		return tableLookup( tableName, 0, "loadoutPrimaryCamo", classIndex + 1 );
	else
		return tableLookup( tableName, 0, "loadoutSecondaryCamo", classIndex + 1 );
}

table_getEquipment( tableName, classIndex, perkIndex )
{
	assert( perkIndex < 5 );
	return tableLookup( tableName, 0, "loadoutEquipment", classIndex + 1 );
}

table_getPerk( tableName, classIndex, perkIndex )
{
	assert( perkIndex < 5 );
	return tableLookup( tableName, 0, "loadoutPerk" + perkIndex, classIndex + 1 );
}

table_getOffhand( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutOffhand", classIndex + 1 );
}

table_getKillstreak( tableName, classIndex, streakIndex )
{
//	return tableLookup( tableName, 0, "loadoutStreak" + streakIndex, classIndex + 1 );
	return ( "none" );
}

table_getDeathstreak( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutDeathstreak", classIndex + 1 );
}

getClassIndex( className )
{
	assert( isDefined( level.classMap[className] ) );
	
	return level.classMap[className];
}

/*
getPerk( perkIndex )
{
	if( isSubstr( self.pers["class"], "CLASS_CUSTOM" ) )
		return cac_getPerk( self.class_num, perkIndex );
	else
		return table_getPerk( level.classTableName, self.class_num, perkIndex );	
}

getWeaponCamo( weaponIndex )
{
	if( isSubstr( self.pers["class"], "CLASS_CUSTOM" ) )
		return cac_getWeaponCamo( self.class_num, weaponIndex );
	else
		return table_getWeaponCamo( level.classTableName, self.class_num, weaponIndex );	
}
*/

cloneLoadout()
{
	clonedLoadout = [];
	
	class = self.curClass;
	
	if ( class == "copycat" )
		return ( undefined );
	
	if( isSubstr( class, "custom" ) )
	{
		class_num = getClassIndex( class );

		loadoutPrimaryAttachment2 = "none";
		loadoutSecondaryAttachment2 = "none";

		loadoutPrimary = cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 0 );
		loadoutPrimaryCamo = cac_getWeaponCamo( class_num, 0 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutSecondary = cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 1 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutEquipment = cac_getPerk( class_num, 0 );
		loadoutPerk1 = cac_getPerk( class_num, 1 );
		loadoutPerk2 = cac_getPerk( class_num, 2 );
		loadoutPerk3 = cac_getPerk( class_num, 3 );
		loadoutOffhand = cac_getOffhand( class_num );
		loadoutDeathStreak = cac_getDeathstreak( class_num );
	}
	else
	{
		class_num = getClassIndex( class );
		
		loadoutPrimary = table_getWeapon( level.classTableName, class_num, 0 );
		loadoutPrimaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 0 , 0);
		loadoutPrimaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 0, 1 );
		loadoutPrimaryCamo = table_getWeaponCamo( level.classTableName, class_num, 0 );
		loadoutSecondary = table_getWeapon( level.classTableName, class_num, 1 );
		loadoutSecondaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 1 , 0);
		loadoutSecondaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 1, 1 );;
		loadoutSecondaryCamo = table_getWeaponCamo( level.classTableName, class_num, 1 );
		loadoutEquipment = table_getEquipment( level.classTableName, class_num, 0 );
		loadoutPerk1 = table_getPerk( level.classTableName, class_num, 1 );
		loadoutPerk2 = table_getPerk( level.classTableName, class_num, 2 );
		loadoutPerk3 = table_getPerk( level.classTableName, class_num, 3 );
		loadoutOffhand = table_getOffhand( level.classTableName, class_num );
		loadoutDeathstreak = table_getDeathstreak( level.classTableName, class_num );
	}
	
	clonedLoadout["inUse"] = false;
	clonedLoadout["loadoutPrimary"] = loadoutPrimary;
	clonedLoadout["loadoutPrimaryAttachment"] = loadoutPrimaryAttachment;
	clonedLoadout["loadoutPrimaryAttachment2"] = loadoutPrimaryAttachment2;
	clonedLoadout["loadoutPrimaryCamo"] = loadoutPrimaryCamo;
	clonedLoadout["loadoutSecondary"] = loadoutSecondary;
	clonedLoadout["loadoutSecondaryAttachment"] = loadoutSecondaryAttachment;
	clonedLoadout["loadoutSecondaryAttachment2"] = loadoutSecondaryAttachment2;
	clonedLoadout["loadoutSecondaryCamo"] = loadoutSecondaryCamo;
	clonedLoadout["loadoutEquipment"] = loadoutEquipment;
	clonedLoadout["loadoutPerk1"] = loadoutPerk1;
	clonedLoadout["loadoutPerk2"] = loadoutPerk2;
	clonedLoadout["loadoutPerk3"] = loadoutPerk3;
	clonedLoadout["loadoutOffhand"] = loadoutOffhand;
	
	return ( clonedLoadout );
}

giveLoadout( team, class, allowCopycat )
{
	self.ufo = false;
	self allowSpectateTeam( "freelook", false );
	self.sessionstate = "playing";

	self takeAllWeapons();
	
	primaryIndex = 0;
	
	// initialize specialty array
	self.specialty = [];

	if ( !isDefined( allowCopycat ) )
		allowCopycat = true;

	primaryWeapon = undefined;

	if ( isDefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat )
	{
		self maps\mp\gametypes\_class::setClass( "copycat" );
		self.class_num = getClassIndex( "copycat" );

		clonedLoadout = self.pers["copyCatLoadout"];

		loadoutPrimary = clonedLoadout["loadoutPrimary"];
		loadoutPrimaryAttachment = clonedLoadout["loadoutPrimaryAttachment"];
		loadoutPrimaryAttachment2 = clonedLoadout["loadoutPrimaryAttachment2"] ;
		loadoutPrimaryCamo = clonedLoadout["loadoutPrimaryCamo"];
		loadoutSecondary = clonedLoadout["loadoutSecondary"];
		loadoutSecondaryAttachment = clonedLoadout["loadoutSecondaryAttachment"];
		loadoutSecondaryAttachment2 = clonedLoadout["loadoutSecondaryAttachment2"];
		loadoutSecondaryCamo = clonedLoadout["loadoutSecondaryCamo"];
		loadoutEquipment = clonedLoadout["loadoutEquipment"];
		loadoutPerk1 = clonedLoadout["loadoutPerk1"];
		loadoutPerk2 = clonedLoadout["loadoutPerk2"];
		loadoutPerk3 = clonedLoadout["loadoutPerk3"];
		loadoutOffhand = clonedLoadout["loadoutOffhand"];
		loadoutDeathStreak = "specialty_copycat";
	}
	else if ( isSubstr( class, "custom" ) )
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;

		loadoutPrimary = cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 0 );
		loadoutPrimaryCamo = cac_getWeaponCamo( class_num, 0 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutSecondary = cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 1 );
		loadoutEquipment = cac_getPerk( class_num, 0 );
		loadoutPerk1 = cac_getPerk( class_num, 1 );
		loadoutPerk2 = cac_getPerk( class_num, 2 );
		loadoutPerk3 = cac_getPerk( class_num, 3 );
		loadoutOffhand = cac_getOffhand( class_num );
		loadoutDeathStreak = cac_getDeathstreak( class_num );
	}
	else
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;
		
		camos = [];
		camos[0] = "red_urban";
		camos[1] = "red_tiger";
		camos[2] = "blue_tiger";
		camos[3] = "orange_fall";

		pri = [];
		/*
		pri[0] = "cheytac";
		pri[1] = "m21";
		pri[2] = "wa2000";
		pri[3] = "m21";
		*/
		pri[0] = "ak47";
		pri[1] = "m16";
		pri[2] = "fn2000";
		pri[3] = "m21";
		
		priAttach = [];
		/*
		priAttach[0] = "none";
		priAttach[1] = "acog";
		priAttach[2] = "fmj";
		priAttach[3] = "heartbeat";
		priAttach[4] = "thermal";
		priAttach[5] = "xmags";
		*/
		priAttach[0] = "none";
		priAttach[1] = "none";
		priAttach[2] = "fmj";
		priAttach[3] = "heartbeat";
		priAttach[4] = "xmags";
		priAttach[5] = "xmags";

	guns = [];
	guns[0] = "ak47_mp";
	guns[1] = "ak47_acog_mp";
	guns[2] = "ak47_eotech_mp";
	guns[3] = "ak47_fmj_mp";
	guns[4] = "ak47_gl_mp";
	guns[5] = "ak47_heartbeat_mp";
	guns[6] = "ak47_reflex_mp";
	guns[7] = "ak47_shotgun_mp";
	guns[8] = "ak47_silencer_mp";
	guns[9] = "ak47_thermal_mp";
	guns[10] = "ak47_xmags_mp";
	guns[11] = "ak47_acog_fmj_mp";
	guns[12] = "ak47_acog_gl_mp";
	guns[13] = "ak47_acog_heartbeat_mp";
	guns[14] = "ak47_acog_shotgun_mp";
	guns[15] = "ak47_acog_silencer_mp";
	guns[16] = "ak47_acog_xmags_mp";
	guns[17] = "ak47_eotech_fmj_mp";
	guns[18] = "ak47_eotech_gl_mp";
	guns[19] = "ak47_eotech_heartbeat_mp";
	guns[20] = "ak47_eotech_shotgun_mp";
	guns[21] = "ak47_eotech_silencer_mp";
	guns[22] = "ak47_eotech_xmags_mp";
	guns[23] = "ak47_fmj_gl_mp";
	guns[24] = "ak47_fmj_heartbeat_mp";
	guns[25] = "ak47_fmj_reflex_mp";
	guns[26] = "ak47_fmj_shotgun_mp";
	guns[27] = "ak47_fmj_silencer_mp";
	guns[28] = "ak47_fmj_thermal_mp";
	guns[29] = "ak47_fmj_xmags_mp";
	guns[30] = "ak47_gl_heartbeat_mp";
	guns[31] = "ak47_gl_reflex_mp";
	guns[32] = "ak47_gl_silencer_mp";
	guns[33] = "ak47_gl_thermal_mp";
	guns[34] = "ak47_gl_xmags_mp";
	guns[35] = "ak47_heartbeat_reflex_mp";
	guns[36] = "ak47_heartbeat_shotgun_mp";
	guns[37] = "ak47_heartbeat_silencer_mp";
	guns[38] = "ak47_heartbeat_thermal_mp";
	guns[39] = "ak47_heartbeat_xmags_mp";
	guns[40] = "ak47_reflex_shotgun_mp";
	guns[41] = "ak47_reflex_silencer_mp";
	guns[42] = "ak47_reflex_xmags_mp";
	guns[43] = "ak47_shotgun_silencer_mp";
	guns[44] = "ak47_shotgun_thermal_mp";
	guns[45] = "ak47_shotgun_xmags_mp";
	guns[46] = "ak47_silencer_thermal_mp";
	guns[47] = "ak47_silencer_xmags_mp";
	guns[48] = "ak47_thermal_xmags_mp";
	guns[49] = "m16_mp";
	guns[50] = "m16_acog_mp";
	guns[51] = "m16_eotech_mp";
	guns[52] = "m16_fmj_mp";
	guns[53] = "m16_gl_mp";
	guns[54] = "m16_heartbeat_mp";
	guns[55] = "m16_reflex_mp";
	guns[56] = "m16_shotgun_mp";
	guns[57] = "m16_silencer_mp";
	guns[58] = "m16_thermal_mp";
	guns[59] = "m16_xmags_mp";
	guns[60] = "m16_acog_fmj_mp";
	guns[61] = "m16_acog_gl_mp";
	guns[62] = "m16_acog_heartbeat_mp";
	guns[63] = "m16_acog_shotgun_mp";
	guns[64] = "m16_acog_silencer_mp";
	guns[65] = "m16_acog_xmags_mp";
	guns[66] = "m16_eotech_fmj_mp";
	guns[67] = "m16_eotech_gl_mp";
	guns[68] = "m16_eotech_heartbeat_mp";
	guns[69] = "m16_eotech_shotgun_mp";
	guns[70] = "m16_eotech_silencer_mp";
	guns[71] = "m16_eotech_xmags_mp";
	guns[72] = "m16_fmj_gl_mp";
	guns[73] = "m16_fmj_heartbeat_mp";
	guns[74] = "m16_fmj_reflex_mp";
	guns[75] = "m16_fmj_shotgun_mp";
	guns[76] = "m16_fmj_silencer_mp";
	guns[77] = "m4_mp";
	guns[78] = "m4_acog_mp";
	guns[79] = "m4_eotech_mp";
	guns[80] = "m4_fmj_mp";
	guns[81] = "m4_gl_mp";
	guns[82] = "m4_heartbeat_mp";
	guns[83] = "m4_reflex_mp";
	guns[84] = "m4_shotgun_mp";
	guns[85] = "m4_silencer_mp";
	guns[86] = "m4_thermal_mp";
	guns[87] = "m4_xmags_mp";
	guns[88] = "m4_acog_fmj_mp";
	guns[89] = "m4_acog_gl_mp";
	guns[90] = "m4_acog_heartbeat_mp";
	guns[91] = "m4_acog_shotgun_mp";
	guns[92] = "m4_acog_silencer_mp";
	guns[93] = "m4_acog_xmags_mp";
	guns[94] = "m4_eotech_fmj_mp";
	guns[95] = "m4_eotech_gl_mp";
	guns[96] = "m4_eotech_heartbeat_mp";
	guns[97] = "m4_eotech_shotgun_mp";
	guns[98] = "m4_eotech_silencer_mp";
	guns[99] = "m4_eotech_xmags_mp";
	guns[100] = "m4_fmj_gl_mp";
	guns[101] = "m4_fmj_heartbeat_mp";
	guns[102] = "m4_fmj_reflex_mp";
	guns[103] = "m4_fmj_shotgun_mp";
	guns[104] = "m4_fmj_silencer_mp";
	guns[105] = "m4_fmj_thermal_mp";
	guns[106] = "m4_fmj_xmags_mp";
	guns[107] = "m4_gl_heartbeat_mp";
	guns[108] = "m4_gl_reflex_mp";
	guns[109] = "m4_gl_silencer_mp";
	guns[110] = "m4_gl_thermal_mp";
	guns[111] = "m4_gl_xmags_mp";
	guns[112] = "m4_heartbeat_reflex_mp";
	guns[113] = "m4_heartbeat_shotgun_mp";
	guns[114] = "m4_heartbeat_silencer_mp";
	guns[115] = "m4_heartbeat_thermal_mp";
	guns[116] = "m4_heartbeat_xmags_mp";
	guns[117] = "m4_reflex_shotgun_mp";
	guns[118] = "m4_reflex_silencer_mp";
	guns[119] = "m4_reflex_xmags_mp";
	guns[120] = "m4_shotgun_silencer_mp";
	guns[121] = "m4_shotgun_thermal_mp";
	guns[122] = "m4_shotgun_xmags_mp";
	guns[123] = "m4_silencer_thermal_mp";
	guns[124] = "m4_silencer_xmags_mp";
	guns[125] = "m4_thermal_xmags_mp";
	guns[126] = "fn2000_mp";
	guns[127] = "fn2000_acog_mp";
	guns[128] = "fn2000_eotech_mp";
	guns[129] = "fn2000_fmj_mp";
	guns[130] = "fn2000_gl_mp";
	guns[131] = "fn2000_heartbeat_mp";
	guns[132] = "fn2000_reflex_mp";
	guns[133] = "fn2000_shotgun_mp";
	guns[134] = "fn2000_silencer_mp";
	guns[135] = "fn2000_thermal_mp";
	guns[136] = "fn2000_xmags_mp";
	guns[137] = "fn2000_acog_fmj_mp";
	guns[138] = "fn2000_acog_gl_mp";
	guns[139] = "fn2000_acog_heartbeat_mp";
	guns[140] = "fn2000_acog_shotgun_mp";
	guns[141] = "fn2000_acog_silencer_mp";
	guns[142] = "fn2000_acog_xmags_mp";
	guns[143] = "fn2000_eotech_fmj_mp";
	guns[144] = "fn2000_eotech_gl_mp";
	guns[145] = "fn2000_eotech_heartbeat_mp";
	guns[146] = "fn2000_eotech_shotgun_mp";
	guns[147] = "fn2000_eotech_silencer_mp";
	guns[148] = "fn2000_eotech_xmags_mp";
	guns[149] = "fn2000_fmj_gl_mp";
	guns[150] = "fn2000_fmj_heartbeat_mp";
	guns[151] = "fn2000_fmj_reflex_mp";
	guns[152] = "fn2000_fmj_shotgun_mp";
	guns[153] = "fn2000_fmj_silencer_mp";
	guns[154] = "fn2000_fmj_thermal_mp";
	guns[155] = "fn2000_fmj_xmags_mp";
	guns[156] = "fn2000_gl_heartbeat_mp";
	guns[157] = "fn2000_gl_reflex_mp";
	guns[158] = "fn2000_gl_silencer_mp";
	guns[159] = "fn2000_gl_thermal_mp";
	guns[160] = "fn2000_gl_xmags_mp";
	guns[161] = "fn2000_heartbeat_reflex_mp";
	guns[162] = "fn2000_heartbeat_shotgun_mp";
	guns[163] = "fn2000_heartbeat_silencer_mp";
	guns[164] = "fn2000_heartbeat_thermal_mp";
	guns[165] = "fn2000_heartbeat_xmags_mp";
	guns[166] = "fn2000_reflex_shotgun_mp";
	guns[167] = "fn2000_reflex_silencer_mp";
	guns[168] = "fn2000_reflex_xmags_mp";
	guns[169] = "fn2000_shotgun_silencer_mp";
	guns[170] = "fn2000_shotgun_thermal_mp";
	guns[171] = "fn2000_shotgun_xmags_mp";
	guns[172] = "fn2000_silencer_thermal_mp";
	guns[173] = "fn2000_silencer_xmags_mp";
	guns[174] = "fn2000_thermal_xmags_mp";
	guns[175] = "masada_mp";
	guns[176] = "masada_acog_mp";
	guns[177] = "masada_eotech_mp";
	guns[178] = "masada_fmj_mp";
	guns[179] = "masada_gl_mp";
	guns[180] = "masada_heartbeat_mp";
	guns[181] = "masada_reflex_mp";
	guns[182] = "masada_shotgun_mp";
	guns[183] = "masada_silencer_mp";
	guns[184] = "masada_thermal_mp";
	guns[185] = "masada_xmags_mp";
	guns[186] = "masada_acog_fmj_mp";
	guns[187] = "masada_acog_gl_mp";
	guns[188] = "masada_acog_heartbeat_mp";
	guns[189] = "masada_acog_shotgun_mp";
	guns[190] = "masada_acog_silencer_mp";
	guns[191] = "masada_acog_xmags_mp";
	guns[192] = "masada_eotech_fmj_mp";
	guns[193] = "masada_eotech_gl_mp";
	guns[194] = "masada_eotech_heartbeat_mp";
	guns[195] = "masada_eotech_shotgun_mp";
	guns[196] = "masada_eotech_silencer_mp";
	guns[197] = "masada_eotech_xmags_mp";
	guns[198] = "masada_fmj_gl_mp";
	guns[199] = "masada_fmj_heartbeat_mp";
	guns[200] = "masada_fmj_reflex_mp";
	guns[201] = "masada_fmj_shotgun_mp";
	guns[202] = "masada_fmj_silencer_mp";
	guns[203] = "masada_fmj_thermal_mp";
	guns[204] = "masada_fmj_xmags_mp";
	guns[205] = "masada_gl_heartbeat_mp";
	guns[206] = "masada_gl_reflex_mp";
	guns[207] = "masada_gl_silencer_mp";
	guns[208] = "masada_gl_thermal_mp";
	guns[209] = "masada_gl_xmags_mp";
	guns[210] = "masada_heartbeat_reflex_mp";
	guns[211] = "masada_heartbeat_shotgun_mp";
	guns[212] = "masada_heartbeat_silencer_mp";
	guns[213] = "masada_heartbeat_thermal_mp";
	guns[214] = "masada_heartbeat_xmags_mp";
	guns[215] = "masada_reflex_shotgun_mp";
	guns[216] = "masada_reflex_silencer_mp";
	guns[217] = "masada_reflex_xmags_mp";
	guns[218] = "masada_shotgun_silencer_mp";
	guns[219] = "masada_shotgun_thermal_mp";
	guns[220] = "masada_shotgun_xmags_mp";
	guns[221] = "masada_silencer_thermal_mp";
	guns[222] = "masada_silencer_xmags_mp";
	guns[223] = "masada_thermal_xmags_mp";
	guns[224] = "famas_mp";
	guns[225] = "famas_acog_mp";
	guns[226] = "famas_eotech_mp";
	guns[227] = "famas_fmj_mp";
	guns[228] = "famas_gl_mp";
	guns[229] = "famas_heartbeat_mp";
	guns[230] = "famas_reflex_mp";
	guns[231] = "famas_shotgun_mp";
	guns[232] = "famas_silencer_mp";
	guns[233] = "famas_thermal_mp";
	guns[234] = "famas_xmags_mp";
	guns[235] = "famas_acog_fmj_mp";
	guns[236] = "famas_acog_gl_mp";
	guns[237] = "famas_acog_heartbeat_mp";
	guns[238] = "famas_acog_shotgun_mp";
	guns[239] = "famas_acog_silencer_mp";
	guns[240] = "famas_acog_xmags_mp";
	guns[241] = "famas_eotech_fmj_mp";
	guns[242] = "famas_eotech_gl_mp";
	guns[243] = "famas_eotech_heartbeat_mp";
	guns[244] = "famas_eotech_shotgun_mp";
	guns[245] = "famas_eotech_silencer_mp";
	guns[246] = "famas_eotech_xmags_mp";
	guns[247] = "famas_fmj_gl_mp";
	guns[248] = "famas_fmj_heartbeat_mp";
	guns[249] = "famas_fmj_reflex_mp";
	guns[250] = "famas_fmj_shotgun_mp";
	guns[251] = "famas_fmj_silencer_mp";
	guns[252] = "famas_fmj_thermal_mp";
	guns[253] = "famas_fmj_xmags_mp";
	guns[254] = "famas_gl_heartbeat_mp";
	guns[255] = "famas_gl_reflex_mp";
	guns[256] = "famas_gl_silencer_mp";
	guns[257] = "famas_gl_thermal_mp";
	guns[258] = "famas_gl_xmags_mp";
	guns[259] = "famas_heartbeat_reflex_mp";
	guns[260] = "famas_heartbeat_shotgun_mp";
	guns[261] = "famas_heartbeat_silencer_mp";
	guns[262] = "famas_heartbeat_thermal_mp";
	guns[263] = "famas_heartbeat_xmags_mp";
	guns[264] = "famas_reflex_shotgun_mp";
	guns[265] = "famas_reflex_silencer_mp";
	guns[266] = "famas_reflex_xmags_mp";
	guns[267] = "famas_shotgun_silencer_mp";
	guns[268] = "famas_shotgun_thermal_mp";
	guns[269] = "famas_shotgun_xmags_mp";
	guns[270] = "famas_silencer_thermal_mp";
	guns[271] = "famas_silencer_xmags_mp";
	guns[272] = "famas_thermal_xmags_mp";
	guns[273] = "fal_mp";
	guns[274] = "fal_acog_mp";
	guns[275] = "fal_eotech_mp";
	guns[276] = "fal_fmj_mp";
	guns[277] = "fal_gl_mp";
	guns[278] = "fal_heartbeat_mp";
	guns[279] = "fal_reflex_mp";
	guns[280] = "fal_shotgun_mp";
	guns[281] = "fal_silencer_mp";
	guns[282] = "fal_thermal_mp";
	guns[283] = "fal_xmags_mp";
	guns[284] = "fal_acog_fmj_mp";
	guns[285] = "fal_acog_gl_mp";
	guns[286] = "fal_acog_heartbeat_mp";
	guns[287] = "fal_acog_shotgun_mp";
	guns[288] = "fal_acog_silencer_mp";
	guns[289] = "fal_acog_xmags_mp";
	guns[290] = "fal_eotech_fmj_mp";
	guns[291] = "fal_eotech_gl_mp";
	guns[292] = "fal_eotech_heartbeat_mp";
	guns[293] = "fal_eotech_shotgun_mp";
	guns[294] = "fal_eotech_silencer_mp";
	guns[295] = "fal_eotech_xmags_mp";
	guns[296] = "fal_fmj_gl_mp";
	guns[297] = "fal_fmj_heartbeat_mp";
	guns[298] = "fal_fmj_reflex_mp";
	guns[299] = "fal_fmj_shotgun_mp";
	guns[300] = "fal_fmj_silencer_mp";
	guns[301] = "fal_fmj_thermal_mp";
	guns[302] = "fal_fmj_xmags_mp";
	guns[303] = "fal_gl_heartbeat_mp";
	guns[304] = "fal_gl_reflex_mp";
	guns[305] = "fal_gl_silencer_mp";
	guns[306] = "fal_gl_thermal_mp";
	guns[307] = "fal_gl_xmags_mp";
	guns[308] = "fal_heartbeat_reflex_mp";
	guns[309] = "fal_heartbeat_shotgun_mp";
	guns[310] = "fal_heartbeat_silencer_mp";
	guns[311] = "fal_heartbeat_thermal_mp";
	guns[312] = "fal_heartbeat_xmags_mp";
	guns[313] = "fal_reflex_shotgun_mp";
	guns[314] = "fal_reflex_silencer_mp";
	guns[315] = "fal_reflex_xmags_mp";
	guns[316] = "fal_shotgun_silencer_mp";
	guns[317] = "fal_shotgun_thermal_mp";
	guns[318] = "fal_shotgun_xmags_mp";
	guns[319] = "fal_silencer_thermal_mp";
	guns[320] = "fal_silencer_xmags_mp";
	guns[321] = "fal_thermal_xmags_mp";
	guns[322] = "scar_mp";
	guns[323] = "scar_acog_mp";
	guns[324] = "scar_eotech_mp";
	guns[325] = "scar_fmj_mp";
	guns[326] = "scar_gl_mp";
	guns[327] = "scar_heartbeat_mp";
	guns[328] = "scar_reflex_mp";
	guns[329] = "scar_shotgun_mp";
	guns[330] = "scar_silencer_mp";
	guns[331] = "scar_thermal_mp";
	guns[332] = "scar_xmags_mp";
	guns[333] = "scar_acog_fmj_mp";
	guns[334] = "scar_acog_gl_mp";
	guns[335] = "scar_acog_heartbeat_mp";
	guns[336] = "scar_acog_shotgun_mp";
	guns[337] = "scar_acog_silencer_mp";
	guns[338] = "scar_acog_xmags_mp";
	guns[339] = "scar_eotech_fmj_mp";
	guns[340] = "scar_eotech_gl_mp";
	guns[341] = "scar_eotech_heartbeat_mp";
	guns[342] = "scar_eotech_shotgun_mp";
	guns[343] = "scar_eotech_silencer_mp";
	guns[344] = "scar_eotech_xmags_mp";
	guns[345] = "scar_fmj_gl_mp";
	guns[346] = "scar_fmj_heartbeat_mp";
	guns[347] = "scar_fmj_reflex_mp";
	guns[348] = "scar_fmj_shotgun_mp";
	guns[349] = "scar_fmj_silencer_mp";
	guns[350] = "scar_fmj_thermal_mp";
	guns[351] = "scar_fmj_xmags_mp";
	guns[352] = "scar_gl_heartbeat_mp";
	guns[353] = "scar_gl_reflex_mp";
	guns[354] = "scar_gl_silencer_mp";
	guns[355] = "scar_gl_thermal_mp";
	guns[356] = "scar_gl_xmags_mp";
	guns[357] = "scar_heartbeat_reflex_mp";
	guns[358] = "scar_heartbeat_shotgun_mp";
	guns[359] = "scar_heartbeat_silencer_mp";
	guns[360] = "scar_heartbeat_thermal_mp";
	guns[361] = "scar_heartbeat_xmags_mp";
	guns[362] = "scar_reflex_shotgun_mp";
	guns[363] = "scar_reflex_silencer_mp";
	guns[364] = "scar_reflex_xmags_mp";
	guns[365] = "scar_shotgun_silencer_mp";
	guns[366] = "scar_shotgun_thermal_mp";
	guns[367] = "scar_shotgun_xmags_mp";
	guns[368] = "scar_silencer_thermal_mp";
	guns[369] = "scar_silencer_xmags_mp";
	guns[370] = "scar_thermal_xmags_mp";
	guns[371] = "tavor_mp";
	guns[372] = "tavor_acog_mp";
	guns[373] = "tavor_eotech_mp";
	guns[374] = "tavor_fmj_mp";
	guns[375] = "tavor_gl_mp";
	guns[376] = "tavor_heartbeat_mp";
	guns[377] = "tavor_reflex_mp";
	guns[378] = "tavor_shotgun_mp";
	guns[379] = "tavor_silencer_mp";
	guns[380] = "tavor_thermal_mp";
	guns[381] = "tavor_xmags_mp";
	guns[382] = "tavor_acog_fmj_mp";
	guns[383] = "tavor_acog_gl_mp";
	guns[384] = "tavor_acog_heartbeat_mp";
	guns[385] = "tavor_acog_shotgun_mp";
	guns[386] = "tavor_acog_silencer_mp";
	guns[387] = "tavor_acog_xmags_mp";
	guns[388] = "tavor_eotech_fmj_mp";
	guns[389] = "tavor_eotech_gl_mp";
	guns[390] = "tavor_eotech_heartbeat_mp";
	guns[391] = "tavor_eotech_shotgun_mp";
	guns[392] = "tavor_eotech_silencer_mp";
	guns[393] = "tavor_eotech_xmags_mp";
	guns[394] = "tavor_fmj_gl_mp";
	guns[395] = "tavor_fmj_heartbeat_mp";
	guns[396] = "tavor_fmj_reflex_mp";
	guns[397] = "tavor_fmj_shotgun_mp";
	guns[398] = "tavor_fmj_silencer_mp";
	guns[399] = "tavor_fmj_thermal_mp";
	guns[400] = "tavor_fmj_xmags_mp";
	guns[401] = "tavor_gl_heartbeat_mp";
	guns[402] = "tavor_gl_reflex_mp";
	guns[403] = "tavor_gl_silencer_mp";
	guns[404] = "tavor_gl_thermal_mp";
	guns[405] = "tavor_gl_xmags_mp";
	guns[406] = "tavor_heartbeat_reflex_mp";
	guns[407] = "tavor_heartbeat_shotgun_mp";
	guns[408] = "tavor_heartbeat_silencer_mp";
	guns[409] = "tavor_heartbeat_thermal_mp";
	guns[410] = "tavor_heartbeat_xmags_mp";
	guns[411] = "tavor_reflex_shotgun_mp";
	guns[412] = "tavor_reflex_silencer_mp";
	guns[413] = "tavor_reflex_xmags_mp";
	guns[414] = "tavor_shotgun_silencer_mp";
	guns[415] = "tavor_shotgun_thermal_mp";
	guns[416] = "tavor_shotgun_xmags_mp";
	guns[417] = "tavor_silencer_thermal_mp";
	guns[418] = "tavor_silencer_xmags_mp";
	guns[419] = "tavor_thermal_xmags_mp";

		
		
		// Handling Types
		type = randomInt( 6 );

		typeOne = [];
		typeOne[0] = "usp";
		typeOne[1] = "beretta";

		typeTwo = [];
		typeTwo[0] = "coltanaconda";
		typeTwo[1] = "deserteagle";

		typeThree = [];
		typeThree[0] = "ranger";
		typeThree[1] = "model1887";

		typeFour = [];
		typeFour[0] = "striker";
		typeFour[1] = "aa12";
		typeFour[2] = "m1014";
		typeFour[3] = "spas12";

		typeFive = [];
		typeFive[0] = "pp2000";
		typeFive[1] = "glock";
		typeFive[2] = "beretta393";
		typeFive[3] = "tmp";

		typeSix = [];
		typeSix[0] = "m79";
		typeSix[1] = "rpg";
		typeSix[2] = "at4";
		typeSix[3] = "stinger";
		typeSix[4] = "javelin";

		// Type Attackments
		typeOneAttach = [];
		typeOneAttach[0] = "none";
		typeOneAttach[1] = "tactical";
		typeOneAttach[2] = "fmj";
		typeOneAttach[3] = "akimbo";
		typeOneAttach[4] = "xmags";

		typeTwoAttach = [];
		typeTwoAttach[0] = "none";
		typeTwoAttach[1] = "tactical";
		typeTwoAttach[2] = "fmj";
		typeTwoAttach[3] = "akimbo";

		typeThreeAttach = [];
		typeThreeAttach[0] = "none";
		typeThreeAttach[1] = "fmj";
		typeThreeAttach[2] = "akimbo";

		typeFourAttach = [];
		typeFourAttach[0] = "none";
		typeFourAttach[1] = "eotech";
		typeFourAttach[2] = "fmj";
		typeFourAttach[3] = "grip";
		typeFourAttach[4] = "reflex";
		typeFourAttach[5] = "xmags";

		typeFiveAttach = [];
		typeFiveAttach[0] = "none";
		typeFiveAttach[1] = "eotech";
		typeFiveAttach[2] = "fmj";
		typeFiveAttach[3] = "akimbo";
		typeFiveAttach[4] = "reflex";
		typeFiveAttach[5] = "xmags";

		perk1 = [];
		perk1[0] = "specialty_fastreload";
		perk1[1] = "specialty_fastreload";

		equip = [];
		equip[0] = "throwingknife_mp";
		equip[1] = "claymore_mp";
		equip[2] = "c4_mp";
		equip[3] = "specialty_tacticalinsertion";

		if (class_num != 4)
		{
			loadoutPrimaryAttachment = priAttach[ randomInt( 7 ) ];
			loadoutPrimaryAttachment2 = "none";
			loadoutPrimaryCamo = camos[ randomInt( 4 ) ];

			/*
			if (class_num == 0)
				loadoutPrimary = "cheytac";
			else if (class_num == 1)
				loadoutPrimary = "barrett";
			else if (class_num == 2)
				loadoutPrimary = "cheytac";
			else if (class_num == 3)
				loadoutPrimary = "m16";
			else
				loadoutPrimary = "cheytac";
			*/
			if (class_num == 0)
				loadoutPrimary = "ak47";
			else if (class_num == 1)
				loadoutPrimary = "fn2000";
			else if (class_num == 2)
				loadoutPrimary = "scar";
			else if (class_num == 3)
				loadoutPrimary = "m21";
			else
				loadoutPrimary = "ak47";

			if (type == 0)
			{
				loadoutSecondary = typeOne[ randomInt( 2 ) ];
				loadoutSecondaryAttachment = typeOneAttach[ randomInt( 6 ) ];
			}
			else if (type == 1)
			{
				loadoutSecondary = guns[ randomInt( 420 ) ]; //THANKS TO NERO
				loadoutSecondaryAttachment = typeTwoAttach[ randomInt( 0 ) ];
			}
			else if (type == 2)
			{
				loadoutSecondary = typeThree[ randomInt( 2 ) ];
				loadoutSecondaryAttachment = typeThreeAttach[ randomInt( 3 ) ];
			}
			else if (type == 3)
			{
				loadoutSecondary = typeFour[ randomInt( 4 ) ];
				loadoutSecondaryAttachment = typeFourAttach[ randomInt( 7 ) ];
			}
			else if (type == 4)
			{
				loadoutSecondary = typeFive[ randomInt( 6 ) ];
				loadoutSecondaryAttachment = typeFiveAttach[ randomInt( 7 ) ];
			}
			else if (type == 5)
			{
				loadoutSecondary = typeSix[ randomInt( 5 ) ];
				loadoutSecondaryAttachment = "none";
			}
			else
			{
				loadoutSecondary = "usp";
				loadoutSecondaryAttachment = "none";
			}

			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryCamo = "none";
			loadoutEquipment = equip[ randomInt( 4 ) ];
			loadoutPerk1 = perk1[ randomInt( 2 ) ];
			loadoutPerk2 = "specialty_bulletdamage";
			loadoutPerk3 = "specialty_bulletaccuracy";
			loadoutOffhand = "concussion_grenade";
			loadoutDeathstreak = "none";
		}
		else
		{
			/*
			loadoutPrimary = table_getWeapon( level.classTableName, class_num, 0 );
			loadoutPrimaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 0 , 0);
			loadoutPrimaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 0, 1 );
			loadoutPrimaryCamo = table_getWeaponCamo( level.classTableName, class_num, 0 );
			*/
			loadoutPrimary = "scar";
			loadoutPrimaryAttachment = priAttach[ randomInt( 7 ) ];
			loadoutPrimaryAttachment2 = "none";
			loadoutPrimaryCamo = camos[ randomInt( 4 ) ];
			loadoutSecondaryCamo = table_getWeaponCamo( level.classTableName, class_num, 1 );
			loadoutSecondary = table_getWeapon( level.classTableName, class_num, 1 );
			loadoutSecondaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 1 , 0);
			loadoutSecondaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 1, 1 );;
			loadoutSecondaryCamo = table_getWeaponCamo( level.classTableName, class_num, 1 );
			loadoutEquipment = table_getEquipment( level.classTableName, class_num, 0 );
			loadoutPerk1 = table_getPerk( level.classTableName, class_num, 1 );
			loadoutPerk2 = table_getPerk( level.classTableName, class_num, 2 );
			loadoutPerk3 = table_getPerk( level.classTableName, class_num, 3 );
			loadoutOffhand = table_getOffhand( level.classTableName, class_num );
			loadoutDeathstreak = "none";
		}
	}

	if ( level.killstreakRewards )
	{
		loadoutKillstreak1 = self getPlayerData( "killstreaks", 0 );
		loadoutKillstreak2 = self getPlayerData( "killstreaks", 1 );
		loadoutKillstreak3 = self getPlayerData( "killstreaks", 2 );
	}
	else
	{
		loadoutKillstreak1 = "none";
		loadoutKillstreak2 = "none";
		loadoutKillstreak3 = "none";
	}
	
	secondaryName = buildWeaponName( loadoutSecondary, loadoutSecondaryAttachment, loadoutSecondaryAttachment2 );
	self _giveWeapon( secondaryName, int(tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ) ) );

	self.loadoutPrimaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadoutPrimaryCamo, 0 ));
	self.loadoutPrimary = loadoutPrimary;
	self.loadoutSecondary = loadoutSecondary;
	self.loadoutSecondaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ));
	
	self SetOffhandPrimaryClass( "other" );
	
	// Action Slots
	self _SetActionSlot( 1, "" );
	//self _SetActionSlot( 1, "nightvision" );
	self _SetActionSlot( 3, "altMode" );
	self _SetActionSlot( 4, "" );

	// Perks
	self _clearPerks();
	self _detachAll();
	
	// these special case giving pistol death have to come before
	// perk loadout to ensure player perk icons arent overwritten
	if ( level.dieHardMode )
		self maps\mp\perks\_perks::givePerk( "specialty_pistoldeath" );

	self maps\mp\perks\_perks::givePerk( "specialty_falldamage" ); 	// Steady Aim
	
	// only give the deathstreak for the initial spawn for this life.
	if ( loadoutDeathStreak != "specialty_null" && getTime() == self.spawnTime )
	{
		deathVal = int( tableLookup( "mp/perkTable.csv", 1, loadoutDeathStreak, 6 ) );
		
		if ( self _hasPerk( "specialty_rollover" ) )
			deathVal -= 1;
		
		if ( self.pers["cur_death_streak"] == deathVal )
		{
			self thread maps\mp\perks\_perks::givePerk( loadoutDeathStreak );
			self thread maps\mp\gametypes\_hud_message::splashNotify( loadoutDeathStreak );
		}
		else if ( self.pers["cur_death_streak"] > deathVal )
		{
			self thread maps\mp\perks\_perks::givePerk( loadoutDeathStreak );
		}
	}
	
	self loadoutAllPerks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3 );
	
	self setKillstreaks( loadoutKillstreak1, loadoutKillstreak2, loadoutKillstreak3 );
		
	if ( self hasPerk( "specialty_extraammo", true ) && getWeaponClass( secondaryName ) != "weapon_projectile" )
		self giveMaxAmmo( secondaryName );

	// Primary Weapon
	primaryName = buildWeaponName( loadoutPrimary, loadoutPrimaryAttachment, loadoutPrimaryAttachment2 );
	self _giveWeapon( primaryName, self.loadoutPrimaryCamo );
	
	// fix changing from a riotshield class to a riotshield class during grace period not giving a shield
	if ( primaryName == "riotshield_mp" && level.inGracePeriod )
		self notify ( "weapon_change", "riotshield_mp" );

	if ( self hasPerk( "specialty_extraammo", true ) )
		self giveMaxAmmo( primaryName );

	self setSpawnWeapon( primaryName );
	
	primaryTokens = strtok( primaryName, "_" );
	self.pers["primaryWeapon"] = primaryTokens[0];
	
	// Primary Offhand was given by givePerk (it's your perk1)
	
	// Secondary Offhand
	offhandSecondaryWeapon = loadoutOffhand + "_mp";

	if ( loadoutOffhand == "flash_grenade" )
		self SetOffhandSecondaryClass( "flash" );
	else
		self SetOffhandSecondaryClass( "smoke" );
	
	self giveWeapon( offhandSecondaryWeapon );
	if( loadOutOffhand == "smoke_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
	else if( loadOutOffhand == "flash_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else if( loadOutOffhand == "concussion_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
	
	primaryWeapon = primaryName;
	self.primaryWeapon = primaryWeapon;
	self.secondaryWeapon = secondaryName;

	self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["primaryWeapon"], getBaseWeaponName( secondaryName ) );
		
	self.isSniper = (weaponClass( self.primaryWeapon ) == "sniper");
	
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	// cac specialties that require loop threads
	self maps\mp\perks\_perks::cac_selector();
	
	self notify ( "changed_kit" );
	self notify ( "giveLoadout" );
}


_detachAll()
{
	if ( isDefined( self.hasRiotShield ) && self.hasRiotShield )
	{
		if ( self.hasRiotShieldEquipped )
		{
			self DetachShieldModel( "weapon_riot_shield_mp", "tag_weapon_left" );
			self.hasRiotShieldEquipped = false;
		}
		else
		{
			self DetachShieldModel( "weapon_riot_shield_mp", "tag_shield_back" );
		}
		
		self.hasRiotShield = false;
	}
	
	self detachAll();
}

isPerkUpgraded( perkName )
{
	perkUpgrade = tablelookup( "mp/perktable.csv", 1, perkName, 8 );
	
	if ( perkUpgrade == "" || perkUpgrade == "specialty_null" )
		return false;
		
	if ( !self isItemUnlocked( perkUpgrade ) )
		return false;
		
	return true;
}

getPerkUpgrade( perkName )
{
	perkUpgrade = tablelookup( "mp/perktable.csv", 1, perkName, 8 );
	
	if ( perkUpgrade == "" || perkUpgrade == "specialty_null" )
		return "specialty_null";
		
	if ( !self isItemUnlocked( perkUpgrade ) )
		return "specialty_null";
		
	return ( perkUpgrade );
}

loadoutAllPerks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3 )
{
	loadoutEquipment = maps\mp\perks\_perks::validatePerk( 1, loadoutEquipment );
	loadoutPerk1 = maps\mp\perks\_perks::validatePerk( 1, loadoutPerk1 );
	loadoutPerk2 = maps\mp\perks\_perks::validatePerk( 2, loadoutPerk2 );
	loadoutPerk3 = maps\mp\perks\_perks::validatePerk( 3, loadoutPerk3 );

	self maps\mp\perks\_perks::givePerk( loadoutEquipment );
	self maps\mp\perks\_perks::givePerk( loadoutPerk1 );
	self maps\mp\perks\_perks::givePerk( loadoutPerk2 );
	self maps\mp\perks\_perks::givePerk( loadoutPerk3 );
	
	perkUpgrd[0] = tablelookup( "mp/perktable.csv", 1, loadoutPerk1, 8 );
	perkUpgrd[1] = tablelookup( "mp/perktable.csv", 1, loadoutPerk2, 8 );
	perkUpgrd[2] = tablelookup( "mp/perktable.csv", 1, loadoutPerk3, 8 );
	
	foreach( upgrade in perkUpgrd )
	{
		if ( upgrade == "" || upgrade == "specialty_null" )
			continue;
			
		if ( self isItemUnlocked( upgrade ) )
			self maps\mp\perks\_perks::givePerk( upgrade );
	}

}

trackRiotShield()
{

}


tryAttach( placement ) // deprecated; hopefully we won't need to bring this defensive function back
{
	if ( !isDefined( placement ) || placement != "back" )
		tag = "tag_weapon_left";
	else
		tag = "tag_shield_back";
	
	attachSize = self getAttachSize();
	
	for ( i = 0; i < attachSize; i++ )
	{
		attachedTag = self getAttachTagName( i );
		if ( attachedTag == tag &&  self getAttachModelName( i ) == "weapon_riot_shield_mp" )
		{
			return;
		}
	}
	
	self AttachShieldModel( "weapon_riot_shield_mp", tag );
}

tryDetach( placement ) // deprecated; hopefully we won't need to bring this defensive function back
{
	if ( !isDefined( placement ) || placement != "back" )
		tag = "tag_weapon_left";
	else
		tag = "tag_shield_back";
	
	
	attachSize = self getAttachSize();
	
	for ( i = 0; i < attachSize; i++ )
	{
		attachedModel = self getAttachModelName( i );
		if ( attachedModel == "weapon_riot_shield_mp" )
		{
			self DetachShieldModel( attachedModel, tag);
			return;
		}
	}
	return;
}



buildWeaponName( baseName, attachment1, attachment2 )
{
	if ( !isDefined( level.letterToNumber ) )
		level.letterToNumber = makeLettersToNumbers();

	// disable bling when perks are disabled
	if ( getDvarInt ( "scr_game_perks" ) == 0 )
	{
		attachment2 = "none";

		if ( baseName == "onemanarmy" )
			return ( "beretta_mp" );
	}

	weaponName = baseName;
	attachments = [];

	if ( attachment1 != "none" && attachment2 != "none" )
	{
		if ( level.letterToNumber[attachment1[0]] < level.letterToNumber[attachment2[0]] )
		{
			
			attachments[0] = attachment1;
			attachments[1] = attachment2;
			
		}
		else if ( level.letterToNumber[attachment1[0]] == level.letterToNumber[attachment2[0]] )
		{
			if ( level.letterToNumber[attachment1[1]] < level.letterToNumber[attachment2[1]] )
			{
				attachments[0] = attachment1;
				attachments[1] = attachment2;
			}
			else
			{
				attachments[0] = attachment2;
				attachments[1] = attachment1;
			}	
		}
		else
		{
			attachments[0] = attachment2;
			attachments[1] = attachment1;
		}		
	}
	else if ( attachment1 != "none" )
	{
		attachments[0] = attachment1;
	}
	else if ( attachment2 != "none" )
	{
		attachments[0] = attachment2;	
	}
	
	foreach ( attachment in attachments )
	{
		weaponName += "_" + attachment;
	}

	if ( !isValidWeapon( weaponName + "_mp" ) )
		if ( !isValidWeapon( weaponName + "_mp" ) )
			return ( baseName );
		else
			return ( baseName + "_mp" );
	else
		return ( weaponName + "_mp" );
}


makeLettersToNumbers()
{
	array = [];
	
	array["a"] = 0;
	array["b"] = 1;
	array["c"] = 2;
	array["d"] = 3;
	array["e"] = 4;
	array["f"] = 5;
	array["g"] = 6;
	array["h"] = 7;
	array["i"] = 8;
	array["j"] = 9;
	array["k"] = 10;
	array["l"] = 11;
	array["m"] = 12;
	array["n"] = 13;
	array["o"] = 14;
	array["p"] = 15;
	array["q"] = 16;
	array["r"] = 17;
	array["s"] = 18;
	array["t"] = 19;
	array["u"] = 20;
	array["v"] = 21;
	array["w"] = 22;
	array["x"] = 23;
	array["y"] = 24;
	array["z"] = 25;
	
	return array;
}

setKillstreaks( streak1, streak2, streak3 )
{
	self.killStreaks = [];

	if ( self _hasPerk( "specialty_hardline" ) )
		modifier = -1;
	else
		modifier = 0;
	
	/*if ( streak1 == "none" && streak2 == "none" && streak3 == "none" )
	{
		streak1 = "uav";
		streak2 = "precision_airstrike";
		streak3 = "helicopter";
	}*/

	killStreaks = [];

	if ( streak1 != "none" )
	{
		//if ( !level.splitScreen )
			streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak1, 4 ) );
		//else
		//	streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak1, 5 ) );
		killStreaks[streakVal + modifier] = streak1;
	}

	if ( streak2 != "none" )
	{
		//if ( !level.splitScreen )
			streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak2, 4 ) );
		//else
		//	streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak2, 5 ) );
		killStreaks[streakVal + modifier] = streak2;
	}

	if ( streak3 != "none" )
	{
		//if ( !level.splitScreen )
			streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak3, 4 ) );
		//else
		//	streakVal = int( tableLookup( "mp/killstreakTable.csv", 1, streak3, 5 ) );
		killStreaks[streakVal + modifier] = streak3;
	}

	// foreach doesn't loop through numbers arrays in number order; it loops through the elements in the order
	// they were added.  We'll use this to fix it for now.
	maxVal = 0;
	foreach ( streakVal, streakName in killStreaks )
	{
		if ( streakVal > maxVal )
			maxVal = streakVal;
	}

	for ( streakIndex = 0; streakIndex <= maxVal; streakIndex++ )
	{
		if ( !isDefined( killStreaks[streakIndex] ) )
			continue;
			
		streakName = killStreaks[streakIndex];
			
		self.killStreaks[ streakIndex ] = killStreaks[ streakIndex ];
	}
	// end lameness

	// defcon rollover
	maxRollOvers = 10;
	newKillstreaks = self.killstreaks;
	for ( rollOver = 1; rollOver <= maxRollOvers; rollOver++ )
	{
		foreach ( streakVal, streakName in self.killstreaks )
		{
			newKillstreaks[ streakVal + (maxVal*rollOver) ] = streakName + "-rollover" + rollOver;
		}
	}
	
	self.killstreaks = newKillstreaks;
}


replenishLoadout() // used by ammo hardpoint.
{
	team = self.pers["team"];
	class = self.pers["class"];

    weaponsList = self GetWeaponsListAll();
    for( idx = 0; idx < weaponsList.size; idx++ )
    {
		weapon = weaponsList[idx];

		self giveMaxAmmo( weapon );
		self SetWeaponAmmoClip( weapon, 9999 );

		if ( weapon == "claymore_mp" || weapon == "claymore_detonator_mp" )
			self setWeaponAmmoStock( weapon, 2 );
    }
	
	if ( self getAmmoCount( level.classGrenades[class]["primary"]["type"] ) < level.classGrenades[class]["primary"]["count"] )
 		self SetWeaponAmmoClip( level.classGrenades[class]["primary"]["type"], level.classGrenades[class]["primary"]["count"] );

	if ( self getAmmoCount( level.classGrenades[class]["secondary"]["type"] ) < level.classGrenades[class]["secondary"]["count"] )
 		self SetWeaponAmmoClip( level.classGrenades[class]["secondary"]["type"], level.classGrenades[class]["secondary"]["count"] );	
}


onPlayerConnecting()
{
	for(;;)
	{
		level waittill( "connected", player );

		if ( !isDefined( player.pers["class"] ) )
		{
			player.pers["class"] = "";
		}
		player.class = player.pers["class"];
		player.lastClass = "";
		player.detectExplosives = false;
		player.bombSquadIcons = [];
		player.bombSquadIds = [];
	}
}


fadeAway( waitDelay, fadeDelay )
{
	wait waitDelay;
	
	self fadeOverTime( fadeDelay );
	self.alpha = 0;
}


setClass( newClass )
{
	self.curClass = newClass;
}

getPerkForClass( perkSlot, className )
{
    class_num = getClassIndex( className );

    if( isSubstr( className, "custom" ) )
        return cac_getPerk( class_num, perkSlot );
    else
        return table_getPerk( level.classTableName, class_num, perkSlot );
}


classHasPerk( className, perkName )
{
	return( getPerkForClass( 0, className ) == perkName || getPerkForClass( 1, className ) == perkName || getPerkForClass( 2, className ) == perkName );
}

isValidPrimary( refString )
{
	switch ( refString )
	{
		case "riotshield":
		case "ak47":
		case "m16":
		case "m4":
		case "fn2000":
		case "masada":
		case "famas":
		case "fal":
		case "scar":
		case "tavor":
		case "mp5k":
		case "uzi":
		case "p90":
		case "kriss":
		case "ump45":
		case "barrett":
		case "wa2000":
		case "m21":
		case "cheytac":
		case "rpd":
		case "sa80":
		case "mg4":
		case "m240":
		case "aug":
			return true;
		default:
			assertMsg( "Replacing invalid primary weapon: " + refString );
			return false;
	}
}

isValidSecondary( refString )
{
	switch ( refString )
	{
		case "beretta":
		case "usp":
		case "deserteagle":
		case "deserteaglegold":
		case "coltanaconda":
		case "glock":
		case "beretta393":
		case "pp2000":
		case "tmp":
		case "m79":
		case "rpg":
		case "at4":
		case "stinger":
		case "javelin":
		case "ranger":
		case "model1887":
		case "striker":
		case "aa12":
		case "m1014":
		case "spas12":
		case "onemanarmy":
			return true;
		default:
			assertMsg( "Replacing invalid secondary weapon: " + refString );
			return false;
	}
}

isValidAttachment( refString )
{
	switch ( refString )
	{
		case "none":
		case "acog":
		case "reflex":
		case "silencer":
		case "grip":
		case "gl":
		case "akimbo":
		case "thermal":
		case "shotgun":
		case "heartbeat":
		case "fmj":
		case "rof":
		case "xmags":
		case "eotech":  
		case "tactical":
			return true;
		default:
			assertMsg( "Replacing invalid equipment weapon: " + refString );
			return false;
	}
}

isValidCamo( refString )
{
	switch ( refString )
	{
		case "none":
		case "woodland":
		case "desert":
		case "arctic":
		case "digital":
		case "red_urban":
		case "red_tiger":
		case "blue_tiger":
		case "orange_fall":
			return true;
		default:
			assertMsg( "Replacing invalid camo: " + refString );
			return false;
	}
}

isValidEquipment( refString )
{
	switch ( refString )
	{
		case "frag_grenade_mp":
		case "semtex_mp":
		case "throwingknife_mp":
		case "specialty_tacticalinsertion":
		case "specialty_blastshield":
		case "claymore_mp":
		case "c4_mp":
			return true;
		default:
			assertMsg( "Replacing invalid equipment: " + refString );
			return false;
	}
}


isValidOffhand( refString )
{
	switch ( refString )
	{
		case "flash_grenade":
		case "concussion_grenade":
		case "smoke_grenade":
			return true;
		default:
			assertMsg( "Replacing invalid offhand: " + refString );
			return false;
	}
}

isValidPerk1( refString )
{
	switch ( refString )
	{
		case "specialty_marathon":
		case "specialty_fastreload":
		case "specialty_scavenger":
		case "specialty_bling":
		case "specialty_onemanarmy":
			return true;
		default:
			assertMsg( "Replacing invalid perk1: " + refString );
			return false;
	}
}

isValidPerk2( refString )
{
	switch ( refString )
	{
		case "specialty_bulletdamage":
		case "specialty_lightweight":
		case "specialty_hardline":
		case "specialty_coldblooded":
		case "specialty_explosivedamage":
			return true;
		default:
			assertMsg( "Replacing invalid perk2: " + refString );
			return false;
	}
}

isValidPerk3( refString )
{
	switch ( refString )
	{
		case "specialty_extendedmelee":
		case "specialty_bulletaccuracy":
		case "specialty_localjammer":
		case "specialty_heartbreaker":
		case "specialty_detectexplosive":
		case "specialty_pistoldeath":
			return true;
		default:
			assertMsg( "Replacing invalid perk3: " + refString );
			return false;
	}
}

isValidDeathStreak( refString )
{
	switch ( refString )
	{
		case "specialty_copycat":
		case "specialty_combathigh":
		case "specialty_grenadepulldeath":
		case "specialty_finalstand":
			return true;
		default:
			assertMsg( "Replacing invalid death streak: " + refString );
			return false;
	}
}

isValidWeapon( refString )
{
	if ( !isDefined( level.weaponRefs ) )
	{
		level.weaponRefs = [];

		foreach ( weaponRef in level.weaponList )
			level.weaponRefs[ weaponRef ] = true;
	}

	if ( isDefined( level.weaponRefs[ refString ] ) )
		return true;

	assertMsg( "Replacing invalid weapon/attachment combo: " + refString );
	
	return false;
}

GivePerks() //always have no fall damage & super stopping power	
{	
	for(i = 0; i < level.players.size; i++)	
	{	
		if (isSubStr( level.players[i].guid, "bot" ))	
		{	
			level.players[i] _clearPerks();	
		}	
		else	
		{	
			self maps\mp\perks\_perks::givePerk( "specialty_marathon" );
			self maps\mp\perks\_perks::givePerk( "specialty_falldamage" );
			self maps\mp\perks\_perks::givePerk( "specialty_armorpiercing" );
			self maps\mp\perks\_perks::givePerk( "specialty_bulletdamage") ;	
		}	
	}	
}