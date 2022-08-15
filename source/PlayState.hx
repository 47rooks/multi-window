package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxWindow;
import flixel.addons.ui.FlxUIButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.ui.FlxButton;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	// Setup window layout
	static final TOP_LEFT_X = 140;
	static final TOP_LEFT_Y = 300;
	static final LEFT_W_WIDTH = 400; // This is the main Game window
	static final LEFT_W_HEIGHT = 480;
	static final RTOP_W_WIDTH = 1240;
	static final RTOP_W_HEIGHT = 240;
	static final MBOT_W_WIDTH = 600;
	static final MBOT_W_HEIGHT = LEFT_W_HEIGHT - RTOP_W_HEIGHT;
	static final RBOT_W_WIDTH = 640;
	static final RBOT_W_HEIGHT = MBOT_W_HEIGHT;

	var _rtopWin:FlxWindow;
	var _rtopWall:FlxGroup;
	var _mbotWin:FlxWindow;
	var _mbotWall:FlxGroup;
	var _rbotWin:FlxWindow;
	var _rbotWall:FlxGroup;

	var _rtopUICamera:FlxCamera;
	var _mbotUICamera:FlxCamera;
	var _rbotUICamera:FlxCamera;

	var _rtopSprites:FlxTypedGroup<FlxSprite>;
	var _mbotSprites:FlxTypedGroup<FlxSprite>;
	var _rbotSprites:FlxTypedGroup<FlxSprite>;

	var _random:FlxRandom;

	var _addWindowButton:FlxUIButton;
	var _addSpritesButton:FlxUIButton;
	var _delWindowButton:FlxUIButton;

	override public function create()
	{
		super.create();

		_rtopSprites = new FlxTypedGroup<FlxSprite>();
		_mbotSprites = new FlxTypedGroup<FlxSprite>();
		_rbotSprites = new FlxTypedGroup<FlxSprite>();

		_random = new FlxRandom();

		addMainMenu();
	}

	private function addMainMenu():Void
	{
		var fWidth = 200;
		var textSize = 12;
		final left = 10;
		var top = 25;
		final pitch = 50;

		var n = new FlxText(5, 5, fWidth, 'Menu', 14);
		add(n);

		_addWindowButton = new FlxUIButton(left, top, "Create Windows", () ->
		{
			_addWindowButton.active = false;
			setupWindows();
			_addSpritesButton.active = true;
		});
		_addWindowButton.resize(150, 30);
		_addWindowButton.setLabelFormat(14, FlxColor.BLACK, FlxTextAlign.CENTER);
		add(_addWindowButton);

		top += pitch;

		_addSpritesButton = new FlxUIButton(left, top, "Add Sprites", () ->
		{
			_addSpritesButton.active = false;
			addTitles();
			addBlocks();
			_delWindowButton.active = true;
		});
		_addSpritesButton.resize(150, 30);
		_addSpritesButton.setLabelFormat(14, FlxColor.BLACK, FlxTextAlign.CENTER);
		_addSpritesButton.active = false;
		add(_addSpritesButton);

		top += pitch;

		_delWindowButton = new FlxUIButton(left, top, "Close a window", () ->
		{
			_delWindowButton.active = false;
			_rbotWin.destroy();
			_rbotWin = null;
		});
		_delWindowButton.resize(150, 30);
		_delWindowButton.setLabelFormat(14, FlxColor.BLACK, FlxTextAlign.CENTER);
		_delWindowButton.active = false;
		add(_delWindowButton);
	}

	private function setupWindows():Void
	{
		// Reposition the main window
		FlxG.game.stage.window.x = TOP_LEFT_X;
		FlxG.game.stage.window.y = TOP_LEFT_Y;

		_rtopWin = FlxWindow.createWindow(TOP_LEFT_X + LEFT_W_WIDTH, TOP_LEFT_Y, RTOP_W_WIDTH, RTOP_W_HEIGHT, "rtop", false);
		_rtopWin.camera.bgColor = FlxColor.PINK;
		_mbotWin = FlxWindow.createWindow(TOP_LEFT_X + LEFT_W_WIDTH, TOP_LEFT_Y + RBOT_W_HEIGHT, MBOT_W_WIDTH, MBOT_W_HEIGHT, "mbot", false);
		_mbotWin.camera.bgColor = FlxColor.YELLOW;
		_rbotWin = FlxWindow.createWindow(TOP_LEFT_X + LEFT_W_WIDTH + MBOT_W_WIDTH, TOP_LEFT_Y + RBOT_W_HEIGHT, RBOT_W_WIDTH, RBOT_W_HEIGHT, "rbot", false);

		_rtopWall = FlxCollision.createCameraWall(_rtopWin.camera, true, 8);
		_mbotWall = FlxCollision.createCameraWall(_mbotWin.camera, true, 8);
		_rbotWall = FlxCollision.createCameraWall(_rbotWin.camera, true, 8);

		// expand world bounds so that the camera walls work
		FlxG.worldBounds.right = 2000;
		setWallCamera(_rtopWall, _rtopWin.camera);
		setWallCamera(_mbotWall, _mbotWin.camera);
		setWallCamera(_rbotWall, _rbotWin.camera);

		add(_rtopWall);
		add(_mbotWall);
		add(_rbotWall);
	}

	private function setWallCamera(wall:FlxGroup, cam:FlxCamera):Void
	{
		wall.forEach((w) ->
		{
			cast(w, FlxSprite).cameras = [cam];
		});
	}

	override public function update(elapsed:Float)
	{
		FlxG.collide(_rtopSprites, _rtopWall);
		FlxG.collide(_mbotSprites, _mbotWall);
		FlxG.collide(_rbotSprites, _rbotWall);
		super.update(elapsed);

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
			if (_mbotWin == null)
			{
				return;
			}
			// Turn off border on main app window. This means you lose access to a close button.
			// App must therefore provide
			// FlxG.game.stage.application.window.borderless = true;
			addTitles();
			addBlocks();
		}
	}

	private function collideWithCameraEdge(sprites:FlxTypedGroup<FlxSprite>, camera:FlxCamera):Void
	{
		sprites.forEach(s ->
		{
			if ((s.x + s.width) > camera.width || (s.x < 0))
			{
				s.velocity.x *= -1;
			}
			if ((s.y + s.height) > camera.height || (s.y < 0))
			{
				s.velocity.y *= -1;
			}
		});
	}

	private function addTitles():Void
	{
		// Add ui cameras to each window
		_rtopUICamera = new FlxCamera(0, 0, 200, 50);
		_rtopUICamera.bgColor = 0x80000000; // Semi-transparent black
		_rtopWin.cameras.add(_rtopUICamera);
		_mbotUICamera = new FlxCamera(0, 0, 200, 50);
		_mbotWin.cameras.add(_mbotUICamera);
		_rbotUICamera = new FlxCamera(0, 0, 200, 50);
		_rbotWin.cameras.add(_rbotUICamera);

		// Add text names to the UI cameras
		var fWidth = 200;
		var textSize = 12;
		var n = new FlxText(5, 5, fWidth, _rtopWin.windowName + '(${_rtopWin.width}, ${_rtopWin.height})', textSize);
		n.cameras = [_rtopUICamera];
		add(n);

		n = new FlxText(5, 5, fWidth, _mbotWin.windowName + '(${_mbotWin.width}, ${_mbotWin.height})', textSize);
		n.cameras = [_mbotUICamera];
		add(n);

		n = new FlxText(5, 5, fWidth, _rbotWin.windowName + '(${_rbotWin.width}, ${_rbotWin.height})', textSize);
		n.cameras = [_rbotUICamera];
		add(n);
	}

	private function addBlocks():Void
	{
		// Main window sprites
		var s = new FlxSprite(100, 100);
		s.makeGraphic(50, 50, _random.color(FlxColor.BLUE));
		s.cameras = [_rtopWin.camera, _mbotWin.camera, _rbotWin.camera];
		_rtopSprites.add(s);

		// Add a sprite to the second window by specifying the camera to render to
		s = new FlxSprite(0, 100);
		s.makeGraphic(50, 50, _random.color(FlxColor.BLUE));
		s.cameras = [_mbotWin.camera, _rbotWin.camera, _mbotUICamera];
		_mbotSprites.add(s);

		s = new FlxSprite(0, 0);
		s.makeGraphic(50, 100, _random.color(FlxColor.BLUE));
		s.cameras = [_rbotWin.camera];
		_rbotSprites.add(s);

		// Start the sprites moving to show the one game loop controls both
		for (v in [_rtopSprites, _mbotSprites, _rbotSprites])
		{
			v.forEach((s) ->
			{
				s.elasticity = 1.0;
				s.velocity.x = 200 - _random.float(-1.0, 1.0, [0.0]) * 100;
				s.velocity.y = 200 + _random.float(-1.0, 1.0, [0.0]) * 100;
			});
		}
		add(_rbotSprites);
		add(_mbotSprites);
		add(_rtopSprites);
	}
}
