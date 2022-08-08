# Multi-Window Notes

## MVP Features

   * borderless windows
   * multiple cameras per window
   * sprites can display in more than one window
     * requires a new shader be built per window for a sprite. I have a hack that isn't perfect right now
   * sprites can move between windows
   * shaders on sprites work as normal
   * filters on cameras work
   * bring game to front brings all windows to front
     * this is hard - still cannot do it without a spin

### Restrictions

   * resizing is programmatic only - consequence of borderless
   * window placement is programmatic only - consequence of borderless
   * only on sys targets
   * camera follow confined to one window - consequence of camera being confined to a window
   * no input on secondary windows yet - basically they cannot receive focus
   * 
  
## Using the POC

Once it boots move the first window to one side - the second one will cover it otherwise. Hit A to add the second window. Then refocus to the first window and hit L to draw the one example sprite and start it moving.

## Probably Architecture

It is possible to add multi-window support by adding a FlxWindow class that creates an openfl window, which is a lime window with a stage. You can then set a camera on this stage and it will be called by update code to draw FlxSprites on the screen.

Setting up the window itself is easy. Getting the rendering to work requires pulling code from CameraFrontEnd and FlxGame. The likely thing is that there should be a CameraFrontEnd for each FlxWindow. There should be a FlxWindowManager that is available through FlxG. It will handle window cleanup at the end of the game.

## Current Problems

   * The camera only renders onto this new window if there is a openfl.display.Sprite added to the stage as well as a FlxSprite. I have no idea why.
   * When moving the sprite it is not cleared before rendering. I suspect this is just because I have hacked together a few routines instead of a proper rendering module.
   * CameraFrontEnd is too tightly bound to FlxG and would have to be modified to work with a window
   * Currently you have to close both windows separately - this would be fixed by a window manager

## Multi-Window Rendering (as 7/17/2022)

Rendering the same sprite to more than window results in the sprite shape but no color in second and subsequent 
windows. In addition there is another problem that the third window will not show even the sprite shape if there are other sprites being rendered.

Sprites are rendered to win2 and win3 when NativeApplication.hx handleRenderEvent() is called for those windows. Specifically when 

```
	private function handleRenderEvent():Void
	{
		// TODO: Allow windows to render independently

		for (window in parent.__windows)
		{
			if (window == null) continue;

			// parent.renderer = renderer;

			switch (renderEventInfo.type)
			{
				case RENDER:
					if (window.context != null)
					{
						window.__backend.render();
						window.onRender.dispatch(window.context);

						if (!window.onRender.canceled)
						{
							window.__backend.contextFlip();
						}
					}
```
hits the `window.__backend.contextFlip();`.

However, the first image rendering to the main window occurs far sooner during initial camera render.

Looks like `window.__backend.handleRenderEvent();` drives the window render. It's near the bottom of the stack. So lime drives each window render one after the other.

`window.__backend.render();` is called for each window but only the first one goes all the way to the FlxSprite.draw() function. This is I suspect because of the !WIN_CAMERA implementation.

With WIN_CAMERA, 

FlxCamera.drawComplex() copies the pixels of the sprite to the camera at:

```
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
```

For default camera behaviour we need to set this correctly for the rendering window's default cameras
   FlxCamera._defaultCameras

Drawing on the first pass goes through FlxSprite.updateFramePixels(). This is not then used again on any window.

## FlxQuadsDrawItem.render
From FlxGame


From FlxWindow

flixel.graphics.tile.FlxDrawQuadsItem.render (d:\UserData\Daniel\Code\HaxeFlixel\flixel-fork\flixel\flixel\graphics\tile\FlxDrawQuadsItem.hx:118)
flixel.FlxCamera.render (d:\UserData\Daniel\Code\HaxeFlixel\flixel-fork\flixel\flixel\FlxCamera.hx:686)
flixel.FlxGame.draw (d:\UserData\Daniel\Code\HaxeFlixel\flixel-fork\flixel\flixel\FlxGame.hx:914)
flixel.FlxWindow.onEnterFrame (d:\UserData\Daniel\Code\HaxeFlixel\flixel-fork\flixel\flixel\FlxWindow.hx:180)
<local function> (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\.haxelib\lime\7,9,0\src\lime\app\Module.hx:0)
openfl.events.EventDispatcher.__dispatchEvent (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\.haxelib\openfl\9,1,0\src\openfl\events\EventDispatcher.hx:402)
openfl.display.DisplayObject.__dispatch (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\.haxelib\openfl\9,1,0\src\openfl\display\DisplayObject.hx:1399)
openfl.display.Stage.__broadcastEvent (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\.haxelib\openfl\9,1,0\src\openfl\display\Stage.hx:1166)
openfl.display.Stage.__onLimeRender (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\.haxelib\openfl\9,1,0\src\openfl\display\Stage.hx:1950)
lime.app._Event_lime_graphics_RenderContext_Void.dispatch (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\.haxelib\lime\7,9,0\src\lime\_internal\macros\EventMacro.hx:91)
lime._internal.backend.native.NativeApplication.handleRenderEvent (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\.haxelib\lime\7,9,0\src\lime\_internal\backend\native\NativeApplication.hx:370)
lime.app.Application.exec (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\.haxelib\lime\7,9,0\src\lime\app\Application.hx:150)
ApplicationMain.create (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\export\hl\haxe\ApplicationMain.hx:130)
ApplicationMain.main (d:\UserData\Daniel\Code\HaxeFlixel\multi-window\export\hl\haxe\ApplicationMain.hx:25)