package flixel.addons.ui;

import flixel.tweens.FlxTween;
import flixel.FlxObject;
import flixel.tweens.motion.Motion;

class QuadMotion extends FlxTween {
    public var startX:Float;
    public var startY:Float;
    public var endX:Float;
    public var endY:Float;
    public var target:FlxObject;
    public var duration:Float;

    public function new(target:FlxObject, startX:Float, startY:Float, endX:Float, endY:Float, duration:Float) {
        // Calling the super constructor with required arguments for FlxTween
        super(target, { x: endX, y: endY }, duration);

        // Initializing the specific properties
        this.target = target;
        this.startX = startX;
        this.startY = startY;
        this.endX = endX;
        this.endY = endY;
        this.duration = duration;
    }

    override public function update(elapsed:Float):Void {
        // Ensure the tween is progressing correctly
        super.update(elapsed);

        // Get progress of motion (from 0 to 1)
        var progress = this.progress;
        if (progress > 1) progress = 1; // Clamping to 1

        // Apply quadratic easing (easeInOut)
        var curve = Math.pow(progress, 2);

        // Update position using quadratic easing
        target.x = startX + (endX - startX) * curve;
        target.y = startY + (endY - startY) * curve;

        // Optionally, you can add any other logic to trigger onComplete once done
        if (progress == 1) {
            // On completion actions (if any)
        }
    }
}