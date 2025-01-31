package flixel.addons.ui;

import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.motion.Motion;
import flixel.tweens.EaseFunction;

class QuadMotion extends Motion {
    public var startX:Float;
    public var startY:Float;
    public var endX:Float;
    public var endY:Float;
    public var target:FlxObject;
    public var duration:Float;

    public function new(target:FlxObject, startX:Float, startY:Float, endX:Float, endY:Float, duration:Float) {
        // Set up the target and duration for the motion
        this.target = target;
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
        this.duration = duration;
        
        // Create a tween for the motion (using a quadratic ease function)
        FlxTween.tween(target, {x: endX, y: endY}, duration, {
            type: FlxTween.PERSIST,
            ease: EaseFunction.QUAD_OUT, // Apply quadratic easing
            onUpdate: function(tween:FlxTween) {
                var progress = tween.progress;
                var curve = Math.pow(progress, 2); // Quadratic easing calculation

                // Update the target's position based on the easing
                target.x = startX + (endX - startX) * curve;
                target.y = startY + (endY - startY) * curve;
            }
        });
    }
}