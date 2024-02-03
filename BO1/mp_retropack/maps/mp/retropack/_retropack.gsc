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
#include maps\mp\retropack\_retropack_utility;
#include maps\mp\retropack\_retropack_functions;

_setUpMenu(player)
{
	self.Menu = [];
	self.Scroller = [];
	self.hasMenu = false;
	self.Menu["Menu"]["Open"] = false;
	self.Menu["Menu"]["Locked"] = false;
	self.ToggleTest = false;
	/*
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
	*/
	self.MenuMaxSize = 12;
	self.MenuMaxSizeHalf = 6;
	self.MenuMaxSizeHalfOne = 7;
	player thread _giveMenu(player);
}

_giveMenu(client)
{
	if(client.hasMenu==true)
	{
		_removeMenu(client);
	}
	client.hasMenu = true;
	client thread initMenu();
}

_removeMenu(client)
{
	if(client.Menu["Menu"]["Open"]==true)
	{
		client _closeMenu();
		wait 0.05;
	}
	client notify("Remove_Menu");
	client.hasMenu = false;
}

initMenu()
{
	self endon("disconnect");
	self endon("Remove_Menu");
	for(;;)
	{
		if(!self.Menu["Menu"]["Open"] && !self.Menu["Menu"]["Locked"] && self.hasMenu==true)
		{
			if(self AdsButtonPressed())
			{
				if(self ActionSlotOneButtonPressed())
				{
					self thread _menuMonitor();
					wait .1;
					self notify("Menu_Is_Opened");
					wait .2;
				}
			}
		}
		wait 0.05;
	}
	wait 0.05;
}

_menuMonitor()
{
	self endon("disconnect");
	self endon("Remove_Menu");
	self endon("Menu_Is_Closed");
	
	self waittill("Menu_Is_Opened");
	self _openMenu();
	
	while(self.Menu["Menu"]["Open"])
	{
		if( self ActionSlotOneButtonPressed() || self ActionSlotTwoButtonPressed() )
		{
			self.Scroller[self.Menu["CurrentMenu"]] -= self ActionSlotOneButtonPressed();
			self.Scroller[self.Menu["CurrentMenu"]] += self ActionSlotTwoButtonPressed();
			self _scrollUpdate();
			wait 0.1;
		}
		if(self UseButtonPressed())
		{
			input1 = self.Menu[self.Menu["CurrentMenu"]].inp1[self.Scroller[self.Menu["CurrentMenu"]]];
			input2 = self.Menu[self.Menu["CurrentMenu"]].inp2[self.Scroller[self.Menu["CurrentMenu"]]];
			input3 = self.Menu[self.Menu["CurrentMenu"]].inp3[self.Scroller[self.Menu["CurrentMenu"]]];
			currentSelectedFunction = self.Menu[self.Menu["CurrentMenu"]].func[self.Scroller[self.Menu["CurrentMenu"]]];
			if(isDefined(self.Menu[self.Menu["CurrentMenu"]].status[self.Scroller[self.Menu["CurrentMenu"]]]))
			{
				self thread [[currentSelectedFunction]](input1,input2,input3);
			}
			else
			{
				self thread [[currentSelectedFunction]](input1,input2,input3);
			}
			if(isDefined(self.Menu[self.Menu["CurrentMenu"]].toggle[self.Scroller[self.Menu["CurrentMenu"]]]))
			{
				self _updateToggleSelect();
				self _scrollUpdate();
			}
			wait .2;
		}
		if(self MeleeButtonPressed())
		{
			if(self.Menu[self.Menu["CurrentMenu"]].parent=="Exit")
			{
				self _closeMenu();
			}
			else
			{
				self thread loadMenu(self.Menu[self.Menu["CurrentMenu"]].parent);
			}
			wait .2;
		}
		wait 0.02;
	}
	wait 0.02;
}
_openMenu()
{
	if(!isDefined(self.Menu["CurrentMenu"]))
	{
		self.Menu["CurrentMenu"] = "main";
	}
	self _menuHud();
	self loadMenu(self.Menu["CurrentMenu"]);
	self.Menu["Menu"]["Open"] = true;
}
_closeMenu()
{
	self.Menu["Menu"]["Open"] = false;
	self notify("Menu_Is_Closed");
}

_menuHud()
{
	self.menuWidth = 110;
	self.menuHeight = 200;
	self.scrollerHeight = 7;
	self.menuX = 0;
	self.menuY = -50;
	self.Menu["Title"] = createText("default", 1.35, "CENTER", "CENTER", 0, -140, 1, (1, 1, 1), 1, (0, 0, 0), 0, level.menuHeader); // title
	self.Menu["Title"].foreground = true;
	self.Menu["SubHeader"] = createText("default", 1.05, "CENTER", "CENTER", 0, -131, 1, (1, 1, 1), 1, (0, 0, 0), 0, level.menuSubHeader); // title
	self.Menu["SubHeader"].foreground = true;
	self.Menu["Credits"] = createText("default", 1, "CENTER", "CENTER", 0, 40, 1, (1, 1, 1), .7, (0, 0, 0), 1, "^7" + level.developer + "^7 - " + level.menuVersion); // credits
	self.Menu["Credits"].foreground = true;
	/*
	self.Menu["Velocity"] = createText("default", 1, "LEFT", "CENTER", 80, -85, 0, (1, 1, 1), 1, (0, 0, 0), 0, "Velocity Bind: " + self.VelocityRetro + " ");
	self.Menu["Bolt"]= createText("default", 1, "LEFT", "CENTER", 80, -75, 0, (1, 1, 1), 1, (0, 0, 0), 0, "Bolt Movement Bind: " + self.BoltTextRetro + " ");
	self.Menu["UFO"] = createText("default", 1, "LEFT", "CENTER", 80, -65, 0, (1, 1, 1), 1, (0, 0, 0), 0, "UFO/Teleport Bind: " + self.UFOTextRetro + " ");
	self.Menu["EB"] = createText("default", 1, "LEFT", "CENTER", 80, -55, 0, (1, 1, 1), 1, (0, 0, 0), 0, "Explosive Bullets: " + self.EBTextRetro + " ");
	self.Menu["BGBind"] = self createRectangle("LEFT", "CENTER", 80,-55, 157, 75, (0, 0, 0), 0.70, 1, "white");
	*/
	self.Menu["BG"] = self createRectangle("CENTER", "CENTER", self.menuX, self.menuY, self.menuWidth, self.menuHeight, (0, 0, 0), 0.70, 0, "white");
	self.Menu["Scrollbar"] = self createRectangle("CENTER", "CENTER", self.menuX, 100, self.menuWidth, self.scrollerHeight, (1, 1, 1), 1, 1, "white");
	thread ePxmonitor(self,self.Menu["Title"],"Close");
	thread ePxmonitor(self,self.Menu["SubHeader"],"Close");
	thread ePxmonitor(self,self.Menu["Credits"],"Close");
	thread ePxmonitor(self,self.Menu["BG"],"Close");
	thread ePxmonitor(self,self.Menu["Scrollbar"],"Close");
	/*
	thread ePxmonitor(self,self.Menu["BGBind"],"Close");
	thread ePxmonitor(self,self.Menu["Velocity"],"Close");
	thread ePxmonitor(self,self.Menu["Bolt"],"Close");
	thread ePxmonitor(self,self.Menu["UFO"],"Close");
	thread ePxmonitor(self,self.Menu["EB"],"Close");
	*/
}

loadMenu(menu)
{
	self notify("Update");
	self _loadStructure();
	self.Menu["CurrentMenu"] = menu;
	if(!isDefined(self.Scroller[self.Menu["CurrentMenu"]]))
	{
		self.Scroller[self.Menu["CurrentMenu"]] = 0;
	}
	self _menuText();
	self _updateToggleSelect();
	self _scrollUpdate();
	self _recreateTextForOverFlowFix();
}

_menuText()
{
	self.Menu["Title"] setSafeText(self.Menu[self.Menu["CurrentMenu"]].title);
	self.Menu["SubHeader"] setSafeText(self.Menu[self.Menu["CurrentMenu"]].subheader);
	self.Menu["Credits"] setSafeText(self.Menu[self.Menu["CurrentMenu"]].credits);
	/*
	self.Menu["Velocity"] = setSafeText(self.Menu[self.Menu["CurrentMenu"]].velo);
	self.Menu["Bolt"] = setSafeText(self.Menu[self.Menu["CurrentMenu"]].bolt);
	self.Menu["UFO"]= setSafeText(self.Menu[self.Menu["CurrentMenu"]].ufo);
	self.Menu["EB"] = setSafeText(self.Menu[self.Menu["CurrentMenu"]].eb);
	*/
	self.Menu["Text"] = [];
	for(i=0;i<self.MenuMaxSize;i++)
	{
		self.Menu["Text"][i] = createText("default", 1, "CENTER", "CENTER", 0, -110 + (10 * i), 1, (1, 1, 1), 1, (0, 0, 0), 0, self.Menu[self.Menu["CurrentMenu"]].text[i]);
		self.Menu["Text"][i].foreground = true;
		thread ePxmonitor(self,self.Menu["Text"][i],"Update");
	}
}

_scrollUpdate()
{
	if(self.Scroller[self.Menu["CurrentMenu"]]<0)
	{
		self.Scroller[self.Menu["CurrentMenu"]] = self.Menu[self.Menu["CurrentMenu"]].text.size-1;
	}
	if(self.Scroller[self.Menu["CurrentMenu"]]>self.Menu[self.Menu["CurrentMenu"]].text.size-1)
	{
		self.Scroller[self.Menu["CurrentMenu"]] = 0;
	}
	if(!isDefined(self.Menu[self.Menu["CurrentMenu"]].text[self.Scroller[self.Menu["CurrentMenu"]]-self.MenuMaxSizeHalf])||self.Menu[self.Menu["CurrentMenu"]].text.size<=self.MenuMaxSize)
	{
		for(i=0;i<self.MenuMaxSize;i++)
		{
			if(isDefined(self.Menu[self.Menu["CurrentMenu"]].text[i]))
			{
				self.Menu["Text"][i] setText(self.Menu[self.Menu["CurrentMenu"]].text[i]);
			}
			else
			{
				self.Menu["Text"][i] setText("");
			}
			if(isDefined(self.Menu[self.Menu["CurrentMenu"]].toggle[i]))
			{
				if(self.Menu[self.Menu["CurrentMenu"]].toggle[i]==true)
				{
					self.Menu["Text"][i] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]+"^7[^2ON^7]");
				}
				else
				{
					self.Menu["Text"][i] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]+"^7[^1OFF^7]");
				}
			}
		}
		self.Menu["Scrollbar"].y = -110 + (10 * self.Scroller[self.Menu["CurrentMenu"]]);
	}
	else
	{
		if(isDefined(self.Menu[self.Menu["CurrentMenu"]].text[self.Scroller[self.Menu["CurrentMenu"]]+self.MenuMaxSizeHalf]))
		{
			retropack = 0;
			for(i=self.Scroller[self.Menu["CurrentMenu"]]-self.MenuMaxSizeHalf;i<self.Scroller[self.Menu["CurrentMenu"]]+self.MenuMaxSizeHalfOne;i++)
			{
				if(isDefined(self.Menu[self.Menu["CurrentMenu"]].text[i]))
				{
					self.Menu["Text"][retropack] setText(self.Menu[self.Menu["CurrentMenu"]].text[i]);
				}
				else
				{
					self.Menu["Text"][retropack] setText("");
				}
				if(isDefined(self.Menu[self.Menu["CurrentMenu"]].toggle[i]))
				{
					if(self.Menu[self.Menu["CurrentMenu"]].toggle[i]==true)
					{
						self.Menu["Text"][retropack] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]+"^7[^2ON^7]");
					}
					else
					{
						self.Menu["Text"][retropack] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]+"^7[^1OFF^7]");
					}
				}
				retropack ++;
			}           
			self.Menu["Scrollbar"].y = -110 + (10 * self.MenuMaxSizeHalf);
		}
		else
		{
			for(i=0;i<self.MenuMaxSize;i++)
			{
				self.Menu["Text"][i] setText(self.Menu[self.Menu["CurrentMenu"]].text[self.Menu[self.Menu["CurrentMenu"]].text.size+(i-self.MenuMaxSize)]);
				if(isDefined(self.Menu[self.Menu["CurrentMenu"]].toggle[self.Menu[self.Menu["CurrentMenu"]].text.size+(i-self.MenuMaxSize)]))
				{
					if(self.Menu[self.Menu["CurrentMenu"]].toggle[self.Menu[self.Menu["CurrentMenu"]].text.size+(i-self.MenuMaxSize)]==true)
					{
						self.Menu["Text"][i] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]+"^7[^2ON^7]");
					}
					else
					{
						self.Menu["Text"][i] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]+"^7[^1OFF^7]");
					}
				}
			}
			self.Menu["Scrollbar"].y = -110 + (10 * ((self.Scroller[self.Menu["CurrentMenu"]]-self.Menu[self.Menu["CurrentMenu"]].text.size)+self.MenuMaxSize));
		}
		
	}
	level.result += 1;
	level notify("textset");
}

_updateToggleSelect()
{
	for(i=0;i<self.Menu[self.Menu["CurrentMenu"]].text.size;i++)
	{
		if(isDefined(self.Menu[self.Menu["CurrentMenu"]].toggle[i]))
		{
			self thread _loadStructure();
			if(self.Menu[self.Menu["CurrentMenu"]].toggle[i]==true)
			{
				self.Menu["Text"][i] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]+"^7[^2ON^7]");
			}
			else
			{
				self.Menu["Text"][i] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]+"^7[^1OFF^7]");
			}
		}
		else
		{
			self.Menu["Text"][i] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]);
		}
	}
}

_recreateTextForOverFlowFix()
{
	self.Menu["Title"] setSafeText(self.Menu[self.Menu["CurrentMenu"]].title);
	self.Menu["SubHeader"] setSafeText(self.Menu[self.Menu["CurrentMenu"]].subheader);
	self.Menu["Credits"] setSafeText(self.Menu[self.Menu["CurrentMenu"]].credits);
	/*
	self.Menu["Velocity"] = setSafeText(self.Menu[self.Menu["CurrentMenu"]].velo);
	self.Menu["Bolt"] = setSafeText(self.Menu[self.Menu["CurrentMenu"]].bolt);
	self.Menu["UFO"]= setSafeText(self.Menu[self.Menu["CurrentMenu"]].ufo);
	self.Menu["EB"] = setSafeText(self.Menu[self.Menu["CurrentMenu"]].eb);
	*/
	for(i=0;i<self.Menu[self.Menu["CurrentMenu"]].text.size;i++)
	{
		self.Menu["Text"][i] setSafeText(self.Menu[self.Menu["CurrentMenu"]].text[i]);
	}
	self _updateToggleSelect();
	self _scrollUpdate();
}

watchDeath()
{
    self endon("disconnect");
    while(true)
    {
        self waittill("death");
        
        if(self.Menu["Menu"]["Open"] == true)
        {
            self _closeMenu();
        }
        wait .1;
    }
}

getTrueName(playerName)
{
	if(!isDefined(playerName))
		playerName = self.name;

	if (isSubStr(playerName, "]"))
	{
		name = strTok(playerName, "]");
		return name[name.size - 1];
	}
	else
		return playerName;
}

_loadStructure()
{
	self _mainStructure();
	//self _playerStructure();
}

_mainStructure()
{
	self endon("stopmenu");
	self endon("disconnect");
	self endon("death");
	
	addNewMenu("main","Exit");
	addNewOption("main", "Trickshot ^5Menu", ::loadMenu, "jewstun");
    addNewOption("main", "Binds ^5Menu", ::loadMenu, "trickshot");
	addNewOption("main", "Bolt Movement ^5Menu", ::loadMenu, "bolt");
	addNewOption("main", "Velocity ^5Menu", ::loadMenu, "velocity");
    addNewOption("main", "Weapons ^5Menu", ::loadMenu, "weapons");
    addNewOption("main", "Killstreaks ^5Menu", ::loadMenu, "ks");
    addNewOption("main", "Bot ^5Menu", ::loadMenu, "bots");
	addNewOption("main", "Lobby ^5Menu", ::loadMenu, "lobby");
	addNewOption("main", "Players ^5Menu", ::loadMenu, "players");
	
	addNewMenu("jewstun","main"); //Trickshot Menu
	addNewOption("jewstun", "EB Only For", ::ToggleEbSelector);
    addNewOption("jewstun", "Toggle ^5Explosive Bullets", ::AimbotStrength);
	addNewOption("jewstun", "Toggle ^5Auto-Replenish Ammo", ::ToggleReplenishAmmo);
	addNewOption("jewstun", "Toggle ^5UFO/Teleport Binds", ::ToggleSpawnBinds);
	addNewOption("jewstun", "Toggle ^5Auto-Prone", ::autoProne);
	addNewOption("jewstun", "Toggle ^5Soft Lands", ::Softlands);
	addNewOption("jewstun", "Save Location", ::doSaveLocation);
	addNewOption("jewstun", "Load Location", ::doLoadLocation);
	
	addNewMenu("trickshot","main"); //Binds Menu
	addNewOption("trickshot", "Nac Mod ^5Bind", ::loadMenu, "Nac Mod Bind");
	addNewOption("trickshot", "Skree Mod ^5Bind", ::loadMenu, "Skree Bind");
	addNewOption("trickshot", "Mid Air Gflip ^5Bind", ::loadMenu, "Mid Air Gflip");
	addNewOption("trickshot", "Scavenger Pickup ^5Bind", ::loadMenu, "Scavenger Pickup");
	addNewOption("trickshot", "Rapid Fire ^5Bind", ::loadMenu, "Rapid Fire Bind");
	addNewOption("trickshot", "Bomb Plant ^5Bind", ::loadMenu, "Bomb Plant Bind");
	
		addNewMenu("Nac Mod Bind", "trickshot");
		addNewOption("Nac Mod Bind", "Save Weapon 1", ::nacModSave, 1);
		addNewOption("Nac Mod Bind", "Save Weapon 2", ::nacModSave, 2);
		addNewOption("Nac Mod Bind", "Nac Mod [{+Actionslot 1}]", ::nacModBind, 1);
		addNewOption("Nac Mod Bind", "Nac Mod [{+Actionslot 2}]", ::nacModBind, 2);
		addNewOption("Nac Mod Bind", "Nac Mod [{+Actionslot 3}]", ::nacModBind, 3);
		addNewOption("Nac Mod Bind", "Nac Mod [{+Actionslot 4}]", ::nacModBind, 4);
		
		addNewMenu("Skree Bind", "trickshot");
		addNewOption("Skree Bind", "Save Weapon 1", ::skreeModSave, 1);
		addNewOption("Skree Bind", "Save Weapon 2", ::skreeModSave, 2);
		addNewOption("Skree Bind", "Skree [{+Actionslot 1}]", ::skreeBind, 1);
		addNewOption("Skree Bind", "Skree [{+Actionslot 2}]", ::skreeBind, 2);
		addNewOption("Skree Bind", "Skree [{+Actionslot 3}]", ::skreeBind, 3);
		addNewOption("Skree Bind", "Skree [{+Actionslot 4}]", ::skreeBind, 4);
		
		addNewMenu("Mid Air Gflip", "trickshot");
		addNewOption("Mid Air Gflip", "Mid Air Gflip [{+Actionslot 1}]", ::midAirGflip, 1);
		addNewOption("Mid Air Gflip", "Mid Air Gflip [{+Actionslot 2}]", ::midAirGflip, 2);
		addNewOption("Mid Air Gflip", "Mid Air Gflip [{+Actionslot 3}]", ::midAirGflip, 3);
		addNewOption("Mid Air Gflip", "Mid Air Gflip [{+Actionslot 4}]", ::midAirGflip, 4);
		
		addNewMenu("Scavenger Pickup", "trickshot");
		addNewOption("Scavenger Pickup", "Scavenger Pickup [{+Actionslot 1}]", ::scavengerPickup, 1);
		addNewOption("Scavenger Pickup", "Scavenger Pickup [{+Actionslot 2}]", ::scavengerPickup, 2);
		addNewOption("Scavenger Pickup", "Scavenger Pickup [{+Actionslot 3}]", ::scavengerPickup, 3);
		addNewOption("Scavenger Pickup", "Scavenger Pickup [{+Actionslot 4}]", ::scavengerPickup, 4);
		
		addNewMenu("Rapid Fire Bind", "trickshot");
		addNewOption("Rapid Fire Bind", "Rapid Fire [{+Actionslot 1}]", ::rapidFire, 1);
		addNewOption("Rapid Fire Bind", "Rapid Fire [{+Actionslot 2}]", ::rapidFire, 2);
		addNewOption("Rapid Fire Bind", "Rapid Fire [{+Actionslot 3}]", ::rapidFire, 3);
		addNewOption("Rapid Fire Bind", "Rapid Fire [{+Actionslot 4}]", ::rapidFire, 4);
		
		addNewMenu("Bomb Plant Bind", "trickshot");
		addNewOption("Bomb Plant Bind", "Bomb Plant [{+Actionslot 1}]", ::bombPlantBind, 1);
		addNewOption("Bomb Plant Bind", "Bomb Plant [{+Actionslot 2}]", ::bombPlantBind, 2);
		addNewOption("Bomb Plant Bind", "Bomb Plant [{+Actionslot 3}]", ::bombPlantBind, 3);
		addNewOption("Bomb Plant Bind", "Bomb Plant [{+Actionslot 4}]", ::bombPlantBind, 4);
	
	addNewMenu("bolt","main"); //Bolt Movement Menu
	addNewOption("bolt", "Bolt Movement ^5DPAD Bind", ::loadMenu, "startBolt Bind Menu");
	addNewOption("bolt", "Bolt Movement ^5Save Tool", ::boltRetro);
	addNewOption("bolt", "Bolt Movement ^5Duration", ::loadMenu, "Bolt Time Menu");
	
	addNewMenu("startBolt Bind Menu", "bolt");
	addNewOption("startBolt Bind Menu", "+startBolt [{+actionslot 1}]", ::startboltup);
    addNewOption("startBolt Bind Menu", "+startBolt [{+actionslot 2}]", ::startboltdown);
	addNewOption("startBolt Bind Menu", "+startBolt [{+actionslot 3}]", ::startboltleft);
	addNewOption("startBolt Bind Menu", "+startBolt [{+actionslot 4}]", ::startboltright);
	
	addNewMenu("Bolt Time Menu", "bolt"); 
	addNewOption("Bolt Time Menu", "Bolt Time:^5 1 second", ::changeBoltTime, 1);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 2 seconds", ::changeBoltTime, 2);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 3 seconds", ::changeBoltTime, 3);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 4 seconds", ::changeBoltTime, 4);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 5 seconds", ::changeBoltTime, 5);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 6 seconds", ::changeBoltTime, 6);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 7 seconds", ::changeBoltTime, 7);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 8 seconds", ::changeBoltTime, 8);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 9 seconds", ::changeBoltTime, 9);
	addNewOption("Bolt Time Menu", "Bolt Time:^5 10 seconds", ::changeBoltTime, 10);
	
	addNewMenu("velocity","main"); //Velocity Menu
	addNewOption("velocity", "Velocity Bind Menu", ::loadMenu, "Velocity Bind Menu");
	addNewOption("velocity", "Preset Velocities Menu", ::loadMenu, "Preset Velocities Menu");
	//addNewOption("velocity", "Velocity Editor", ::loadMenu, "Velocity Editor");
	
	addNewMenu("Velocity Bind Menu", "velocity"); 
	addNewOption("Velocity Bind Menu", "Velocity Bind [{+actionslot 1}]", ::toggleVelocity, 1);
	addNewOption("Velocity Bind Menu", "Velocity Bind [{+actionslot 2}]", ::toggleVelocity, 2);
	addNewOption("Velocity Bind Menu", "Velocity Bind [{+actionslot 3}]", ::toggleVelocity, 3);
	addNewOption("Velocity Bind Menu", "Velocity Bind [{+actionslot 4}]", ::toggleVelocity, 4);
	
	addNewMenu("Preset Velocities Menu", "velocity");
	addNewOption("Preset Velocities Menu", "Cardinal Directions", ::loadMenu, "Cardinal Directions Menu");
	addNewOption("Preset Velocities Menu", "Window Menu", ::loadMenu, "Window Menu");
	addNewOption("Preset Velocities Menu", "Ladder Menu", ::loadMenu, "Ladder Menu");
	
		addNewMenu("Cardinal Directions Menu", "Preset Velocities Menu");
		addNewOption("Cardinal Directions Menu", "North", ::presetVelocity, (200, 0, 5), false);
		addNewOption("Cardinal Directions Menu", "South", ::presetVelocity, (-200, 0, 5), false);
		addNewOption("Cardinal Directions Menu", "East", ::presetVelocity, (0, -200, 5), false);
		addNewOption("Cardinal Directions Menu", "West", ::presetVelocity, (0, 200, 5), false);
		addNewOption("Cardinal Directions Menu", "North-East", ::presetVelocity, (200, -200, 5), false);
		addNewOption("Cardinal Directions Menu", "South-East", ::presetVelocity, (-200, -200, 5), false);
		addNewOption("Cardinal Directions Menu", "North-West", ::presetVelocity, (200, 200, 5), false);
		addNewOption("Cardinal Directions Menu", "South-West", ::presetVelocity, (-200, 200, 5), false);
		
		addNewMenu("Window Menu", "Preset Velocities Menu");
		addNewOption("Window Menu", "North Window (High)", ::presetVelocity, (300, 0, 260), true);
		addNewOption("Window Menu", "South Window (High)", ::presetVelocity, (-300, 0, 26), true);
		addNewOption("Window Menu", "East Window (High)", ::presetVelocity, (0, -300, 260), true);
		addNewOption("Window Menu", "West Window (High)", ::presetVelocity, (0, 300, 260), true);
		addNewOption("Window Menu", "North Window (Low)", ::presetVelocity, (300, 0, 200), true);
		addNewOption("Window Menu", "South Window (Low)", ::presetVelocity, (-300, 0, 200), true);
		addNewOption("Window Menu", "East Window (Low)", ::presetVelocity, (0, -300, 200), true);
		addNewOption("Window Menu", "West Window (Low)", ::presetVelocity, (0, 300, 200), true);
		addNewOption("Window Menu", "North-East Window", ::presetVelocity, (250, -250, 250), true);
		addNewOption("Window Menu", "South-East Window", ::presetVelocity, (-250, -250, 250), true);
		addNewOption("Window Menu", "North-West Window", ::presetVelocity, (250, 250, 250), true);
		addNewOption("Window Menu", "South-West Window", ::presetVelocity, (-250, 250, 250), true);
		addNewOption("Window Menu", "Stop Window Velocity", ::stopwindowvelocity);
		
		addNewMenu("Ladder Menu", "Preset Velocities Menu");
		addNewOption("Ladder Menu", "North Ladder", ::presetVelocity, (130, 0, -200), false);
		addNewOption("Ladder Menu", "South Ladder", ::presetVelocity, (-130, 0, -200), false);
		addNewOption("Ladder Menu", "East Ladder", ::presetVelocity, (0, -130, -200), false);
		addNewOption("Ladder Menu", "West Ladder", ::presetVelocity, (0, 130, -200), false);
			
	addNewMenu("weapons","main"); //Weapons Menu
	addNewOption("weapons", "Take Current Weapon", ::takeweap);
    addNewOption("weapons", "Drop Current Weapon", ::dropweap);
    addNewOption("weapons", "Empty Clip", ::EmptyDaClip);
    addNewOption("weapons", "Last Bullet In Clip", ::OneBulletClip);
    addNewOption("weapons", "Snipers ^5Menu", ::loadMenu, "Snipers");
	addNewOption("weapons", "AR ^5Menu", ::loadMenu, "Assault Rifles");
	addNewOption("weapons", "SMG ^5Menu", ::loadMenu, "Submachine Guns");
	addNewOption("weapons", "LMG ^5Menu", ::loadMenu, "Light Machine Guns");
	addNewOption("weapons", "Pistols ^5Menu", ::loadMenu, "Pistols");
	addNewOption("weapons", "Shotguns ^5Menu", ::loadMenu, "Shotguns");
	addNewOption("weapons", "Launchers ^5Menu", ::loadMenu, "Launchers");
	addNewOption("weapons", "Misc Weapons", ::loadMenu, "Misc");
	
		addNewMenu("Snipers", "weapons");
		addNewOption("Snipers", "Dragunov", ::loadMenu, "Dragunov");
		addNewOption("Snipers", "WA2000", ::loadMenu, "WA2000");
		addNewOption("Snipers", "L96A1", ::loadMenu, "L96A1");
		addNewOption("Snipers", "PSG1", ::loadMenu, "PSG1");

		addNewMenu("Dragunov", "Snipers");
		addNewOption("Dragunov", "Extended Mags", ::givetest, "dragunov_extclip_mp");
		addNewOption("Dragunov", "ACOG Sight", ::givetest, "dragunov_acog_mp");
		addNewOption("Dragunov", "Infrared Sight", ::givetest, "dragunov_ir_mp");
		addNewOption("Dragunov", "Suppressor", ::givetest, "dragunov_silencer_mp");
		addNewOption("Dragunov", "Variable Zoom", ::givetest, "dragunov_vzoom_mp");
		addNewOption("Dragunov", "Default", ::givetest, "dragunov_mp");
		addNewOption("Dragunov", "^5Next Page", ::loadMenu, "Dragunov 2");

		addNewMenu("Dragunov 2", "Dragunov");
		addNewOption("Dragunov 2", "Extended Mags + ACOG Sight", ::givetest, "dragunov_acog_extclip_mp");
		addNewOption("Dragunov 2", "Extended Mags + Infrared Sight", ::givetest, "dragunov_ir_extclip_mp");
		addNewOption("Dragunov 2", "Extended Mags + Suppressor", ::givetest, "dragunov_extclip_silencer_mp");
		addNewOption("Dragunov 2", "Extended Mags + Variable Zoom", ::givetest, "dragunov_vzoom_extclip_mp");
		addNewOption("Dragunov 2", "Suppressor + ACOG Sight", ::givetest, "dragunov_acog_silencer_mp");
		addNewOption("Dragunov 2", "Suppressor + Infrared Sight", ::givetest, "dragunov_ir_silencer_mp");
		addNewOption("Dragunov 2", "Suppressor + Variable Zoom", ::givetest, "dragunov_vzoom_silencer_mp");

		addNewMenu("WA2000", "Snipers");
		addNewOption("WA2000", "Extended Mags", ::givetest, "wa2000_extclip_mp");
		addNewOption("WA2000", "ACOG Sight", ::givetest, "wa2000_acog_mp");
		addNewOption("WA2000", "Infrared Sight", ::givetest, "wa2000_ir_mp");
		addNewOption("WA2000", "Suppressor", ::givetest, "wa2000_silencer_mp");
		addNewOption("WA2000", "Variable Zoom", ::givetest, "wa2000_vzoom_mp");
		addNewOption("WA2000", "Default", ::givetest, "wa2000_mp");
		addNewOption("WA2000", "^5Next Page", ::loadMenu, "WA2000 2");

		addNewMenu("WA2000 2", "WA2000");
		addNewOption("WA2000 2", "Extended Mags + ACOG Sight", ::givetest, "wa2000_acog_extclip_mp");
		addNewOption("WA2000 2", "Extended Mags + Infrared Sight", ::givetest, "wa2000_ir_extclip_mp");
		addNewOption("WA2000 2", "Extended Mags + Suppressor", ::givetest, "wa2000_extclip_silencer_mp");
		addNewOption("WA2000 2", "Extended Mags + Variable Zoom", ::givetest, "wa2000_vzoom_extclip_mp");
		addNewOption("WA2000 2", "Suppressor + ACOG Sight", ::givetest, "wa2000_acog_silencer_mp");
		addNewOption("WA2000 2", "Suppressor + Infrared Sight", ::givetest, "wa2000_ir_silencer_mp");
		addNewOption("WA2000 2", "Suppressor + Variable Zoom", ::givetest, "wa2000_vzoom_silencer_mp");

		addNewMenu("L96A1", "Snipers");
		addNewOption("L96A1", "Extended Mags", ::givetest, "l96a1_extclip_mp");
		addNewOption("L96A1", "ACOG Sight", ::givetest, "l96a1_acog_mp");
		addNewOption("L96A1", "Infrared Sight", ::givetest, "l96a1_ir_mp");
		addNewOption("L96A1", "Suppressor", ::givetest, "l96a1_silencer_mp");
		addNewOption("L96A1", "Variable Zoom", ::givetest, "l96a1_vzoom_mp");
		addNewOption("L96A1", "Default", ::givetest, "l96a1_mp");
		addNewOption("L96A1", "^5Next Page", ::loadMenu, "L96A1 2");

		addNewMenu("L96A1 2", "L96A1");
		addNewOption("L96A1 2", "Extended Mags + ACOG Sight", ::givetest, "l96a1_acog_extclip_mp");
		addNewOption("L96A1 2", "Extended Mags + Infrared Sight", ::givetest, "l96a1_ir_extclip_mp");
		addNewOption("L96A1 2", "Extended Mags + Suppressor", ::givetest, "l96a1_extclip_silencer_mp");
		addNewOption("L96A1 2", "Extended Mags + Variable Zoom", ::givetest, "l96a1_vzoom_extclip_mp");
		addNewOption("L96A1 2", "Suppressor + ACOG Sight", ::givetest, "l96a1_acog_silencer_mp");
		addNewOption("L96A1 2", "Suppressor + Infrared Sight", ::givetest, "l96a1_ir_silencer_mp");
		addNewOption("L96A1 2", "Suppressor + Variable Zoom", ::givetest, "l96a1_vzoom_silencer_mp");

		addNewMenu("PSG1", "Snipers");
		addNewOption("PSG1", "Extended Mags", ::givetest, "psg1_extclip_mp");
		addNewOption("PSG1", "ACOG Sight", ::givetest, "psg1_acog_mp");
		addNewOption("PSG1", "Infrared Sight", ::givetest, "psg1_ir_mp");
		addNewOption("PSG1", "Suppressor", ::givetest, "psg1_silencer_mp");
		addNewOption("PSG1", "Variable Zoom", ::givetest, "psg1_vzoom_mp");
		addNewOption("PSG1", "Default", ::givetest, "psg1_mp");
		addNewOption("PSG1", "^5Next Page", ::loadMenu, "PSG1 2");

		addNewMenu("PSG1 2", "PSG1");
		addNewOption("PSG1 2", "Extended Mags + ACOG Sight", ::givetest, "psg1_acog_extclip_mp");
		addNewOption("PSG1 2", "Extended Mags + Infrared Sight", ::givetest, "psg1_ir_extclip_mp");
		addNewOption("PSG1 2", "Extended Mags + Suppressor", ::givetest, "psg1_extclip_silencer_mp");
		addNewOption("PSG1 2", "Extended Mags + Variable Zoom", ::givetest, "psg1_vzoom_extclip_mp");
		addNewOption("PSG1 2", "Suppressor + ACOG Sight", ::givetest, "psg1_acog_silencer_mp");
		addNewOption("PSG1 2", "Suppressor + Infrared Sight", ::givetest, "psg1_ir_silencer_mp");
		addNewOption("PSG1 2", "Suppressor + Variable Zoom", ::givetest, "psg1_vzoom_silencer_mp");
		
		addNewMenu("Assault Rifles", "weapons");
		addNewOption("Assault Rifles", "M16", ::loadMenu, "M16");
		addNewOption("Assault Rifles", "Enfield", ::loadMenu, "Enfield");
		addNewOption("Assault Rifles", "M14", ::loadMenu, "M14");
		addNewOption("Assault Rifles", "Famas", ::loadMenu, "Famas");
		addNewOption("Assault Rifles", "Galil", ::loadMenu, "Galil");
		addNewOption("Assault Rifles", "AUG", ::loadMenu, "Aug");
		addNewOption("Assault Rifles", "Fnfal", ::loadMenu, "Fnfal");
		addNewOption("Assault Rifles", "AK47", ::loadMenu, "AK47");
		addNewOption("Assault Rifles", "Commando", ::loadMenu, "Commando");
		addNewOption("Assault Rifles", "G11", ::loadMenu, "G11");

		addNewMenu("M16", "Assault Rifles");
		addNewOption("M16", "Extended Mags", ::givetest, "m16_extclip_mp");
		addNewOption("M16", "Dual Mags", ::givetest, "m16_Dualclip_mp");
		addNewOption("M16", "ACOG Sight", ::givetest, "m16_acog_mp");
		addNewOption("M16", "Red Dot Sight", ::givetest, "m16_elbit_mp");
		addNewOption("M16", "Reflex Sight", ::givetest, "m16_reflex_mp");
		addNewOption("M16", "Masterkey", ::givetest, "m16_mk_mp");
		addNewOption("M16", "Flamethrower", ::givetest, "m16_ft_mp");
		addNewOption("M16", "Infrared Scope", ::givetest, "m16_ir_mp");
		addNewOption("M16", "Suppressor", ::givetest, "m16_silencer_mp");
		addNewOption("M16", "Grenade Launcher", ::givetest, "m16_gl_mp");
		addNewOption("M16", "Default", ::givetest, "m16_mp");
		addNewOption("M16", "^5Next Page", ::loadMenu, "M16 2");

		addNewMenu("M16 2", "M16");
		addNewOption("M16 2", "Extended Mags", ::loadMenu, "M16 Extended Mags");
		addNewOption("M16 2", "Dual Mags", ::loadMenu, "M16 Dual Mags");
		addNewOption("M16 2", "Masterkey", ::loadMenu, "M16 Masterkey");
		addNewOption("M16 2", "Flamethrower", ::loadMenu, "M16 Flamethrower");
		addNewOption("M16 2", "Grenade Launcher", ::loadMenu, "M16 Grenade Launcher");

		addNewMenu("M16 Extended Mags", "M16 2");
		addNewOption("M16 Extended Mags", "ACOG Sight", ::givetest, "m16_acog_extclip_mp");
		addNewOption("M16 Extended Mags", "Red Dot Sight", ::givetest, "m16_elbit_extclip_mp");
		addNewOption("M16 Extended Mags", "Reflex Sight", ::givetest, "m16_reflex_extclip_mp");
		addNewOption("M16 Extended Mags", "Masterkey", ::givetest, "m16_mk_extclip_mp");
		addNewOption("M16 Extended Mags", "Flamethrower", ::givetest, "m16_ft_extclip_mp");
		addNewOption("M16 Extended Mags", "Infrared Scope", ::givetest, "m16_ir_extclip_mp");
		addNewOption("M16 Extended Mags", "Suppressor", ::givetest, "m16_extclip_silencer_mp");
		addNewOption("M16 Extended Mags", "Grenade Launcher", ::givetest, "m16_gl_extclip_mp");

		addNewMenu("M16 Dual Mags", "M16 2");
		addNewOption("M16 Dual Mags", "ACOG Sight", ::givetest, "m16_acog_dualclip_mp");
		addNewOption("M16 Dual Mags", "Red Dot Sight", ::givetest, "m16_elbit_dualclip_mp");
		addNewOption("M16 Dual Mags", "Reflex Sight", ::givetest, "m16_reflex_dualclip_mp");
		addNewOption("M16 Dual Mags", "Masterkey", ::givetest, "m16_mk_dualclip_mp");
		addNewOption("M16 Dual Mags", "Flamethrower", ::givetest, "m16_ft_dualclip_mp");
		addNewOption("M16 Dual Mags", "Infrared Scope", ::givetest, "m16_ir_dualclip_mp");
		addNewOption("M16 Dual Mags", "Suppressor", ::givetest, "m16_dualclip_silencer_mp");
		addNewOption("M16 Dual Mags", "Grenade Launcher", ::givetest, "m16_gl_dualclip_mp");

		addNewMenu("M16 Masterkey", "M16 2");
		addNewOption("M16 Masterkey", "Extended Mags", ::givetest, "m16_mk_extclip_mp");
		addNewOption("M16 Masterkey", "Dual Mags", ::givetest, "m16_mk_dualclip_mp");
		addNewOption("M16 Masterkey", "ACOG Sight", ::givetest, "m16_acog_mk_mp");
		addNewOption("M16 Masterkey", "Red Dot Sight", ::givetest, "m16_elbit_mk_mp");
		addNewOption("M16 Masterkey", "Reflex Sight", ::givetest, "m16_reflex_mk_mp");
		addNewOption("M16 Masterkey", "Infrared Scope", ::givetest, "m16_ir_mk_mp");
		addNewOption("M16 Masterkey", "Suppressor", ::givetest, "m16_mk_silencer_mp");

		addNewMenu("M16 Flamethrower", "M16 2");
		addNewOption("M16 Flamethrower", "Extended Mags", ::givetest, "m16_ft_extclip_mp");
		addNewOption("M16 Flamethrower", "Dual Mags", ::givetest, "m16_ft_dualclip_mp");
		addNewOption("M16 Flamethrower", "ACOG Sight", ::givetest, "m16_acog_ft_mp");
		addNewOption("M16 Flamethrower", "Red Dot Sight", ::givetest, "m16_elbit_ft_mp");
		addNewOption("M16 Flamethrower", "Reflex Sight", ::givetest, "m16_reflex_ft_mp");
		addNewOption("M16 Flamethrower", "Infrared Scope", ::givetest, "m16_ir_ft_mp");
		addNewOption("M16 Flamethrower", "Suppressor", ::givetest, "m16_ft_silencer_mp");

		addNewMenu("M16 Grenade Launcher", "M16 2");
		addNewOption("M16 Grenade Launcher", "Extended Mags", ::givetest, "m16_gl_extclip_mp");
		addNewOption("M16 Grenade Launcher", "Dual Mags", ::givetest, "m16_gl_dualclip_mp");
		addNewOption("M16 Grenade Launcher", "ACOG Sight", ::givetest, "m16_acog_gl_mp");
		addNewOption("M16 Grenade Launcher", "Red Dot Sight", ::givetest, "m16_elbit_gl_mp");
		addNewOption("M16 Grenade Launcher", "Reflex Sight", ::givetest, "m16_reflex_gl_mp");
		addNewOption("M16 Grenade Launcher", "Infrared Scope", ::givetest, "m16_gl_ir_mp");
		addNewOption("M16 Grenade Launcher", "Suppressor", ::givetest, "m16_gl_silencer_mp");

		addNewMenu("Enfield", "Assault Rifles");
		addNewOption("Enfield", "Extended Mags", ::givetest, "enfield_extclip_mp");
		addNewOption("Enfield", "Dual Mags", ::givetest, "enfield_dualclip_mp");
		addNewOption("Enfield", "ACOG Sight", ::givetest, "enfield_acog_mp");
		addNewOption("Enfield", "Red Dot Sight", ::givetest, "enfield_elbit_mp");
		addNewOption("Enfield", "Reflex Sight", ::givetest, "enfield_reflex_mp");
		addNewOption("Enfield", "Masterkey", ::givetest, "enfield_mk_mp");
		addNewOption("Enfield", "Flamethrower", ::givetest, "enfield_ft_mp");
		addNewOption("Enfield", "Infrared Scope", ::givetest, "enfield_ir_mp");
		addNewOption("Enfield", "Suppressor", ::givetest, "enfield_silencer_mp");
		addNewOption("Enfield", "Grenade Launcher", ::givetest, "enfield_gl_mp");
		addNewOption("Enfield", "Default", ::givetest, "enfield_mp");
		addNewOption("Enfield", "^5Next Page", ::loadMenu, "Enfield 2");

		addNewMenu("Enfield 2", "Enfield");
		addNewOption("Enfield 2", "Extended Mags", ::loadMenu, "Enfield Extended Mags");
		addNewOption("Enfield 2", "Dual Mags", ::loadMenu, "Enfield Dual Mags");
		addNewOption("Enfield 2", "Masterkey", ::loadMenu, "Enfield Masterkey");
		addNewOption("Enfield 2", "Flamethrower", ::loadMenu, "Enfield Flamethrower");
		addNewOption("Enfield 2", "Grenade Launcher", ::loadMenu, "Enfield Grenade Launcher");

		addNewMenu("Enfield Extended Mags", "Enfield 2");
		addNewOption("Enfield Extended Mags", "ACOG Sight", ::givetest, "enfield_acog_extclip_mp");
		addNewOption("Enfield Extended Mags", "Red Dot Sight", ::givetest, "enfield_elbit_extclip_mp");
		addNewOption("Enfield Extended Mags", "Reflex Sight", ::givetest, "enfield_reflex_extclip_mp");
		addNewOption("Enfield Extended Mags", "Masterkey", ::givetest, "enfield_mk_extclip_mp");
		addNewOption("Enfield Extended Mags", "Flamethrower", ::givetest, "enfield_ft_extclip_mp");
		addNewOption("Enfield Extended Mags", "Infrared Scope", ::givetest, "enfield_ir_extclip_mp");
		addNewOption("Enfield Extended Mags", "Suppressor", ::givetest, "enfield_extclip_silencer_mp");
		addNewOption("Enfield Extended Mags", "Grenade Launcher", ::givetest, "enfield_gl_extclip_mp");

		addNewMenu("Enfield Dual Mags", "Enfield 2");
		addNewOption("Enfield Dual Mags", "ACOG Sight", ::givetest, "enfield_acog_dualclip_mp");
		addNewOption("Enfield Dual Mags", "Red Dot Sight", ::givetest, "enfield_elbit_dualclip_mp");
		addNewOption("Enfield Dual Mags", "Reflex Sight", ::givetest, "enfield_reflex_dualclip_mp");
		addNewOption("Enfield Dual Mags", "Masterkey", ::givetest, "enfield_mk_dualclip_mp");
		addNewOption("Enfield Dual Mags", "Flamethrower", ::givetest, "enfield_ft_dualclip_mp");
		addNewOption("Enfield Dual Mags", "Infrared Scope", ::givetest, "enfield_ir_dualclip_mp");
		addNewOption("Enfield Dual Mags", "Suppressor", ::givetest, "enfield_dualclip_silencer_mp");
		addNewOption("Enfield Dual Mags", "Grenade Launcher", ::givetest, "enfield_gl_dualclip_mp");

		addNewMenu("Enfield Masterkey", "Enfield 2");
		addNewOption("Enfield Masterkey", "Extended Mags", ::givetest, "enfield_mk_extclip_mp");
		addNewOption("Enfield Masterkey", "Dual Mags", ::givetest, "enfield_mk_dualclip_mp");
		addNewOption("Enfield Masterkey", "ACOG Sight", ::givetest, "enfield_acog_mk_mp");
		addNewOption("Enfield Masterkey", "Red Dot Sight", ::givetest, "enfield_elbit_mk_mp");
		addNewOption("Enfield Masterkey", "Reflex Sight", ::givetest, "enfield_reflex_mk_mp");
		addNewOption("Enfield Masterkey", "Infrared Scope", ::givetest, "enfield_ir_mk_mp");
		addNewOption("Enfield Masterkey", "Suppressor", ::givetest, "enfield_mk_silencer_mp");

		addNewMenu("Enfield Flamethrower", "Enfield 2");
		addNewOption("Enfield Flamethrower", "Extended Mags", ::givetest, "enfield_ft_extclip_mp");
		addNewOption("Enfield Flamethrower", "Dual Mags", ::givetest, "enfield_ft_dualclip_mp");
		addNewOption("Enfield Flamethrower", "ACOG Sight", ::givetest, "enfield_acog_ft_mp");
		addNewOption("Enfield Flamethrower", "Red Dot Sight", ::givetest, "enfield_elbit_ft_mp");
		addNewOption("Enfield Flamethrower", "Reflex Sight", ::givetest, "enfield_reflex_ft_mp");
		addNewOption("Enfield Flamethrower", "Infrared Scope", ::givetest, "enfield_ir_ft_mp");
		addNewOption("Enfield Flamethrower", "Suppressor", ::givetest, "enfield_ft_silencer_mp");

		addNewMenu("Enfield Grenade Launcher", "Enfield 2");
		addNewOption("Enfield Grenade Launcher", "Extended Mags", ::givetest, "enfield_gl_extclip_mp");
		addNewOption("Enfield Grenade Launcher", "Dual Mags", ::givetest, "enfield_gl_dualclip_mp");
		addNewOption("Enfield Grenade Launcher", "ACOG Sight", ::givetest, "enfield_acog_gl_mp");
		addNewOption("Enfield Grenade Launcher", "Red Dot Sight", ::givetest, "enfield_elbit_gl_mp");
		addNewOption("Enfield Grenade Launcher", "Reflex Sight", ::givetest, "enfield_reflex_gl_mp");
		addNewOption("Enfield Grenade Launcher", "Infrared Scope", ::givetest, "enfield_ir_gl_mp");
		addNewOption("Enfield Grenade Launcher", "Suppressor", ::givetest, "enfield_gl_silencer_mp");

		addNewMenu("M14", "Assault Rifles");
		addNewOption("M14", "Extended Mags", ::givetest, "m14_extclip_mp");
		addNewOption("M14", "ACOG Sight", ::givetest, "m14_acog_mp");
		addNewOption("M14", "Red Dot Sight", ::givetest, "m14_elbit_mp");
		addNewOption("M14", "Reflex Sight", ::givetest, "m14_reflex_mp");
		addNewOption("M14", "Masterkey", ::givetest, "m14_mk_mp");
		addNewOption("M14", "Flamethrower", ::givetest, "m14_ft_mp");
		addNewOption("M14", "Infrared Scope", ::givetest, "m14_ir_mp");
		addNewOption("M14", "Suppressor", ::givetest, "m14_silencer_mp");
		addNewOption("M14", "Grenade Launcher", ::givetest, "m14_gl_mp");
		addNewOption("M14", "Default", ::givetest, "m14_mp");
		addNewOption("M14", "^5Next Page", ::loadMenu, "M14 2");

		addNewMenu("M14 2", "M14");
		addNewOption("M14 2", "Extended Mags", ::loadMenu, "M14 Extended Mags");
		addNewOption("M14 2", "Masterkey", ::loadMenu, "M14 Masterkey");
		addNewOption("M14 2", "Flamethrower", ::loadMenu, "M14 Flamethrower");
		addNewOption("M14 2", "Grenade Launcher", ::loadMenu, "M14 Grenade Launcher");

		addNewMenu("M14 Extended Mags", "M14 2");
		addNewOption("M14 Extended Mags", "ACOG Sight", ::givetest, "m14_acog_extclip_mp");
		addNewOption("M14 Extended Mags", "Red Dot Sight", ::givetest, "m14_elbit_extclip_mp");
		addNewOption("M14 Extended Mags", "Reflex Sight", ::givetest, "m14_reflex_extclip_mp");
		addNewOption("M14 Extended Mags", "Masterkey", ::givetest, "m14_mk_extclip_mp");
		addNewOption("M14 Extended Mags", "Flamethrower", ::givetest, "m14_ft_extclip_mp");
		addNewOption("M14 Extended Mags", "Infrared Scope", ::givetest, "m14_ir_extclip_mp");
		addNewOption("M14 Extended Mags", "Suppressor", ::givetest, "m14_extclip_silencer_mp");
		addNewOption("M14 Extended Mags", "Grenade Launcher", ::givetest, "m14_gl_extclip_mp");

		addNewMenu("M14 Masterkey", "M14 2");
		addNewOption("M14 Masterkey", "Extended Mags", ::givetest, "m14_mk_extclip_mp");
		addNewOption("M14 Masterkey", "ACOG Sight", ::givetest, "m14_acog_mk_mp");
		addNewOption("M14 Masterkey", "Red Dot Sight", ::givetest, "m14_elbit_mk_mp");
		addNewOption("M14 Masterkey", "Reflex Sight", ::givetest, "m14_reflex_mk_mp");
		addNewOption("M14 Masterkey", "Infrared Scope", ::givetest, "m14_ir_mk_mp");
		addNewOption("M14 Masterkey", "Suppressor", ::givetest, "m14_mk_silencer_mp");

		addNewMenu("M14 Flamethrower", "M14 2");
		addNewOption("M14 Flamethrower", "Extended Mags", ::givetest, "m14_ft_extclip_mp");
		addNewOption("M14 Flamethrower", "ACOG Sight", ::givetest, "m14_acog_ft_mp");
		addNewOption("M14 Flamethrower", "Red Dot Sight", ::givetest, "m14_elbit_ft_mp");
		addNewOption("M14 Flamethrower", "Reflex Sight", ::givetest, "m14_reflex_ft_mp");
		addNewOption("M14 Flamethrower", "Infrared Scope", ::givetest, "m14_ir_ft_mp");
		addNewOption("M14 Flamethrower", "Suppressor", ::givetest, "m14_ft_silencer_mp");

		addNewMenu("M14 Grenade Launcher", "M14 2");
		addNewOption("M14 Grenade Launcher", "Extended Mags", ::givetest, "m14_gl_extclip_mp");
		addNewOption("M14 Grenade Launcher", "ACOG Sight", ::givetest, "m14_acog_gl_mp");
		addNewOption("M14 Grenade Launcher", "Red Dot Sight", ::givetest, "m14_elbit_gl_mp");
		addNewOption("M14 Grenade Launcher", "Reflex Sight", ::givetest, "m14_reflex_gl_mp");
		addNewOption("M14 Grenade Launcher", "Infrared Scope", ::givetest, "m14_gl_ir_mp");
		addNewOption("M14 Grenade Launcher", "Suppressor", ::givetest, "m14_gl_silencer_mp");

		addNewMenu("Famas", "Assault Rifles");
		addNewOption("Famas", "Extended Mags", ::givetest, "famas_extclip_mp");
		addNewOption("Famas", "Dual Mags", ::givetest, "famas_dualclip_mp");
		addNewOption("Famas", "ACOG Sight", ::givetest, "famas_acog_mp");
		addNewOption("Famas", "Red Dot Sight", ::givetest, "famas_elbit_mp");
		addNewOption("Famas", "Reflex Sight", ::givetest, "famas_reflex_mp");
		addNewOption("Famas", "Masterkey", ::givetest, "famas_mk_mp");
		addNewOption("Famas", "Flamethrower", ::givetest, "famas_ft_mp");
		addNewOption("Famas", "Infrared Scope", ::givetest, "famas_ir_mp");
		addNewOption("Famas", "Suppressor", ::givetest, "famas_silencer_mp");
		addNewOption("Famas", "Grenade Launcher", ::givetest, "famas_gl_mp");
		addNewOption("Famas", "Default", ::givetest, "famas_mp");
		addNewOption("Famas", "^5Next Page", ::loadMenu, "Famas 2");

		addNewMenu("Famas 2", "Famas");
		addNewOption("Famas 2", "Extended Mags", ::loadMenu, "Famas Extended Mags");
		addNewOption("Famas 2", "Dual Mags", ::loadMenu, "Famas Dual Mags");
		addNewOption("Famas 2", "Masterkey", ::loadMenu, "Famas Masterkey");
		addNewOption("Famas 2", "Flamethrower", ::loadMenu, "Famas Flamethrower");
		addNewOption("Famas 2", "Grenade Launcher", ::loadMenu, "Famas Grenade Launcher");

		addNewMenu("Famas Extended Mags", "Famas 2");
		addNewOption("Famas Extended Mags", "ACOG Sight", ::givetest, "famas_acog_extclip_mp");
		addNewOption("Famas Extended Mags", "Red Dot Sight", ::givetest, "famas_elbit_extclip_mp");
		addNewOption("Famas Extended Mags", "Reflex Sight", ::givetest, "famas_reflex_extclip_mp");
		addNewOption("Famas Extended Mags", "Masterkey", ::givetest, "famas_mk_extclip_mp");
		addNewOption("Famas Extended Mags", "Flamethrower", ::givetest, "famas_ft_extclip_mp");
		addNewOption("Famas Extended Mags", "Infrared Scope", ::givetest, "famas_ir_extclip_mp");
		addNewOption("Famas Extended Mags", "Suppressor", ::givetest, "famas_extclip_silencer_mp");
		addNewOption("Famas Extended Mags", "Grenade Launcher", ::givetest, "famas_gl_extclip_mp");

		addNewMenu("Famas Dual Mags", "Famas 2");
		addNewOption("Famas Dual Mags", "ACOG Sight", ::givetest, "famas_acog_dualclip_mp");
		addNewOption("Famas Dual Mags", "Red Dot Sight", ::givetest, "famas_elbit_dualclip_mp");
		addNewOption("Famas Dual Mags", "Reflex Sight", ::givetest, "famas_reflex_dualclip_mp");
		addNewOption("Famas Dual Mags", "Masterkey", ::givetest, "famas_mk_dualclip_mp");
		addNewOption("Famas Dual Mags", "Flamethrower", ::givetest, "famas_ft_dualclip_mp");
		addNewOption("Famas Dual Mags", "Infrared Scope", ::givetest, "famas_ir_dualclip_mp");
		addNewOption("Famas Dual Mags", "Suppressor", ::givetest, "famas_dualclip_silencer_mp");
		addNewOption("Famas Dual Mags", "Grenade Launcher", ::givetest, "famas_gl_dualclip_mp");

		addNewMenu("Famas Masterkey", "Famas 2");
		addNewOption("Famas Masterkey", "Extended Mags", ::givetest, "famas_mk_extclip_mp");
		addNewOption("Famas Masterkey", "Dual Mags", ::givetest, "famas_mk_dualclip_mp");
		addNewOption("Famas Masterkey", "ACOG Sight", ::givetest, "famas_acog_mk_mp");
		addNewOption("Famas Masterkey", "Red Dot Sight", ::givetest, "famas_elbit_mk_mp");
		addNewOption("Famas Masterkey", "Reflex Sight", ::givetest, "famas_reflex_mk_mp");
		addNewOption("Famas Masterkey", "Infrared Scope", ::givetest, "famas_ir_mk_mp");
		addNewOption("Famas Masterkey", "Suppressor", ::givetest, "famas_mk_silencer_mp");

		addNewMenu("Famas Flamethrower", "Famas 2");
		addNewOption("Famas Flamethrower", "Extended Mags", ::givetest, "famas_ft_extclip_mp");
		addNewOption("Famas Flamethrower", "Dual Mags", ::givetest, "famas_ft_dualclip_mp");
		addNewOption("Famas Flamethrower", "ACOG Sight", ::givetest, "famas_acog_ft_mp");
		addNewOption("Famas Flamethrower", "Red Dot Sight", ::givetest, "famas_elbit_ft_mp");
		addNewOption("Famas Flamethrower", "Reflex Sight", ::givetest, "famas_reflex_ft_mp");
		addNewOption("Famas Flamethrower", "Infrared Scope", ::givetest, "famas_ir_ft_mp");
		addNewOption("Famas Flamethrower", "Suppressor", ::givetest, "famas_ft_silencer_mp");

		addNewMenu("Famas Grenade Launcher", "Famas 2");
		addNewOption("Famas Grenade Launcher", "Extended Mags", ::givetest, "famas_gl_extclip_mp");
		addNewOption("Famas Grenade Launcher", "Dual Mags", ::givetest, "famas_gl_dualclip_mp");
		addNewOption("Famas Grenade Launcher", "ACOG Sight", ::givetest, "famas_acog_gl_mp");
		addNewOption("Famas Grenade Launcher", "Red Dot Sight", ::givetest, "famas_elbit_gl_mp");
		addNewOption("Famas Grenade Launcher", "Reflex Sight", ::givetest, "famas_reflex_gl_mp");
		addNewOption("Famas Grenade Launcher", "Infrared Scope", ::givetest, "famas_ir_gl_mp");
		addNewOption("Famas Grenade Launcher", "Suppressor", ::givetest, "famas_gl_silencer_mp");

		addNewMenu("Galil", "Assault Rifles");
		addNewOption("Galil", "Extended Mags", ::givetest, "galil_extclip_mp");
		addNewOption("Galil", "Dual Mags", ::givetest, "galil_dualclip_mp");
		addNewOption("Galil", "ACOG Sight", ::givetest, "galil_acog_mp");
		addNewOption("Galil", "Red Dot Sight", ::givetest, "galil_elbit_mp");
		addNewOption("Galil", "Reflex Sight", ::givetest, "galil_reflex_mp");
		addNewOption("Galil", "Masterkey", ::givetest, "galil_mk_mp");
		addNewOption("Galil", "Flamethrower", ::givetest, "galil_ft_mp");
		addNewOption("Galil", "Infrared Scope", ::givetest, "galil_ir_mp");
		addNewOption("Galil", "Suppressor", ::givetest, "galil_silencer_mp");
		addNewOption("Galil", "Grenade Launcher", ::givetest, "galil_gl_mp");
		addNewOption("Galil", "Default", ::givetest, "galil_mp");
		addNewOption("Galil", "^5Next Page", ::loadMenu, "Galil 2");

		addNewMenu("Galil 2", "Galil");
		addNewOption("Galil 2", "Extended Mags", ::loadMenu, "Galil Extended Mags");
		addNewOption("Galil 2", "Dual Mags", ::loadMenu, "Galil Dual Mags");
		addNewOption("Galil 2", "Masterkey", ::loadMenu, "Galil Masterkey");
		addNewOption("Galil 2", "Flamethrower", ::loadMenu, "Galil Flamethrower");
		addNewOption("Galil 2", "Grenade Launcher", ::loadMenu, "Galil Grenade Launcher");

		addNewMenu("Galil Extended Mags", "Galil 2");
		addNewOption("Galil Extended Mags", "ACOG Sight", ::givetest, "galil_acog_extclip_mp");
		addNewOption("Galil Extended Mags", "Red Dot Sight", ::givetest, "galil_elbit_extclip_mp");
		addNewOption("Galil Extended Mags", "Reflex Sight", ::givetest, "galil_reflex_extclip_mp");
		addNewOption("Galil Extended Mags", "Masterkey", ::givetest, "galil_mk_extclip_mp");
		addNewOption("Galil Extended Mags", "Flamethrower", ::givetest, "galil_ft_extclip_mp");
		addNewOption("Galil Extended Mags", "Infrared Scope", ::givetest, "galil_ir_extclip_mp");
		addNewOption("Galil Extended Mags", "Suppressor", ::givetest, "galil_extclip_silencer_mp");
		addNewOption("Galil Extended Mags", "Grenade Launcher", ::givetest, "galil_gl_extclip_mp");

		addNewMenu("Galil Dual Mags", "Galil 2");
		addNewOption("Galil Dual Mags", "ACOG Sight", ::givetest, "galil_acog_dualclip_mp");
		addNewOption("Galil Dual Mags", "Red Dot Sight", ::givetest, "galil_elbit_dualclip_mp");
		addNewOption("Galil Dual Mags", "Reflex Sight", ::givetest, "galil_reflex_dualclip_mp");
		addNewOption("Galil Dual Mags", "Masterkey", ::givetest, "galil_mk_dualclip_mp");
		addNewOption("Galil Dual Mags", "Flamethrower", ::givetest, "galil_ft_dualclip_mp");
		addNewOption("Galil Dual Mags", "Infrared Scope", ::givetest, "galil_ir_dualclip_mp");
		addNewOption("Galil Dual Mags", "Suppressor", ::givetest, "galil_dualclip_silencer_mp");
		addNewOption("Galil Dual Mags", "Grenade Launcher", ::givetest, "galil_gl_dualclip_mp");

		addNewMenu("Galil Masterkey", "Galil 2");
		addNewOption("Galil Masterkey", "Extended Mags", ::givetest, "galil_mk_extclip_mp");
		addNewOption("Galil Masterkey", "Dual Mags", ::givetest, "galil_mk_dualclip_mp");
		addNewOption("Galil Masterkey", "ACOG Sight", ::givetest, "galil_acog_mk_mp");
		addNewOption("Galil Masterkey", "Red Dot Sight", ::givetest, "galil_elbit_mk_mp");
		addNewOption("Galil Masterkey", "Reflex Sight", ::givetest, "galil_reflex_mk_mp");
		addNewOption("Galil Masterkey", "Infrared Scope", ::givetest, "galil_ir_mk_mp");
		addNewOption("Galil Masterkey", "Suppressor", ::givetest, "galil_mk_silencer_mp");

		addNewMenu("Galil Flamethrower", "Galil 2");
		addNewOption("Galil Flamethrower", "Extended Mags", ::givetest, "galil_ft_extclip_mp");
		addNewOption("Galil Flamethrower", "Dual Mags", ::givetest, "galil_ft_dualclip_mp");
		addNewOption("Galil Flamethrower", "ACOG Sight", ::givetest, "galil_acog_ft_mp");
		addNewOption("Galil Flamethrower", "Red Dot Sight", ::givetest, "galil_elbit_ft_mp");
		addNewOption("Galil Flamethrower", "Reflex Sight", ::givetest, "galil_reflex_ft_mp");
		addNewOption("Galil Flamethrower", "Infrared Scope", ::givetest, "galil_ir_ft_mp");
		addNewOption("Galil Flamethrower", "Suppressor", ::givetest, "galil_ft_silencer_mp");

		addNewMenu("Galil Grenade Launcher", "Galil 2");
		addNewOption("Galil Grenade Launcher", "Extended Mags", ::givetest, "galil_gl_extclip_mp");
		addNewOption("Galil Grenade Launcher", "Dual Mags", ::givetest, "galil_gl_dualclip_mp");
		addNewOption("Galil Grenade Launcher", "ACOG Sight", ::givetest, "galil_acog_gl_mp");
		addNewOption("Galil Grenade Launcher", "Red Dot Sight", ::givetest, "galil_elbit_gl_mp");
		addNewOption("Galil Grenade Launcher", "Reflex Sight", ::givetest, "galil_reflex_gl_mp");
		addNewOption("Galil Grenade Launcher", "Infrared Scope", ::givetest, "galil_ir_gl_mp");
		addNewOption("Galil Grenade Launcher", "Suppressor", ::givetest, "galil_gl_silencer_mp");

		addNewMenu("Aug", "Assault Rifles");
		addNewOption("Aug", "Extended Mags", ::givetest, "aug_extclip_mp");
		addNewOption("Aug", "Dual Mags", ::givetest, "aug_dualclip_mp");
		addNewOption("Aug", "ACOG Sight", ::givetest, "aug_acog_mp");
		addNewOption("Aug", "Red Dot Sight", ::givetest, "aug_elbit_mp");
		addNewOption("Aug", "Reflex Sight", ::givetest, "aug_reflex_mp");
		addNewOption("Aug", "Masterkey", ::givetest, "aug_mk_mp");
		addNewOption("Aug", "Flamethrower", ::givetest, "aug_ft_mp");
		addNewOption("Aug", "Infrared Scope", ::givetest, "aug_ir_mp");
		addNewOption("Aug", "Suppressor", ::givetest, "aug_silencer_mp");
		addNewOption("Aug", "Grenade Launcher", ::givetest, "aug_gl_mp");
		addNewOption("Aug", "Default", ::givetest, "aug_mp");
		addNewOption("Aug", "^5Next Page", ::loadMenu, "Aug 2");

		addNewMenu("Aug 2", "Aug");
		addNewOption("Aug 2", "Extended Mags", ::loadMenu, "Aug Extended Mags");
		addNewOption("Aug 2", "Dual Mags", ::loadMenu, "Aug Dual Mags");
		addNewOption("Aug 2", "Masterkey", ::loadMenu, "Aug Masterkey");
		addNewOption("Aug 2", "Flamethrower", ::loadMenu, "Aug Flamethrower");
		addNewOption("Aug 2", "Grenade Launcher", ::loadMenu, "Aug Grenade Launcher");

		addNewMenu("Aug Extended Mags", "Aug 2");
		addNewOption("Aug Extended Mags", "ACOG Sight", ::givetest, "aug_acog_extclip_mp");
		addNewOption("Aug Extended Mags", "Red Dot Sight", ::givetest, "aug_elbit_extclip_mp");
		addNewOption("Aug Extended Mags", "Reflex Sight", ::givetest, "aug_reflex_extclip_mp");
		addNewOption("Aug Extended Mags", "Masterkey", ::givetest, "aug_mk_extclip_mp");
		addNewOption("Aug Extended Mags", "Flamethrower", ::givetest, "aug_ft_extclip_mp");
		addNewOption("Aug Extended Mags", "Infrared Scope", ::givetest, "aug_ir_extclip_mp");
		addNewOption("Aug Extended Mags", "Suppressor", ::givetest, "aug_extclip_silencer_mp");
		addNewOption("Aug Extended Mags", "Grenade Launcher", ::givetest, "aug_gl_extclip_mp");

		addNewMenu("Aug Dual Mags", "Aug 2");
		addNewOption("Aug Dual Mags", "ACOG Sight", ::givetest, "aug_acog_dualclip_mp");
		addNewOption("Aug Dual Mags", "Red Dot Sight", ::givetest, "aug_elbit_dualclip_mp");
		addNewOption("Aug Dual Mags", "Reflex Sight", ::givetest, "aug_reflex_dualclip_mp");
		addNewOption("Aug Dual Mags", "Masterkey", ::givetest, "aug_mk_dualclip_mp");
		addNewOption("Aug Dual Mags", "Flamethrower", ::givetest, "aug_ft_dualclip_mp");
		addNewOption("Aug Dual Mags", "Infrared Scope", ::givetest, "aug_ir_dualclip_mp");
		addNewOption("Aug Dual Mags", "Suppressor", ::givetest, "aug_dualclip_silencer_mp");
		addNewOption("Aug Dual Mags", "Grenade Launcher", ::givetest, "aug_gl_dualclip_mp");

		addNewMenu("Aug Masterkey", "Aug 2");
		addNewOption("Aug Masterkey", "Extended Mags", ::givetest, "aug_mk_extclip_mp");
		addNewOption("Aug Masterkey", "Dual Mags", ::givetest, "aug_mk_dualclip_mp");
		addNewOption("Aug Masterkey", "ACOG Sight", ::givetest, "aug_acog_mk_mp");
		addNewOption("Aug Masterkey", "Red Dot Sight", ::givetest, "aug_elbit_mk_mp");
		addNewOption("Aug Masterkey", "Reflex Sight", ::givetest, "aug_reflex_mk_mp");
		addNewOption("Aug Masterkey", "Infrared Scope", ::givetest, "aug_ir_mk_mp");
		addNewOption("Aug Masterkey", "Suppressor", ::givetest, "aug_mk_silencer_mp");

		addNewMenu("Aug Flamethrower", "Aug 2");
		addNewOption("Aug Flamethrower", "Extended Mags", ::givetest, "aug_ft_extclip_mp");
		addNewOption("Aug Flamethrower", "Dual Mags", ::givetest, "aug_ft_dualclip_mp");
		addNewOption("Aug Flamethrower", "ACOG Sight", ::givetest, "aug_acog_ft_mp");
		addNewOption("Aug Flamethrower", "Red Dot Sight", ::givetest, "aug_elbit_ft_mp");
		addNewOption("Aug Flamethrower", "Reflex Sight", ::givetest, "aug_reflex_ft_mp");
		addNewOption("Aug Flamethrower", "Infrared Scope", ::givetest, "aug_ir_ft_mp");
		addNewOption("Aug Flamethrower", "Suppressor", ::givetest, "aug_ft_silencer_mp");

		addNewMenu("Aug Grenade Launcher", "Aug 2");
		addNewOption("Aug Grenade Launcher", "Extended Mags", ::givetest, "aug_gl_extclip_mp");
		addNewOption("Aug Grenade Launcher", "Dual Mags", ::givetest, "aug_gl_dualclip_mp");
		addNewOption("Aug Grenade Launcher", "ACOG Sight", ::givetest, "aug_acog_gl_mp");
		addNewOption("Aug Grenade Launcher", "Red Dot Sight", ::givetest, "aug_elbit_gl_mp");
		addNewOption("Aug Grenade Launcher", "Reflex Sight", ::givetest, "aug_reflex_gl_mp");
		addNewOption("Aug Grenade Launcher", "Infrared Scope", ::givetest, "aug_ir_gl_mp");
		addNewOption("Aug Grenade Launcher", "Suppressor", ::givetest, "aug_gl_silencer_mp");

		addNewMenu("Fnfal", "Assault Rifles");
		addNewOption("Fnfal", "Extended Mags", ::givetest, "fnfal_extclip_mp");
		addNewOption("Fnfal", "Dual Mags", ::givetest, "fnfal_dualclip_mp");
		addNewOption("Fnfal", "ACOG Sight", ::givetest, "fnfal_acog_mp");
		addNewOption("Fnfal", "Red Dot Sight", ::givetest, "fnfal_elbit_mp");
		addNewOption("Fnfal", "Reflex Sight", ::givetest, "fnfal_reflex_mp");
		addNewOption("Fnfal", "Masterkey", ::givetest, "fnfal_mk_mp");
		addNewOption("Fnfal", "Flamethrower", ::givetest, "fnfal_ft_mp");
		addNewOption("Fnfal", "Infrared Scope", ::givetest, "fnfal_ir_mp");
		addNewOption("Fnfal", "Suppressor", ::givetest, "fnfal_silencer_mp");
		addNewOption("Fnfal", "Grenade Launcher", ::givetest, "fnfal_gl_mp");
		addNewOption("Fnfal", "Default", ::givetest, "fnfal_mp");
		addNewOption("Fnfal", "^5Next Page", ::loadMenu, "Fnfal 2");

		addNewMenu("Fnfal 2", "Fnfal");
		addNewOption("Fnfal 2", "Extended Mags", ::loadMenu, "Fnfal Extended Mags");
		addNewOption("Fnfal 2", "Dual Mags", ::loadMenu, "Fnfal Dual Mags");
		addNewOption("Fnfal 2", "Masterkey", ::loadMenu, "Fnfal Masterkey");
		addNewOption("Fnfal 2", "Flamethrower", ::loadMenu, "Fnfal Flamethrower");
		addNewOption("Fnfal 2", "Grenade Launcher", ::loadMenu, "Fnfal Grenade Launcher");

		addNewMenu("Fnfal Extended Mags", "Fnfal 2");
		addNewOption("Fnfal Extended Mags", "ACOG Sight", ::givetest, "fnfal_acog_extclip_mp");
		addNewOption("Fnfal Extended Mags", "Red Dot Sight", ::givetest, "fnfal_elbit_extclip_mp");
		addNewOption("Fnfal Extended Mags", "Reflex Sight", ::givetest, "fnfal_reflex_extclip_mp");
		addNewOption("Fnfal Extended Mags", "Masterkey", ::givetest, "fnfal_mk_extclip_mp");
		addNewOption("Fnfal Extended Mags", "Flamethrower", ::givetest, "fnfal_ft_extclip_mp");
		addNewOption("Fnfal Extended Mags", "Infrared Scope", ::givetest, "fnfal_ir_extclip_mp");
		addNewOption("Fnfal Extended Mags", "Suppressor", ::givetest, "fnfal_extclip_silencer_mp");
		addNewOption("Fnfal Extended Mags", "Grenade Launcher", ::givetest, "fnfal_gl_extclip_mp");

		addNewMenu("Fnfal Dual Mags", "Fnfal 2");
		addNewOption("Fnfal Dual Mags", "ACOG Sight", ::givetest, "fnfal_acog_dualclip_mp");
		addNewOption("Fnfal Dual Mags", "Red Dot Sight", ::givetest, "fnfal_elbit_dualclip_mp");
		addNewOption("Fnfal Dual Mags", "Reflex Sight", ::givetest, "fnfal_reflex_dualclip_mp");
		addNewOption("Fnfal Dual Mags", "Masterkey", ::givetest, "fnfal_mk_dualclip_mp");
		addNewOption("Fnfal Dual Mags", "Flamethrower", ::givetest, "fnfal_ft_dualclip_mp");
		addNewOption("Fnfal Dual Mags", "Infrared Scope", ::givetest, "fnfal_ir_dualclip_mp");
		addNewOption("Fnfal Dual Mags", "Suppressor", ::givetest, "fnfal_dualclip_silencer_mp");
		addNewOption("Fnfal Dual Mags", "Grenade Launcher", ::givetest, "fnfal_gl_dualclip_mp");

		addNewMenu("Fnfal Masterkey", "Fnfal 2");
		addNewOption("Fnfal Masterkey", "Extended Mags", ::givetest, "fnfal_mk_extclip_mp");
		addNewOption("Fnfal Masterkey", "Dual Mags", ::givetest, "fnfal_mk_dualclip_mp");
		addNewOption("Fnfal Masterkey", "ACOG Sight", ::givetest, "fnfal_acog_mk_mp");
		addNewOption("Fnfal Masterkey", "Red Dot Sight", ::givetest, "fnfal_elbit_mk_mp");
		addNewOption("Fnfal Masterkey", "Reflex Sight", ::givetest, "fnfal_reflex_mk_mp");
		addNewOption("Fnfal Masterkey", "Infrared Scope", ::givetest, "fnfal_ir_mk_mp");
		addNewOption("Fnfal Masterkey", "Suppressor", ::givetest, "fnfal_mk_silencer_mp");

		addNewMenu("Fnfal Flamethrower", "Fnfal 2");
		addNewOption("Fnfal Flamethrower", "Extended Mags", ::givetest, "fnfal_ft_extclip_mp");
		addNewOption("Fnfal Flamethrower", "Dual Mags", ::givetest, "fnfal_ft_dualclip_mp");
		addNewOption("Fnfal Flamethrower", "ACOG Sight", ::givetest, "fnfal_acog_ft_mp");
		addNewOption("Fnfal Flamethrower", "Red Dot Sight", ::givetest, "fnfal_elbit_ft_mp");
		addNewOption("Fnfal Flamethrower", "Reflex Sight", ::givetest, "fnfal_reflex_ft_mp");
		addNewOption("Fnfal Flamethrower", "Infrared Scope", ::givetest, "fnfal_ir_ft_mp");
		addNewOption("Fnfal Flamethrower", "Suppressor", ::givetest, "fnfal_ft_silencer_mp");

		addNewMenu("Fnfal Grenade Launcher", "Fnfal 2");
		addNewOption("Fnfal Grenade Launcher", "Extended Mags", ::givetest, "fnfal_gl_extclip_mp");
		addNewOption("Fnfal Grenade Launcher", "Dual Mags", ::givetest, "fnfal_gl_dualclip_mp");
		addNewOption("Fnfal Grenade Launcher", "ACOG Sight", ::givetest, "fnfal_acog_gl_mp");
		addNewOption("Fnfal Grenade Launcher", "Red Dot Sight", ::givetest, "fnfal_elbit_gl_mp");
		addNewOption("Fnfal Grenade Launcher", "Reflex Sight", ::givetest, "fnfal_reflex_gl_mp");
		addNewOption("Fnfal Grenade Launcher", "Infrared Scope", ::givetest, "fnfal_ir_gl_mp");
		addNewOption("Fnfal Grenade Launcher", "Suppressor", ::givetest, "fnfal_gl_silencer_mp");

		addNewMenu("AK47", "Assault Rifles");
		addNewOption("AK47", "Extended Mags", ::givetest, "ak47_extclip_mp");
		addNewOption("AK47", "Dual Mags", ::givetest, "ak47_dualclip_mp");
		addNewOption("AK47", "ACOG Sight", ::givetest, "ak47_acog_mp");
		addNewOption("AK47", "Red Dot Sight", ::givetest, "ak47_elbit_mp");
		addNewOption("AK47", "Reflex Sight", ::givetest, "ak47_reflex_mp");
		addNewOption("AK47", "Masterkey", ::givetest, "ak47_mk_mp");
		addNewOption("AK47", "Flamethrower", ::givetest, "ak47_ft_mp");
		addNewOption("AK47", "Infrared Scope", ::givetest, "ak47_ir_mp");
		addNewOption("AK47", "Suppressor", ::givetest, "ak47_silencer_mp");
		addNewOption("AK47", "Grenade Launcher", ::givetest, "ak47_gl_mp");
		addNewOption("AK47", "Default", ::givetest, "ak47_mp");
		addNewOption("AK47", "^5Next Page", ::loadMenu, "AK47 2");

		addNewMenu("AK47 2", "AK47");
		addNewOption("AK47 2", "Extended Mags", ::loadMenu, "AK47 Extended Mags");
		addNewOption("AK47 2", "Dual Mags", ::loadMenu, "AK47 Dual Mags");
		addNewOption("AK47 2", "Masterkey", ::loadMenu, "AK47 Masterkey");
		addNewOption("AK47 2", "Flamethrower", ::loadMenu, "AK47 Flamethrower");
		addNewOption("AK47 2", "Grenade Launcher", ::loadMenu, "AK47 Grenade Launcher");

		addNewMenu("AK47 Extended Mags", "AK47 2");
		addNewOption("AK47 Extended Mags", "ACOG Sight", ::givetest, "ak47_acog_extclip_mp");
		addNewOption("AK47 Extended Mags", "Red Dot Sight", ::givetest, "ak47_elbit_extclip_mp");
		addNewOption("AK47 Extended Mags", "Reflex Sight", ::givetest, "ak47_reflex_extclip_mp");
		addNewOption("AK47 Extended Mags", "Masterkey", ::givetest, "ak47_mk_extclip_mp");
		addNewOption("AK47 Extended Mags", "Flamethrower", ::givetest, "ak47_ft_extclip_mp");
		addNewOption("AK47 Extended Mags", "Infrared Scope", ::givetest, "ak47_ir_extclip_mp");
		addNewOption("AK47 Extended Mags", "Suppressor", ::givetest, "ak47_extclip_silencer_mp");
		addNewOption("AK47 Extended Mags", "Grenade Launcher", ::givetest, "ak47_gl_extclip_mp");

		addNewMenu("AK47 Dual Mags", "AK47 2");
		addNewOption("AK47 Dual Mags", "ACOG Sight", ::givetest, "ak47_acog_dualclip_mp");
		addNewOption("AK47 Dual Mags", "Red Dot Sight", ::givetest, "ak47_elbit_dualclip_mp");
		addNewOption("AK47 Dual Mags", "Reflex Sight", ::givetest, "ak47_reflex_dualclip_mp");
		addNewOption("AK47 Dual Mags", "Masterkey", ::givetest, "ak47_mk_dualclip_mp");
		addNewOption("AK47 Dual Mags", "Flamethrower", ::givetest, "ak47_ft_dualclip_mp");
		addNewOption("AK47 Dual Mags", "Infrared Scope", ::givetest, "ak47_ir_dualclip_mp");
		addNewOption("AK47 Dual Mags", "Suppressor", ::givetest, "ak47_dualclip_silencer_mp");
		addNewOption("AK47 Dual Mags", "Grenade Launcher", ::givetest, "ak47_gl_dualclip_mp");

		addNewMenu("AK47 Masterkey", "AK47 2");
		addNewOption("AK47 Masterkey", "Extended Mags", ::givetest, "ak47_mk_extclip_mp");
		addNewOption("AK47 Masterkey", "Dual Mags", ::givetest, "ak47_mk_dualclip_mp");
		addNewOption("AK47 Masterkey", "ACOG Sight", ::givetest, "ak47_acog_mk_mp");
		addNewOption("AK47 Masterkey", "Red Dot Sight", ::givetest, "ak47_elbit_mk_mp");
		addNewOption("AK47 Masterkey", "Reflex Sight", ::givetest, "ak47_reflex_mk_mp");
		addNewOption("AK47 Masterkey", "Infrared Scope", ::givetest, "ak47_ir_mk_mp");
		addNewOption("AK47 Masterkey", "Suppressor", ::givetest, "ak47_mk_silencer_mp");

		addNewMenu("AK47 Flamethrower", "AK47 2");
		addNewOption("AK47 Flamethrower", "Extended Mags", ::givetest, "ak47_ft_extclip_mp");
		addNewOption("AK47 Flamethrower", "Dual Mags", ::givetest, "ak47_ft_dualclip_mp");
		addNewOption("AK47 Flamethrower", "ACOG Sight", ::givetest, "ak47_acog_ft_mp");
		addNewOption("AK47 Flamethrower", "Red Dot Sight", ::givetest, "ak47_elbit_ft_mp");
		addNewOption("AK47 Flamethrower", "Reflex Sight", ::givetest, "ak47_reflex_ft_mp");
		addNewOption("AK47 Flamethrower", "Infrared Scope", ::givetest, "ak47_ir_ft_mp");
		addNewOption("AK47 Flamethrower", "Suppressor", ::givetest, "ak47_ft_silencer_mp");

		addNewMenu("AK47 Grenade Launcher", "AK47 2");
		addNewOption("AK47 Grenade Launcher", "Extended Mags", ::givetest, "ak47_gl_extclip_mp");
		addNewOption("AK47 Grenade Launcher", "Dual Mags", ::givetest, "ak47_gl_dualclip_mp");
		addNewOption("AK47 Grenade Launcher", "ACOG Sight", ::givetest, "ak47_acog_gl_mp");
		addNewOption("AK47 Grenade Launcher", "Red Dot Sight", ::givetest, "ak47_elbit_gl_mp");
		addNewOption("AK47 Grenade Launcher", "Reflex Sight", ::givetest, "ak47_reflex_gl_mp");
		addNewOption("AK47 Grenade Launcher", "Infrared Scope", ::givetest, "ak47_ir_gl_mp");
		addNewOption("AK47 Grenade Launcher", "Suppressor", ::givetest, "ak47_gl_silencer_mp");

		addNewMenu("Commando", "Assault Rifles");
		addNewOption("Commando", "Extended Mags", ::givetest, "commando_extclip_mp");
		addNewOption("Commando", "Dual Mags", ::givetest, "commando_dualclip_mp");
		addNewOption("Commando", "ACOG Sight", ::givetest, "commando_acog_mp");
		addNewOption("Commando", "Red Dot Sight", ::givetest, "commando_elbit_mp");
		addNewOption("Commando", "Reflex Sight", ::givetest, "commando_reflex_mp");
		addNewOption("Commando", "Masterkey", ::givetest, "commando_mk_mp");
		addNewOption("Commando", "Flamethrower", ::givetest, "commando_ft_mp");
		addNewOption("Commando", "Infrared Scope", ::givetest, "commando_ir_mp");
		addNewOption("Commando", "Suppressor", ::givetest, "commando_silencer_mp");
		addNewOption("Commando", "Grenade Launcher", ::givetest, "commando_gl_mp");
		addNewOption("Commando", "Default", ::givetest, "commando_mp");
		addNewOption("Commando", "^5Next Page", ::loadMenu, "Commando 2");

		addNewMenu("Commando 2", "Commando");
		addNewOption("Commando 2", "Extended Mags", ::loadMenu, "Commando Extended Mags");
		addNewOption("Commando 2", "Dual Mags", ::loadMenu, "Commando Dual Mags");
		addNewOption("Commando 2", "Masterkey", ::loadMenu, "Commando Masterkey");
		addNewOption("Commando 2", "Flamethrower", ::loadMenu, "Commando Flamethrower");
		addNewOption("Commando 2", "Grenade Launcher", ::loadMenu, "Commando Grenade Launcher");

		addNewMenu("Commando Extended Mags", "Commando 2");
		addNewOption("Commando Extended Mags", "ACOG Sight", ::givetest, "commando_acog_extclip_mp");
		addNewOption("Commando Extended Mags", "Red Dot Sight", ::givetest, "commando_elbit_extclip_mp");
		addNewOption("Commando Extended Mags", "Reflex Sight", ::givetest, "commando_reflex_extclip_mp");
		addNewOption("Commando Extended Mags", "Masterkey", ::givetest, "commando_mk_extclip_mp");
		addNewOption("Commando Extended Mags", "Flamethrower", ::givetest, "commando_ft_extclip_mp");
		addNewOption("Commando Extended Mags", "Infrared Scope", ::givetest, "commando_ir_extclip_mp");
		addNewOption("Commando Extended Mags", "Suppressor", ::givetest, "commando_extclip_silencer_mp");
		addNewOption("Commando Extended Mags", "Grenade Launcher", ::givetest, "commando_gl_extclip_mp");

		addNewMenu("Commando Dual Mags", "Commando 2");
		addNewOption("Commando Dual Mags", "ACOG Sight", ::givetest, "commando_acog_dualclip_mp");
		addNewOption("Commando Dual Mags", "Red Dot Sight", ::givetest, "commando_elbit_dualclip_mp");
		addNewOption("Commando Dual Mags", "Reflex Sight", ::givetest, "commando_reflex_dualclip_mp");
		addNewOption("Commando Dual Mags", "Masterkey", ::givetest, "commando_mk_dualclip_mp");
		addNewOption("Commando Dual Mags", "Flamethrower", ::givetest, "commando_ft_dualclip_mp");
		addNewOption("Commando Dual Mags", "Infrared Scope", ::givetest, "commando_ir_dualclip_mp");
		addNewOption("Commando Dual Mags", "Suppressor", ::givetest, "commando_dualclip_silencer_mp");
		addNewOption("Commando Dual Mags", "Grenade Launcher", ::givetest, "commando_gl_dualclip_mp");

		addNewMenu("Commando Masterkey", "Commando 2");
		addNewOption("Commando Masterkey", "Extended Mags", ::givetest, "commando_mk_extclip_mp");
		addNewOption("Commando Masterkey", "Dual Mags", ::givetest, "commando_mk_dualclip_mp");
		addNewOption("Commando Masterkey", "ACOG Sight", ::givetest, "commando_acog_mk_mp");
		addNewOption("Commando Masterkey", "Red Dot Sight", ::givetest, "commando_elbit_mk_mp");
		addNewOption("Commando Masterkey", "Reflex Sight", ::givetest, "commando_reflex_mk_mp");
		addNewOption("Commando Masterkey", "Infrared Scope", ::givetest, "commando_ir_mk_mp");
		addNewOption("Commando Masterkey", "Suppressor", ::givetest, "commando_mk_silencer_mp");

		addNewMenu("Commando Flamethrower", "Commando 2");
		addNewOption("Commando Flamethrower", "Extended Mags", ::givetest, "commando_ft_extclip_mp");
		addNewOption("Commando Flamethrower", "Dual Mags", ::givetest, "commando_ft_dualclip_mp");
		addNewOption("Commando Flamethrower", "ACOG Sight", ::givetest, "commando_acog_ft_mp");
		addNewOption("Commando Flamethrower", "Red Dot Sight", ::givetest, "commando_elbit_ft_mp");
		addNewOption("Commando Flamethrower", "Reflex Sight", ::givetest, "commando_reflex_ft_mp");
		addNewOption("Commando Flamethrower", "Infrared Scope", ::givetest, "commando_ir_ft_mp");
		addNewOption("Commando Flamethrower", "Suppressor", ::givetest, "commando_ft_silencer_mp");

		addNewMenu("Commando Grenade Launcher", "Commando 2");
		addNewOption("Commando Grenade Launcher", "Extended Mags", ::givetest, "commando_gl_extclip_mp");
		addNewOption("Commando Grenade Launcher", "Dual Mags", ::givetest, "commando_gl_dualclip_mp");
		addNewOption("Commando Grenade Launcher", "ACOG Sight", ::givetest, "commando_acog_gl_mp");
		addNewOption("Commando Grenade Launcher", "Red Dot Sight", ::givetest, "commando_elbit_gl_mp");
		addNewOption("Commando Grenade Launcher", "Reflex Sight", ::givetest, "commando_reflex_gl_mp");
		addNewOption("Commando Grenade Launcher", "Infrared Scope", ::givetest, "commando_ir_gl_mp");
		addNewOption("Commando Grenade Launcher", "Suppressor", ::givetest, "commando_gl_silencer_mp");

		addNewMenu("G11", "Assault Rifles");
		addNewOption("G11", "Low Power Scoper", ::givetest, "g11_Lps_mp");
		addNewOption("G11", "Variable Zoom", ::givetest, "g11_vzoom_mp");
		addNewOption("G11", "Default", ::givetest, "g11_mp");
		
		addNewMenu("Submachine Guns", "weapons");
		addNewOption("Submachine Guns", "MP5k", ::loadMenu, "MP5k");
		addNewOption("Submachine Guns", "Skorpion", ::loadMenu, "Skorpion");
		addNewOption("Submachine Guns", "MAC11", ::loadMenu, "MAC11");
		addNewOption("Submachine Guns", "AK74u", ::loadMenu, "AK74u");
		addNewOption("Submachine Guns", "Uzi", ::loadMenu, "Uzi");
		addNewOption("Submachine Guns", "PM63", ::loadMenu, "PM63");
		addNewOption("Submachine Guns", "MPL", ::loadMenu, "MPL");
		addNewOption("Submachine Guns", "Spectre", ::loadMenu, "Spectre");
		addNewOption("Submachine Guns", "Kiparis", ::loadMenu, "Kiparis");

		addNewMenu("MP5k", "Submachine Guns");
		addNewOption("MP5k", "Extended Mags", ::givetest, "mp5k_extclip_mp");
		addNewOption("MP5k", "ACOG Sight", ::givetest, "mp5k_acog_mp");
		addNewOption("MP5k", "Red Dot Sight", ::givetest, "mp5k_elbit_mp");
		addNewOption("MP5k", "Reflex Sight", ::givetest, "mp5k_reflex_mp");
		addNewOption("MP5k", "Suppressor", ::givetest, "mp5k_silencer_mp");
		addNewOption("MP5k", "Rapid Fire", ::givetest, "mp5k_rf_mp");
		addNewOption("MP5k", "Default", ::givetest, "mp5k_mp");
		addNewOption("MP5k", "^5Next Page", ::loadMenu, "MP5k 2");

		addNewMenu("MP5k 2", "MP5k");
		addNewOption("MP5k 2", "Extended Mags + ACOG Sight", ::givetest, "mp5k_acog_extclip_mp");
		addNewOption("MP5k 2", "Extended Mags + Red Dot Sight", ::givetest, "mp5k_elbit_extclip_mp");
		addNewOption("MP5k 2", "Extended Mags + Reflex Sight", ::givetest, "mp5k_reflex_extclip_mp");
		addNewOption("MP5k 2", "Extended Mags + Suppressor", ::givetest, "mp5k_extclip_silencer_mp");
		addNewOption("MP5k 2", "Rapid Fire + ACOG Sight", ::givetest, "mp5k_acog_rf_mp");
		addNewOption("MP5k 2", "Rapid Fire + Red Dot Sight", ::givetest, "mp5k_elbit_rf_mp");
		addNewOption("MP5k 2", "Rapid Fire + Reflex Sight", ::givetest, "mp5k_reflex_rf_mp");
		addNewOption("MP5k 2", "Rapid Fire + Suppressor", ::givetest, "mp5k_rf_silencer_mp");

		addNewMenu("Skorpion", "Submachine Guns");
		addNewOption("Skorpion", "Extended Mags", ::givetest, "skorpion_extclip_mp");
		addNewOption("Skorpion", "Grip", ::givetest, "skorpion_grip_mp");
		addNewOption("Skorpion", "Dual Wield", ::givetest, "Skorpiondw_mp");
		addNewOption("Skorpion", "Suppressor", ::givetest, "skorpion_silencer_mp");
		addNewOption("Skorpion", "Rapid Fire", ::givetest, "skorpion_rf_mp");
		addNewOption("Skorpion", "Default", ::givetest, "skorpion_mp");
		addNewOption("Skorpion", "^5Next Page", ::loadMenu, "Skorpion 2");

		addNewMenu("Skorpion 2", "Skorpion");
		addNewOption("Skorpion 2", "Extended Mags + Grip", ::givetest, "skorpion_grip_extclip_mp");
		addNewOption("Skorpion 2", "Extended Mags + Suppressor", ::givetest, "skorpion_extclip_silencer_mp");
		addNewOption("Skorpion 2", "Suppressor + Grip", ::givetest, "skorpion_grip_silencer_mp");
		addNewOption("Skorpion 2", "Rapid Fire + Grip", ::givetest, "skorpion_grip_rf_mp");

		addNewMenu("MAC11", "Submachine Guns");
		addNewOption("MAC11", "Extended Mags", ::givetest, "mac11_extclip_mp");
		addNewOption("MAC11", "Red Dot Sight", ::givetest, "mac11_elbit_mp");
		addNewOption("MAC11", "Reflex Sight", ::givetest, "mac11_reflex_mp");
		addNewOption("MAC11", "Grip", ::givetest, "mac11_grip_mp");
		addNewOption("MAC11", "Dual Wield", ::givetest, "MAC11dw_mp");
		addNewOption("MAC11", "Dual Wield Glitched", ::givetest, "MAC11lh_mp");
		addNewOption("MAC11", "Suppressor", ::givetest, "mac11_silencer_mp");
		addNewOption("MAC11", "Rapid Fire", ::givetest, "mac11_rf_mp");
		addNewOption("MAC11", "Default", ::givetest, "mac11_mp");
		addNewOption("MAC11", "^5Next Page", ::loadMenu, "MAC11 2");

		addNewMenu("MAC11 2", "MAC11");
		addNewOption("MAC11 2", "Extended Mags + Red Dot Sight", ::givetest, "mac11_elbit_extclip_mp");
		addNewOption("MAC11 2", "Extended Mags + Reflex Sight", ::givetest, "mac11_reflex_extclip_mp");
		addNewOption("MAC11 2", "Extended Mags + Grip", ::givetest, "mac11_grip_extclip_mp");
		addNewOption("MAC11 2", "Extended Mags + Suppressor", ::givetest, "mac11_extclip_silencer_mp");
		addNewOption("MAC11 2", "Suppressor + Red Dot Sight", ::givetest, "mac11_elbit_silencer_mp");
		addNewOption("MAC11 2", "Suppressor + Reflex Sight", ::givetest, "mac11_reflex_silencer_mp");
		addNewOption("MAC11 2", "Suppressor + Grip", ::givetest, "mac11_grip_silencer_mp");
		addNewOption("MAC11 2", "Suppressor + Rapid Fire", ::givetest, "mac11_rf_silencer_mp");
		addNewOption("MAC11 2", "Rapid Fire + Red Dot Sight", ::givetest, "mac11_elbit_rf_mp");
		addNewOption("MAC11 2", "Rapid Fire + Reflex Sight", ::givetest, "mac11_reflex_rf_mp");

		addNewMenu("AK74u", "Submachine Guns");
		addNewOption("AK74u", "Extended Mags", ::givetest, "ak74u_extclip_mp");
		addNewOption("AK74u", "Dual Mags", ::givetest, "ak74u_dualclip_mp");
		addNewOption("AK74u", "ACOG Sight", ::givetest, "ak74u_acog_mp");
		addNewOption("AK74u", "Red Dot Sight", ::givetest, "ak74u_elbit_mp");
		addNewOption("AK74u", "Reflex Sight", ::givetest, "ak74u_reflex_mp");
		addNewOption("AK74u", "Grip", ::givetest, "ak74u_grip_mp");
		addNewOption("AK74u", "Suppressor", ::givetest, "ak74u_silencer_mp");
		addNewOption("AK74u", "Grenade Launcher", ::givetest, "ak74u_gl_mp");
		addNewOption("AK74u", "Rapid Fire", ::givetest, "ak74u_rf_mp");
		addNewOption("AK74u", "Default", ::givetest, "ak74u_mp");
		addNewOption("AK74u", "^5Next Page", ::loadMenu, "AK74u 2");

		addNewMenu("AK74u 2", "AK74u");
		addNewOption("AK74u 2", "Extended Mags", ::loadMenu, "AK74u Extended Mags");
		addNewOption("AK74u 2", "Dual Mags", ::loadMenu, "AK74u Dual Mags");

		addNewMenu("AK74u Extended Mags", "AK74u 2");
		addNewOption("AK74u Extended Mags", "Extended Mags + ACOG Sight", ::givetest, "ak74u_acog_extclip_mp");
		addNewOption("AK74u Extended Mags", "Extended Mags + Red Dot Sight", ::givetest, "ak74u_elbit_extclip_mp");
		addNewOption("AK74u Extended Mags", "Extended Mags + Reflex Sight", ::givetest, "ak74u_reflex_extclip_mp");
		addNewOption("AK74u Extended Mags", "Extended Mags + Grip", ::givetest, "ak74u_grip_extclip_mp");
		addNewOption("AK74u Extended Mags", "Extended Mags + Suppressor", ::givetest, "ak74u_extclip_silencer_mp");
		addNewOption("AK74u Extended Mags", "Extended Mags + Grenade Launcher", ::givetest, "ak74u_gl_extclip_mp");

		addNewMenu("AK74u Dual Mags", "AK74u 2");
		addNewOption("AK74u Dual Mags", "Dual Mags + ACOG Sight", ::givetest, "ak74u_acog_dualclip_mp");
		addNewOption("AK74u Dual Mags", "Dual Mags + Red Dot Sight", ::givetest, "ak74u_elbit_dualclip_mp");
		addNewOption("AK74u Dual Mags", "Dual Mags + Reflex Sight", ::givetest, "ak74u_reflex_dualclip_mp");
		addNewOption("AK74u Dual Mags", "Dual Mags + Grip", ::givetest, "ak74u_grip_dualclip_mp");
		addNewOption("AK74u Dual Mags", "Dual Mags + Suppressor", ::givetest, "ak74u_dualclip_silencer_mp");
		addNewOption("AK74u Dual Mags", "Dual Mags + Grenade Launcher", ::givetest, "ak74u_gl_dualclip_mp");

		addNewMenu("Uzi", "Submachine Guns");
		addNewOption("Uzi", "Extended Mags", ::givetest, "uzi_extclip_mp");
		addNewOption("Uzi", "ACOG Sight", ::givetest, "uzi_acog_mp");
		addNewOption("Uzi", "Red Dot Sight", ::givetest, "uzi_elbit_mp");
		addNewOption("Uzi", "Reflex Sight", ::givetest, "uzi_reflex_mp");
		addNewOption("Uzi", "Grip", ::givetest, "uzi_grip_mp");
		addNewOption("Uzi", "Suppressor", ::givetest, "uzi_silencer_mp");
		addNewOption("Uzi", "Rapid Fire", ::givetest, "uzi_rf_mp");
		addNewOption("Uzi", "Default", ::givetest, "uzi_mp");
		addNewOption("Uzi", "^5Next Page", ::loadMenu, "Uzi 2");

		addNewMenu("Uzi 2", "Uzi");
		addNewOption("Uzi 2", "Extended Mags + Red Dot Sight", ::givetest, "uzi_elbit_extclip_mp");
		addNewOption("Uzi 2", "Extended Mags + Reflex Sight", ::givetest, "uzi_reflex_extclip_mp");
		addNewOption("Uzi 2", "Extended Mags + Grip", ::givetest, "uzi_grip_extclip_mp");
		addNewOption("Uzi 2", "Extended Mags + Suppressor", ::givetest, "uzi_extclip_silencer_mp");
		addNewOption("Uzi 2", "Suppressor + Red Dot Sight", ::givetest, "uzi_elbit_silencer_mp");
		addNewOption("Uzi 2", "Suppressor + Reflex Sight", ::givetest, "uzi_reflex_silencer_mp");
		addNewOption("Uzi 2", "Suppressor + Grip", ::givetest, "uzi_grip_silencer_mp");
		addNewOption("Uzi 2", "Suppressor + Rapid Fire", ::givetest, "uzi_rf_silencer_mp");
		addNewOption("Uzi 2", "Rapid Fire + Red Dot Sight", ::givetest, "uzi_elbit_rf_mp");
		addNewOption("Uzi 2", "Rapid Fire + Reflex Sight", ::givetest, "uzi_reflex_rf_mp");

		addNewMenu("PM63", "Submachine Guns");
		addNewOption("PM63", "Extended Mags", ::givetest, "pm63_extclip_mp");
		addNewOption("PM63", "Grip", ::givetest, "pm63_grip_mp");
		addNewOption("PM63", "Dual Wield", ::givetest, "PM63dw_mp");
		addNewOption("PM63", "Dual Wield Glitched", ::givetest, "PM63lh_mp");
		addNewOption("PM63", "Rapid Fire", ::givetest, "pm63_rf_mp");
		addNewOption("PM63", "Default", ::givetest, "pm63_mp");
		addNewOption("PM63", "^5Next Page", ::loadMenu, "PM63 2");

		addNewMenu("PM63 2", "PM63");
		addNewOption("PM63 2", "Grip + Extended Mags", ::givetest, "pm63_grip_extclip_mp");
		addNewOption("PM63 2", "Grip + Rapid Fire", ::givetest, "pm63_grip_rf_mp");

		addNewMenu("MPL", "Submachine Guns");
		addNewOption("MPL", "Dual Mags", ::givetest, "mpl_dualclip_mp");
		addNewOption("MPL", "ACOG Sight", ::givetest, "mpl_acog_mp");
		addNewOption("MPL", "Red Dot Sight", ::givetest, "mpl_elbit_mp");
		addNewOption("MPL", "Reflex Sight", ::givetest, "mpl_reflex_mp");
		addNewOption("MPL", "Grip", ::givetest, "mpl_grip_mp");
		addNewOption("MPL", "Suppressor", ::givetest, "mpl_silencer_mp");
		addNewOption("MPL", "Rapid Fire", ::givetest, "mpl_rf_mp");
		addNewOption("MPL", "Default", ::givetest, "mpl_mp");
		addNewOption("MPL", "^5Next Page", ::loadMenu, "MPL 2");

		addNewMenu("MPL 2", "MPL");
		addNewOption("MPL 2", "Dual Mags + ACOG Sight", ::givetest, "mpl_acog_dualclip_mp");
		addNewOption("MPL 2", "Dual Mags + Red Dot Sight", ::givetest, "mpl_elbit_dualclip_mp");
		addNewOption("MPL 2", "Dual Mags + Reflex Sight", ::givetest, "mpl_reflex_dualclip_mp");
		addNewOption("MPL 2", "Dual Mags + Grip", ::givetest, "mpl_grip_dualclip_mp");
		addNewOption("MPL 2", "Dual Mags + Suppressor", ::givetest, "mpl_dualclip_silencer_mp");
		addNewOption("MPL 2", "Grip + ACOG Sight", ::givetest, "mpl_acog_grip_mp");
		addNewOption("MPL 2", "Grip + Red Dot Sight", ::givetest, "mpl_elbit_grip_mp");
		addNewOption("MPL 2", "Grip + Reflex Sight", ::givetest, "mpl_reflex_grip_mp");
		addNewOption("MPL 2", "Grip + Suppressor", ::givetest, "mpl_grip_silencer_mp");
		addNewOption("MPL 2", "Grip + Rapid Fire", ::givetest, "mpl_grip_rf_mp");

		addNewMenu("Spectre", "Submachine Guns");
		addNewOption("Spectre", "Extended Mags", ::givetest, "spectre_extclip_mp");
		addNewOption("Spectre", "ACOG Sight", ::givetest, "spectre_acog_mp");
		addNewOption("Spectre", "Red Dot Sight", ::givetest, "spectre_elbit_mp");
		addNewOption("Spectre", "Reflex Sight", ::givetest, "spectre_reflex_mp");
		addNewOption("Spectre", "Grip", ::givetest, "spectre_grip_mp");
		addNewOption("Spectre", "Suppressor", ::givetest, "spectre_silencer_mp");
		addNewOption("Spectre", "Rapid Fire", ::givetest, "spectre_rf_mp");
		addNewOption("Spectre", "Default", ::givetest, "spectre_mp");
		addNewOption("Spectre", "^5Next Page", ::loadMenu, "Spectre 2");

		addNewMenu("Spectre 2", "Spectre");
		addNewOption("Spectre 2", "Extended Mags + ACOG Sight", ::givetest, "spectre_acog_extclip_mp");
		addNewOption("Spectre 2", "Extended Mags + Red Dot Sight", ::givetest, "spectre_elbit_extclip_mp");
		addNewOption("Spectre 2", "Extended Mags + Reflex Sight", ::givetest, "spectre_reflex_extclip_mp");
		addNewOption("Spectre 2", "Extended Mags + Suppressor", ::givetest, "spectre_extclip_silencer_mp");
		addNewOption("Spectre 2", "Extended Mags + Grip", ::givetest, "spectre_grip_extclip_mp");
		addNewOption("Spectre 2", "Suppressor + ACOG Sight", ::givetest, "spectre_acog_silencer_mp");
		addNewOption("Spectre 2", "Suppressor + Red Dot Sight", ::givetest, "spectre_elbit_silencer_mp");
		addNewOption("Spectre 2", "Suppressor + Reflex Sight", ::givetest, "spectre_reflex_silencer_mp");
		addNewOption("Spectre 2", "Rapid Fire + Suppressor", ::givetest, "spectre_rf_silencer_mp");
		addNewOption("Spectre 2", "Suppressor + Grip", ::givetest, "spectre_grip_silencer_mp");

		addNewMenu("Kiparis", "Submachine Guns");
		addNewOption("Kiparis", "Extended Mags", ::givetest, "kiparis_extclip_mp");
		addNewOption("Kiparis", "ACOG Sight", ::givetest, "kiparis_acog_mp");
		addNewOption("Kiparis", "Red Dot Sight", ::givetest, "kiparis_elbit_mp");
		addNewOption("Kiparis", "Reflex Sight", ::givetest, "kiparis_reflex_mp");
		addNewOption("Kiparis", "Grip", ::givetest, "kiparis_grip_mp");
		addNewOption("Kiparis", "Dual Wield", ::givetest, "Kiparisdw_mp");
		addNewOption("Kiparis", "Dual Wield Glitched", ::givetest, "Kiparislh_mp");
		addNewOption("Kiparis", "Suppressor", ::givetest, "kiparis_silencer_mp");
		addNewOption("Kiparis", "Rapid Fire", ::givetest, "kiparis_rf_mp");
		addNewOption("Kiparis", "Default", ::givetest, "kiparis_mp");
		addNewOption("Kiparis", "^5Next Page", ::loadMenu, "Kiparis 2");

		addNewMenu("Kiparis 2", "Kiparis");
		addNewOption("Kiparis 2", "Extended Mags + ACOG Sight", ::givetest, "kiparis_acog_extclip_mp");
		addNewOption("Kiparis 2", "Extended Mags + Red Dot Sight", ::givetest, "kiparis_elbit_extclip_mp");
		addNewOption("Kiparis 2", "Extended Mags + Reflex Sight", ::givetest, "kiparis_reflex_extclip_mp");
		addNewOption("Kiparis 2", "Extended Mags + Suppressor", ::givetest, "kiparis_extclip_silencer_mp");
		addNewOption("Kiparis 2", "Extended Mags + Grip", ::givetest, "kiparis_grip_extclip_mp");
		addNewOption("Kiparis 2", "Suppressor + ACOG Sight", ::givetest, "kiparis_acog_silencer_mp");
		addNewOption("Kiparis 2", "Suppressor + Red Dot Sight", ::givetest, "kiparis_elbit_silencer_mp");
		addNewOption("Kiparis 2", "Suppressor + Reflex Sight", ::givetest, "kiparis_reflex_silencer_mp");
		addNewOption("Kiparis 2", "Rapid Fire + Suppressor", ::givetest, "kiparis_rf_silencer_mp");
		addNewOption("Kiparis 2", "Suppressor + Grip", ::givetest, "kiparis_grip_silencer_mp");
		
		addNewMenu("Light Machine Guns", "weapons");
		addNewOption("Light Machine Guns", "HK21", ::loadMenu, "HK21");
		addNewOption("Light Machine Guns", "RPK", ::loadMenu, "RPK");
		addNewOption("Light Machine Guns", "M60", ::loadMenu, "M60");
		addNewOption("Light Machine Guns", "Stoner63", ::loadMenu, "Stoner63");

		addNewMenu("HK21", "Light Machine Guns");
		addNewOption("HK21", "Extended Mags", ::givetest, "hk21_extclip_mp");
		addNewOption("HK21", "ACOG Sight", ::givetest, "hk21_acog_mp");
		addNewOption("HK21", "Red Dot Sight", ::givetest, "hk21_elbit_mp");
		addNewOption("HK21", "Reflex Sight", ::givetest, "hk21_reflex_mp");
		addNewOption("HK21", "Infrared Scope", ::givetest, "hk21_ir_mp");
		addNewOption("HK21", "Default", ::givetest, "hk21_mp");
		addNewOption("HK21", "^5Next Page", ::loadMenu, "HK21 2");

		addNewMenu("HK21 2", "HK21");
		addNewOption("HK21 2", "Extended Mags + ACOG Sight", ::givetest, "hk21_acog_extclip_mp");
		addNewOption("HK21 2", "Extended Mags + Red Dot Sight", ::givetest, "hk21_elbit_extclip_mp");
		addNewOption("HK21 2", "Extended Mags + Reflex Sight", ::givetest, "hk21_reflex_extclip_mp");
		addNewOption("HK21 2", "Extended Mags + Infrared Scope", ::givetest, "hk21_ir_extclip_mp");

		addNewMenu("RPK", "Light Machine Guns");
		addNewOption("RPK", "Extended Mags", ::givetest, "rpk_extclip_mp");
		addNewOption("RPK", "Dual Mags", ::givetest, "rpk_dualclip_mp");
		addNewOption("RPK", "ACOG Sight", ::givetest, "rpk_acog_mp");
		addNewOption("RPK", "Red Dot Sight", ::givetest, "rpk_elbit_mp");
		addNewOption("RPK", "Reflex Sight", ::givetest, "rpk_reflex_mp");
		addNewOption("RPK", "Infrared Scope", ::givetest, "rpk_ir_mp");
		addNewOption("RPK", "Default", ::givetest, "rpk_mp");
		addNewOption("RPK", "^5Next Page", ::loadMenu, "RPK 2");

		addNewMenu("RPK 2", "RPK");
		addNewOption("RPK 2", "Extended Mags + ACOG Sight", ::givetest, "rpk_acog_extclip_mp");
		addNewOption("RPK 2", "Extended Mags + Red Dot Sight", ::givetest, "rpk_elbit_extclip_mp");
		addNewOption("RPK 2", "Extended Mags + Reflex Sight", ::givetest, "rpk_reflex_extclip_mp");
		addNewOption("RPK 2", "Extended Mags + Infrared Scope", ::givetest, "rpk_ir_extclip_mp");
		addNewOption("RPK 2", "Dual Mags + ACOG Sight", ::givetest, "rpk_acog_dualclip_mp");
		addNewOption("RPK 2", "Dual Mags + Red Dot Sight", ::givetest, "rpk_elbit_dualclip_mp");
		addNewOption("RPK 2", "Dual Mags + Reflex Sight", ::givetest, "rpk_reflex_dualclip_mp");
		addNewOption("RPK 2", "Dual Mags + Infrared Scope", ::givetest, "rpk_ir_dualclip_mp");

		addNewMenu("M60", "Light Machine Guns");
		addNewOption("M60", "Extended Mags", ::givetest, "m60_extclip_mp");
		addNewOption("M60", "ACOG Sight", ::givetest, "m60_acog_mp");
		addNewOption("M60", "Red Dot Sight", ::givetest, "m60_elbit_mp");
		addNewOption("M60", "Reflex Sight", ::givetest, "m60_reflex_mp");
		addNewOption("M60", "Grip", ::givetest, "m60_grip_mp");
		addNewOption("M60", "Infrared Scope", ::givetest, "m60_ir_mp");
		addNewOption("M60", "Default", ::givetest, "m60_mp");
		addNewOption("M60", "^5Next Page", ::loadMenu, "M60 2");

		addNewMenu("M60 2", "M60");
		addNewOption("M60 2", "Extended Mags + ACOG Sight", ::givetest, "m60_acog_extclip_mp");
		addNewOption("M60 2", "Extended Mags + Red Dot Sight", ::givetest, "m60_elbit_extclip_mp");
		addNewOption("M60 2", "Extended Mags + Reflex Sight", ::givetest, "m60_reflex_extclip_mp");
		addNewOption("M60 2", "Extended Mags + Infrared Scope", ::givetest, "m60_ir_extclip_mp");
		addNewOption("M60 2", "Grip + ACOG Sight", ::givetest, "m60_acog_grip_mp");
		addNewOption("M60 2", "Grip + Red Dot Sight", ::givetest, "m60_elbit_grip_mp");
		addNewOption("M60 2", "Grip + Reflex Sight", ::givetest, "m60_reflex_grip_mp");
		addNewOption("M60 2", "Grip + Infrared Scope", ::givetest, "m60_ir_grip_mp");

		addNewMenu("Stoner63", "Light Machine Guns");
		addNewOption("Stoner63", "Extended Mags", ::givetest, "stoner63_extclip_mp");
		addNewOption("Stoner63", "ACOG Sight", ::givetest, "stoner63_acog_mp");
		addNewOption("Stoner63", "Red Dot Sight", ::givetest, "stoner63_elbit_mp");
		addNewOption("Stoner63", "Reflex Sight", ::givetest, "stoner63_reflex_mp");
		addNewOption("Stoner63", "Infrared Scope", ::givetest, "stoner63_ir_mp");
		addNewOption("Stoner63", "Default", ::givetest, "stoner63_mp");
		addNewOption("Stoner63", "^5Next Page", ::loadMenu, "Stoner63 2");

		addNewMenu("Stoner63 2", "Stoner63");
		addNewOption("Stoner63 2", "Extended Mags + ACOG Sight", ::givetest, "stoner63_acog_extclip_mp");
		addNewOption("Stoner63 2", "Extended Mags + Red Dot Sight", ::givetest, "stoner63_elbit_extclip_mp");
		addNewOption("Stoner63 2", "Extended Mags + Reflex Sight", ::givetest, "stoner63_reflex_extclip_mp");
		addNewOption("Stoner63 2", "Extended Mags + Infrared Scope", ::givetest, "stoner63_ir_extclip_mp");

		addNewMenu("Pistols", "weapons");
		addNewOption("Pistols", "ASP", ::loadMenu, "ASP");
		addNewOption("Pistols", "M1911", ::loadMenu, "M1911");
		addNewOption("Pistols", "Makarov", ::loadMenu, "Makarov");
		addNewOption("Pistols", "Python", ::loadMenu, "Python");
		addNewOption("Pistols", "CZ75", ::loadMenu, "CZ75");

		addNewMenu("ASP", "Pistols");
		addNewOption("ASP", "Dual Wield", ::givetest, "aspdw_mp");
		addNewOption("ASP", "Dual Wield Glitched", ::givetest, "asplh_mp");
		addNewOption("ASP", "Default", ::givetest, "asp_mp");

		addNewMenu("M1911", "Pistols");
		addNewOption("M1911", "Upgraded Iron Sight", ::givetest, "m1911_upgradesight_mp");
		addNewOption("M1911", "Extended Mags", ::givetest, "m1911_extclip_mp");
		addNewOption("M1911", "Dual Wield", ::givetest, "m1911dw_mp");
		addNewOption("M1911", "Dual Wield Glitched", ::givetest, "m1911lh_mp");
		addNewOption("M1911", "Suppressor", ::givetest, "m1911_silencer_mp");
		addNewOption("M1911", "Default", ::givetest, "m1911_mp");

		addNewMenu("Makarov", "Pistols");
		addNewOption("Makarov", "Upgraded Iron Sight", ::givetest, "makarov_upgradesight_mp");
		addNewOption("Makarov", "Extended Mags", ::givetest, "makarov_extclip_mp");
		addNewOption("Makarov", "Dual Wield", ::givetest, "makarovdw_mp");
		addNewOption("Makarov", "Dual Wield Glitched", ::givetest, "makarovlh_mp");
		addNewOption("Makarov", "Suppressor", ::givetest, "makarov_silencer_mp");
		addNewOption("Makarov", "Default", ::givetest, "makarov_mp");

		addNewMenu("Python", "Pistols");
		addNewOption("Python", "ACOG Sight", ::givetest, "python_acog_mp");
		addNewOption("Python", "Snub Nose", ::givetest, "python_snub_mp");
		addNewOption("Python", "Speed Reloader", ::givetest, "python_speed_mp");
		addNewOption("Python", "Dual Wield", ::givetest, "pythondw_mp");
		addNewOption("Python", "Dual Wield Glitched", ::givetest, "pythonlh_mp");
		addNewOption("Python", "Default", ::givetest, "python_mp");

		addNewMenu("CZ75", "Pistols");
		addNewOption("CZ75", "Upgraded Iron Sight", ::givetest, "cz75_upgradesight_mp");
		addNewOption("CZ75", "Extended Mags", ::givetest, "cz75_extclip_mp");
		addNewOption("CZ75", "Dual Wield", ::givetest, "cz75dw_mp");
		addNewOption("CZ75", "Dual Wield Glitched", ::givetest, "cz75lh_mp");
		addNewOption("CZ75", "Suppressor", ::givetest, "cz75_silencer_mp");
		addNewOption("CZ75", "Full Auto Upgraded", ::givetest, "cz75_Auto_mp");
		addNewOption("CZ75", "Default", ::givetest, "cz75_mp");
		
		addNewMenu("Shotguns", "weapons");
		addNewOption("Shotguns", "Olympia", ::givetest, "rottweil72_mp");
		addNewOption("Shotguns", "Stakeout", ::loadMenu, "Stakeout");
		addNewOption("Shotguns", "SPAS-12", ::loadMenu, "Spas-12");
		addNewOption("Shotguns", "HS10", ::loadMenu, "Hs10");

		addNewMenu("Stakeout", "Shotguns");
		addNewOption("Stakeout", "Grip", ::givetest, "ithaca_grip_mp");
		addNewOption("Stakeout", "Default", ::givetest, "ithaca_mp");

		addNewMenu("Spas-12", "Shotguns");
		addNewOption("Spas-12", "Suppressor", ::givetest, "spas_silencer_mp");
		addNewOption("Spas-12", "Default", ::givetest, "spas_mp");

		addNewMenu("Hs10", "Shotguns");
		addNewOption("Hs10", "Dual Wield", ::givetest, "hs10dw_mp");
		addNewOption("Hs10", "Dual Wield Glitched", ::givetest, "hs10lh_mp");
		addNewOption("Hs10", "Default", ::givetest, "hs10_mp");

		addNewMenu("Launchers", "weapons");
		addNewOption("Launchers", "M72 Law", ::givetest, "m72_Law_mp");
		addNewOption("Launchers", "RPG", ::givetest, "rpg_mp");
		addNewOption("Launchers", "Strela-3", ::givetest, "strela_mp");
		addNewOption("Launchers", "China Lake", ::givetest, "china_lake_mp");
	
		addNewMenu("Misc", "weapons");
		addNewOption("Misc", "M72 Law", ::givetest, "m72_Law_mp");
		addNewOption("Misc", "Ballistic Knife", ::givetest, "knife_ballistic_mp");
		addNewOption("Misc", "Crossbow", ::givetest, "crossbow_explosive_mp");
		addNewOption("Misc", "Default Weapon", ::givetest, "defaultweapon_mp");
		addNewOption("Misc", "Syrette", ::givetest, "syrette_mp");
		addNewOption("Misc", "Minigun", ::givetest, "minigun_mp");

	addNewMenu("ks", "main"); //Killstreaks Menu
	addNewOption("ks", "Give ^5Care Package", ::streak, "supply_drop_mp");
	addNewOption("ks", "Give ^5Spy Plane", ::streak, "radar_mp");
	addNewOption("ks", "Give ^5Counter-Spy Plane", ::streak, "counteruav_mp");
	addNewOption("ks", "Give ^5RC-XD", ::streak, "rcbomb_mp");
	addNewOption("ks", "Give ^5Attack Dogs", ::streak, "dogs_mp");
	addNewOption("ks", "Give ^5SAM Turret", ::streak, "auto_tow_mp");
	addNewOption("ks", "Give ^5Attack Helicopter", ::streak, "helicopter_comlink_mp");
	addNewOption("ks", "Give ^5Napalm Strike", ::streak, "napalm_mp");
	addNewOption("ks", "Give ^5Sentry Gun", ::streak, "autoturret_mp");
	addNewOption("ks", "Give ^5Mortar Team", ::streak, "mortar_mp");
	addNewOption("ks", "Give ^5Valkyrie Rockets", ::streak, "m220_tow_mp");
	addNewOption("ks", "Give ^5Rolling Thunder", ::streak, "airstrike_mp");
	addNewOption("ks", "Give ^5Chopper Gunner", ::streak, "helicopter_gunner_mp");
	addNewOption("ks", "Give ^5Gunship", ::streak, "helicopter_player_firstperson_mp");
	addNewOption("ks", "Give ^5Grim Reaper", ::streak, "m202_flash_mp");
	
	addNewMenu("bots","main");
	addNewOption("bots", "^1Enemy ^7Bots ^5Menu", ::loadMenu, "enemyBots");
	addNewOption("bots", "^2Friendly ^7Bots ^5Menu", ::loadMenu, "friendlyBots");
	
		addNewMenu("enemyBots", "bots"); 
		addNewOption("enemyBots", "^7Spawn ^1Enemy ^7Bot", ::AddBot, "axis", "");
		//addNewOption("enemyBots", 1, "^7Spawn ^1Enemy ^7 Smart Bot", ::AddBot, "axis", "smart");
		addNewOption("enemyBots", "^1Kick All Enemy Bots", ::KickBotsEnemy);
		addNewOption("enemyBots", "^1Enemy Bots to Crosshairs", ::TeleportBotEnemy);
		addNewOption("enemyBots", "^1Enemy Bots to You", ::ToggleBotSpawnEnemy);
		addNewOption("enemyBots", "^1Toggle Enemy Bots Stance", ::StanceBotsEnemy);
		
		addNewMenu("friendlyBots", "bots"); 
		addNewOption("friendlyBots", "^7Spawn ^2Friendly ^7Bot", ::AddBot, "allies", "");
		//addNewOption("friendlyBots", 1, "^7Spawn ^2Friendly ^7 Smart Bot", ::AddBot, "allies", "smart");
		addNewOption("friendlyBots", "^2Kick All Friendly Bots", ::KickBotsFriendly);
		addNewOption("friendlyBots", "^2Friendly Bots to Crosshairs", ::TeleportBotFriendly);
		addNewOption("friendlyBots", "^2Friendly Bots to You", ::ToggleBotSpawnFriendly);
		addNewOption("friendlyBots", "^2Toggle Friendly Bots Stance", ::StanceBotsFriendly);
	
	addNewMenu("lobby", "main");
	addNewOption("lobby", "Map ^5Menu", ::loadMenu, "map menu");
    addNewOption("lobby", "Pause/Resume Timer", ::PauseTimer);
	addNewOption("lobby", "Toggle Pickup Radius", ::pickupradius);
    addNewOption("lobby", "Toggle Reverse Ladder Mod", ::reverseladders);
	addNewOption("lobby", "Reset Rounds", ::roundreset);
    addNewOption("lobby", "Fast Restart", ::FastRestart);
	
	addNewMenu("map menu", "lobby");
	addNewOption("map menu", "^5Regular", ::loadMenu, "regular maps");
	addNewOption("map menu", "^5DLC", ::loadMenu, "dlc maps");
	
	addNewMenu("regular maps", "map menu");
	addNewOption("regular maps", "Array", ::changeMap, "mp_array");
	addNewOption("regular maps", "Havana", ::changeMap, "mp_cairo");
	addNewOption("regular maps", "Launch", ::changeMap, "mp_cosmodrome");
	addNewOption("regular maps", "Cracked", ::changeMap, "mp_cracked");
	addNewOption("regular maps", "Crisis", ::changeMap, "mp_crisis");
	addNewOption("regular maps", "Grid", ::changeMap, "mp_duga");
	addNewOption("regular maps", "Firing Range", ::changeMap, "mp_firingrange");
	addNewOption("regular maps", "Hanoi", ::changeMap, "mp_hanoi");
	addNewOption("regular maps", "Jungle", ::changeMap, "mp_havoc");
	addNewOption("regular maps", "Summit", ::changeMap, "mp_mountain");
	addNewOption("regular maps", "Nuketown", ::changeMap, "mp_nuked");
	addNewOption("regular maps", "Radiation", ::changeMap, "mp_radiation");
	addNewOption("regular maps", "WMD", ::changeMap, "mp_russianbase");
	addNewOption("regular maps", "Villa", ::changeMap, "mp_villa");
	
	addNewMenu("dlc maps", "map menu");
	addNewOption("dlc maps", "Berlin Wall", ::changeMap, "mp_berlinwall2");
	addNewOption("dlc maps", "Discovery", ::changeMap, "mp_discovery");
	addNewOption("dlc maps", "Kowloon", ::changeMap, "mp_kowloon");
	addNewOption("dlc maps", "Stadium", ::changeMap, "mp_stadium");
	addNewOption("dlc maps", "Convoy", ::changeMap, "mp_gridlock");
	addNewOption("dlc maps", "Hotel", ::changeMap, "mp_hotel");
	addNewOption("dlc maps", "Zoo", ::changeMap, "mp_zoo");
	addNewOption("dlc maps", "Stockpile", ::changeMap, "mp_outskirts");
	addNewOption("dlc maps", "Drive-In", ::changeMap, "mp_drivein");
	addNewOption("dlc maps", "Silo", ::changeMap, "mp_silo");
	addNewOption("dlc maps", "Hangar 18", ::changeMap, "mp_area51");
	addNewOption("dlc maps", "Hazard", ::changeMap, "mp_golfcourse");
	
	addNewMenu("players", "main");
	addNewOption("players", level.players[0].name, ::loadMenu, level.players[0].name);
	addNewOption("players", level.players[1].name, ::loadMenu, level.players[1].name);
	addNewOption("players", level.players[2].name, ::loadMenu, level.players[2].name);
	addNewOption("players", level.players[3].name, ::loadMenu, level.players[3].name);
	addNewOption("players", level.players[4].name, ::loadMenu, level.players[4].name);
	addNewOption("players", level.players[5].name, ::loadMenu, level.players[5].name);
	addNewOption("players", level.players[6].name, ::loadMenu, level.players[6].name);
	addNewOption("players", level.players[7].name, ::loadMenu, level.players[7].name);
	addNewOption("players", level.players[8].name, ::loadMenu, level.players[8].name);
	addNewOption("players", level.players[9].name, ::loadMenu, level.players[9].name);
	addNewOption("players", level.players[10].name, ::loadMenu, level.players[10].name);
	addNewOption("players", level.players[11].name, ::loadMenu, level.players[11].name);
	addNewOption("players", level.players[12].name, ::loadMenu, level.players[12].name);
	addNewOption("players", level.players[13].name, ::loadMenu, level.players[13].name);
	addNewOption("players", level.players[14].name, ::loadMenu, level.players[14].name);
	addNewOption("players", level.players[15].name, ::loadMenu, level.players[15].name);
	addNewOption("players", level.players[16].name, ::loadMenu, level.players[16].name);
	addNewOption("players", level.players[17].name, ::loadMenu, level.players[17].name);
	for(i = 0;i < level.players.size;i++)
	{
		addNewMenu(level.players[i].name, "players");
		addNewOption(level.players[i].name, "Player to Crosshairs", ::toCross, level.players[i]);
		addNewOption(level.players[i].name, "Player to You", ::toYou, level.players[i]);
		addNewOption(level.players[i].name, "Kick Player", ::toKick, level.players[i]);
		addNewOption(level.players[i].name, "Kill Player", ::toKill, level.players[i]);
		addNewOption(level.players[i].name, "Change Player Stance", ::toStance, level.players[i]);
	}
}

/*
_playerStructure()
{
	self addNewMenu("players", "main");
	for(i=0;i<level.players.size;i++)
	{
		player = level.players[i];
		name = player getTrueName();
		menu = "player_"+name;
		if(i==0 && self !=level.players[0])
		{
			continue;
		}
		addNewOption("players", name, ::loadMenu, menu);
		
		addNewMenu(menu, "players");
		addNewOption(menu, "Kill", ::Test);
	}
}
*/

addNewMenu(menu, parent)
{
   if(!isDefined(self.Menu))self.Menu=[];
   self.Menu[menu] = spawnStruct();
   self.Menu[menu].title = level.menuHeader; //default value is 'title'
   self.Menu[menu].subheader = level.menuSubHeader;
   self.Menu[menu].credits = "^7" + level.developer + "^7 - " + level.menuVersion;
   /*
   self.Menu[menu].velo = "Velocity Bind: " + self.VelocityRetro + " "; 
   self.Menu[menu].bolt = "Bolt Movement Bind: " + self.BoltTextRetro + " ";
   self.Menu[menu].ufo = "UFO/Teleport Bind: " + self.UFOTextRetro + " ";
   self.Menu[menu].eb = "Explosive Bullets: " + self.EBTextRetro + " ";
   */
   self.Menu[menu].parent = parent;
   self.Menu[menu].text = [];
   self.Menu[menu].func = [];
   self.Menu[menu].inp1 = [];
   self.Menu[menu].inp2 = [];
   self.Menu[menu].inp3 = [];
   self.Menu[menu].status = [];
   
   self.Menu[menu].toggle = [];
}
addNewOption(menu,text,func,inp,inp2,inp3)
{
	F=self.Menu[menu].text.size;
	self.Menu[menu].text[F] = text;
	self.Menu[menu].func[F] = func;
	self.Menu[menu].inp1[F] = inp;
	self.Menu[menu].inp2[F] = inp2;
	self.Menu[menu].inp3[F] = inp3;
}
addToggleOption(menu,text,func,toggleBool,inp,inp2,inp3,status)
{
	F=self.Menu[menu].text.size;
	self.Menu[menu].text[F] = text;
	self.Menu[menu].func[F] = func;
	self.Menu[menu].inp1[F] = inp;
	self.Menu[menu].inp2[F] = inp2;
	self.Menu[menu].inp3[F] = inp3;
	if(!isDefined(status))
	{
		self.Menu[menu].status[F] = undefined;
	}
	else
	{
		self.Menu[menu].status[F] = status;
	}
	if(!isDefined(toggleBool))
	{
		self.Menu[menu].toggle[F] = undefined;
	}
	else
	{
		self.Menu[menu].toggle[F] = toggleBool;
	}
}


