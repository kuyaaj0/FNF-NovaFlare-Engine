package flixel.addons.ui;

import flixel.tweens.motion.Motion;
import flixel.FlxObject;

class QuadMotion extends Motion {
    public var startX:Float;
    public var startY:Float;
    public var endX:Float;
    public var endY:Float;
    public var duration:Float;
    public var target:FlxObject;
    
    public function new(target:FlxObject, startX:Float, startY:Float, endX:Float, endY:Float, duration:Float) {
        super(target);
        this.target = target;
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
        this.duration = duration;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Get progress of motion (from 0 to 1)
        var progress = elapsed / duration;
        if (progress > 1) progress = 1; // Clamping to 1

        // Apply quadratic easing (easeInOut)
        var curve = Math.pow(progress, 2);

        // Update position using quadratic easing
        target.x = startX + (endX - startX) * curve;
        target.y = startY + (endY - startY) * curve;

        // Check if we reached the target position
        if (progress == 1) {
            // Optionally, trigger any onComplete callback if needed
            // onComplete();
        }
    }
}