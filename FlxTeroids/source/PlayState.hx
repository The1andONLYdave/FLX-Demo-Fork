package;

import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.addons.effects.FlxTrail;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.ui.FlxVirtualPad;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.group.FlxGroup;

/**
 * ...
 * @author Zaphod, modified D.-L. Kulsch
 */
class PlayState extends FlxState
{
	public static var asteroids:FlxTypedGroup<Asteroid>;
	public static var bullets:FlxTypedGroup<FlxSprite>;
	
	private var _playerShip:PlayerShip;
	private var _scoreText:FlxText;
	
	private var _score:Int = 0;
	
	public static var virtualPad:FlxVirtualPad;
	public var pauseButton:FlxButton;
	public var pause:Bool;

	public static var colorArray:Array<Dynamic>;
	private var _pos:FlxText;
	private var _health:FlxText;
	private var _walls:FlxGroup;
	private var _leftWall:FlxSprite;
	private var _rightWall:FlxSprite;
	private var _topWall:FlxSprite;
	private var _bottomWall:FlxSprite;
	public var _cooldown:Float;
	
	override public function create():Void 
	{
		FlxG.mouse.visible = false;
		
		Reg.live=5;
		if(Reg.moreHealth==true){Reg.live=80;}
		
		if(Reg.level>Reg.maxLevel){
			trace("level not existing yet");
		Reg.level=Reg.maxLevel;
		}

		// Create a starfield
		add(new FlxStarField2D());
		
		_walls = new FlxGroup();
		
		_leftWall = new FlxSprite(0, 0);
		_leftWall.makeGraphic(3, 240, FlxColor.GRAY);
		_leftWall.immovable = true;
		_walls.add(_leftWall);
		
		_rightWall = new FlxSprite(317, 0);
		_rightWall.makeGraphic(3, 240, FlxColor.GRAY);
		_rightWall.immovable = true;
		_walls.add(_rightWall);
		
		_topWall = new FlxSprite(0, 0);
		_topWall.makeGraphic(320, 3, FlxColor.GRAY);
		_topWall.immovable = true;
		_walls.add(_topWall);
		
		_bottomWall = new FlxSprite(0, 237);
		_bottomWall.makeGraphic(320, 3, FlxColor.TRANSPARENT);
		_bottomWall.immovable = true;
		_walls.add(_bottomWall);
		
		
		
		// Spawn 3 asteroids for a start
		asteroids = new FlxTypedGroup<Asteroid>();
		add(asteroids);
		
		for (i in 0...2)
		{
			spawnAsteroid();
		}
		
		// Make sure we don't ever run out of asteroids! :)
		resetTimer(new FlxTimer());
		
		// Create the player ship
		_playerShip = new PlayerShip();
		var trail:FlxTrail = new FlxTrail(_playerShip);
		add(trail);
		add(_playerShip);
		
		// There'll only ever be 32 bullets that we recycle over and over
		var numBullets:Int = 32;
		bullets = new FlxTypedGroup<FlxSprite>(numBullets);

		var sprite:FlxSprite;
		var colorArray:Array<Dynamic> = [0xffff9024,0xffff9024,0xff10FF24];
		
		for (i in 0...numBullets)
		{
			sprite = new FlxSprite( -100, -100);
			sprite.makeGraphic(8, 2);
			sprite.width = 10;
			sprite.height = 10;
			sprite.offset.set( -1, -4);
			sprite.exists = false;
			sprite.color =colorArray[Reg.gun];
			bullets.add(sprite);
		}
		
		// A text to display the score
		_scoreText = new FlxText(0, 4, FlxG.width, "Score: " + 0);
		_scoreText.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
		add(_scoreText);
		
		add(bullets);
		
		pauseButton =  new FlxButton((FlxG.width /2)-20 , FlxG.height-15, "Exit Level", pauseMode);
		add(pauseButton);

		virtualPad = new FlxVirtualPad(FULL, A);
		virtualPad.setAll("alpha", 0.5);
		add(virtualPad);	 //add last  = foreground

		if(Reg.music==true){FlxG.sound.playMusic("assets/music/background_1.ogg",true);}
	
		pause=false;		
		
		_health = new FlxText(0, 0, FlxG.width);
		_health.setFormat(null, 10, FlxColor.GREEN, "left", FlxText.BORDER_OUTLINE, 0x131c1b);
		_health.scrollFactor.set(0, 0);
		add(_health);
		
		_pos = new FlxText(0, (FlxG.height-35), FlxG.width);
		_pos.setFormat(null, 5, FlxColor.GREEN, "left", FlxText.BORDER_OUTLINE, 0x131c1b);
			
		if(Reg.debug==true){
			_pos.scrollFactor.set(0, 0);
			add(_pos);
		}
		

	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		_playerShip = null; 
		bullets = null;
		asteroids = null;
	}
	
	override public function update():Void 
	{
		
		_pos.text="x: "+Std.string(_playerShip.x)+"\ny:"+Std.string(_playerShip.y)+"\nL:"+Std.string(Reg.level)+"\nG:"+Std.string(Reg.gun)+"\nm:"+Std.string(Reg.maxLevel);

		_health.text=Reg.live+ " health";
		
		// Escape to the menu
		if (FlxG.keys.pressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}

		super.update();
		_cooldown += FlxG.elapsed;
		// Don't continue in case we lost
		if (!_playerShip.alive)
		{
			if (FlxG.keys.pressed.R || PlayState.virtualPad.buttonA.status == FlxButton.PRESSED || FlxG.mouse.justPressed)
			{
				Reg.moreHealth=false;
				Reg.gun=1;
				Reg.level=1;
				if(_cooldown>1.0){FlxG.resetState();}
			}

			return;
		}
		
		FlxG.overlap(bullets, asteroids, bulletHitsAsteroid);
		FlxG.overlap(asteroids, _playerShip, asteroidHitsShip);
		FlxG.collide(asteroids);
		FlxG.collide(_walls, bullets,destroyBullet);
			
		for (bullet in bullets.members)
		{
			if (bullet.exists)
			{
				FlxSpriteUtil.screenWrap(bullet);
			}
		}
		
		
}
	
	private function destroyBullet(Wall:FlxObject, Bullet:FlxObject):Void
	{
		trace("bullet wall");
		Bullet.kill();
	}
	private function increaseScore(Amount:Int = 10):Void
	{
		_score += Amount;
		_scoreText.text = "Score: " + _score;
		_scoreText.alpha = 0;
		FlxTween.tween(_scoreText, { alpha: 1 }, 0.5);
	}
	
	private function bulletHitsAsteroid(Object1:FlxObject, Object2:FlxObject):Void
	{
		Object1.kill();
		Object2.kill();
		increaseScore();
	}
	
	private function asteroidHitsShip(Object1:FlxObject, Object2:FlxObject):Void
	{
		
		//start timer for 3 seconds
		//if timer expired continue, else break
		if(_cooldown> 1.0){ //3 sekunden
			
			Object1.kill();
			Reg.live--;
			bullets.kill();
			if(Reg.live<0){Reg.live=0;}
			if(Reg.live==0){
				Object2.kill();
				_scoreText.text = "Game Over! Final score: " + _score + " - Click Screen to retry.";
			}
			if(Reg.live>0){
				//_health.flicker(1); //flicker for 1 second and dont null while flickering
				
			}
			_cooldown=0;
		}
	}
	
	private function resetTimer(Timer:FlxTimer):Void
	{
		Timer.start((5*Reg.level), resetTimer);
		spawnAsteroid();
	}
	
	private function spawnAsteroid():Void
	{
	
	var brickColours:Array<Int> = [0xffd03ad1, 0xfff75352, 0xfffd8014, 0xffff9024, 0xff05b320, 0xff6d65f6];
	//var a:Int = FlxRandom.intRanged(0, 5);
		var asteroid:Asteroid = asteroids.recycle(Asteroid);
		asteroid.init();
		}
	
	

private function pauseMenu():Void
	{
		pause=true;
		trace("pauseMenu");
		//TODO bool for music and sound, onResume too
		FlxG.sound.volume=0; 
		//GAnalytics.trackEvent("Game", "pauseMenu", "called", 1);
		openDebug();
	}
	private function onResume():Void
	{
		trace("onResume");
		FlxG.sound.volume=1;
		//GAnalytics.trackEvent("Game", "onResume", "called", 1);
		pause=false;
	}
	private function pauseMode():Void
	{
		trace("pauseMode");
		//GAnalytics.trackEvent("Game", "PauseMenu", "starting", 1);
			if(!pause){
				pauseMenu();
			}
			else{
				onResume();
			}
	}
		private function openDebug():Void
	{
		trace("openDebug");
		//GAnalytics.trackEvent("Game", "PauseMenu", "starting", 1);
		FlxG.switchState(new MenuState());
	}
		
}