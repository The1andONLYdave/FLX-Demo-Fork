package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.ui.FlxButton;
import flixel.ui.FlxVirtualPad;
import flixel.text.FlxText;
import flixel.util.FlxStringUtil;
/**
* Atari 2600 Breakout
* 
* @author Davey, Photon Storm
* @link http://www.photonstorm.com/archives/1290/video-of-me-coding-breakout-in-flixel-in-20-mins
*
* rewrite for android inclluding virtualPad and more by David-Lee Kulsch
* github: http://github.com/the1andonlydave/flx-demo-fork in breakout
*/
class PlayState extends FlxState
{
	private static inline var BAT_SPEED:Int = 350;
	
	private var _bat:FlxSprite;
	private var _ball:FlxSprite;
	
	private var _walls:FlxGroup;
	private var _leftWall:FlxSprite;
	private var _rightWall:FlxSprite;
	private var _topWall:FlxSprite;
	private var _bottomWall:FlxSprite;
	private var _floor:FlxGroup;
	
	
	private var _bricks:FlxGroup;
	
	public static var virtualPad:FlxVirtualPad;
	
	private var score:Int;
	private var ball:Int;
	private var _hudball:FlxText;  
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		_bat = new FlxSprite(180, 220);
		_bat.makeGraphic(40, 6, FlxColor.HOT_PINK);
		_bat.immovable = true;
		
		_ball = new FlxSprite(180, 160);
		_ball.makeGraphic(6, 6, FlxColor.HOT_PINK);
		_ball.elasticity = 1;
		_ball.maxVelocity.set(200, 200);
		_ball.velocity.y = 200;
		
		_walls = new FlxGroup();
		
		_leftWall = new FlxSprite(0, 0);
		_leftWall.makeGraphic(10, 240, FlxColor.GRAY);
		_leftWall.immovable = true;
		_walls.add(_leftWall);
		
		_rightWall = new FlxSprite(310, 0);
		_rightWall.makeGraphic(10, 240, FlxColor.GRAY);
		_rightWall.immovable = true;
		_walls.add(_rightWall);
		
		_topWall = new FlxSprite(0, 0);
		_topWall.makeGraphic(320, 10, FlxColor.GRAY);
		_topWall.immovable = true;
		_walls.add(_topWall);
		
		_bottomWall = new FlxSprite(0, 239);
		_bottomWall.makeGraphic(320, 10, FlxColor.TRANSPARENT);
		_bottomWall.immovable = true;
		//_walls.add(_bottomWall);
		_floor = new FlxGroup();
		_floor.add(_bottomWall);
		
		// Some bricks
		_bricks = new FlxGroup();
		
		var bx:Int = 10;
		var by:Int = 30;
		
		var brickColours:Array<Int> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];
		
		for (y in 0...6)
		{
			for (x in 0...20)
			{
				var tempBrick:FlxSprite = new FlxSprite(bx, by);
				tempBrick.makeGraphic(15, 15, brickColours[y]);
				tempBrick.immovable = true;
				_bricks.add(tempBrick);
				bx += 15;
			}
			
			bx = 10;
			by += 15;
		}
		
		add(_walls);
		add(_bat);
		add(_ball);
		add(_bricks);
		add(_floor);
		
		// HUD - score and ball count
		_hudball = new FlxText(0, 0, FlxG.width);
		_hudball.setFormat(null, 16, FlxColor.YELLOW, "center", FlxText.BORDER_OUTLINE, 0x131c1b);
		_hudball.scrollFactor.set(0, 0);
		add(_hudball);		
	

		virtualPad = new FlxVirtualPad(LEFT_RIGHT, A);
		virtualPad.setAll("alpha", 0.5);
		add(virtualPad);	 //add last  = foreground
		
		score=0; //TODO add something like oldscore=score for making red if lower and green (in _hudball) if score>oldscore. but how do we transfer in gameover() to playstate, but on first run we need to initialize it with a value in onCreate
		ball=3;//just in case
		
		FlxG.sound.playMusic("assets/music/background_1.ogg",true); //true enable looping
	
	}
	
	override public function update():Void
	{
		super.update();
		
		_bat.velocity.x = 0;
		
		updateHud();

		#if !FLX_NO_TOUCH
		// Simple routine to move bat to x position of touch
		for (touch in FlxG.touches.list)
		{
			if (touch.pressed)
			{
				if (touch.x > 10 && touch.x < 270)
				_bat.x = touch.x;
			}
		}
		// Vertical long swipe up or down resets game state
		for (swipe in FlxG.swipes)
		{
			if (swipe.distance > 100)
			{
				if ((swipe.angle < 10 && swipe.angle > -10) || (swipe.angle > 170 || swipe.angle < -170))
				{
					FlxG.resetState();
				}
			}
		}
		#end
		
		if ((FlxG.keys.anyPressed(["LEFT", "A"])  || PlayState.virtualPad.buttonLeft.status == FlxButton.PRESSED )&& _bat.x > 10)
		{
			_bat.velocity.x = - BAT_SPEED;
		}
		else if ((FlxG.keys.anyPressed(["RIGHT", "D"]) || PlayState.virtualPad.buttonA.status == FlxButton.PRESSED || PlayState.virtualPad.buttonRight.status == FlxButton.PRESSED)&& _bat.x < 270)
		{
			_bat.velocity.x = BAT_SPEED;
		}
		else
		{	//TODO:do we need a if flxbutton.release for left, right and A-Button here too?
			_bat.velocity.x =0;//stop moving if key released on virtualpad
		}
		
		if (FlxG.keys.justReleased.R) //TODO map it to onscreen button or something on android, or move into pausemenu on press of overlaybutton or back-key(@override in .java file with template?)
		{
			FlxG.resetState();
		}
		
		if (_bat.x < 10)
		{
			_bat.x = 10;
		}
		
		if (_bat.x > 270)
		{
			_bat.x = 270;
		}
		
		FlxG.collide(_ball, _walls);
		FlxG.collide(_bat, _ball, ping);
		FlxG.collide(_ball, _bricks, hit);
		FlxG.collide(_ball, _floor, floor);	
	}
	
	private function hit(Ball:FlxObject, Brick:FlxObject):Void
	{
		trace("score increase");
		Brick.exists = false;
		score++;
		FlxG.sound.play("assets/sfx/_brickdestroy", 1, false);	//123
		Ball.velocity.y += 10; //beginn with 200 and increase on every block collision
	}
	
	private function ping(Bat:FlxObject, Ball:FlxObject):Void
	{
		var batmid:Int = Std.int(Bat.x) + 20;
		var ballmid:Int = Std.int(Ball.x) + 3;
		var diff:Int;
		
		if (ballmid < batmid)
		{
			// Ball is on the left of the bat
			diff = batmid - ballmid;
			Ball.velocity.x = ( -10 * diff);
		}
		else if (ballmid > batmid)
		{
			// Ball on the right of the bat
			diff = ballmid - batmid;
			Ball.velocity.x = (10 * diff);
		}
		else
		{
			// Ball is perfectly in the middle
			// A little random X to stop it bouncing up!
			Ball.velocity.x = 2 + FlxRandom.intRanged(0, 8);
		}
	}
	
	private function floor(Ball:FlxObject, Floor:FlxObject):Void
	{
		trace("floor");
		var batmid:Int = Std.int(Bat.x) + 20;
		trace ("batmid="+batmid);
		//TODO make screen shake/flicker 
		//FlxG.camera.flash(0xff000000, 1);
		ball--;//decrease ballcounter
		_ball.x=batmid;
		_ball.y=210;//10 above batmid
		_ball.velocity.y = 200;//slow down
		//TODO ball.exists = false;
	}
	
	private function gameover():Void
	{
		trace("gameover");
		//TODO make screen shake/flicker FlxG.camera.flash(0xff000000, 1);
		ball=3;//for next turn
		FlxG.switchState(new PlayState()); //TODO check if working or do we need something like state(current_state) like in unity 3d?
	}
	
	private function updateHud():Void
	{
		if(ball==1){		trace("1 ball");
			_hudball.text=Std.string(ball)+" Ball remaining "+Std.string(score)+" Score";
			}
		else if(ball>1){	trace("more than 1 ball");
			_hudball.text=Std.string(ball)+" Balls remaining "+Std.string(score)+" Score";
			}
		else{	trace("empty ball");
			gameover();
		}
	}
}