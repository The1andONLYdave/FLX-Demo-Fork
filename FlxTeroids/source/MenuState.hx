package;

import flixel.addons.display.FlxStarField.FlxStarField3D;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
/**
 * ...
 * @author Zaphod
 */
class MenuState extends FlxState
{
public var DemoButton1:FlxButton;
public var DemoButton2:FlxButton;
public var DemoButton3:FlxButton;


	override public function create():Void 
	{
		FlxG.mouse.visible = true;
		
		add(new FlxStarField3D());
		
		var t:FlxText;
		t = new FlxText(0, FlxG.height / 2 - 110, FlxG.width, "FlxTeroids");
		t.setFormat(null, 32, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
		add(t);
		
		t = new FlxText(0, FlxG.height - 140, FlxG.width, "click to play");
		t.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
		add(t);
		
		DemoButton1 =  new FlxButton((FlxG.width /2)-30 , (FlxG.height/4)*3, "Options", openOptions);
		add(DemoButton1);
		DemoButton2 =  new FlxButton(((FlxG.width /4)*3 )-30, FlxG.height/2, "Play", closeMenu);
		add(DemoButton2);
		DemoButton3 =  new FlxButton(((FlxG.width /4)*1 )-30, FlxG.height/2, "Exit", closeGame);
		add(DemoButton3);
		
		
		
		
		
		
	}
	
	private function openOptions():Void
	{
		trace("openOptions");
		//GAnalytics.trackEvent("Game", "PauseMenu", "starting", 1);
		FlxG.switchState(new SettingsState());
	}
		private function closeMenu():Void
	{
		trace("closeMenu");
		//GAnalytics.trackEvent("Game", "PauseMenu", "starting", 1);
		FlxG.switchState(new PlayState());
	}
		private function closeGame():Void
	{
		trace("closeGame");
		//GAnalytics.trackEvent("Game", "PauseMenu", "starting", 1);
		//FlxG.fade();
	}
	
}