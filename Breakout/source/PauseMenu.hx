package;

	import flixel.FlxButton;
	import flixel.FlxG;
	import flixel.FlxText;
	import flixel.FlxSubState;

	/**
	 * @author andreas
	 */
	class PauseMenu extends FlxSubState
	{

		public function PauseMenu()
		{
			super(true, 0x88000000, true);
		}
		
		 override public function create():void
		{
			//Sorry about all the hardcoded position values. :(
			var currentY:Number = 50;
			
			var text:FlxText = new FlxText(0, currentY, FlxG.width, "PAUSED");
			text.setFormat(null, 24, 0xFFFFFF00, TextAlign.CENTER, 0xFFCCCCCC);
			this.add(text);
			currentY += text.height + 20;
			
			var resumeBtn:FlxButton = new FlxButton(0, currentY, "Resume game", resume);
			resumeBtn.x = (FlxG.width / 2) - (resumeBtn.width / 2);
			this.add(resumeBtn);
			currentY += resumeBtn.height + 5;
			
			var quitBtn:FlxButton = new FlxButton(0, currentY, "Quit game", tryQuit);
			quitBtn.x = (FlxG.width / 2) - (quitBtn.width / 2);
			this.add(quitBtn);
		}
		
		private function resume():void
		{
			this.close("PauseMenu::resume_game");
		}
		
		private function tryQuit():void
		{
			this.close("PauseMenu::quit_game");
			
			//TODO
			//this.setSubState(new Dialog("Are you sure you want to quit?", yes, no));
			//this.quit(null, yes);
		}
		
		/*
		private const yes:String = "Yes";
		private const no:String = "No";
		
		private function quit(state:FlxSubState, result:String):void
		{
			if (result == yes)
			{
				this.close(QUIT_GAME);
			}
		}*/

	}
