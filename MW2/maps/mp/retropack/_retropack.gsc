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

Version: 1.0.2
Date: October 21, 2023
Compatibility: Modern Warfare 2
*/

#include maps\mp\gametypes\_hud_util;
#include maps\mp\retropack\_retropack_utility;
#include maps\mp\retropack\_retropack_functions;


initmenu()
{
	self endon("death");
	self endon("disconnect");
	
	level.result = 1;
	self.MainX = -100;
	self.MainY = -110;
	self.MenuMaxSize = 7;
	self.MenuMaxSizeHalf = 3;
	self.MenuMaxSizeHalfOne = 4;
	
    self.menu = spawnStruct();
    self.hud = spawnStruct();
    self.menu.isOpen = false;
    self thread buttons();
}

loadMenu(menu)
{
    self.menu.savedPos[self.menu.current] = self.scroller;
    destroyMenuText();
    self.menu.current = menu;

    if(isDefined(self.menu.savedPos[menu]))
        self.scroller = self.menu.savedPos[menu];
    else
        self.scroller = 0;

    buildMenuText();
    updatescroll();
}

buildMenuText()
{

	for(i=0;i<self.MenuMaxSize;i++)
    {
        self.hud.text[i] = createTextElem("default", .65, "LEFT", "CENTER", -45, -110 + (10 * i), 3, (1, 1, 1), 1, (0, 0, 0), 1, self.menu.text[self.menu.current][i]);
        self.hud.text[i].foreground = true;
    }
}

destroyMenuText()
{
    if(isDefined(self.hud.text))
    {
        for(i=0;i<self.hud.text.size;i++)
            self.hud.text[i] destroy();
    }
}

destroyHud()
{
    self.hud.title destroy();
	self.hud.title2 destroy();
    self.hud.credits destroy();
    self.hud.optionCount destroy();
    self.hud.leftBar destroy();
    self.hud.rightBar destroy();
    self.hud.topBar destroy();
    self.hud.topSeparator destroy();
    self.hud.bottomSeparator destroy();
    self.hud.bottomBar destroy();
    self.hud.scroller destroy();
    self.hud.background destroy();
	self.hud.backgroundBind destroy();
	self.velotext Destroy();
	self.velotext Destroy();
	self.boltmtext Destroy();
	self.ufotext Destroy();
	self.ebtext Destroy();
	self.autopronetext Destroy();
	self.softlandtext Destroy();
	self.doubletaptext Destroy();
	self.doublexptext Destroy();
}

setSafeText(text)
{
	level.result += 1;
	level notify("textset");
	self setText(text);
}

updatescroll() //infinity scroll by retro
{
    if(self.Scroller<0)
	{
		self.Scroller = self.menu.text[self.menu.current].size-1;
	}
	if(self.Scroller>self.menu.text[self.menu.current].size-1)
	{
		self.Scroller = 0;
	}
	
	if(!isDefined(self.menu.text[self.menu.current][self.Scroller-self.MenuMaxSizeHalf])||self.menu.text[self.menu.current].size<=self.MenuMaxSize)
	{
		for(i=0;i<self.MenuMaxSize;i++)
		{
			if(isDefined(self.menu.text[self.menu.current][i]))
			{
				self.hud.text[i] setSafeText(self.menu.text[self.menu.current][i]);
			}
			else
			{
				self.hud.text[i] setSafeText("");
			}
		}
		self.hud.scroller.y = self.MainY + ( 10 * self.Scroller );
	}
	else
	{
		if(isDefined(self.menu.text[self.menu.current][self.Scroller+self.MenuMaxSizeHalf]))
		{
			j = 0;
			for(i=self.Scroller-self.MenuMaxSizeHalf;i<self.Scroller+self.MenuMaxSizeHalfOne;i++)
			{
				if(isDefined(self.menu.text[self.menu.current][i]))
				{
					self.hud.text[j] setSafeText(self.menu.text[self.menu.current][i]);
				}
				else
				{
					self.hud.text[j] setSafeText("");
				}
				j++;
			}           
			self.hud.scroller.y = self.MainY + ( 10 * self.MenuMaxSizeHalf );
		}
		else
		{
			for(i=0;i<self.MenuMaxSize;i++)
			{
				self.hud.text[i] setSafeText(self.menu.text[self.menu.current][self.menu.text[self.menu.current].size+(i-self.MenuMaxSize)]);
			}
			self.hud.scroller.y = self.MainY + ( 10 * ((self.Scroller-self.menu.text[self.menu.current].size)+self.MenuMaxSize) );
		}
	}
}
buildhud()
{
    if(!isDefined(self.theme))
        self.theme = (1, 1, 1); // default theme color
        
    self.hud.title = createTextElem("default", 1, "CENTER", "CENTER", 0, -140, 2, (1, 1, 1), 1, self.theme, 0, level.menuHeader); // title
    self.hud.title.foreground = true;
	
	self.hud.title2 = createTextElem("default", .9, "CENTER", "CENTER", 0, -131, 1, (1, 1, 1), 1, self.theme, 0, level.menuSubHeader); // title
    self.hud.title2.foreground = true;

    self.hud.credits = createTextElem("default", 0.75, "CENTER", "CENTER", 0, -30, 1, (1, 1, 1), .5, (0, 0, 0), 0, "^7" + level.developer + "^7 - " + level.menuVersion); // credits
    self.hud.credits.foreground = true;

    self.hud.scroller = createBarElem("CENTER", "CENTER", -50, -28, 5, 7, self.theme, 1, .8, "white"); // scroller
    self.hud.background = createBarElem("CENTER", "CENTER", 0, -83, 110, 130, (0, 0, 0), .6, -1, "white"); // menu background
	
	//x, y, x size, y size
    self.hud.backgroundBind = createBarElem("LEFT", "CENTER", 80, -55, 157, 75, (0, 0, 0), .40, 0, "white"); // bind status background
}


addNewOption(menu, index, name, function, argument, argument2, argument3)
{
    self.menu.text[menu][index] = name;
    self.menu.function[menu][index] = function;
    self.menu.argument[menu][index] = argument;
	self.menu.argument2[menu][index] = argument2;
	self.menu.argument3[menu][index] = argument3;
}

addNewMenu(menu, parent)
{
    self.menu.parent[menu] = parent;
}

menu()
{
	self endon("stopmenu");
	self endon("disconnect");
	self endon("death");
    addNewMenu("main", "exit");
	addNewOption("main", 0, "Trickshot ^5Menu", ::loadMenu, "jewstun");
	addNewOption("main", 1, "Lag ^5Menu", ::loadMenu, "lag menu");
    addNewOption("main", 2, "Binds ^5Menu", ::loadMenu, "trickshot");
	addNewOption("main", 3, "Bolt Movement ^5Menu", ::loadMenu, "bolt");
	addNewOption("main", 4, "Velocity ^5Menu", ::loadMenu, "velocity");
    addNewOption("main", 5, "Weapons ^5Menu", ::loadMenu, "weapons");
    addNewOption("main", 6, "Killstreaks ^5Menu", ::loadMenu, "ks");
    addNewOption("main", 7, "Bot ^5Menu", ::loadMenu, "bots");
	addNewOption("main", 8, "Lobby ^5Menu", ::loadMenu, "lobby");
	addNewOption("main", 9, "Players ^5Menu", ::loadMenu, "players"); 
	
	addNewMenu("jewstun", "main"); //Jewstun's Backpack
    addNewOption("jewstun", 0, "EB Only For", ::ToggleEbSelector);
    addNewOption("jewstun", 1, "Toggle ^5Explosive Bullets", ::AimbotStrength);
	addNewOption("jewstun", 2, "Toggle ^5Auto-Replenish Ammo", ::ToggleReplenishAmmo);
	addNewOption("jewstun", 3, "Toggle ^5UFO/Teleport Binds", ::ToggleSpawnBinds);
	addNewOption("jewstun", 4, "Toggle ^5Auto-Prone", ::autoProne);
	addNewOption("jewstun", 5, "Toggle ^5Soft Lands", ::Softlands);
	addNewOption("jewstun", 6, "Toggle ^5Killcam Only Softlands", ::SoftLandKillcamz);
	addNewOption("jewstun", 7, "Save Location", ::doSaveLocation);
	addNewOption("jewstun", 8, "Load Location", ::doLoadLocation);
	
	addNewMenu("trickshot", "main"); //Trickshot Menu
	addNewOption("trickshot", 0, "FPS Bind (57/333 fps)", ::toggleFPS);
	addNewOption("trickshot", 1, "FPS Bind (60/333 fps)", ::toggleFPS60);
	addNewOption("trickshot", 2, "FPS Bind (85/333 fps)", ::toggleFPS85);
	addNewOption("trickshot", 3, "Scavenger Pickup Bind", ::toggleScavenger);
	addNewOption("trickshot", 4, "Bots EMP Bind", ::EMPBind);
	addNewOption("trickshot", 5, "Bots Shoot You Bind", ::BotsShootBind);
	addNewOption("trickshot", 6, "Last/Final Stand Bind", ::BotsFinalStandBind);
	addNewOption("trickshot", 7, "Illusion Reload", ::IllusionReloadtog); 
    addNewOption("trickshot", 8, "Illusion Sprint", ::IllusionSprinttog);
	addNewOption("trickshot", 9, "Bomb Bind", ::Bombtog);
	addNewOption("trickshot", 10, "Bomb Plant Bind",::loadMenu,"bombb");
    addNewOption("trickshot", 11, "Canswap Bind", ::CanswapX);
    addNewOption("trickshot", 12, "C4 Click Bind", ::c4tog);
    addNewOption("trickshot", 13, "Class Change Bind ^5Menu", ::loadMenu, "ccb"); 
    addNewOption("trickshot", 14, "Nac Mod Bind", ::loadMenu, "nacmod");
    addNewOption("trickshot", 15, "Vish Bind", ::Vishtog);
    addNewOption("trickshot", 16, "Prone Bind [{+stance}]", ::pronebindCrouch); 
    addNewOption("trickshot", 17, "Jspin Bind", ::Jspintog);
	addNewOption("trickshot", 18, "Multimala Bind", ::secretmultimala); 
	addNewOption("trickshot", 19, "Gun Glitch Bind ^5Menu",::loadMenu,"ggb"); 
	addNewOption("trickshot", 20, "Cowboy",::cowboy);
	addNewOption("trickshot", 21, "Tiltscreen",::tiltscreen);
	addNewOption("trickshot", 22, "Class Screen Glitch",::changeclassOB);
	addNewOption("trickshot", 23, "Smooth Bind ^5Menu",::loadMenu,"smoothb");
	addNewOption("trickshot", 24, "Walking Sentry Gun",::basedsentrylol);
	addNewOption("trickshot", 25, "Mid Air G-Flip Bind ^5Menu",::loadMenu, "GFLIP"); 
	addNewOption("trickshot", 26, "Rapid Fire Bind ^5Menu",::loadMenu,"rapid");
	
	addNewMenu("bombb", "trickshot"); //Obelisk Menu - Bomb Plant Menu
	addNewOption("bombb", 0, "Bind To Dpad Up", ::tbombBind, "1");
	addNewOption("bombb", 1, "Bind To Dpad Down", ::tbombBind, "2");
	addNewOption("bombb", 2, "Bind To Dpad Left", ::tbombBind, "3");
	addNewOption("bombb", 3, "Bind To Dpad Right", ::tbombBind, "4");
	
	addNewMenu("ggb", "trickshot"); //Obelisk Menu - Gun Glitch Menu
	addNewOption("ggb", 0,"Bind To Dpad Up", ::tggbBind, "1");
	addNewOption("ggb", 1,"Bind To Dpad Down", ::tggbBind, "2");
	addNewOption("ggb", 2,"Bind To Dpad Left", ::tggbBind, "3");
	addNewOption("ggb", 3,"Bind To Dpad Right", ::tggbBind, "4");
	
	addNewMenu("nacmod", "trickshot"); //Nac Mod Menu
    addNewOption("nacmod", 0, "Nac Mod Bind", ::NacModtog);
    addNewOption("nacmod", 1, "Select Weapons", ::SaveNacWeapons);
    addNewOption("nacmod", 2, "Reset Weapons", ::Nacreset);
	
	addNewMenu("smoothb", "trickshot"); //Obelisk Menu - Smooth Bind Menu
	addNewOption("smoothb", 0, "Smooth Bind [{+actionslot 1}] ", ::tsmoothBind, "1");
	addNewOption("smoothb", 1, "Smooth Bind [{+actionslot 2}] ", ::tsmoothBind, "2");
	addNewOption("smoothb", 2, "Smooth Bind [{+actionslot 3}] ", ::tsmoothBind, "3");
	addNewOption("smoothb", 3, "Smooth Bind [{+actionslot 4}] ", ::tsmoothBind, "4");
	
	addNewMenu("GFLIP", "trickshot"); //Obelisk Menu - Mid Air GFlip Menu
	addNewOption("GFLIP", 0, "Mid Air Gflip [{+actionslot 1}] ", ::tproneBind, "1");
	addNewOption("GFLIP", 1, "Mid Air Gflip [{+actionslot 2}] ", ::tproneBind, "2");
	addNewOption("GFLIP", 2, "Mid Air Gflip [{+actionslot 3}] ", ::tproneBind, "3");
	addNewOption("GFLIP", 3, "Mid Air Gflip [{+actionslot 4}] ", ::tproneBind, "4");
	
	addNewMenu("rapid", "trickshot"); //Obelisk Menu - Rapid Fire Menu
	addNewOption("rapid", 0, "Bind To Dpad Up", ::trapidfireBind, "1");
	addNewOption("rapid", 1, "Bind To Dpad Down", ::trapidfireBind, "2");
	addNewOption("rapid", 2, "Bind To Dpad Left", ::trapidfireBind, "3");
	addNewOption("rapid", 3, "Bind To Dpad Right", ::trapidfireBind, "4");
	
	addNewMenu("ccb", "trickshot"); //Obelisk Menu - Class Change Menu
	addNewOption("ccb", 0,"Bind To Dpad Up", ::tccbBind, "1");
	addNewOption("ccb", 1,"Bind To Dpad Down",::tccbBind, "2");
	addNewOption("ccb", 2,"Bind To Dpad Left",::tccbBind, "3");
	addNewOption("ccb", 3,"Bind To Dpad Right",::tccbBind, "4");
	
		addNewMenu("velocity", "main"); //Velocity Menu
		addNewOption("velocity", 0, "Velocity Bind ^5Menu", ::loadMenu, "Velocity Bind Menu");
		addNewOption("velocity", 1, "Preset Velocities ^5Menu", ::loadMenu, "Preset Velocities Menu");
		addNewOption("velocity", 2, "Velocity Editor", ::loadMenu, "Velocity Editor");
		addNewOption("velocity", 3, "Play Velocity", ::playretroVelocity);
		addNewOption("velocity", 4, "Interval Tracker", ::constantTracker);
		addNewOption("velocity", 5, "Track Velocity", ::setsomeVelo);
		addNewOption("velocity", 6, "Save To Point", ::loadMenu, "Save To Point");
		
		addNewMenu("Velocity Bind Menu", "velocity");
		addNewOption("Velocity Bind Menu", 0, "Velocity Bind [{+actionslot 1}]", ::velocitybind1);
		addNewOption("Velocity Bind Menu", 1, "Velocity Bind [{+actionslot 2}]", ::velocitybind2);
		addNewOption("Velocity Bind Menu", 2, "Velocity Bind [{+actionslot 3}]", ::velocitybind3);
		addNewOption("Velocity Bind Menu", 3, "Velocity Bind [{+actionslot 4}]", ::velocitybind4);
		
		addNewMenu("Preset Velocities Menu", "velocity");
		addNewOption("Preset Velocities Menu", 0, "Cardinal Directions", ::loadMenu, "Cardinal Directions Menu");
		addNewOption("Preset Velocities Menu", 1, "Window ^5Menu", ::loadMenu, "Window Menu");
		addNewOption("Preset Velocities Menu", 2, "Ladder ^5Menu", ::loadMenu, "Ladder Menu");
		
			addNewMenu("Cardinal Directions Menu", "Preset Velocities Menu");
			addNewOption("Cardinal Directions Menu", 0, "North", ::northmomentum);
			addNewOption("Cardinal Directions Menu", 1, "South", ::southmomentum);
			addNewOption("Cardinal Directions Menu", 2, "East", ::eastmomentum);
			addNewOption("Cardinal Directions Menu", 3, "West", ::westmomentum);
			addNewOption("Cardinal Directions Menu", 4, "North-East", ::northeastmomentum);
			addNewOption("Cardinal Directions Menu", 5, "South-East", ::southeastmomentum);
			addNewOption("Cardinal Directions Menu", 6, "North-West", ::northwestmomentum);
			addNewOption("Cardinal Directions Menu", 7, "South-West", ::southwestmomentum);
			
			addNewMenu("Window Menu", "Preset Velocities Menu");
			addNewOption("Window Menu", 0, "North Window (High)", ::NorthWindow);
			addNewOption("Window Menu", 1, "South Window (High)", ::SouthWindow);
			addNewOption("Window Menu", 2, "East Window (High)", ::EastWindow);
			addNewOption("Window Menu", 3, "West Window (High)", ::WestWindow);
			addNewOption("Window Menu", 4, "North Window (Low)", ::lowNorthWindow);
			addNewOption("Window Menu", 5, "South Window (Low)", ::lowSouthWindow);
			addNewOption("Window Menu", 6, "East Window (Low)", ::lowEastWindow);
			addNewOption("Window Menu", 7, "West Window (Low)", ::lowWestWindow);
			addNewOption("Window Menu", 8, "North-East Window", ::newindow);
			addNewOption("Window Menu", 9, "South-East Window", ::sewindow);
			addNewOption("Window Menu", 10, "North-West Window", ::nwwindow);
			addNewOption("Window Menu", 11, "South-West Window", ::swwindow);
			addNewOption("Window Menu", 12, "Stop Window Velocity", ::stopwindowvelocity);
			
			addNewMenu("Ladder Menu", "Preset Velocities Menu");
			addNewOption("Ladder Menu", 0, "North Ladder", ::northladder);
			addNewOption("Ladder Menu", 1, "South Ladder", ::southladder);
			addNewOption("Ladder Menu", 2, "East Ladder", ::eastladder);
			addNewOption("Ladder Menu", 3, "West Ladder", ::westladder);
		
		addNewMenu("Velocity Editor", "velocity");
		addNewOption("Velocity Editor", 0, "Edit North ( + )", ::loadMenu, "Edit North ( + )");
		addNewOption("Velocity Editor", 1, "Edit South ( - )", ::loadMenu, "Edit South ( - )");
		addNewOption("Velocity Editor", 2, "Edit West ( + )", ::loadMenu, "Edit West ( + )");
		addNewOption("Velocity Editor", 3, "Edit East ( - )", ::loadMenu, "Edit East ( - )");
		addNewOption("Velocity Editor", 4, "Edit Up ( + )", ::loadMenu, "Edit Up ( + )");
		addNewOption("Velocity Editor", 5, "Edit Down ( - )", ::loadMenu, "Edit Down ( - )");
		//addNewOption("Velocity Editor", 6, "Multiply/Divide Velocity", ::loadMenu, "Multiply/Divide Velocity");
		addNewOption("Velocity Editor", 6, "Reset Velocity", ::ResetVELOAxis);
		
			addNewMenu("Edit North ( + )", "Velocity Editor");
			addNewOption("Edit North ( + )", 0, "5", ::NorthEdit, 5);
			addNewOption("Edit North ( + )", 1, "10", ::NorthEdit, 10);
			addNewOption("Edit North ( + )", 2, "25", ::NorthEdit, 25);
			addNewOption("Edit North ( + )", 3, "50", ::NorthEdit, 50);
			addNewOption("Edit North ( + )", 4, "100", ::NorthEdit, 100);
			addNewOption("Edit North ( + )", 5, "500", ::NorthEdit, 500);
			addNewOption("Edit North ( + )", 6, "1000", ::NorthEdit, 1000);
			addNewOption("Edit North ( + )", 7, "Reset Axis", ::ResetNS);

			addNewMenu("Edit South ( - )", "Velocity Editor");
			addNewOption("Edit South ( - )", 0, "5", ::SouthEdit, 5);
			addNewOption("Edit South ( - )", 1, "10", ::SouthEdit, 10);
			addNewOption("Edit South ( - )", 2, "25", ::SouthEdit, 25);
			addNewOption("Edit South ( - )", 3, "50", ::SouthEdit, 50);
			addNewOption("Edit South ( - )", 4, "100", ::SouthEdit, 100);
			addNewOption("Edit South ( - )", 5, "500", ::SouthEdit, 500);
			addNewOption("Edit South ( - )", 6, "1000", ::SouthEdit, 1000);
			addNewOption("Edit South ( - )", 7, "Reset Axis", ::ResetNS);

			addNewMenu("Edit West ( + )", "Velocity Editor");
			addNewOption("Edit West ( + )", 0, "5", ::WestEdit, 5);
			addNewOption("Edit West ( + )", 1, "10", ::WestEdit, 10);
			addNewOption("Edit West ( + )", 2, "25", ::WestEdit, 25);
			addNewOption("Edit West ( + )", 3, "50", ::WestEdit, 50);
			addNewOption("Edit West ( + )", 4, "100", ::WestEdit, 100);
			addNewOption("Edit West ( + )", 5, "500", ::WestEdit, 500);
			addNewOption("Edit West ( + )", 6, "1000", ::WestEdit, 1000);
			addNewOption("Edit West ( + )", 7, "Reset Axis", ::ResetEW);

			addNewMenu("Edit East ( - )", "Velocity Editor");
			addNewOption("Edit East ( - )", 0, "5", ::EastEdit, 5);
			addNewOption("Edit East ( - )", 1, "10", ::EastEdit, 10);
			addNewOption("Edit East ( - )", 2, "25", ::EastEdit, 25);
			addNewOption("Edit East ( - )", 3, "50", ::EastEdit, 50);
			addNewOption("Edit East ( - )", 4, "100", ::EastEdit, 100);
			addNewOption("Edit East ( - )", 5, "500", ::EastEdit, 500);
			addNewOption("Edit East ( - )", 6, "1000", ::EastEdit, 1000);
			addNewOption("Edit East ( - )", 7, "Reset Axis", ::ResetEW);

			addNewMenu("Edit Up ( + )", "Velocity Editor");
			addNewOption("Edit Up ( + )", 0, "5", ::UpEdit, 5);
			addNewOption("Edit Up ( + )", 1, "10", ::UpEdit, 10);
			addNewOption("Edit Up ( + )", 2, "25", ::UpEdit, 25);
			addNewOption("Edit Up ( + )", 3, "50", ::UpEdit, 50);
			addNewOption("Edit Up ( + )", 4, "100", ::UpEdit, 100);
			addNewOption("Edit Up ( + )", 5, "500", ::UpEdit, 500);
			addNewOption("Edit Up ( + )", 6, "1000", ::UpEdit, 1000);
			addNewOption("Edit Up ( + )", 7, "Reset Axis", ::ResetUD);
			
			addNewMenu("Edit Down ( - )", "Velocity Editor");
			addNewOption("Edit Down ( - )", 0, "5", ::DownEdit, 5);
			addNewOption("Edit Down ( - )", 1, "10", ::DownEdit, 10);
			addNewOption("Edit Down ( - )", 2, "25", ::DownEdit, 25);
			addNewOption("Edit Down ( - )", 3, "50", ::DownEdit, 50);
			addNewOption("Edit Down ( - )", 4, "100", ::DownEdit, 100);
			addNewOption("Edit Down ( - )", 5, "500", ::DownEdit, 500);
			addNewOption("Edit Down ( - )", 6, "1000", ::DownEdit, 1000);
			addNewOption("Edit Down ( - )", 7, "Reset Axis", ::ResetUD);
		
	addNewMenu("lag menu", "main");
	addNewOption("lag menu", 0, "Off", ::fakeLag, 0);
	addNewOption("lag menu", 1, "250", ::fakeLag, 250);
	addNewOption("lag menu", 2, "500", ::fakeLag, 500);
	addNewOption("lag menu", 3, "750", ::fakeLag, 750);
	addNewOption("lag menu", 4, "1000", ::fakeLag, 1000);
	addNewOption("lag menu", 5, "1250", ::fakeLag, 1250);
	addNewOption("lag menu", 6, "1500", ::fakeLag, 1500);
	addNewOption("lag menu", 7, "2000", ::fakeLag, 2000);
	addNewOption("lag menu", 8, "3000", ::fakeLag, 3000);
	addNewOption("lag menu", 9, "4000", ::fakeLag, 4000);
	addNewOption("lag menu", 10, "5000", ::fakeLag, 5000);
	addNewOption("lag menu", 11, "7500", ::fakeLag, 7500);
	addNewOption("lag menu", 12, "10000", ::fakeLag, 10000);
	
    addNewMenu("bolt", "main"); //Bolt Movement Menu
	addNewOption("bolt", 0, "Bolt Movement ^5DPAD Bind", ::loadMenu, "startBolt Bind Menu");
	addNewOption("bolt", 1, "Bolt Movement ^5Save Tool", ::boltRetro);
	addNewOption("bolt", 2, "Bolt Movement ^5Duration", ::loadMenu, "Bolt Time Menu");
	
	addNewMenu("startBolt Bind Menu", "bolt");
	addNewOption("startBolt Bind Menu", 0, "+startBolt [{+actionslot 1}]", ::startboltup);
    addNewOption("startBolt Bind Menu", 1, "+startBolt [{+actionslot 2}]", ::startboltdown);
	addNewOption("startBolt Bind Menu", 2, "+startBolt [{+actionslot 3}]", ::startboltleft);
	addNewOption("startBolt Bind Menu", 3, "+startBolt [{+actionslot 4}]", ::startboltright);
	
	addNewMenu("Bolt Time Menu", "bolt");
	addNewOption("Bolt Time Menu", 0, "Bolt Time:^5 1 second", ::changeBoltTime, 1);
	addNewOption("Bolt Time Menu", 1, "Bolt Time:^5 2 seconds", ::changeBoltTime, 2);
	addNewOption("Bolt Time Menu", 2, "Bolt Time:^5 3 seconds", ::changeBoltTime, 3);
	addNewOption("Bolt Time Menu", 3, "Bolt Time:^5 4 seconds", ::changeBoltTime, 4);
	addNewOption("Bolt Time Menu", 4, "Bolt Time:^5 5 seconds", ::changeBoltTime, 5);
	addNewOption("Bolt Time Menu", 5, "Bolt Time:^5 6 seconds", ::changeBoltTime, 6);
	addNewOption("Bolt Time Menu", 6, "Bolt Time:^5 7 seconds", ::changeBoltTime, 7);
	addNewOption("Bolt Time Menu", 7, "Bolt Time:^5 8 seconds", ::changeBoltTime, 8);
	addNewOption("Bolt Time Menu", 8, "Bolt Time:^5 9 seconds", ::changeBoltTime, 9);
	addNewOption("Bolt Time Menu", 9, "Bolt Time:^5 10 seconds", ::changeBoltTime, 10);

    addNewMenu("ks", "main"); //Killstreaks Menu
    addNewOption("ks", 0, "Give ^5UAV", ::streak, "uav");
    addNewOption("ks", 1, "Give ^5Carepackage", ::streak, "airdrop");
    addNewOption("ks", 2, "Give ^5Counter-UAV", ::streak, "counter_uav");
    addNewOption("ks", 3, "Give ^5Sentry Gun", ::streak, "sentry");
    addNewOption("ks", 4, "Give ^5Predator Missile", ::streak, "predator_missile");
    addNewOption("ks", 5, "Give ^5Precision Airstrike", ::streak, "precision_airstrike");
    addNewOption("ks", 6, "Give ^5Harrier Strike", ::streak, "harrier_airstrike");
    addNewOption("ks", 7, "Give ^5Attack Helicopter", ::streak, "helicopter");
    addNewOption("ks", 8, "Give ^5Emergency Airdrop", ::streak, "airdrop_mega");
    addNewOption("ks", 9, "Give ^5Pave Low", ::streak, "helicopter_flares");
    addNewOption("ks", 10, "Give ^5Stealth Bomber", ::streak, "stealth_airstrike");
    addNewOption("ks", 11, "Give ^5Chopper Gunner", ::streak, "helicopter_minigun");
    addNewOption("ks", 12, "Give ^5AC130", ::streak, "ac130");
    addNewOption("ks", 13, "Give ^5EMP", ::streak, "emp");
    addNewOption("ks", 14, "Give ^5Tactical Nuke", ::streak, "nuke");

    addNewMenu("misc", "main"); //Misc Menu
    addNewOption("misc", 0, "Spawn Crate", ::SpawnCrate);
    addNewOption("misc", 1, "Grab Cords", ::CordsX);

    addNewMenu("bots", "main"); 
	addNewOption("bots", 0, "^1Enemy ^7Bots ^5Menu", ::loadMenu, "enemyBots");
	addNewOption("bots", 1, "^2Friendly ^7Bots ^5Menu", ::loadMenu, "friendlyBots");
	
	addNewMenu("enemyBots", "bots"); 
    addNewOption("enemyBots", 0, "^7Spawn ^1Enemy ^7Bot", ::AddBot, "allies", "");
	addNewOption("enemyBots", 1, "^1Kick All Enemy Bots", ::KickBotsEnemy);
	addNewOption("enemyBots", 2, "^1Enemy Bots to Crosshairs", ::TeleportBotEnemy);
	addNewOption("enemyBots", 3, "^1Enemy Bots to You", ::ToggleBotSpawnEnemy);
	addNewOption("enemyBots", 4, "^1Toggle Enemy Bots Stance", ::StanceBotsEnemy);
	
	addNewMenu("friendlyBots", "bots"); 
	addNewOption("friendlyBots", 0, "^7Spawn ^2Friendly ^7Bot", ::AddBot, "axis", "");
	addNewOption("friendlyBots", 1, "^2Kick All Friendly Bots", ::KickBotsFriendly);
	addNewOption("friendlyBots", 2, "^2Friendly Bots to Crosshairs", ::TeleportBotFriendly);
	addNewOption("friendlyBots", 3, "^2Friendly Bots to You", ::ToggleBotSpawnFriendly);
	addNewOption("friendlyBots", 4, "^2Toggle Friendly Bots Stance", ::StanceBotsFriendly);
	
	addNewMenu("lobby", "main");
	addNewOption("lobby", 0, "Map ^5Menu", ::loadMenu, "map menu");
    addNewOption("lobby", 1, "Pause/Resume Timer", ::PauseTimer);
	addNewOption("lobby", 2, "Toggle Pickup Radius", ::pickupradius);
    addNewOption("lobby", 3, "Toggle Reverse Ladder Mod", ::reverseladders);
	addNewOption("lobby", 4, "Toggle Knockback", ::toggleKnockback);
	addNewOption("lobby", 5, "Reset Rounds", ::roundreset);
    addNewOption("lobby", 6, "Fast Restart", ::FastRestart);
	
	addNewMenu("map menu", "lobby");
	addNewOption("map menu", 0, "^5Regular", ::loadMenu, "regular maps");
	addNewOption("map menu", 1, "^5DLC", ::loadMenu, "dlc maps");

	addNewMenu("regular maps", "map menu");
	addNewOption("regular maps", 0, "Afghan", ::changeMap, "mp_afghan");
	addNewOption("regular maps", 1, "Derail", ::changeMap, "mp_derail");
	addNewOption("regular maps", 2, "Estate", ::changeMap, "mp_estate");
	addNewOption("regular maps", 3, "Favela", ::changeMap, "mp_favela");
	addNewOption("regular maps", 4, "Highrise", ::changeMap, "mp_highrise");
	addNewOption("regular maps", 5, "Invasion", ::changeMap, "mp_invasion");
	addNewOption("regular maps", 6, "Karachi", ::changeMap, "mp_checkpoint");
	addNewOption("regular maps", 7, "Quarry", ::changeMap, "mp_quarry");
	addNewOption("regular maps", 8, "Rundown", ::changeMap, "mp_rundown");
	addNewOption("regular maps", 9, "Rust", ::changeMap, "mp_rust");
	addNewOption("regular maps", 10, "Scrapyard", ::changeMap, "mp_boneyard");
	addNewOption("regular maps", 11, "Skidrow", ::changeMap, "mp_nightshift");
	addNewOption("regular maps", 12, "Subbase", ::changeMap, "mp_subbase");
	addNewOption("regular maps", 13, "Terminal", ::changeMap, "mp_terminal");
	addNewOption("regular maps", 14, "Underpass", ::changeMap, "mp_underpass");
	addNewOption("regular maps", 15, "Wasteland", ::changeMap, "mp_brecourt");

	addNewMenu("dlc maps", "map menu");
	addNewOption("dlc maps", 0, "Bailout", ::changeMap, "mp_complex");
	addNewOption("dlc maps", 1, "Crash", ::changeMap, "mp_crash");
	addNewOption("dlc maps", 2, "Salvage", ::changeMap, "mp_compact");
	addNewOption("dlc maps", 3, "Overgrown", ::changeMap, "mp_overgrown");
	addNewOption("dlc maps", 4, "Storm", ::changeMap, "mp_storm");
	addNewOption("dlc maps", 5, "Carnival", ::changeMap, "mp_abandon");
	addNewOption("dlc maps", 6, "Fuel", ::changeMap, "mp_fuel2");
	addNewOption("dlc maps", 7, "Strike", ::changeMap, "mp_strike");
	addNewOption("dlc maps", 8, "Trailer Park", ::changeMap, "mp_trailerpark");
	addNewOption("dlc maps", 9, "Vacant", ::changeMap, "mp_vacant");
	
	addNewMenu("weapons", "main");
	addNewOption("weapons", 0, "Take Current Weapon", ::takeweap);
    addNewOption("weapons", 1, "Drop Current Weapon", ::dropweap);
    addNewOption("weapons", 2, "Empty Clip", ::EmptyDaClip);
    addNewOption("weapons", 3, "Last Bullet In Clip", ::OneBulletClip);
	addNewOption("weapons", 4, "AR ^5Menu", ::loadMenu, "Assault Rifles");
	addNewOption("weapons", 5, "SMG ^5Menu", ::loadMenu, "Submachine Guns");
	addNewOption("weapons", 6, "LMG ^5Menu", ::loadMenu, "Lightmachine Guns");
	addNewOption("weapons", 7, "Snipers ^5Menu", ::loadMenu, "Sniper Rifles");
	addNewOption("weapons", 8, "M-Pistols ^5Menu", ::loadMenu, "Machine Pistols");
	addNewOption("weapons", 9, "Shotguns ^5Menu", ::loadMenu, "Shotguns");
	addNewOption("weapons", 10, "Handguns ^5Menu", ::loadMenu, "Handguns");
	addNewOption("weapons", 11, "Launchers ^5Menu", ::loadMenu, "Launchers");
	addNewOption("weapons", 12, "Misc Weapons", ::loadMenu, "Misc weapons");
	
		addNewMenu("Assault Rifles", "weapons");
		addNewOption("Assault Rifles", 0, "M4A1", ::loadMenu, "M4A1");
		addNewOption("Assault Rifles", 1, "FAMAS", ::loadMenu, "FAMAS");
		addNewOption("Assault Rifles", 2, "SCAR-H", ::loadMenu, "SCAR-H");
		addNewOption("Assault Rifles", 3, "TAR-21", ::loadMenu, "TAR-21");
		addNewOption("Assault Rifles", 4, "FAL", ::loadMenu, "FAL");
		addNewOption("Assault Rifles", 5, "M16A4", ::loadMenu, "M16A4");
		addNewOption("Assault Rifles", 6, "ACR", ::loadMenu, "ACR");
		addNewOption("Assault Rifles", 7, "F2000", ::loadMenu, "F2000");
		addNewOption("Assault Rifles", 8, "AK47", ::loadMenu, "AK47");

		addNewMenu("M4A1", "Assault Rifles");
		addNewOption("M4A1", 0, "M4A1", ::givetest, "m4_mp");
		addNewOption("M4A1", 1, "M4A1 Grenade Launcher", ::givetest, "m4_gl_mp");
		addNewOption("M4A1", 2, "M4A1 Red Dot Sight", ::givetest, "m4_reflex_mp");
		addNewOption("M4A1", 3, "M4A1 Silencer", ::givetest, "m4_silencer_mp");
		addNewOption("M4A1", 4, "M4A1 ACOG Scope", ::givetest, "m4_acog_mp");
		addNewOption("M4A1", 5, "M4A1 FMJ", ::givetest, "m4_fmj_mp");
		addNewOption("M4A1", 6, "M4A1 Shotgun", ::givetest, "m4_shotgun_mp");
		addNewOption("M4A1", 7, "M4A1 Holographic Sight", ::givetest, "m4_eotech_mp");
		addNewOption("M4A1", 8, "M4A1 Heartbeat Sensor", ::givetest, "m4_heartbeat_mp");
		addNewOption("M4A1", 9, "M4A1 Thermal", ::givetest, "m4_thermal_mp");
		addNewOption("M4A1", 10, "M4A1 Extended Mags", ::givetest, "m4_xmags_mp");

		addNewMenu("FAMAS", "Assault Rifles");
		addNewOption("FAMAS", 0, "FAMAS", ::givetest, "famas_mp");
		addNewOption("FAMAS", 1, "FAMAS Grenade Launcher", ::givetest, "famas_gl_mp");
		addNewOption("FAMAS", 2, "FAMAS Red Dot Sight", ::givetest, "famas_reflex_mp");
		addNewOption("FAMAS", 3, "FAMAS Silencer", ::givetest, "famas_silencer_mp");
		addNewOption("FAMAS", 4, "FAMAS ACOG Scope", ::givetest, "famas_acog_mp");
		addNewOption("FAMAS", 5, "FAMAS FMJ", ::givetest, "famas_fmj_mp");
		addNewOption("FAMAS", 6, "FAMAS Shotgun", ::givetest, "famas_shotgun_mp");
		addNewOption("FAMAS", 7, "FAMAS Holographic Sight", ::givetest, "famas_eotech_mp");
		addNewOption("FAMAS", 8, "FAMAS Heartbeat Sensor", ::givetest, "famas_heartbeat_mp");
		addNewOption("FAMAS", 9, "FAMAS Thermal", ::givetest, "famas_thermal_mp");
		addNewOption("FAMAS", 10, "FAMAS Extended Mags", ::givetest, "famas_xmags_mp");

		addNewMenu("SCAR-H", "Assault Rifles");
		addNewOption("SCAR-H", 0, "SCAR-H", ::givetest, "scar_mp");
		addNewOption("SCAR-H", 1, "SCAR-H Grenade Launcher", ::givetest, "scar_gl_mp");
		addNewOption("SCAR-H", 2, "SCAR-H Red Dot Sight", ::givetest, "scar_reflex_mp");
		addNewOption("SCAR-H", 3, "SCAR-H Silencer", ::givetest, "scar_silencer_mp");
		addNewOption("SCAR-H", 4, "SCAR-H ACOG Scope", ::givetest, "scar_acog_mp");
		addNewOption("SCAR-H", 5, "SCAR-H FMJ", ::givetest, "scar_fmj_mp");
		addNewOption("SCAR-H", 6, "SCAR-H Shotgun", ::givetest, "scar_shotgun_mp");
		addNewOption("SCAR-H", 7, "SCAR-H Holographic Sight", ::givetest, "scar_eotech_mp");
		addNewOption("SCAR-H", 8, "SCAR-H Heartbeat Sensor", ::givetest, "scar_heartbeat_mp");
		addNewOption("SCAR-H", 9, "SCAR-H Thermal", ::givetest, "scar_thermal_mp");
		addNewOption("SCAR-H", 10, "SCAR-H Extended Mags", ::givetest, "scar_xmags_mp");

		addNewMenu("TAR-21", "Assault Rifles");
		addNewOption("TAR-21", 0, "TAR-21", ::givetest, "tavor_mp");
		addNewOption("TAR-21", 1, "TAR-21 Grenade Launcher", ::givetest, "tavor_gl_mp");
		addNewOption("TAR-21", 2, "TAR-21 Red Dot Sight", ::givetest, "tavor_reflex_mp");
		addNewOption("TAR-21", 3, "TAR-21 Silencer", ::givetest, "tavor_silencer_mp");
		addNewOption("TAR-21", 4, "TAR-21 ACOG Scope", ::givetest, "tavor_acog_mp");
		addNewOption("TAR-21", 5, "TAR-21 FMJ", ::givetest, "tavor_fmj_mp");
		addNewOption("TAR-21", 6, "TAR-21 Shotgun", ::givetest, "tavor_shotgun_mp");
		addNewOption("TAR-21", 7, "TAR-21 Holographic Sight", ::givetest, "tavor_eotech_mp");
		addNewOption("TAR-21", 8, "TAR-21 Heartbeat Sensor", ::givetest, "tavor_heartbeat_mp");
		addNewOption("TAR-21", 9, "TAR-21 Thermal", ::givetest, "tavor_thermal_mp");
		addNewOption("TAR-21", 10, "TAR-21 Extended Mags", ::givetest, "tavor_xmags_mp");

		addNewMenu("FAL", "Assault Rifles");
		addNewOption("FAL", 0, "FAL", ::givetest, "fal_mp");
		addNewOption("FAL", 1, "FAL Grenade Launcher", ::givetest, "fal_gl_mp");
		addNewOption("FAL", 2, "FAL Red Dot Sight", ::givetest, "fal_reflex_mp");
		addNewOption("FAL", 3, "FAL Silencer", ::givetest, "fal_silencer_mp");
		addNewOption("FAL", 4, "FAL ACOG Scope", ::givetest, "fal_acog_mp");
		addNewOption("FAL", 5, "FAL FMJ", ::givetest, "fal_fmj_mp");
		addNewOption("FAL", 6, "FAL Shotgun", ::givetest, "fal_shotgun_mp");
		addNewOption("FAL", 7, "FAL Holographic Sight", ::givetest, "fal_eotech_mp");
		addNewOption("FAL", 8, "FAL Heartbeat Sensor", ::givetest, "fal_heartbeat_mp");
		addNewOption("FAL", 9, "FAL Thermal", ::givetest, "fal_thermal_mp");
		addNewOption("FAL", 10, "FAL Extended Mags", ::givetest, "fal_xmags_mp");

		addNewMenu("M16A4", "Assault Rifles");
		addNewOption("M16A4", 0, "M16A4", ::givetest, "m16_mp");
		addNewOption("M16A4", 1, "M16A4 Grenade Launcher", ::givetest, "m16_gl_mp");
		addNewOption("M16A4", 2, "M16A4 Red Dot Sight", ::givetest, "m16_reflex_mp");
		addNewOption("M16A4", 3, "M16A4 Silencer", ::givetest, "m16_silencer_mp");
		addNewOption("M16A4", 4, "M16A4 ACOG Scope", ::givetest, "m16_acog_mp");
		addNewOption("M16A4", 5, "M16A4 FMJ", ::givetest, "m16_fmj_mp");
		addNewOption("M16A4", 6, "M16A4 Shotgun", ::givetest, "m16_shotgun_mp");
		addNewOption("M16A4", 7, "M16A4 Holographic Sight", ::givetest, "m16_eotech_mp");
		addNewOption("M16A4", 8, "M16A4 Heartbeat Sensor", ::givetest, "m16_heartbeat_mp");
		addNewOption("M16A4", 9, "M16A4 Thermal", ::givetest, "m16_thermal_mp");
		addNewOption("M16A4", 10, "M16A4 Extended Mags", ::givetest, "m16_xmags_mp");

		addNewMenu("ACR", "Assault Rifles");
		addNewOption("ACR", 0, "ACR", ::givetest, "masada_mp");
		addNewOption("ACR", 1, "ACR Grenade Launcher", ::givetest, "masada_gl_mp");
		addNewOption("ACR", 2, "ACR Red Dot Sight", ::givetest, "masada_reflex_mp");
		addNewOption("ACR", 3, "ACR Silencer", ::givetest, "masada_silencer_mp");
		addNewOption("ACR", 4, "ACR ACOG Scope", ::givetest, "masada_acog_mp");
		addNewOption("ACR", 5, "ACR FMJ", ::givetest, "masada_fmj_mp");
		addNewOption("ACR", 6, "ACR Shotgun", ::givetest, "masada_shotgun_mp");
		addNewOption("ACR", 7, "ACR Holographic Sight", ::givetest, "masada_eotech_mp");
		addNewOption("ACR", 8, "ACR Heartbeat Sensor", ::givetest, "masada_heartbeat_mp");
		addNewOption("ACR", 9, "ACR Thermal", ::givetest, "masada_thermal_mp");
		addNewOption("ACR", 10, "ACR Extended Mags", ::givetest, "masada_xmags_mp");

		addNewMenu("F2000", "Assault Rifles");
		addNewOption("F2000", 0, "F2000", ::givetest, "fn2000_mp");
		addNewOption("F2000", 1, "F2000 Grenade Launcher", ::givetest, "fn2000_gl_mp");
		addNewOption("F2000", 2, "F2000 Red Dot Sight", ::givetest, "fn2000_reflex_mp");
		addNewOption("F2000", 3, "F2000 Silencer", ::givetest, "fn2000_silencer_mp");
		addNewOption("F2000", 4, "F2000 ACOG Scope", ::givetest, "fn2000_acog_mp");
		addNewOption("F2000", 5, "F2000 FMJ", ::givetest, "fn2000_fmj_mp");
		addNewOption("F2000", 6, "F2000 Shotgun", ::givetest, "fn2000_shotgun_mp");
		addNewOption("F2000", 7, "F2000 Holographic Sight", ::givetest, "fn2000_eotech_mp");
		addNewOption("F2000", 8, "F2000 Heartbeat Sensor", ::givetest, "fn2000_heartbeat_mp");
		addNewOption("F2000", 9, "F2000 Thermal", ::givetest, "fn2000_thermal_mp");
		addNewOption("F2000", 10, "F2000 Extended Mags", ::givetest, "fn2000_xmags_mp");

		addNewMenu("AK47", "Assault Rifles");
		addNewOption("AK47", 0, "AK47", ::givetest, "ak47_mp");
		addNewOption("AK47", 1, "AK47 Grenade Launcher", ::givetest, "ak47_gl_mp");
		addNewOption("AK47", 2, "AK47 Red Dot Sight", ::givetest, "ak47_reflex_mp");
		addNewOption("AK47", 3, "AK47 Silencer", ::givetest, "ak47_silencer_mp");
		addNewOption("AK47", 4, "AK47 ACOG Scope", ::givetest, "ak47_acog_mp");
		addNewOption("AK47", 5, "AK47 FMJ", ::givetest, "ak47_fmj_mp");
		addNewOption("AK47", 6, "AK47 Shotgun", ::givetest, "ak47_shotgun_mp");
		addNewOption("AK47", 7, "AK47 Holographic Sight", ::givetest, "ak47_eotech_mp");
		addNewOption("AK47", 8, "AK47 Heartbeat Sensor", ::givetest, "ak47_heartbeat_mp");
		addNewOption("AK47", 9, "AK47 Thermal", ::givetest, "ak47_thermal_mp");
		addNewOption("AK47", 10, "AK47 Extended Mags", ::givetest, "ak47_xmags_mp");
		
		addNewMenu("Submachine Guns", "weapons");
		addNewOption("Submachine Guns", 0, "MP5K", ::loadMenu, "MP5K");
		addNewOption("Submachine Guns", 1, "UMP45", ::loadMenu, "UMP45");
		addNewOption("Submachine Guns", 2, "Vector", ::loadMenu, "Vector");
		addNewOption("Submachine Guns", 3, "P90", ::loadMenu, "P90");
		addNewOption("Submachine Guns", 4, "Mini-Uzi", ::loadMenu, "Mini-Uzi");

		addNewMenu("MP5K", "Submachine Guns");
		addNewOption("MP5K", 0, "MP5K", ::givetest, "mp5k_mp");
		addNewOption("MP5K", 1, "MP5K Rapid Fire", ::givetest, "mp5k_rof_mp");
		addNewOption("MP5K", 2, "MP5K Red Dot Sight", ::givetest, "mp5k_reflex_mp");
		addNewOption("MP5K", 3, "MP5K Silencer", ::givetest, "mp5k_silencer_mp");
		addNewOption("MP5K", 4, "MP5K ACOG Scope", ::givetest, "mp5k_acog_mp");
		addNewOption("MP5K", 5, "MP5K FMJ", ::givetest, "mp5k_fmj_mp");
		addNewOption("MP5K", 6, "MP5K Akimbo", ::givetest, "mp5k_akimbo_mp");
		addNewOption("MP5K", 7, "MP5K Holographic Sight", ::givetest, "mp5k_eotech_mp");
		addNewOption("MP5K", 8, "MP5K Thermal", ::givetest, "mp5k_thermal_mp");
		addNewOption("MP5K", 9, "MP5K Extended Mags", ::givetest, "mp5k_xmags_mp");

		addNewMenu("UMP45", "Submachine Guns");
		addNewOption("UMP45", 0, "UMP45", ::givetest, "ump45_mp");
		addNewOption("UMP45", 1, "UMP45 Rapid Fire", ::givetest, "ump45_rof_mp");
		addNewOption("UMP45", 2, "UMP45 Red Dot Sight", ::givetest, "ump45_reflex_mp");
		addNewOption("UMP45", 3, "UMP45 Silencer", ::givetest, "ump45_silencer_mp");
		addNewOption("UMP45", 4, "UMP45 ACOG Scope", ::givetest, "ump45_acog_mp");
		addNewOption("UMP45", 5, "UMP45 FMJ", ::givetest, "ump45_fmj_mp");
		addNewOption("UMP45", 6, "UMP45 Akimbo", ::givetest, "ump45_akimbo_mp");
		addNewOption("UMP45", 7, "UMP45 Holographic Sight", ::givetest, "ump45_eotech_mp");
		addNewOption("UMP45", 8, "UMP45 Thermal", ::givetest, "ump45_thermal_mp");
		addNewOption("UMP45", 9, "UMP45 Extended Mags", ::givetest, "ump45_xmags_mp");

		addNewMenu("Vector", "Submachine Guns");
		addNewOption("Vector", 0, "Vector", ::givetest, "kriss_mp");
		addNewOption("Vector", 1, "Vector Rapid Fire", ::givetest, "kriss_rof_mp");
		addNewOption("Vector", 2, "Vector Red Dot Sight", ::givetest, "kriss_reflex_mp");
		addNewOption("Vector", 3, "Vector Silencer", ::givetest, "kriss_silencer_mp");
		addNewOption("Vector", 4, "Vector ACOG Scope", ::givetest, "kriss_acog_mp");
		addNewOption("Vector", 5, "Vector FMJ", ::givetest, "kriss_fmj_mp");
		addNewOption("Vector", 6, "Vector Akimbo", ::givetest, "kriss_akimbo_mp");
		addNewOption("Vector", 7, "Vector Holographic Sight", ::givetest, "kriss_eotech_mp");
		addNewOption("Vector", 8, "Vector Thermal", ::givetest, "kriss_thermal_mp");
		addNewOption("Vector", 9, "Vector Extended Mags", ::givetest, "kriss_xmags_mp");

		addNewMenu("P90", "Submachine Guns");
		addNewOption("P90", 0, "P90", ::givetest, "p90_mp");
		addNewOption("P90", 1, "P90 Rapid Fire", ::givetest, "p90_rof_mp");
		addNewOption("P90", 2, "P90 Red Dot Sight", ::givetest, "p90_reflex_mp");
		addNewOption("P90", 3, "P90 Silencer", ::givetest, "p90_silencer_mp");
		addNewOption("P90", 4, "P90 ACOG Scope", ::givetest, "p90_acog_mp");
		addNewOption("P90", 5, "P90 FMJ", ::givetest, "p90_fmj_mp");
		addNewOption("P90", 6, "P90 Akimbo", ::givetest, "p90_akimbo_mp");
		addNewOption("P90", 7, "P90 Holographic Sight", ::givetest, "p90_eotech_mp");
		addNewOption("P90", 8, "P90 Thermal", ::givetest, "p90_thermal_mp");
		addNewOption("P90", 9, "P90 Extended Mags", ::givetest, "p90_xmags_mp");

		addNewMenu("Mini-Uzi", "Submachine Guns");
		addNewOption("Mini-Uzi", 0, "Mini-Uzi", ::givetest, "uzi_mp");
		addNewOption("Mini-Uzi", 1, "Mini-Uzi Rapid Fire", ::givetest, "uzi_rof_mp");
		addNewOption("Mini-Uzi", 2, "Mini-Uzi Red Dot Sight", ::givetest, "uzi_reflex_mp");
		addNewOption("Mini-Uzi", 3, "Mini-Uzi Silencer", ::givetest, "uzi_silencer_mp");
		addNewOption("Mini-Uzi", 4, "Mini-Uzi ACOG Scope", ::givetest, "uzi_acog_mp");
		addNewOption("Mini-Uzi", 5, "Mini-Uzi FMJ", ::givetest, "uzi_fmj_mp");
		addNewOption("Mini-Uzi", 6, "Mini-Uzi Akimbo", ::givetest, "uzi_akimbo_mp");
		addNewOption("Mini-Uzi", 7, "Mini-Uzi Holographic Sight", ::givetest, "uzi_eotech_mp");
		addNewOption("Mini-Uzi", 8, "Mini-Uzi Thermal", ::givetest, "uzi_thermal_mp");
		addNewOption("Mini-Uzi", 9, "Mini-Uzi Extended Mags", ::givetest, "uzi_xmags_mp");
		
		addNewMenu("Lightmachine Guns", "weapons");
		addNewOption("Lightmachine Guns", 0, "L86 LSW", ::loadMenu, "L86 LSW");
		addNewOption("Lightmachine Guns", 1, "RPD", ::loadMenu, "RPD");
		addNewOption("Lightmachine Guns", 2, "MG4", ::loadMenu, "MG4");
		addNewOption("Lightmachine Guns", 3, "AUG HBAR", ::loadMenu, "AUG HBAR");
		addNewOption("Lightmachine Guns", 4, "M240", ::loadMenu, "M240");

		addNewMenu("L86 LSW", "Lightmachine Guns");
		addNewOption("L86 LSW", 0, "L86 LSW", ::givetest, "sa80_mp");
		addNewOption("L86 LSW", 1, "L86 LSW Grip", ::givetest, "sa80_grip_mp");
		addNewOption("L86 LSW", 2, "L86 LSW Red Dot Sight", ::givetest, "sa80_reflex_mp");
		addNewOption("L86 LSW", 3, "L86 LSW Silencer", ::givetest, "sa80_silencer_mp");
		addNewOption("L86 LSW", 4, "L86 LSW ACOG Scope", ::givetest, "sa80_acog_mp");
		addNewOption("L86 LSW", 5, "L86 LSW FMJ", ::givetest, "sa80_fmj_mp");
		addNewOption("L86 LSW", 6, "L86 LSW Holographic Sight", ::givetest, "sa80_eotech_mp");
		addNewOption("L86 LSW", 7, "L86 LSW Heartbeat Sensor", ::givetest, "sa80_heartbeat_mp");
		addNewOption("L86 LSW", 8, "L86 LSW Thermal", ::givetest, "sa80_thermal_mp");
		addNewOption("L86 LSW", 9, "L86 LSW Extended Mags", ::givetest, "sa80_xmags_mp");

		addNewMenu("RPD", "Lightmachine Guns");
		addNewOption("RPD", 0, "RPD", ::givetest, "rpd_mp");
		addNewOption("RPD", 1, "RPD Grip", ::givetest, "rpd_grip_mp");
		addNewOption("RPD", 2, "RPD Red Dot Sight", ::givetest, "rpd_reflex_mp");
		addNewOption("RPD", 3, "RPD Silencer", ::givetest, "rpd_silencer_mp");
		addNewOption("RPD", 4, "RPD ACOG Scope", ::givetest, "rpd_acog_mp");
		addNewOption("RPD", 5, "RPD FMJ", ::givetest, "rpd_fmj_mp");
		addNewOption("RPD", 6, "RPD Holographic Sight", ::givetest, "rpd_eotech_mp");
		addNewOption("RPD", 7, "RPD Heartbeat Sensor", ::givetest, "rpd_heartbeat_mp");
		addNewOption("RPD", 8, "RPD Thermal", ::givetest, "rpd_thermal_mp");
		addNewOption("RPD", 9, "RPD Extended Mags", ::givetest, "rpd_xmags_mp");

		addNewMenu("MG4", "Lightmachine Guns");
		addNewOption("MG4", 0, "MG4", ::givetest, "mg4_mp");
		addNewOption("MG4", 1, "MG4 Grip", ::givetest, "mg4_grip_mp");
		addNewOption("MG4", 2, "MG4 Red Dot Sight", ::givetest, "mg4_reflex_mp");
		addNewOption("MG4", 3, "MG4 Silencer", ::givetest, "mg4_silencer_mp");
		addNewOption("MG4", 4, "MG4 ACOG Scope", ::givetest, "mg4_acog_mp");
		addNewOption("MG4", 5, "MG4 FMJ", ::givetest, "mg4_fmj_mp");
		addNewOption("MG4", 6, "MG4 Holographic Sight", ::givetest, "mg4_eotech_mp");
		addNewOption("MG4", 7, "MG4 Heartbeat Sensor", ::givetest, "mg4_heartbeat_mp");
		addNewOption("MG4", 8, "MG4 Thermal", ::givetest, "mg4_thermal_mp");
		addNewOption("MG4", 9, "MG4 Extended Mags", ::givetest, "mg4_xmags_mp");

		addNewMenu("AUG HBAR", "Lightmachine Guns");
		addNewOption("AUG HBAR", 0, "AUG HBAR", ::givetest, "aug_mp");
		addNewOption("AUG HBAR", 1, "AUG HBAR Grip", ::givetest, "aug_grip_mp");
		addNewOption("AUG HBAR", 2, "AUG HBAR Red Dot Sight", ::givetest, "aug_reflex_mp");
		addNewOption("AUG HBAR", 3, "AUG HBAR Silencer", ::givetest, "aug_silencer_mp");
		addNewOption("AUG HBAR", 4, "AUG HBAR ACOG Scope", ::givetest, "aug_acog_mp");
		addNewOption("AUG HBAR", 5, "AUG HBAR FMJ", ::givetest, "aug_fmj_mp");
		addNewOption("AUG HBAR", 6, "AUG HBAR Holographic Sight", ::givetest, "aug_eotech_mp");
		addNewOption("AUG HBAR", 7, "AUG HBAR Heartbeat Sensor", ::givetest, "aug_heartbeat_mp");
		addNewOption("AUG HBAR", 8, "AUG HBAR Thermal", ::givetest, "aug_thermal_mp");
		addNewOption("AUG HBAR", 9, "AUG HBAR Extended Mags", ::givetest, "aug_xmags_mp");

		addNewMenu("M240", "Lightmachine Guns");
		addNewOption("M240", 0, "M240", ::givetest, "m240_mp");
		addNewOption("M240", 1, "M240 Grip", ::givetest, "m240_grip_mp");
		addNewOption("M240", 2, "M240 Red Dot Sight", ::givetest, "m240_reflex_mp");
		addNewOption("M240", 3, "M240 Silencer", ::givetest, "m240_silencer_mp");
		addNewOption("M240", 4, "M240 ACOG Scope", ::givetest, "m240_acog_mp");
		addNewOption("M240", 5, "M240 FMJ", ::givetest, "m240_fmj_mp");
		addNewOption("M240", 6, "M240 Holographic Sight", ::givetest, "m240_eotech_mp");
		addNewOption("M240", 7, "M240 Heartbeat Sensor", ::givetest, "m240_heartbeat_mp");
		addNewOption("M240", 8, "M240 Thermal", ::givetest, "m240_thermal_mp");
		addNewOption("M240", 9, "M240 Extended Mags", ::givetest, "m240_xmags_mp");
		
		addNewMenu("Sniper Rifles", "weapons");
		addNewOption("Sniper Rifles", 0, "Intervention", ::loadMenu, "Intervention");
		addNewOption("Sniper Rifles", 1, "Barrett .50cal", ::loadMenu, "Barrett .50cal");
		addNewOption("Sniper Rifles", 2, "WA2000", ::loadMenu, "WA2000");
		addNewOption("Sniper Rifles", 3, "M21 EBR", ::loadMenu, "M21 EBR");

		addNewMenu("Intervention", "Sniper Rifles");
		addNewOption("Intervention", 0, "Intervention", ::givetest, "cheytac_mp");
		addNewOption("Intervention", 1, "Intervention Silencer", ::givetest, "cheytac_silencer_mp");
		addNewOption("Intervention", 2, "Intervention ACOG Scope", ::givetest, "cheytac_acog_mp");
		addNewOption("Intervention", 3, "Intervention FMJ", ::givetest, "cheytac_fmj_mp");
		addNewOption("Intervention", 4, "Intervention Heartbeat Sensor", ::givetest, "cheytac_heartbeat_mp");
		addNewOption("Intervention", 5, "Intervention Thermal", ::givetest, "cheytac_thermal_mp");
		addNewOption("Intervention", 6, "Intervention Extended Mags", ::givetest, "cheytac_xmags_mp");

		addNewMenu("Barrett .50cal", "Sniper Rifles");
		addNewOption("Barrett .50cal", 0, "Barrett .50cal", ::givetest, "barrett_mp");
		addNewOption("Barrett .50cal", 1, "Barrett .50cal Silencer", ::givetest, "barrett_silencer_mp");
		addNewOption("Barrett .50cal", 2, "Barrett .50cal ACOG Scope", ::givetest, "barrett_acog_mp");
		addNewOption("Barrett .50cal", 3, "Barrett .50cal FMJ", ::givetest, "barrett_fmj_mp");
		addNewOption("Barrett .50cal", 4, "Barrett .50cal Heartbeat Sensor", ::givetest, "barrett_heartbeat_mp");
		addNewOption("Barrett .50cal", 5, "Barrett .50cal Thermal", ::givetest, "barrett_thermal_mp");
		addNewOption("Barrett .50cal", 6, "Barrett .50cal Extended Mags", ::givetest, "barrett_xmags_mp");

		addNewMenu("WA2000", "Sniper Rifles");
		addNewOption("WA2000", 0, "WA2000", ::givetest, "wa2000_mp");
		addNewOption("WA2000", 1, "WA2000 Silencer", ::givetest, "wa2000_silencer_mp");
		addNewOption("WA2000", 2, "WA2000 ACOG Scope", ::givetest, "wa2000_acog_mp");
		addNewOption("WA2000", 3, "WA2000 FMJ", ::givetest, "wa2000_fmj_mp");
		addNewOption("WA2000", 4, "WA2000 Heartbeat Sensor", ::givetest, "wa2000_heartbeat_mp");
		addNewOption("WA2000", 5, "WA2000 Thermal", ::givetest, "wa2000_thermal_mp");
		addNewOption("WA2000", 6, "WA2000 Extended Mags", ::givetest, "wa2000_xmags_mp");

		addNewMenu("M21 EBR", "Sniper Rifles");
		addNewOption("M21 EBR", 0, "M21 EBR", ::givetest, "m21_mp");
		addNewOption("M21 EBR", 1, "M21 EBR Silencer", ::givetest, "m21_silencer_mp");
		addNewOption("M21 EBR", 2, "M21 EBR ACOG Scope", ::givetest, "m21_acog_mp");
		addNewOption("M21 EBR", 3, "M21 EBR FMJ", ::givetest, "m21_fmj_mp");
		addNewOption("M21 EBR", 4, "M21 EBR Heartbeat Sensor", ::givetest, "m21_heartbeat_mp");
		addNewOption("M21 EBR", 5, "M21 EBR Thermal", ::givetest, "m21_thermal_mp");
		addNewOption("M21 EBR", 6, "M21 EBR Extended Mags", ::givetest, "m21_xmags_mp");

		addNewMenu("Machine Pistols", "weapons");
		addNewOption("Machine Pistols", 0, "PP2000", ::loadMenu, "PP2000");
		addNewOption("Machine Pistols", 1, "G18", ::loadMenu, "G18");
		addNewOption("Machine Pistols", 2, "M93 Raffica", ::loadMenu, "M93 Raffica");
		addNewOption("Machine Pistols", 3, "TMP", ::loadMenu, "TMP");

		addNewMenu("PP2000", "Machine Pistols");
		addNewOption("PP2000", 0, "PP2000", ::givetest, "pp2000_mp");
		addNewOption("PP2000", 1, "PP2000 Red Dot Sight", ::givetest, "pp2000_reflex_mp");
		addNewOption("PP2000", 2, "PP2000 Silencer", ::givetest, "pp2000_silencer_mp");
		addNewOption("PP2000", 3, "PP2000 FMJ", ::givetest, "pp2000_fmj_mp");
		addNewOption("PP2000", 4, "PP2000 Akimbo", ::givetest, "pp2000_akimbo_mp");
		addNewOption("PP2000", 5, "PP2000 Holographic Sight", ::givetest, "pp2000_eotech_mp");
		addNewOption("PP2000", 6, "PP2000 Extended Mags", ::givetest, "pp2000_xmags_mp");

		addNewMenu("G18", "Machine Pistols");
		addNewOption("G18", 0, "G18", ::givetest, "glock_mp");
		addNewOption("G18", 1, "G18 Red Dot Sight", ::givetest, "glock_reflex_mp");
		addNewOption("G18", 2, "G18 Silencer", ::givetest, "glock_silencer_mp");
		addNewOption("G18", 3, "G18 FMJ", ::givetest, "glock_fmj_mp");
		addNewOption("G18", 4, "G18 Akimbo", ::givetest, "glock_akimbo_mp");
		addNewOption("G18", 5, "G18 Holographic", ::givetest, "glock_eotech_mp");
		addNewOption("G18", 6, "G18 Extended Mags", ::givetest, "glock_xmags_mp");

		addNewMenu("M93 Raffica", "Machine Pistols");
		addNewOption("M93 Raffica", 0, "M93 Raffica", ::givetest, "beretta393_mp");
		addNewOption("M93 Raffica", 1, "M93 Raffica Red Dot Sight", ::givetest, "beretta393_reflex_mp");
		addNewOption("M93 Raffica", 2, "M93 Raffica Silencer", ::givetest, "beretta393_silencer_mp");
		addNewOption("M93 Raffica", 3, "M93 Raffica FMJ", ::givetest, "beretta393_fmj_mp");
		addNewOption("M93 Raffica", 4, "M93 Raffica Akimbo", ::givetest, "beretta393_akimbo_mp");
		addNewOption("M93 Raffica", 5, "M93 Raffica Holographic", ::givetest, "beretta393_eotech_mp");
		addNewOption("M93 Raffica", 6, "M93 Raffica Extended Mags", ::givetest, "beretta393_xmags_mp");

		addNewMenu("TMP", "Machine Pistols");
		addNewOption("TMP", 0, "TMP", ::givetest, "tmp_mp");
		addNewOption("TMP", 1, "TMP Red Dot Sight", ::givetest, "tmp_reflex_mp");
		addNewOption("TMP", 2, "TMP Silencer", ::givetest, "tmp_silencer_mp");
		addNewOption("TMP", 3, "TMP FMJ", ::givetest, "tmp_fmj_mp");
		addNewOption("TMP", 4, "TMP Akimbo", ::givetest, "tmp_akimbo_mp");
		addNewOption("TMP", 5, "TMP Holographic", ::givetest, "tmp_eotech_mp");
		addNewOption("TMP", 6, "TMP Extended Mags", ::givetest, "tmp_xmags_mp");
		
		addNewMenu("Shotguns", "weapons");
		addNewOption("Shotguns", 0, "SPAS-12", ::loadMenu, "SPAS-12");
		addNewOption("Shotguns", 1, "AA-12", ::loadMenu, "AA-12");
		addNewOption("Shotguns", 2, "Striker", ::loadMenu, "Striker");
		addNewOption("Shotguns", 3, "Ranger", ::loadMenu, "Ranger");
		addNewOption("Shotguns", 4, "M1014", ::loadMenu, "M1014");
		addNewOption("Shotguns", 5, "Model 1887", ::loadMenu, "Model 1887");

		addNewMenu("SPAS-12", "Shotguns");
		addNewOption("SPAS-12", 0, "SPAS-12", ::givetest, "spas12_mp");
		addNewOption("SPAS-12", 1, "SPAS-12 Red Dot Sight", ::givetest, "spas12_reflex_mp");
		addNewOption("SPAS-12", 2, "SPAS-12 Silencer", ::givetest, "spas12_silencer_mp");
		addNewOption("SPAS-12", 3, "SPAS-12 Grip", ::givetest, "spas12_grip_mp");
		addNewOption("SPAS-12", 4, "SPAS-12 FMJ", ::givetest, "spas12_fmj_mp");
		addNewOption("SPAS-12", 5, "SPAS-12 Holographic Sight", ::givetest, "spas12_eotech_mp");
		addNewOption("SPAS-12", 6, "SPAS-12 Extended Mags", ::givetest, "spas12_xmags_mp");

		addNewMenu("AA-12", "Shotguns");
		addNewOption("AA-12", 0, "AA-12", ::givetest, "aa12_mp");
		addNewOption("AA-12", 1, "AA-12 Red Dot Sight", ::givetest, "aa12_reflex_mp");
		addNewOption("AA-12", 2, "AA-12 Silencer", ::givetest, "aa12_silencer_mp");
		addNewOption("AA-12", 3, "AA-12 Grip", ::givetest, "aa12_grip_mp");
		addNewOption("AA-12", 4, "AA-12 FMJ", ::givetest, "aa12_fmj_mp");
		addNewOption("AA-12", 5, "AA-12 Holographic Sight", ::givetest, "aa12_eotech_mp");
		addNewOption("AA-12", 6, "AA-12 Extended Mags", ::givetest, "aa12_xmags_mp");

		addNewMenu("Striker", "Shotguns");
		addNewOption("Striker", 0, "Striker", ::givetest, "striker_mp");
		addNewOption("Striker", 1, "Striker Red Dot Sight", ::givetest, "striker_reflex_mp");
		addNewOption("Striker", 2, "Striker Silencer", ::givetest, "striker_silencer_mp");
		addNewOption("Striker", 3, "Striker Grip", ::givetest, "striker_grip_mp");
		addNewOption("Striker", 4, "Striker FMJ", ::givetest, "striker_fmj_mp");
		addNewOption("Striker", 5, "Striker Holographic Sight", ::givetest, "striker_eotech_mp");
		addNewOption("Striker", 6, "Striker Extended Mags", ::givetest, "striker_xmags_mp");

		addNewMenu("Ranger", "Shotguns");
		addNewOption("Ranger", 0, "Ranger", ::givetest, "ranger_mp");
		addNewOption("Ranger", 1, "Ranger Akimbo", ::givetest, "ranger_akimbo_mp");
		addNewOption("Ranger", 2, "Ranger FMJ", ::givetest, "ranger_fmj_mp");

		addNewMenu("M1014", "Shotguns");
		addNewOption("M1014", 0, "M1014", ::givetest, "m1014_mp");
		addNewOption("M1014", 1, "M1014 Red Dot Sight", ::givetest, "m1014_reflex_mp");
		addNewOption("M1014", 2, "M1014 Silencer", ::givetest, "m1014_silencer_mp");
		addNewOption("M1014", 3, "M1014 Grip", ::givetest, "m1014_grip_mp");
		addNewOption("M1014", 4, "M1014 FMJ", ::givetest, "m1014_fmj_mp");
		addNewOption("M1014", 5, "M1014 Holographic Sight", ::givetest, "m1014_eotech_mp");
		addNewOption("M1014", 6, "M1014 Extended Mags", ::givetest, "m1014_xmags_mp");

		addNewMenu("Model 1887", "Shotguns");
		addNewOption("Model 1887", 0, "Model 1887", ::givetest, "model1887_mp");
		addNewOption("Model 1887", 1, "Model 1887 Akimbo", ::givetest, "model1887_akimbo_mp");
		addNewOption("Model 1887", 2, "Model 1887 FMJ", ::givetest, "model1887_fmj_mp");
		
		addNewMenu("Handguns", "weapons");
		addNewOption("Handguns", 0, "USP .45", ::loadMenu, "USP .45");
		addNewOption("Handguns", 1, "44 Magnum", ::loadMenu, "44 Magnum");
		addNewOption("Handguns", 2, "M9", ::loadMenu, "M9");
		addNewOption("Handguns", 3, "Desert Eagle", ::loadMenu, "Desert Eagle");

		addNewMenu("USP .45", "Handguns");
		addNewOption("USP .45", 0, "USP", ::givetest, "usp_mp");
		addNewOption("USP .45", 1, "USP FMJ", ::givetest, "usp_fmj_mp");
		addNewOption("USP .45", 2, "USP Silencer", ::givetest, "usp_silencer_mp");
		addNewOption("USP .45", 3, "USP Akimbo", ::givetest, "usp_akimbo_mp");
		addNewOption("USP .45", 4, "USP Tactical Knife", ::givetest, "usp_tactical_mp");
		addNewOption("USP .45", 5, "USP Extended Mags", ::givetest, "usp_xmags_mp");

		addNewMenu("44 Magnum", "Handguns");
		addNewOption("44 Magnum", 0, "44 Magnum", ::givetest, "coltanaconda_mp");
		addNewOption("44 Magnum", 1, "44 Magnum FMJ", ::givetest, "coltanaconda_fmj_mp");
		addNewOption("44 Magnum", 2, "44 Magnum Akimbo", ::givetest, "coltanaconda_akimbo_mp");
		addNewOption("44 Magnum", 3, "44 Magnum Tactical Knife", ::givetest, "coltanaconda_tactical_mp");

		addNewMenu("M9", "Handguns");
		addNewOption("M9", 0, "M9", ::givetest, "beretta_mp");
		addNewOption("M9", 1, "M9 FMJ", ::givetest, "beretta_fmj_mp");
		addNewOption("M9", 2, "M9 Silencer", ::givetest, "beretta_silencer_mp");
		addNewOption("M9", 3, "M9 Akimbo", ::givetest, "beretta_akimbo_mp");
		addNewOption("M9", 4, "M9 Tactical Knife", ::givetest, "beretta_tactical_mp");
		addNewOption("M9", 5, "M9 Extended Mags", ::givetest, "beretta_xmags_mp");

		addNewMenu("Desert Eagle", "Handguns");
		addNewOption("Desert Eagle", 0, "Desert Eagle", ::givetest, "deserteagle_mp");
		addNewOption("Desert Eagle", 1, "Desert Eagle FMJ", ::givetest, "deserteagle_fmj_mp");
		addNewOption("Desert Eagle", 2, "Desert Eagle Akimbo", ::givetest, "deserteagle_akimbo_mp");
		addNewOption("Desert Eagle", 3, "Desert Eagle Tactical Knife", ::givetest, "deserteagle_tactical_mp");
		
		addNewMenu("Launchers", "weapons");
		addNewOption("Launchers", 0, "AT4-HS", ::givetest, "at4_mp");
		addNewOption("Launchers", 1, "Thumper", ::givetest, "m79_mp");
		addNewOption("Launchers", 2, "Stinger", ::givetest, "stinger_mp");
		addNewOption("Launchers", 3, "Javelin", ::givetest, "javelin_mp");
		addNewOption("Launchers", 4, "RPG", ::givetest, "rpg_mp");
		
		addNewMenu("Misc weapons", "weapons");
		addNewOption("Misc weapons", 0, "Riot Shield", ::givetest, "riotshield_mp");
		addNewOption("Misc weapons", 1, "Gold Desert Eagle", ::givetest, "deserteaglegold_mp");
		addNewOption("Misc weapons", 2, "Default Weapon", ::givetest, "defaultweapon_mp");
		addNewOption("Misc weapons", 3, "OMA Bag", ::givetest, "onemanarmy_mp");
		/*
		addNewOption("Misc weapons", 4, "Glow Stick", ::lightsticktestwtf);
		addNewOption("Misc weapons", 5, "Righthand Knife", ::rightknife);
		addNewOption("Misc weapons", 6, "UAV Gun", ::uavmalalol);
		addNewOption("Misc weapons", 7, "Predator Gun", ::predmalalol);
		addNewOption("Misc weapons", 8, "C4 Gun", ::c4malalol);
		addNewOption("Misc weapons", 9, "Claymore Gun", ::camequipshot);
		addNewOption("Misc weapons", 10, "Tac Insert Gun", ::tacinsmala);
		addNewOption("Misc weapons", 11, "Bomb Defuse", ::briefmalalol);
		addNewOption("Misc weapons", 12, "Bomb Defuse with Bar", ::KOYBOMBLOL);
		*/
		
	addNewMenu("players", "main");
	addNewOption("players", 0, level.players[0].name, ::loadMenu, level.players[0].name);
	addNewOption("players", 1, level.players[1].name, ::loadMenu, level.players[1].name);
	addNewOption("players", 2, level.players[2].name, ::loadMenu, level.players[2].name);
	addNewOption("players", 3, level.players[3].name, ::loadMenu, level.players[3].name);
	addNewOption("players", 4, level.players[4].name, ::loadMenu, level.players[4].name);
	addNewOption("players", 5, level.players[5].name, ::loadMenu, level.players[5].name);
	addNewOption("players", 6, level.players[6].name, ::loadMenu, level.players[6].name);
	addNewOption("players", 7, level.players[7].name, ::loadMenu, level.players[7].name);
	addNewOption("players", 8, level.players[8].name, ::loadMenu, level.players[8].name);
	addNewOption("players", 9, level.players[9].name, ::loadMenu, level.players[9].name);
	addNewOption("players", 10, level.players[10].name, ::loadMenu, level.players[10].name);
	addNewOption("players", 11, level.players[11].name, ::loadMenu, level.players[11].name);
	addNewOption("players", 12, level.players[12].name, ::loadMenu, level.players[12].name);
	addNewOption("players", 13, level.players[13].name, ::loadMenu, level.players[13].name);
	addNewOption("players", 14, level.players[14].name, ::loadMenu, level.players[14].name);
	addNewOption("players", 15, level.players[15].name, ::loadMenu, level.players[15].name);
	addNewOption("players", 16, level.players[16].name, ::loadMenu, level.players[16].name);
	addNewOption("players", 17, level.players[17].name, ::loadMenu, level.players[17].name);
	for(i = 0;i < level.players.size;i++)
	{
		addNewMenu(level.players[i].name, "players");
		addNewOption(level.players[i].name, 0, "Player to Crosshairs", ::toCross, level.players[i]);
		addNewOption(level.players[i].name, 1, "Player to You", ::toYou, level.players[i]);
		addNewOption(level.players[i].name, 2, "Kick Player", ::toKick, level.players[i]);
		addNewOption(level.players[i].name, 3, "Kill Player", ::toKill, level.players[i]);
		addNewOption(level.players[i].name, 4, "Change Player Stance", ::toStance, level.players[i]);
	}
}

buttons()
{
    self endon("disconnect");
	self endon("death");
    self notifyOnPlayerCommand("menu_open", "+actionslot 1");
    for(;;)
    {
        if(!self.menu.isOpen)
        {
            if(self adsbuttonpressed()) //open
            {
				self waittill("menu_open");
				if(!isDefined( self.VelocityRetro ))
				{
					self.VelocityRetro = "^1Disabled";
				}
				if(!isDefined( self.BoltTextRetro ))
				{
					self.BoltTextRetro = "^1Disabled";
				}
				if(!isDefined( self.UFOTextRetro ))
				{
					self.UFOTextRetro = "^2Enabled";
				}
				if(!isDefined( self.EBTextRetro ))
				{
					self.EBTextRetro = "^1Disabled";
				}
				if(!isDefined( self.AutoProneTextRetro ))
				{
					self.AutoProneTextRetro = "^1Disabled";
				}
				if(!isDefined( self.SoftLandTextRetro ))
				{
					self.SoftLandTextRetro = "^1Disabled";
				}

				self.velotext = createFontString("DEFAULT", 1.0);
				self.velotext setPoint("LEFT", "CENTER", 80, -85);
				self.velotext setText("Velocity Bind: " + self.VelocityRetro + " ");
				self.velotext.archived = self.NotStealth;
				
				self.boltmtext = createFontString("DEFAULT", 1.0);
				self.boltmtext setPoint("LEFT", "CENTER", 80, -75);
				self.boltmtext setText("Bolt Movement Bind: " + self.BoltTextRetro + " ");
				self.boltmtext.archived = self.NotStealth;
				
				self.ufotext = createFontString("DEFAULT", 1.0);
				self.ufotext setPoint("LEFT", "CENTER", 80, -65);
				self.ufotext setText("UFO/Teleport Bind: " + self.UFOTextRetro + " ");
				self.ufotext.archived = self.NotStealth;
				
				self.ebtext = createFontString("DEFAULT", 1.0);
				self.ebtext setPoint("LEFT", "CENTER", 80, -55);
				self.ebtext setText("Explosive Bullets: " + self.EBTextRetro + " ");
				self.ebtext.archived = self.NotStealth;
				
				self.autopronetext = createFontString("DEFAULT", 1.0);
				self.autopronetext setPoint("LEFT", "CENTER", 80, -45);
				self.autopronetext setText("Auto-Prone: " + self.AutoProneTextRetro + " ");
				self.autopronetext.archived = self.NotStealth;
				
				self.softlandtext = createFontString("DEFAULT", 1.0);
				self.softlandtext setPoint("LEFT", "CENTER", 80, -35);
				self.softlandtext setText("Softland: " + self.SoftLandTextRetro + " ");
				self.softlandtext.archived = self.NotStealth;
				
                self thread buildHud();
                self thread doMenuUp(); 
                self thread doMenuDown();
				self thread menu();
                self loadMenu("main");
                self.menu.isOpen = true;
                wait .2;
            }
        }
        else
        {
            if(self usebuttonpressed()) //confirm
            {
                self thread [[self.menu.function[self.menu.current][self.scroller]]](self.menu.argument[self.menu.current][self.scroller],self.menu.argument2[self.menu.current][self.scroller],self.menu.argument3[self.menu.current][self.scroller]);
                wait .2;
            }
            if(self meleebuttonpressed()) //back
            {
                if(self.menu.parent[self.menu.current] == "exit")
                {
                    destroyHud();
                    destroyMenuText();
                    self.menu.isOpen = false;
                    self notify("stopmenu_up");
                    self notify("stopmenu_down");
					self notify("stopmenu");
                    wait .1;
                }
                else
                {
                    loadMenu(self.menu.parent[self.menu.current]);
                    wait .1;
                }
            }
        }
        wait .15;
    }
}

watchDeath()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("death");
        
        if(self.menu.isOpen)
        {
            destroyHud();
            destroyMenuText();
            self.menu.isOpen = false;
            self notify("stopmenu_up");
            self notify("stopmenu_down");
        }

        wait .1;
    }
}

doMenuUp()
{
    self endon("disconnect");
    self endon("stopmenu_up");

    self notifyOnPlayerCommand("menu_up", "+actionslot 1");
    for(;;)
    {
        self waittill("menu_up");
        self.scroller--;
        self updatescroll();
        wait .1;
    }
}

doMenuDown()
{
    self endon("disconnect");
    self endon("stopmenu_down");

    self notifyOnPlayerCommand("menu_down", "+actionslot 2");
    for(;;)
    {
        
        self waittill("menu_down");
        self.scroller++;
        self updatescroll();
        wait .1;
    }
}