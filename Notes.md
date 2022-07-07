# Multi-Window Notes

## Using the POC

Once it boots hit A to add the second window. Then refocus to the first window and hit L to draw the one example sprite and start it moving.

## Probably Architecture

It is possible to add multi-window support by adding a FlxWindow class that creates an openfl window, which is a lime window with a stage. You can then set a camera on this stage and it will be called by update code to draw FlxSprites on the screen.

Setting up the window itself is easy. Getting the rendering to work requires pulling code from CameraFrontEnd and FlxGame. The likely thing is that there should be a CameraFrontEnd for each FlxWindow. There should be a FlxWindowManager that is available through FlxG. It will handle window cleanup at the end of the game.

## Current Problems

   * The camera only renders onto this new window if there is a openfl.display.Sprite added to the stage as well as a FlxSprite. I have no idea why.
   * When moving the sprite it is not cleared before rendering. I suspect this is just because I have hacked together a few routines instead of a proper rendering module.
   * CameraFrontEnd is too tightly bound to FlxG and would have to be modified to work with a window
   * Currently you have to close both windows separately - this would be fixed by a window manager
