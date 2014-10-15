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

/**
 * ...
 * @author Zaphod
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

	
	override public function create():Void 
	{
		FlxG.mouse.visible = false;
		
		// Create a starfield
		add(new FlxStarField2D());
		
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

		for (i in 0...numBullets)
		{
			sprite = new FlxSprite( -100, -100);
			sprite.makeGraphic(8, 2);
			sprite.width = 10;
			sprite.height = 10;
			sprite.offset.set( -1, -4);
			sprite.exists = false;
			sprite.color =0xffff9024;
			bullets.add(sprite);
		}
		
		// A text to display the score
		_scoreText = new FlxText(0, 4, FlxG.width, "Score: " + 0);
		_scoreText.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
		add(_scoreText);
		
		add(bullets);
		
		pauseButton =  new FlxButton((FlxG.width /2)-20 , FlxG.height-15, "Pause", pauseMode);
		add(pauseButton);

		virtualPad = new FlxVirtualPad(FULL, A);
		virtualPad.setAll("alpha", 0.5);
		add(virtualPad);	 //add last  = foreground

		if(Reg.music==true){FlxG.sound.playMusic("assets/music/background_1.ogg",true);}
	
		pause=false;		

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
		// Escape to the menu
		if (FlxG.keys.pressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}

		super.update();
		
		// Don't continue in case we lost
		if (!_playerShip.alive)
		{
			if (FlxG.keys.pressed.R || PlayState.virtualPad.buttonA.status == FlxButton.PRESSED || FlxG.mouse.justPressed)
			{
				FlxG.resetState();
			}

			return;
		}
		
		FlxG.overlap(bullets, asteroids, bulletHitsAsteroid);
		FlxG.overlap(asteroids, _playerShip, asteroidHitsShip);
		FlxG.collide(asteroids);
		
		for (bullet in bullets.members)
		{
			if (bullet.exists)
			{
				FlxSpriteUtil.screenWrap(bullet);
			}
		}
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
		Object1.kill();
		Object2.kill();
		bullets.kill();
		_scoreText.text = "Game Over! Final score: " + _score + " - Click Screen to retry.";
	}
	
	private function resetTimer(Timer:FlxTimer):Void
	{
		Timer.start(5, resetTimer);
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
		FlxG.switchState(new DebugState());
	}
		
}