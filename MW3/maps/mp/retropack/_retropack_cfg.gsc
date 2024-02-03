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

Version: 1.0.1
Date: June 5, 2022
Compatibility: Modern Warfare 3

THIS FILE IS EXCLUSIVELY USED FOR RETROPACK'S CFG BIND FUNCTION.
TO USE IT SET THE "level.script_x" VARIABLE'S VALUE WITH YOUR CFG SCRIPT/COMMAND.
MAKE SURE THE END OF YOUR CFG SCRIPT/COMMAND IS WITHOUT A SEMICOLON.
YOU CAN USE UP TO 4 SCRIPTS/COMMANDS (level.script_1, level.script_2, level.script_3, level.script_4)

E.G

"+attack;-attack;weapnext;"; <---- INCORRECT SYNTAX WITH SEMICOLON BEFORE CLOSING PARAMATERS 
"+attack;-attack;weapnext"; <---- CORRECT SYNTAX WITH SEMICOLON REMOVED

*/

init() 
{
	//Script 1
	level.script_1 = "+attack;-attack;+usereload;-usereload;wait 218;weapnext;wait 2;weapnext;wait 2;weapnext;wait 2;weapnext;wait 2;+attack;-attack;wait 2;+usereload;-usereload;wait 42;weapnext;wait 2;weapnext;wait 2;weapnext;wait 2;weapnext;wait 2;+usereload;-usereload;wait 138;+breath_sprint;wait 5;+forward;wait 38;-breath_sprint;-forward;wait 2;weapnext;wait 2;weapnext;wait 2;weapnext;wait 2;+attack;-attack;wait 2;+frag;wait 20;-frag";

	//Script 2
	level.script_2 = "+attack;-attack;+usereload;-usereload;wait 218;weapnext";
	
	//Script 3
	level.script_2 = "+attack;-attack;+usereload;-usereload;wait 218;weapnext";
		
	//Script 4
	level.script_2 = "+attack;-attack;+usereload;-usereload;wait 218;weapnext";
}

