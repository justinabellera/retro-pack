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

#include maps\mp\gametypes\_hud_util;
#include maps\mp\retropack\_retropack_utility;
#include maps\mp\retropack\_retropack_functions;

init() {}


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

//self.hud.text[i] = createTextElem("default", 1, "CENTER", "CENTER", 0, -110 + (10 * i), 1, (1, 1, 1), 1, (0, 0, 0), 0, self.menu.text[self.menu.current][i]);

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
    addNewOption("main", 1, "Binds ^5Menu", ::loadMenu, "trickshot");
	addNewOption("main", 2, "Bolt Movement ^5Menu", ::loadMenu, "bolt");
	addNewOption("main", 3, "Velocity ^5Menu", ::loadMenu, "velocity");
    addNewOption("main", 4, "Weapons ^5Menu", ::loadMenu, "weapons");
    addNewOption("main", 5, "Killstreaks ^5Menu", ::loadMenu, "ks");
    addNewOption("main", 6, "Bot ^5Menu", ::loadMenu, "bots");
	addNewOption("main", 7, "Lobby ^5Menu", ::loadMenu, "lobby");
	addNewOption("main", 8, "Players ^5Menu", ::loadMenu, "players"); 
	
	addNewMenu("jewstun", "main"); //Jewstun's Backpack
    addNewOption("jewstun", 0, "EB Only For", ::ToggleEbSelector);
    addNewOption("jewstun", 1, "Toggle ^5Explosive Bullets", ::AimbotStrength);
	addNewOption("jewstun", 2, "Toggle ^5Auto-Replenish Ammo", ::ToggleReplenishAmmo);
	addNewOption("jewstun", 3, "Toggle ^5UFO/Teleport Binds", ::ToggleSpawnBinds);
	addNewOption("jewstun", 4, "Toggle ^5Auto-Prone", ::autoProne);
	addNewOption("jewstun", 5, "Toggle ^5Soft Lands", ::Softlands);
	//addNewOption("jewstun", 6, "Toggle ^5Killcam Only Softlands", ::SoftLandKillcamz); //not compatible on mw3
	addNewOption("jewstun", 6, "Save Location", ::doSaveLocation);
	addNewOption("jewstun", 7, "Load Location", ::doLoadLocation);
	
	addNewMenu("trickshot", "main"); //Trickshot Menu
	addNewOption("trickshot", 0, "FPS Bind (57/333 fps)", ::toggleFPS);
	addNewOption("trickshot", 1, "FPS Bind (60/333 fps)", ::toggleFPS60);
	addNewOption("trickshot", 2, "FPS Bind (85/333 fps)", ::toggleFPS85);
	addNewOption("trickshot", 3, "Execute CFG Bind ^5Menu", ::loadMenu, "CFGMenu");
	addNewOption("trickshot", 4, "Scavenger Pickup Bind", ::toggleScavenger);
	addNewOption("trickshot", 5, "Bots EMP Bind", ::EMPBind);
	addNewOption("trickshot", 6, "Bots Shoot You Bind", ::BotsShootBind);
	addNewOption("trickshot", 7, "Last/Final Stand Bind", ::BotsFinalStandBind);
	addNewOption("trickshot", 8, "Illusion Reload", ::IllusionReloadtog); 
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
	addNewOption("trickshot", 24, "Always Knife Lunge",::tknifeLunge); //removed on mw2
	addNewOption("trickshot", 25, "AH6 Bind ^5Menu",::loadMenu,"AH6Bind"); //removed on mw2
	addNewOption("trickshot", 26, "Walking Sentry Gun",::basedsentrylol);
	addNewOption("trickshot", 27, "Mid Air G-Flip Bind ^5Menu",::loadMenu, "GFLIP"); 
	addNewOption("trickshot", 28, "Rapid Fire Bind ^5Menu",::loadMenu,"rapid");
	addNewOption("trickshot", 29, "Modded Elevators", ::moddedelevators); //removed on mw2
	addNewOption("trickshot", 30, "Easy Bounces", ::cyfBounces); //removed on mw2
	addNewOption("trickshot", 31, "Illusion Sprint", ::IllusionSprinttog);
	
	addNewMenu("CFGMenu", "trickshot"); //Trickshot Menu
	addNewOption("CFGMenu", 0, "^1Disable ^7All Scripts", ::execCFGBind, 0);
	addNewOption("CFGMenu", 1, "Execute ^5script_1", ::execCFGBind, 1);
	addNewOption("CFGMenu", 2, "Execute ^5script_2", ::execCFGBind, 2);
	addNewOption("CFGMenu", 3, "Execute ^5script_3", ::execCFGBind, 3);
	addNewOption("CFGMenu", 4, "Execute ^5script_4", ::execCFGBind, 4);
	
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
	
	addNewMenu("ccb", "trickshot"); //Obelisk Menu - Class Change Menu
	addNewOption("ccb", 0,"Bind To Dpad Up", ::tccbBind, "1");
	addNewOption("ccb", 1,"Bind To Dpad Down",::tccbBind, "2");
	addNewOption("ccb", 2,"Bind To Dpad Left",::tccbBind, "3");
	addNewOption("ccb", 3,"Bind To Dpad Right",::tccbBind, "4");
	
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

	addNewMenu("AH6Bind", "trickshot"); //Obelisk Menu - Smooth Bind Menu
	addNewOption("AH6Bind", 0, "AH6 Bind [{+actionslot 1}] ", ::tah6Bind, "1");
	addNewOption("AH6Bind", 1, "AH6 Bind [{+actionslot 2}] ", ::tah6Bind, "2");
	addNewOption("AH6Bind", 2, "AH6 Bind [{+actionslot 3}] ", ::tah6Bind, "3");
	addNewOption("AH6Bind", 3, "AH6 Bind [{+actionslot 4}] ", ::tah6Bind, "4");
	
		addNewMenu("velocity", "main"); //Velocity Menu
		addNewOption("velocity", 0, "Velocity Bind Menu", ::loadMenu, "Velocity Bind Menu");
		addNewOption("velocity", 1, "Preset Velocities Menu", ::loadMenu, "Preset Velocities Menu");
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
		addNewOption("Preset Velocities Menu", 1, "Window Menu", ::loadMenu, "Window Menu");
		addNewOption("Preset Velocities Menu", 2, "Ladder Menu", ::loadMenu, "Ladder Menu");
		
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
	
	// MW2: lag menu here 
	
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
	addNewOption("ks", 0, "Support Streaks ^5Menu", ::loadMenu, "ks_support");
	addNewOption("ks", 1, "Specialist Streaks ^5Menu", ::loadMenu, "ks_specialist");
	addNewOption("ks", 2, "Assault Streaks ^5Menu", ::loadMenu, "ks_assault");
	
	addNewMenu("ks_support", "ks");
	addNewOption("ks_support", 0, "Give ^5UAV", ::streak, "uav_support");
	addNewOption("ks_support", 1, "Give ^5Counter UAV", ::streak, "counter_uav");
	addNewOption("ks_support", 2, "Give ^5Ballistic Vest", ::streak, "deployable_vest");
	addNewOption("ks_support", 3, "Give ^5Airdrop Trap", ::streak, "airdrop_trap");
	addNewOption("ks_support", 4, "Give ^5SAM Turret", ::streak, "sam_turret");
	addNewOption("ks_support", 5, "Give ^5Recon Drone", ::streak, "remote_uav");
	addNewOption("ks_support", 6, "Give ^5Advanced UAV", ::streak, "triple_uav");
	addNewOption("ks_support", 7, "Give ^5Remote Sentry", ::streak, "remote_mg_turret");
	addNewOption("ks_support", 8, "Give ^5Stealth Bomber", ::streak, "stealth_airstrike");
	addNewOption("ks_support", 9, "Give ^5Juggernaut Airdrop", ::streak, "airdrop_juggernaut_recon");
	addNewOption("ks_support", 10, "Give ^5Escort Airdrop", ::streak, "escort_airdrop");
	
	addNewMenu("ks_specialist", "ks");
	addNewOption("ks_specialist", 0, "Give ^5All Specialists", ::streak, "all_perks_bonus");
	addNewOption("ks_specialist", 1, "Give ^5Extreme Conditioning", ::giveSpecialist, "specialty_longersprint");
	addNewOption("ks_specialist", 2, "Give ^5Sleight of Hand", ::giveSpecialist, "specialty_fastreload");
	addNewOption("ks_specialist", 3, "Give ^5Scavenger", ::giveSpecialist, "specialty_scavenger");
	addNewOption("ks_specialist", 4, "Give ^5Blindeye", ::giveSpecialist, "specialty_blindeye");
	addNewOption("ks_specialist", 5, "Give ^5Paint", ::giveSpecialist, "specialty_paint");
	addNewOption("ks_specialist", 6, "Give ^5Hardline", ::giveSpecialist, "specialty_hardline");
	addNewOption("ks_specialist", 7, "Give ^5Coldblooded", ::giveSpecialist, "specialty_coldblooded");
	addNewOption("ks_specialist", 8, "Give ^5Quickdraw", ::giveSpecialist, "specialty_quickdraw");
	addNewOption("ks_specialist", 9, "Give ^5Assisted Killstreak", ::giveSpecialist, "specialty_assists_ks");
	addNewOption("ks_specialist", 10, "Give ^5Blastshield", ::giveSpecialist, "_specialty_blastshield");
	addNewOption("ks_specialist", 11, "Give ^5SitRep", ::giveSpecialist, "specialty_detectexplosive");
	addNewOption("ks_specialist", 12, "Give ^5Iron Lungs", ::giveSpecialist, "specialty_autospot");
	addNewOption("ks_specialist", 13, "Give ^5Steady Aim", ::giveSpecialist, "specialty_bulletaccuracy");
	addNewOption("ks_specialist", 14, "Give ^5Dead Silence", ::giveSpecialist, "specialty_quieter");
	addNewOption("ks_specialist", 15, "Give ^5Stalker", ::giveSpecialist, "	specialty_stalker");
	addNewOption("ks_specialist", 16, "Give ^5Assassin", ::giveSpecialist, "specialty_heartbreaker");
	
	addNewMenu("ks_assault", "ks");
	addNewOption("ks_assault", 0, "Give ^5UAV", ::streak, "uav");
	addNewOption("ks_assault", 1, "Give ^5Carepackage", ::streak, "airdrop_assault");
	addNewOption("ks_assault", 2, "Give ^5IMS", ::streak, "ims");
	addNewOption("ks_assault", 3, "Give ^5Predator Missile", ::streak, "predator_missile");
	addNewOption("ks_assault", 4, "Give ^5Sentry Minigun Aidrop", ::streak, "airdrop_sentry_minigun");
	addNewOption("ks_assault", 5, "Give ^5Precision Airstrike", ::streak, "precision_airstrike");
	addNewOption("ks_assault", 6, "Give ^5Strafe Run", ::streak, "littlebird_flock");
	addNewOption("ks_assault", 7, "Give ^5AH6-Overwatch", ::streak, "littlebird_support");
	addNewOption("ks_assault", 8, "Give ^5Reaper", ::streak, "remote_mortar");
	addNewOption("ks_assault", 9, "Give ^5Assault Drone", ::streak, "airdrop_remote_tank");
	addNewOption("ks_assault", 10, "Give ^5AC130", ::streak, "ac130");
	addNewOption("ks_assault", 11, "Give ^5Pavelow", ::streak, "helicopter_flares");
	addNewOption("ks_assault", 12, "Give ^5Juggernaut", ::streak, "airdrop_juggernaut");
	addNewOption("ks_assault", 13, "Give ^5Osprey Gunner", ::streak, "osprey_gunner");
	
    addNewMenu("misc", "main"); //Misc Menu
    addNewOption("misc", 0, "Spawn Crate", ::SpawnCrate);
    addNewOption("misc", 1, "Grab Cords", ::CordsX);

    addNewMenu("bots", "main"); 
	//addNewOption("bots", 0, "Toggle Smart Bots Play", ::ToggleSmartBotsPlay);
	addNewOption("bots", 0, "^1Enemy ^7Bots ^5Menu", ::loadMenu, "enemyBots");
	addNewOption("bots", 1, "^2Friendly ^7Bots ^5Menu", ::loadMenu, "friendlyBots");
	
	addNewMenu("enemyBots", "bots"); 
    addNewOption("enemyBots", 0, "^7Spawn ^1Enemy ^7Bot", ::AddBot, "axis", "");
	//addNewOption("enemyBots", 1, "^7Spawn ^1Enemy ^7 Smart Bot", ::AddBot, "axis", "smart");
	addNewOption("enemyBots", 1, "^1Kick All Enemy Bots", ::KickBotsEnemy);
	addNewOption("enemyBots", 2, "^1Enemy Bots to Crosshairs", ::TeleportBotEnemy);
	addNewOption("enemyBots", 3, "^1Enemy Bots to You", ::ToggleBotSpawnEnemy);
	addNewOption("enemyBots", 4, "^1Toggle Enemy Bots Stance", ::StanceBotsEnemy);
	
	addNewMenu("friendlyBots", "bots"); 
	addNewOption("friendlyBots", 0, "^7Spawn ^2Friendly ^7Bot", ::AddBot, "allies", "");
	//addNewOption("friendlyBots", 1, "^7Spawn ^2Friendly ^7 Smart Bot", ::AddBot, "allies", "smart");
	addNewOption("friendlyBots", 1, "^2Kick All Friendly Bots", ::KickBotsFriendly);
	addNewOption("friendlyBots", 2, "^2Friendly Bots to Crosshairs", ::TeleportBotFriendly);
	addNewOption("friendlyBots", 3, "^2Friendly Bots to You", ::ToggleBotSpawnFriendly);
	addNewOption("friendlyBots", 4, "^2Toggle Friendly Bots Stance", ::StanceBotsFriendly);
	
	addNewMenu("lobby", "main");
	addNewOption("lobby", 0, "Map ^5Menu", ::loadMenu, "map menu");
    addNewOption("lobby", 1, "Pause/Resume Timer", ::PauseTimer);
	addNewOption("lobby", 2, "Toggle Double XP", ::ToggleDoubleXP);
	addNewOption("lobby", 3, "Toggle Team Colours", ::toggleTeamColours);
	addNewOption("lobby", 4, "Toggle Pickup Radius", ::pickupradius);
	addNewOption("lobby", 5, "Toggle Double Tap", ::doubletapstog);
    addNewOption("lobby", 6, "Toggle Reverse Ladder Mod", ::reverseladders);
	addNewOption("lobby", 7, "Toggle Knockback", ::toggleKnockback);
	addNewOption("lobby", 8, "Toggle Auto-Bunnyhop", ::toggleBunnyhop);
    addNewOption("lobby", 9, "Fast Restart", ::FastRestart);
	//addNewOption("lobby", 8, "Reset Rounds", ::roundreset); //removed because menu automatically does this
	
	addNewMenu("map menu", "lobby");
	addNewOption("map menu", 0, "^5Regular", ::loadMenu, "regular maps");
	addNewOption("map menu", 1, "^5DLC", ::loadMenu, "dlc maps");
	//addNewOption("map menu", 2, "^5Custom DLC", ::loadMenu, "custom dlc maps");
	
	addNewMenu("regular maps", "map menu");
	addNewOption("regular maps", 0, "Lockdown", ::changeMap, "mp_alpha"); 
	addNewOption("regular maps", 1, "Bootleg", ::changeMap, "mp_bootleg"); 
	addNewOption("regular maps", 2, "Mission", ::changeMap, "mp_bravo"); 
	addNewOption("regular maps", 3, "Carbon", ::changeMap, "mp_carbon"); 
	addNewOption("regular maps", 4, "Dome", ::changeMap, "mp_dome"); 
	addNewOption("regular maps", 5, "Downturn", ::changeMap, "mp_exchange"); 
	addNewOption("regular maps", 6, "Hardhat", ::changeMap, "mp_hardhat"); 
	addNewOption("regular maps", 7, "Interchange", ::changeMap, "mp_interchange"); 
	addNewOption("regular maps", 8, "Fallen", ::changeMap, "mp_lambeth"); 
	addNewOption("regular maps", 9, "Bakaara", ::changeMap, "mp_mogadishu"); 
	addNewOption("regular maps", 10, "Resistance", ::changeMap, "mp_paris"); 
	addNewOption("regular maps", 11, "Arkaden", ::changeMap, "mp_plaza2"); 
	addNewOption("regular maps", 12, "Outpost", ::changeMap, "mp_radar"); 
	addNewOption("regular maps", 13, "Seatown", ::changeMap, "mp_seatown"); 
	addNewOption("regular maps", 14, "Underground", ::changeMap, "mp_underground"); 
	addNewOption("regular maps", 15, "Village", ::changeMap, "mp_village"); 
	
	addNewMenu("dlc maps", "map menu");
	addNewOption("dlc maps", 0, "Aground", ::changeMap, "mp_aground_ss"); 
	addNewOption("dlc maps", 1, "Erosion", ::changeMap, "mp_aqueduct_ss"); 
	addNewOption("dlc maps", 2, "Terminal", ::changeMap, "mp_terminal_cls"); 
	addNewOption("dlc maps", 3, "Foundation", ::changeMap, "mp_cement"); 
	addNewOption("dlc maps", 4, "Getaway", ::changeMap, "mp_hillside_ss"); 
	addNewOption("dlc maps", 5, "Piazza", ::changeMap, "mp_italy"); 
	addNewOption("dlc maps", 6, "Sanctuary", ::changeMap, "mp_meteora"); 
	addNewOption("dlc maps", 7, "Black Box", ::changeMap, "mp_morningwood"); 
	addNewOption("dlc maps", 8, "Overwatch", ::changeMap, "mp_overwatch"); 
	addNewOption("dlc maps", 9, "Liberation", ::changeMap, "mp_park"); 
	addNewOption("dlc maps", 10, "Oasis", ::changeMap, "mp_qadeem"); 
	addNewOption("dlc maps", 11, "Lookout", ::changeMap, "mp_restrepo_ss");
	
	addNewMenu("custom dlc maps", "map menu");
	addNewOption("custom dlc maps", 0, "Highrise", ::changeMap, "mp_park"); 

	addNewMenu("weapons", "main");
	addNewOption("weapons", 0, "Take Current Weapon", ::takeweap);
    addNewOption("weapons", 1, "Drop Current Weapon", ::dropweap);
    addNewOption("weapons", 2, "Empty Clip", ::EmptyDaClip);
    addNewOption("weapons", 3, "Last Bullet In Clip", ::OneBulletClip);
    addNewOption("weapons", 4, "Snipers ^5Menu", ::loadMenu, "snipers");
	addNewOption("weapons", 5, "Pistols ^5Menu", ::loadMenu, "pistols");
	addNewOption("weapons", 6, "Machine Pistols ^5Menu", ::loadMenu, "machinepistols");
	addNewOption("weapons", 7, "Launchers ^5Menu", ::loadMenu, "launchers");
	addNewOption("weapons", 8, "Shotguns ^5Menu", ::loadMenu, "shotguns");
	
	addNewMenu("snipers", "weapons");
	addNewOption("snipers", 0, "Intervention", ::givetest, "iw5_cheytac_mp_cheytacscope");
	addNewOption("snipers", 1, "MSR", ::givetest, "iw5_msr_mp_msrscope_camo"+randomIntRange(10,13));
	addNewOption("snipers", 2, "L118A", ::givetest, "iw5_l96a1_mp_l96a1scope_camo"+randomIntRange(10,13));
	addNewOption("snipers", 3, "Dragunov", ::givetest, "iw5_dragunov_mp_dragunovscope_camo"+randomIntRange(10,13));
	addNewOption("snipers", 4, "AS50", ::givetest, "iw5_as50_mp_as50scope_camo"+randomIntRange(10,13));
	addNewOption("snipers", 5, "RSASS", ::givetest, "iw5_rsass_mp_rsassscope_camo"+randomIntRange(10,13));
	addNewOption("snipers", 6, "Barrett .50 Cal", ::givetest, "iw5_barrett_mp_barrettscope_camo"+randomIntRange(10,13));
	
	addNewMenu("pistols", "weapons");
	addNewOption("pistols", 0, "USP .45", ::givetest, "iw5_usp45_mp");
	addNewOption("pistols", 1, "P99", ::givetest, "iw5_p99_mp");
	addNewOption("pistols", 2, "MP412", ::givetest, "iw5_mp412_mp");
	addNewOption("pistols", 3, ".44 Magnum", ::givetest, "iw5_44magnum_mp");
	addNewOption("pistols", 4, "Five Seven", ::givetest, "iw5_fnfiveseven_mp");
	addNewOption("pistols", 5, "Desert Eagle", ::givetest, "iw5_deserteagle_mp");
	addNewOption("pistols", 6, "USP .45 ^5Akimbo", ::givetest, "iw5_usp45_akimbo_mp");
	addNewOption("pistols", 7, "P99 ^5Akimbo", ::givetest, "iw5_p99_akimbo_mp");
	addNewOption("pistols", 8, "MP412 ^5Akimbo", ::givetest, "iw5_mp412_akimbo_mp");
	addNewOption("pistols", 9, ".44 Magnum ^5Akimbo", ::givetest, "iw5_44magnum_akimbo_mp");
	addNewOption("pistols", 10, "Five Seven ^5Akimbo", ::givetest, "iw5_fnfiveseven_akimbo_mp");
	addNewOption("pistols", 11, "Desert Eagle ^5Akimbo", ::givetest, "iw5_deserteagle_akimbo_mp");
	
	addNewMenu("machinepistols", "weapons");
	addNewOption("machinepistols", 0, "FMG9", ::givetest, "iw5_fmg9_mp");
	addNewOption("machinepistols", 1, "MP9", ::givetest, "iw5_mp9_mp");
	addNewOption("machinepistols", 2, "Skorpion", ::givetest, "iw5_skorpion_mp");
	addNewOption("machinepistols", 3, "G18", ::givetest, "iw5_g18_mp");
	addNewOption("machinepistols", 4, "FMG9 ^5Akimbo", ::givetest, "iw5_fmg9_akimbo_mp");
	addNewOption("machinepistols", 5, "MP9 ^5Akimbo", ::givetest, "iw5_mp9_akimbo_mp");
	addNewOption("machinepistols", 6, "Skorpion ^5Akimbo", ::givetest, "iw5_skorpion_akimbo_mp");
	addNewOption("machinepistols", 7, "G18 ^5Akimbo", ::givetest, "iw5_g18_akimbo_mp");
	
	addNewMenu("launchers", "weapons");
	addNewOption("launchers", 0, "SMAW", ::givetest, "iw5_smaw_mp");
	addNewOption("launchers", 1, "Javelin", ::givetest, "iw5_javelin_mp");
	addNewOption("launchers", 2, "Stinger", ::givetest, "iw5_stinger_mp");
	addNewOption("launchers", 3, "XM25", ::givetest, "iw5_xm25_mp");
	addNewOption("launchers", 4, "M320 GLM", ::givetest, "iw5_m320_mp");
	addNewOption("launchers", 5, "RPG-7", ::givetest, "iw5_rpg_mp");
	
	addNewMenu("shotguns", "weapons");
	addNewOption("shotguns", 0, "USAS 12", ::givetest, "iw5_usas12_mp");
	addNewOption("shotguns", 1, "KSG", ::givetest, "iw5_ksg_mp");
	addNewOption("shotguns", 2, "SPAS-12", ::givetest, "iw5_spas12_mp_camo"+randomIntRange(10,13));
	addNewOption("shotguns", 3, "AA-12", ::givetest, "iw5_aa12_mp");
	addNewOption("shotguns", 4, "Striker", ::givetest, "iw5_striker_mp");
	addNewOption("shotguns", 5, "Model 1887", ::givetest, "iw5_1887_mp");
	
	//for(;;)
	//{
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
		//wait 2.5;
	//}
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
				if(!isDefined( self.DoubleTapTextRetro ))
				{
					self.DoubleTapTextRetro = "^2Enabled";
				}
				if(!isDefined( self.DoubleXPTextRetro ))
				{
					self.DoubleXPTextRetro = "^1Disabled";
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
				
				/*
				self.doubletaptext = createFontString("DEFAULT", 1.0);
				self.doubletaptext setPoint("LEFT", "CENTER", 80, -25);
				self.doubletaptext setText("Double Tap: " + self.DoubleTapTextRetro + " ");
				self.doubletaptext.archived = self.NotStealth;
				*/
				
				/*
				self.doublexptext = createFontString("DEFAULT", 1.0);
				self.doublexptext setPoint("LEFT", "CENTER", 80, -15);
				self.doublexptext setText("Double XP: " + self.DoubleXPTextRetro + " ");
				self.doublexptext.archived = self.NotStealth;
				*/
				
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