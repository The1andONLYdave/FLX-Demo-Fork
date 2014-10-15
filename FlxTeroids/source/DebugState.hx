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
class DebugState extends FlxState
{

public var DemoButton1:FlxButton;
public var DemoButton2:FlxButton;
public var DemoButton3:FlxButton;
public var _pos:FlxText;

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
		
		DemoButton1 =  new FlxButton((FlxG.width /2)-30 , (FlxG.height/4)*3, "Level 2", closeDebug);
		add(DemoButton1);
		DemoButton2 =  new FlxButton(((FlxG.width /4)*3 )-30, FlxG.height/2, "More Health", closeDebug2);
		add(DemoButton2);
		DemoButton3 =  new FlxButton(((FlxG.width /4)*1 )-30, FlxG.height/2, "Change gun", closeDebug3);
		add(DemoButton3);
		
		_pos = new FlxText(0, (FlxG.height-35), FlxG.width);
		_pos.setFormat(null, 5, FlxColor.GREEN, "left", FlxText.BORDER_OUTLINE, 0x131c1b);
			
		if(Reg.debug==true){
			_pos.scrollFactor.set(0, 0);
			add(_pos);
		}
		
		
			
		
	}
	
	override public function update():Void 
	{
	_pos.text="x: "+Std.string(null)+"\ny:"+Std.string(null)+"\nL:"+Std.string(Reg.level)+"\nG:"+Std.string(Reg.gun)+"\nm:"+Std.string(Reg.maxLevel);

	super.update();
	
	}
	private function closeDebug():Void
	{
		trace("closeDebug");
		//GAnalytics.trackEvent("Game", "PauseMenu", "starting", 1);
		Reg.level=2;
		FlxG.switchState(new PlayState());
	}
		private function closeDebug2():Void
	{
		trace("closeDebug2");
		Reg.moreHealth=true;
	}
		private function closeDebug3():Void
	{
		trace("closeDebug3");
		Reg.gun=2;
	}
	
}