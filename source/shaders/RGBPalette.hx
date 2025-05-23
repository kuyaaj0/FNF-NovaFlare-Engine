package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

class RGBPalette {
	public var shader(default, null):RGBPaletteShader = new RGBPaletteShader();
	public var r(default, set):FlxColor;
	public var g(default, set):FlxColor;
	public var b(default, set):FlxColor;
	public var mult(default, set):Float;

	// HSB/Flash/Alpha features from ColorSwap
	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;
	public var daAlpha(default, set):Float = 1;
	public var flash(default, set):Float = 0;
	public var flashR(default, set):Float = 1;
	public var flashG(default, set):Float = 1;
	public var flashB(default, set):Float = 1;
	public var flashA(default, set):Float = 1;

	private function set_r(color:FlxColor) {
		r = color;
		shader.r.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}
	private function set_g(color:FlxColor) {
		g = color;
		shader.g.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}
	private function set_b(color:FlxColor) {
		b = color;
		shader.b.value = [color.redFloat, color.greenFloat, color.blueFloat];
		return color;
	}
	private function set_mult(value:Float) {
		mult = FlxMath.bound(value, 0, 1);
		shader.mult.value = [mult];
		return mult;
	}
	private function set_hue(value:Float) {
		hue = value;
		shader.uTime.value[0] = hue;
		return hue;
	}
	private function set_saturation(value:Float) {
		saturation = value;
		shader.uTime.value[1] = saturation;
		return saturation;
	}
	private function set_brightness(value:Float) {
		brightness = value;
		shader.uTime.value[2] = brightness;
		return brightness;
	}
	private function set_daAlpha(value:Float) {
		daAlpha = value;
		shader.daAlpha.value[0] = daAlpha;
		return daAlpha;
	}
	private function set_flash(value:Float) {
		flash = value;
		shader.flash.value[0] = flash;
		return flash;
	}
	private function set_flashR(value:Float) {
		flashR = value;
		shader.flashColor.value[0] = flashR;
		return flashR;
	}
	private function set_flashG(value:Float) {
		flashG = value;
		shader.flashColor.value[1] = flashG;
		return flashG;
	}
	private function set_flashB(value:Float) {
		flashB = value;
		shader.flashColor.value[2] = flashB;
		return flashB;
	}
	private function set_flashA(value:Float) {
		flashA = value;
		shader.flashColor.value[3] = flashA;
		return flashA;
	}

	public function new() {
		r = 0xFFFF0000;
		g = 0xFF00FF00;
		b = 0xFF0000FF;
		mult = 1.0;
		shader.uTime.value = [0, 0, 0];
		shader.flashColor.value = [1, 1, 1, 1];
		shader.daAlpha.value = [1];
		shader.flash.value = [0];
	}
}
// automatic handler for easy usability
class RGBShaderReference
{
	public var r(default, set):FlxColor;
	public var g(default, set):FlxColor;
	public var b(default, set):FlxColor;
	public var mult(default, set):Float;
	public var enabled(default, set):Bool = true;

	public var parent:RGBPalette;
	private var _owner:FlxSprite;
	private var _original:RGBPalette;
	public function new(owner:FlxSprite, ref:RGBPalette)
	{
		parent = ref;
		_owner = owner;
		_original = ref;
		owner.shader = ref.shader;

		@:bypassAccessor
		{
			r = parent.r;
			g = parent.g;
			b = parent.b;
			mult = parent.mult;
		}
	}
	
	private function set_r(value:FlxColor)
	{
		if(allowNew && value != _original.r) cloneOriginal();
		return (r = parent.r = value);
	}
	private function set_g(value:FlxColor)
	{
		if(allowNew && value != _original.g) cloneOriginal();
		return (g = parent.g = value);
	}
	private function set_b(value:FlxColor)
	{
		if(allowNew && value != _original.b) cloneOriginal();
		return (b = parent.b = value);
	}
	private function set_mult(value:Float)
	{
		if(allowNew && value != _original.mult) cloneOriginal();
		return (mult = parent.mult = value);
	}
	private function set_enabled(value:Bool)
	{
		_owner.shader = value ? parent.shader : null;
		return (enabled = value);
	}

	public var allowNew = true;
	private function cloneOriginal()
	{
		if(allowNew)
		{
			allowNew = false;
			if(_original != parent) return;

			parent = new RGBPalette();
			parent.r = _original.r;
			parent.g = _original.g;
			parent.b = _original.b;
			parent.mult = _original.mult;
			_owner.shader = parent.shader;
			//trace('created new shader');
		}
	}
}

class RGBPaletteShader extends FlxShader {
	@:glFragmentHeader('
		#pragma header

		uniform vec3 r;
		uniform vec3 g;
		uniform vec3 b;
		uniform float mult;
		uniform vec3 uTime; // [hue, sat, bright]
		uniform float daAlpha;
		uniform float flash;
		uniform vec4 flashColor;

		vec3 rgb2hsv(vec3 c) {
			vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
			vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
			vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}
		vec3 hsv2rgb(vec3 c) {
			vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
			vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}
	')
	@:glFragmentSource('
		#pragma header

		void main() {
			vec4 color = texture2D(bitmap, openfl_TextureCoordv);

			// HSB manipulation (from ColorSwap)
			vec3 swagColor = rgb2hsv(color.rgb);
			swagColor[0] = swagColor[0] + uTime[0];
			swagColor[1] = clamp(swagColor[1] * (1.0 + uTime[1]), 0.0, 1.0);
			swagColor[2] = swagColor[2] * (1.0 + uTime[2]);
			color.rgb = hsv2rgb(swagColor);

			// Palette swap logic (from RGBPalette)
			vec3 paletteColor = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
			color.rgb = mix(color.rgb, paletteColor, mult);

			// Flash logic (from ColorSwap)
			if (flash != 0.0) {
				color = mix(color, flashColor, flash) * color.a;
			}
			color *= daAlpha;

			gl_FragColor = color; // Add colorMult() logic if you use color transforms
		}
	')
	public function new() {
		super();
	}
}
