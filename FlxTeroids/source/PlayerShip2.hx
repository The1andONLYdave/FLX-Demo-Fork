package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxSpriteUtil;
import flixel.ui.FlxButton;
/**
 * ...
 * @author Zaphod
 */
class PlayerShip2 extends FlxSprite
{
	private var _thrust:Float = 0;
	
	public function new() 
	{
		super(Math.floor(FlxG.width / 2 - 8), Math.floor(FlxG.height / 2 - 8));
		
		#if flash
		loadRotatedGraphic("assets/ship1.png", 32, -1, false, true);
		#else
		loadGraphic("assets/ship1.png");
		#end
		
		width *= 0.75;
		height *= 0.75;
		centerOffsets();
	}
	
	override public function update():Void 
	{
		angularVelocity = 0;
		
		if (FlxG.keys.anyPressed(["A", "LEFT"])  || PlayState3.virtualPad.buttonLeft.status == FlxButton.PRESSED)
		{
			angularVelocity -= 240;
		}
		
		if (FlxG.keys.anyPressed(["D", "RIGHT"]) || PlayState3.virtualPad.buttonRight.status == FlxButton.PRESSED)
		{
			angularVelocity += 240;
		}
		
		acceleration.set();
		
		if (FlxG.keys.anyPressed(["W", "UP"]) || PlayState3.virtualPad.buttonUp.status == FlxButton.PRESSED)
		{
			FlxAngle.rotatePoint(90, 0, 0, 0, angle, acceleration);
		}
		
		if (FlxG.keys.justPressed.SPACE || PlayState3.virtualPad.buttonA.status == FlxButton.PRESSED)
		{
			var bullet:FlxSprite = PlayState3.bullets.recycle();
			bullet.reset(x + (width - bullet.width) / 2, y + (height - bullet.height) / 2);
			bullet.angle = angle;
			FlxAngle.rotatePoint(150, 0, 0, 0, bullet.angle, bullet.velocity);
			bullet.velocity.x *= 2;
			bullet.velocity.y *= 2;
			FlxG.sound.play("assets/sfx/_gun.wav", 1, false);	//123
		}
		
		FlxSpriteUtil.screenWrap(this);
		
		super.update();
	}
}