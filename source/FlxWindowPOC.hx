package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.util.FlxColor;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;

class FlxWindowPOC extends Sprite
{
	public var _win:lime.ui.Window;

	var _inputContainer:Sprite;

	/**
	 * Contains things related to cameras, a list of all cameras and several effects like `flash()` or `fade()`.
	 */
	public static var cameras(default, null):CameraFrontEnd;

	public var _camera:FlxCamera;

	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		super();

		_inputContainer = new Sprite();

		var attributes:lime.ui.WindowAttributes = {
			allowHighDPI: false,
			alwaysOnTop: false,
			borderless: false,
			// display: 0,
			element: null,
			frameRate: 60,
			#if !web
			fullscreen: false,
			#end
			height: height,
			hidden: #if munit true #else false #end,
			maximized: false,
			minimized: false,
			parameters: {},
			resizable: true,
			title: "Win2",
			width: width,
			x: null,
			y: null
		};

		attributes.context = {
			antialiasing: 0,
			background: 0,
			colorDepth: 32,
			depth: true,
			hardware: true,
			stencil: true,
			type: null,
			vsync: false
		};
		_win = FlxG.stage.application.createWindow(attributes);
		_win.stage.color = FlxColor.ORANGE;

		// cameras = new CameraFrontEnd();  // FIXME ultimately this is required. For now just one
		_camera = new FlxCamera(0, 0, width, height);
		addEventListener(Event.ADDED_TO_STAGE, create);
	}

	function create(_):Void
	{
		trace('create called stage=${stage}');
		removeEventListener(Event.ADDED_TO_STAGE, create);
		if (stage == null)
		{
			trace('stage is null');
			return;
		}
		// Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = FlxG.drawFramerate;

		// Add the window openFL Sprite to the stage
		addChild(_inputContainer);
		// Add camera openFL Sprite to the stage at the same place in the display list
		// Not sure if this before or after the _inputContainer
		addChildAt(_camera.flashSprite, getChildIndex(_inputContainer));

		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function onEnterFrame(_):Void
	{
		_camera.update(FlxG.elapsed);
		draw();
	}

	// This is a hack to be able to call render. This would be done the other way around in a real
	// implementation where FlxCamera.render would have @:allow(FlxWindow)

	@:access(flixel.FlxCamera.render)
	function draw():Void
	{
		// Most of this function is a ripoff from FlxCameraFrontEnd. It should not be done this way.
		// But as a quick proof that you can even draw on another window it works.

		// trace('flxwindow draw');
		// _camera.lock(); This is ultimately required

		// if (FlxG.renderTile)
		// {
		// cameras.render();  // ultimately this is required
		// FlxG.state.draw();
		// _camera.screen.dirty = true;
		// _camera.clearDrawStack();
		_camera.update(FlxG.elapsed);
		FlxDrawBaseItem.drawCalls = 0;

		// These are current attempts to get the sprite move without leaving a trail behind.
		// This is basically pointless. It would be best to move to using a frontend I think.
		_camera.canvas.graphics.clear();
		_camera.flashSprite.graphics.clear();

		_camera.fill(_camera.bgColor.to24Bit(), _camera.useBgAlphaBlending, _camera.bgColor.alphaFloat);

		_camera.render();
		// #if FLX_DEBUG
		// debugger.stats.drawCalls(FlxDrawBaseItem.drawCalls);
		// #end
		// }

		// FlxG.cameras.unlock(); This is ultimately	required
	}
}
