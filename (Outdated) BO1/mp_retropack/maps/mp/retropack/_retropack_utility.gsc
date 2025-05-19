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
#include maps\mp\retropack\_retropack_functions;

createText(font, fontscale, align, relative, x, y, sort, color, alpha, glowColor, glowAlpha, text)
{
	textElem = CreateFontString( font, fontscale );
	textElem setPoint( align, relative, x, y );
	textElem.sort = sort;
	textElem.type = "text";
	textElem setSafeText(text);
	textElem.color = color;
	textElem.alpha = alpha;
	textElem.glowColor = glowColor;
	textElem.glowAlpha = glowAlpha;
	textElem.hideWhenInMenu = true;
	return textElem;
}

createRectangle(align, relative, x, y, width, height, color, alpha, sorting, shadero)
{
	barElemBG = newClientHudElem( self );
	barElemBG.elemType = "bar";
	if ( !level.splitScreen )
	{
		barElemBG.x = -2;
		barElemBG.y = -2;
	}
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.align = align;
	barElemBG.relative = relative;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.children = [];
	barElemBG.color = color;
	if(isDefined(alpha))
		barElemBG.alpha = alpha;
	else
		barElemBG.alpha = 1;
	barElemBG setShader( shadero, width , height );
	barElemBG.hidden = false;
	barElemBG.sort = sorting;
	barElemBG setPoint(align,relative,x,y);
	return barElemBG;
}

elemFadeOverTime(time,alpha)
{
	self fadeovertime(time);
	self.alpha = alpha;
}

elemMoveOverTimeY(time,y)
{
	self moveovertime(time);
	self.y = y;
}

elemMoveOverTimeX(time,x)
{
	self moveovertime(time);
	self.x = x;
}

elemScaleOverTime(time,width,height)
{
	self scaleovertime(time,width,height);
}

ePxmonitor(client,shader,mode)
{
	client endon("disconnect");
	switch(mode)
	{
	   case "Update":
	       client waittill_any("Update","Menu_Is_Closed");
	   break;
	   
	   case "Close":
	       client waittill_any("Menu_Is_Closed");
	   break;
	}
	shader destroy();
}

Test()
{
   self iprintln("^1Test");
}

InputTest(a,b,c)
{
	if(!isDefined(a) && !isDefined(b) && !isDefined(c))
	{
		self iprintln("No Inputs Defined!");
	}
	else if(isDefined(a) && !isDefined(b) && !isDefined(c))
	{
		self iprintln("1: "+a);
	}
	else if(isDefined(a) && isDefined(b) && !isDefined(c))
	{
		self iprintln("1: "+a+" 2: "+b);
	}
	else if(isDefined(a) && isDefined(b) && isDefined(c))
	{
		self iprintln("1: "+a+" 2: "+b+" 3: "+c);
	}
}

TestToggle()
{
	if(!self.ToggleTest)
	{
		self.ToggleTest = true;
	}
	else
	{
		self.ToggleTest = false;
	}
}

OverflowTest()
{
   display=createFontString("default",1.5);
   display setPoint("CENTER","CENTER",0,0);
	i=0;
	for(;;)
	{
		display setSafeText("Strings: ^1"+i);
		i++;
		wait 0.05;
	}
	wait 0.05;
}

getLoc()
{
   self endon("death");
   self.display destroy();
   wait .2;
   self.display = createFontString("default",1.5);
   self.display setPoint("CENTER","CENTER",0,0);
   self.display setSafeText(self.origin);
   wait 0.05;
}

setSafeText(text)
{
	self setText(text);
	level.result += 1;
	level notify("textset");
}

overflowfix()
{  
    level endon("game_ended");
    level.test = createServerFontString("default",1.5);
    level.test setText("xePixTvx");                
    level.test.alpha = 0;
    for(;;)
    {      
        level waittill("textset");
        if(level.result >= 120)
        {
        	level.test ClearAllTextAfterHudElem();
            level.result = 0;
            //foreach(player in level.players)//Gives me syntax WTF
			for(i=0;i<level.players.size;i++)
			{
            	if(level.players[i].Menu["Menu"]["Open"]==true)
				{
                	level.players[i] _recreateTextForOverFlowFix();
				}
			}
        }      
        wait 0.01;    
    }
}