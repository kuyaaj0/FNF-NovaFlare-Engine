package objects;

import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import math.Vector3;

import shaders.NoteColorSwap;
import shaders.RGBNotePalette;

enum abstract ObjectType(#if cpp cpp.UInt8 #else Int #end)
{
	var UNKNOWN = -1;
	var NOTE;
	var STRUM;
}

class NoteObject extends FlxSprite {
	public var objType:ObjectType = UNKNOWN;

	public var column:Int = 0;
	@:isVar
	public var noteData(get,set):Int; // backwards compat
	inline function get_noteData()return column;
	inline function set_noteData(v:Int)return column = v;

	public var colorSwap:NoteColorSwap;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var defScale:FlxPoint = FlxPoint.get(); // for modcharts to keep the scaling
	public var handleRendering:Bool = true;

	public var vec3Cache:Vector3 = new Vector3(); // for vector3 operations in modchart code
	
	override function toString()
	{
		return '(column: $column)';
	}

	override function draw()
	{
		if (handleRendering)
			return super.draw();
	}

	public function new(?x:Float, ?y:Float)
	{
		super(x, y);
	}


       function prepareMatrix(camera:FlxCamera) {
        _matrix.identity();
        _matrix.translate(-origin.x, -origin.y);
        _matrix.scale(scale.x, scale.y);
        _matrix.rotate(angle * (Math.PI / 180));
        _matrix.translate(x + origin.x, y + origin.y);
}

	override function drawComplex(camera:FlxCamera):Void
	{
		prepareMatrix(camera);
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	override function destroy()
	{
		defScale = FlxDestroyUtil.put(defScale);
		super.destroy();
	}
}
