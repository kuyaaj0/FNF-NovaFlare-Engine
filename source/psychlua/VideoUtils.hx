package psychlua;

import hxcodec.flixel.FlxVideo;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import sys.FileSystem;
import openfl.utils.Paths;

class VideoUtils {
    public static var globalData:Array<Array<Dynamic>> = [];

    public static function initialize() {
        createGlobalCallback('makeVideoSprite', makeVideoSprite);
    }

    public static function createGlobalCallback(name: String, func: Dynamic -> Void): Void {
        // Assume this is a utility method to bind Lua function names to Haxe functions
        // Implement this method as per your project structure
        // For example, you might register this function with a Lua environment or some custom handler
    }

    public static function makeVideoSprite(tag: String, videoFile: String, ?x: Float, ?y: Float, ?camera: String, ?shouldLoop: Bool): Void {
        trace('makeVideoSprite: Start');
        var videoData:Array<Dynamic> = [];

        if (FlxG.state.modchartSprites.exists(tag + '_video')) {
            trace('makeVideoSprite: This tag is not available! Use a different tag.');
            return;
        }

        if (!FileSystem.exists(Paths.video(videoFile))) {
            trace('makeVideoSprite: The video file "' + videoFile + '" cannot be found!');
            return;
        }

        trace('makeVideoSprite: Creating sprite');
        var sprite:FlxSprite = new FlxSprite(x, y).makeGraphic(1, 1, FlxColor.TRANSPARENT);
        sprite.camera = cameraFromString(camera);
        FlxG.state.modchartSprites.set(tag + '_video', sprite);
        FlxG.state.add(sprite);

        trace('makeVideoSprite: Creating video');
        var video:FlxVideo = new FlxVideo();

        video.alpha = 0;

        video.onTextureSetup.add(function() {
            trace('makeVideoSprite: onTextureSetup');
            sprite.loadGraphic(video.bitmapData);
        });

        video.play(Paths.video(videoFile), shouldLoop);

        video.onEndReached.add(function() {
            trace('makeVideoSprite: onEndReached');
            video.dispose();

            if (FlxG.game.contains(video))
                FlxG.game.removeChild(video);

            if (globalData.indexOf(videoData) >= 0)
                globalData.remove(videoData);

            if (FlxG.state.modchartSprites.exists(tag + '_video')) {
                FlxG.state.modchartSprites.get(tag + '_video').destroy();
                FlxG.state.modchartSprites.remove(tag + '_video');
            }

            FlxG.state.callOnLuas('onVideoFinished', [tag]);
        });

        FlxG.game.addChild(video);

        videoData.push(video);
        videoData.push(sprite);

        globalData.push(videoData);
        trace('makeVideoSprite: End');
    }

    public static function cameraFromString(camera: String): FlxCamera {
        // Implement this function to convert a string to a FlxCamera
        // This is a placeholder implementation
        return FlxG.camera;
    }

    public static function onPause(): Void {
        for (video in globalData) {
            if (video[0] != null) {
                video[0].pause();

                if (FlxG.autoPause) {
                    if (FlxG.signals.focusGained.has(video[0].resume))
                        FlxG.signals.focusGained.remove(video[0].resume);

                    if (FlxG.signals.focusLost.has(video[0].pause))
                        FlxG.signals.focusLost.remove(video[0].pause);
                }
            }
        }
    }

    public static function onResume(): Void {
        for (video in globalData) {
            if (video[0] != null)
                video[0].resume();

            if (FlxG.autoPause) {
                if (!FlxG.signals.focusGained.has(video[0].resume))
                    FlxG.signals.focusGained.add(video[0].resume);

                if (!FlxG.signals.focusLost.has(video[0].pause))
                    FlxG.signals.focusLost.add(video[0].pause);
            }
        }
    }

    public static function onDestroy(): Void {
        for (video in globalData) {
            if (video[0] != null)
                video[0].stop();
        }
    }

    public static var cacheList:Array<String> = ['Blowing_Cutscene'];

    public static function precacheVideos(list: Array<String>): Void {
        for (i in 0 ... list.length) {
            if (!FileSystem.exists(Paths.video(list[i]))) {
                trace('precacheVideos: The video file "' + list[i] + '" cannot be found!');
                break;
            }

            var video: FlxVideo = new FlxVideo();

            video.play(Paths.video(list[i]));

            video.onEndReached.add(function() {
                video.dispose();
            });

            video.stop();
        }
    }
}