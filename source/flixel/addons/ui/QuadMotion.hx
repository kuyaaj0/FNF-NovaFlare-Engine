package flixel.addons.ui;

import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.motion.Motion;
import flixel.tweens.TweenOptions;

class QuadMotion extends Motion {
    public var startX:Float;
    public var startY:Float;
    public var endX:Float;
    public var endY:Float;
    public var target:FlxObject;

    public function new(target:FlxObject, startX:Float, startY:Float, endX:Float, endY:Float, duration:Float) {
        // Create options for FlxTween with the target, duration, and easing function
        var options = new TweenOptions();
        options.x = endX;
        options.y = endY;
        options.duration = duration;
        options.ease = Math.pow; // This is a simple example of quadratic easing

        // Calling FlxTween constructor with the options
        super(target, options);

        // Set additional properties
        this.target = target;
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed); // Update parent logic

        // Get progress from the super class
        var progress = super.progress;
        if (progress > 1) progress = 1; // Clamping to 1

        // Apply quadratic easing (easeInOut)
        var curve = Math.pow(progress, 2);

        // Update position using quadratic easing
        target.x = startX + (endX - startX) * curve;
        target.y = startY + (endY - startY) * curve;
    }
}