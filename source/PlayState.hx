package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxWindow;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import lime.app.Event;
import openfl.display.Sprite;

class PlayState extends FlxState
{
	var _mainWall:FlxGroup;
	var _win2:FlxWindow;
	var _win2Wall:FlxGroup;
	var _win3:FlxWindow;
	var _win3Wall:FlxGroup;

	var _mainUICamera:FlxCamera;
	var _win2UICamera:FlxCamera;
	var _win3UICamera:FlxCamera;

	var _mainSprites:FlxTypedGroup<FlxSprite>;
	var _win2Sprites:FlxTypedGroup<FlxSprite>;
	var _win3Sprites:FlxTypedGroup<FlxSprite>;

	var _random:FlxRandom;

	override public function create()
	{
		super.create();

		trace('current=${FlxG.stage.getChildAt(0)}');
		trace('renderblit=${FlxG.renderBlit}');
		trace('renderTile=${FlxG.renderTile}');

		_mainSprites = new FlxTypedGroup<FlxSprite>();
		_win2Sprites = new FlxTypedGroup<FlxSprite>();
		_win3Sprites = new FlxTypedGroup<FlxSprite>();

		_random = new FlxRandom();
	}

	private function setupWindows():Void
	{
		final sideWindowWidth = 400;
		final sideWindowHeight = FlxG.height;
		final mainLocX = FlxG.game.stage.window.x;
		final mainLocY = FlxG.game.stage.window.y;

		_win2 = FlxWindow.createWindow(mainLocX - sideWindowWidth, mainLocY, sideWindowWidth, sideWindowHeight, "win2", false);
		_win3 = FlxWindow.createWindow(mainLocX + FlxG.width, mainLocY, Math.floor(sideWindowWidth * 1.5), sideWindowHeight, "win3", false);

		_mainWall = FlxCollision.createCameraWall(FlxG.camera, true, 32);
		_win2Wall = FlxCollision.createCameraWall(_win2._camera, true, 32);
		_win3Wall = FlxCollision.createCameraWall(_win3._camera, true, 32);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.collide(_mainSprites, _mainWall);
		FlxG.collide(_win2Sprites, _win2Wall);
		FlxG.collide(_win3Sprites, _win3Wall);

		if (FlxG.keys.justReleased.X)
		{
			Sys.exit(0);
		}

		if (FlxG.keys.justReleased.A)
		{
			// Setup a couple of additional windows
			setupWindows();
		}

		if (FlxG.keys.justReleased.L)
		{
			if (_win2 == null)
			{
				return;
			}
			FlxG.camera.bgColor = FlxColor.PINK;
			addTitles();
			addBlocks();
		}
	}

	private function addTitles():Void
	{
		// Add ui cameras to each window
		_mainUICamera = new FlxCamera(0, 0, 200, 50);
		FlxG.cameras.add(_mainUICamera, false);
		_win2UICamera = new FlxCamera(0, 0, 200, 50);
		_win2.addCamera(_win2UICamera, false);
		_win3UICamera = new FlxCamera(0, 0, 200, 50);
		_win3.addCamera(_win3UICamera, false);

		// Add text names to the UI cameras
		var fWidth = 200;
		var textSize = 12;
		var n = new FlxText(5, 5, fWidth, FlxG.game.name + '(${FlxG.width}, ${FlxG.height})', textSize);
		n.cameras = [_mainUICamera];
		add(n);

		n = new FlxText(5, 5, fWidth, _win2.windowName + '(${_win2.width}, ${_win2.height})', textSize);
		n.cameras = [_win2UICamera];
		add(n);

		n = new FlxText(5, 5, fWidth, _win3.windowName + '(${_win3.width}, ${_win3.height})', textSize);
		n.cameras = [_win3UICamera];
		add(n);
	}

	private function addBlocks():Void
	{
		// Main window sprites
		var s = new FlxSprite(100, 100);
		s.makeGraphic(50, 50, _random.color(FlxColor.BLUE));

		// var fWidth = 200;
		// var textSize = 12;
		// var s = new FlxText(5, 5, fWidth, 'Some Text', textSize);
		// s.moves = true;

		// s.cameras = [FlxG.camera, _win2._camera, _mainUICamera, _win3._camera];
		s.cameras = [FlxG.camera, _win2._camera, _win3._camera];
		// s.cameras = [_win2._camera, FlxG.camera, _win3._camera];
		// s.cameras = [_win2._camera, _win3._camera];
		// s.cameras = [FlxG.camera];
		// s.setColorTransform(1, 1, 1, 1, 255, 255, 255, 1);
		_mainSprites.add(s);

		// // Add a sprite to the second window by specifying the camera to render to
		s = new FlxSprite(0, 100);
		s.makeGraphic(50, 50, _random.color(FlxColor.BLUE));
		// s.cameras = [_win2._camera, _win3._camera, FlxG.camera];
		s.cameras = [_win2._camera, _win3._camera, _win2UICamera];
		_win2Sprites.add(s);

		s = new FlxSprite(0, 200);
		s.makeGraphic(100, 100, _random.color(FlxColor.BLUE));
		s.cameras = [_win3._camera];
		_win3Sprites.add(s);

		// Start the sprites moving to show the one game loop controls both
		for (v in [_mainSprites, _win2Sprites, _win3Sprites])
		{
			v.forEach((s) ->
			{
				s.elasticity = 1.0;
				s.velocity.x = 100 + _random.float(-1.0, 1.0, [0.0]) * 100;
				s.velocity.y = 100 + _random.float(-1.0, 1.0, [0.0]) * 100;
			});
		}
		add(_win3Sprites);
		add(_win2Sprites);
		add(_mainSprites);
	}
}
