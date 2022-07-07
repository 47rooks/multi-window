package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.display.Sprite;

class PlayState extends FlxState
{
	var _win2:FlxWindow;
	var _ts:FlxSprite;
	var _cam2:FlxCamera;

	override public function create()
	{
		super.create();

		// _win2 = new FlxWindow(0, 0, 800, 600);

		_ts = new FlxSprite(100, 100);
		_ts.makeGraphic(100, 100, FlxColor.GREEN);
		add(_ts);

		trace('current=${FlxG.stage.getChildAt(0)}');
		trace('renderblit=${FlxG.renderBlit}');
		trace('renderTile=${FlxG.renderTile}');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justReleased.A)
		{
			_win2 = new FlxWindow(0, 0, 800, 600);
			_win2._win.stage.addChild(_win2);
		}

		if (FlxG.keys.justReleased.L)
		{
			if (_win2 == null)
			{
				return;
			}

			// Add a sprite to the second window by specifying the camera to render to
			var fs = new FlxSprite(0, 0);
			fs.makeGraphic(100, 100, FlxColor.BLUE);
			fs.cameras = [_win2._camera];
			add(fs);

			// Start the sprites moving to show the one game loop controls both
			fs.velocity.x = 50;
			_ts.velocity.x = 50;
		}
	}
}
