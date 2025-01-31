package flixel.addons.ui;

import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.motion.Motion;
import flixel.util.FlxMath;

class QuadMotion extends Motion {
    public var startX:Float;
    public var startY:Float;
    public var endX:Float;
    public var endY:Float;
    public var target:FlxObject;

    public function new(target:FlxObject, startX:Float, startY:Float, endX:Float, endY:Float, duration:Float) {
        // Set up the target and other parameters
        this.target = target;
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
        
        // Create a tween for the motion
        FlxTween.tween(target, {x: endX, y: endY}, duration, {
            type: FlxTween.PERSIST, // Allow tween to persist
            onUpdate: function(tween:FlxTween) {
                var progress = tween.progress; // Get the progress of the tween

                // Apply quadratic easing manually: Quadratic ease out
                var easedProgress = 1 - Math.pow(1 - progress, 2);

                // Update the position based on eased progress
                target.x = startX + (endX - startX) * easedProgress;
                target.y = startY + (endY - startY) * easedProgress;
            }
        });
    }
}