package objects;

import backend.animation.PsychAnimationController;
import backend.NoteTypesConfig;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

import states.editors.EditorPlayState;

import objects.StrumNote;
import objects.playfields.*;

import flixel.math.FlxRect;
import math.Vector3;
import psychlua.HScript;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

typedef NoteSplashData = {
	disabled:Bool,
	texture:String,
	useGlobalShader:Bool, //breaks r/g/b/a but makes it copy default colors for your custom note
	useRGBShader:Bool,
	antialiasing:Bool,
	r:FlxColor,
	g:FlxColor,
	b:FlxColor,
	a:Float
}

/**
 * The note object used as a data structure to spawn and manage notes during gameplay.
 * 
 * If you want to make a custom note type, you should search for: "function set_noteType"
**/
class Note extends NoteObject
{
    override public var vec3Cache:Vector3;
    public var noteScript:HScript;
    public var genScript:HScript; // note generator script (used for shit like pixel notes or skin mods) ((script provided by the HUD skin))
    
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var strumTime:Float = 0;

	public var zIndex:Float = 0;
	public var z:Float = 0;
    public var realColumn:Int;

	@:isVar
	public var noteData(get, set):Int;
    inline function get_noteData()
        return realColumn;
    inline function set_noteData(v:Int)
        return realColumn = v;

	public var mustPress:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;

	public var wasGoodHit:Bool = false;
	public var missed:Bool = false;

	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

//i forgot this one is sustain note
	public var tail:Array<Note> = []; // for sustains
	public var unhitTail:Array<Note> = [];
	public var parent:Note;
	public var blockHit:Bool = false; // only works for player

	public var sustainLength:Float = 0;
	public var canHold:Bool = false;
	public var isSustainNote:Bool = false;
	public var isSustainEnd:Bool = false;
	public var isRoll:Bool = false;
	public var isHeld:Bool = false;
	public var noteType(default, set):String = null;
//end with the sustain note code

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var rgbShader:RGBShaderReference;
	public static var globalRgbShaders:Array<RGBPalette> = [];
	public var inEditor:Bool = false;
	public var desiredZIndex:Float = 0;

	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 1;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var SUSTAIN_SIZE:Int = 44;
	public static var swagWidth:Float = 160 * 0.7;
	public static var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var defaultNoteSkin:String = 'noteSkins/NOTE_assets';

	public var noteSplashData:NoteSplashData = {
		disabled: false,
		texture: null,
		antialiasing: !PlayState.isPixelStage,
		useGlobalShader: false,
		useRGBShader: (PlayState.SONG != null) ? !(PlayState.SONG.disableNoteRGB == true) : true,
		r: -1,
		g: -1,
		b: -1,
		a: ClientPrefs.data.splashAlpha
	};

	// mod manager
	public var garbage:Bool = false; // if this is true, the note will be removed in the next update cycle
	public var alphaMod:Float = 1;
	public var alphaMod2:Float = 1; // TODO: unhardcode this shit lmao
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;
	public var noteSplashTexture:String = null;  //just use fix old mods  XD

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; //plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;
	public var hitsoundChartEditor:Bool = true;
	public var hitsound:String = 'hitsound';

	public var noteSplashBrt:Int = 0;
	public var noteSplashSat:Int = 0;
	public var noteSplashHue:Int = 0;
    // fix old lua😡

	private function set_multSpeed(value:Float):Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		//trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) //haha funny twitter shit
	{
		if(isSustainNote && isSustainEnd && animation.curAnim != null && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value:String):String {
		if(texture != value) reloadNote(value);

		texture = value;
		return value;
	}

	public function defaultRGB()
	{
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[column];
		if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[column];

		if (column > -1 && column <= arr.length)
		{
			rgbShader.r = arr[0];
			rgbShader.g = arr[1];
			rgbShader.b = arr[2];
		}
	}

	private function set_noteType(value:String):String {
		noteSplashData.texture = PlayState.SONG != null ? PlayState.SONG.splashSkin : 'noteSplashes';
		defaultRGB();

		if(column > -1 && noteType != value) {
			switch(value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					//this used to change the note texture to HURTNOTE_assets.png,
					//but i've changed it to something more optimized with the implementation of RGBPalette:

					// note colors
					rgbShader.r = 0xFF101010;
					rgbShader.g = 0xFFFF0000;
					rgbShader.b = 0xFF990022;

					// splash data and colors
					noteSplashData.r = 0xFFFF0000;
					noteSplashData.g = 0xFF101010;
					noteSplashData.texture = 'noteSplashes/noteSplashes-electric';

					// gameplay data
					lowPriority = true;
					missHealth = isSustainNote ? 0.25 : 0.1;
					hitCausesMiss = true;
					hitsound = 'cancelMenu';
					hitsoundChartEditor = false;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			if (value != null && value.length > 1) NoteTypesConfig.applyNoteTypeData(this, value);
			if (hitsound != 'hitsound' && ClientPrefs.data.hitsoundVolume > 0) Paths.sound(hitsound); //precache new sound for being idiot-proof
			noteType = value;
		}
		return value;
	}

	override function toString()
	{
		return '(column: $column)';
	}

	public function new(strumTime:Float, column:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, ?createdFrom:Dynamic = null)
	{
		super();

		if (ClientPrefs.data.hitsoundType != ClientPrefs.defaultData.hitsoundType) hitsound = 'hitsounds/' + ClientPrefs.data.hitsoundType;

		animation = new PsychAnimationController(this);

		antialiasing = ClientPrefs.data.antialiasing;
		if(createdFrom == null) createdFrom = PlayState.instance;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		this.moves = false;

		x += (ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if(!inEditor) this.strumTime += ClientPrefs.data.noteOffset;

		this.column = column;

		if(column > -1) {
			texture = '';
			rgbShader = new RGBShaderReference(this, initializeGlobalRGBShader(column));
			if(PlayState.SONG != null && (PlayState.SONG.disableNoteRGB || !ClientPrefs.data.noteRGB)) rgbShader.enabled = false;

			x += swagWidth * (column);
			if(!isSustainNote && isSustainEnd && column < colArray.length) { //Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				animToPlay = colArray[column % colArray.length];
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if(prevNote != null)
			prevNote.nextNote = this;

		if (isSustainNote && isSustainEnd && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if(ClientPrefs.data.downScroll) flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			animation.play(colArray[column % colArray.length] + 'holdend');

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(colArray[prevNote.column % colArray.length] + 'hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if(createdFrom != null && createdFrom.songSpeed != null) prevNote.scale.y *= createdFrom.songSpeed;

				if(PlayState.isPixelStage) {
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); //Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}

			if(PlayState.isPixelStage)
			{
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
			earlyHitMult = 0;
		}
		else if(!isSustainNote)
		{
			centerOffsets();
			centerOrigin();
		}
		x += offsetX;
	}

	public static function initializeGlobalRGBShader(column:Int)
	{
		if(globalRgbShaders[column] == null)
		{
			var newRGB:RGBPalette = new RGBPalette();
			globalRgbShaders[column] = newRGB;

			var arr:Array<FlxColor> = (!PlayState.isPixelStage) ? ClientPrefs.data.arrowRGB[column] : ClientPrefs.data.arrowRGBPixel[column];
			if (column > -1 && column <= arr.length)
			{
				newRGB.r = arr[0];
				newRGB.g = arr[1];
				newRGB.b = arr[2];
			}
		}
		return globalRgbShaders[column];
	}

	var _lastNoteOffX:Float = 0;	
	public var originalHeight:Float = 6;
	public var correctionOffset:Float = 0; //dont mess with this
	public function reloadNote(texture:String = '', postfix:String = '') {
		if(texture == null) texture = '';
		if(postfix == null) postfix = '';
		
		if (saveTexture != texture) reloadPath(texture, postfix);
		
		var lastScaleY:Float = scale.y;
		
		var animName:String = null;
		if(animation.curAnim != null) {
			animName = animation.curAnim.name;
		}

		if(PlayState.isPixelStage) {
			if(isSustainNote) {
				var graphic = Paths.image('pixelUI/' + skinPixel + 'ENDS' + skinPostfix, null, false);
				loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 2));
				originalHeight = graphic.height / 2;
			} else {
				var graphic = Paths.image('pixelUI/' + skinPixel + skinPostfix, null, false);
				loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 5));
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;

			if(isSustainNote) {
				offsetX += _lastNoteOffX;
				_lastNoteOffX = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= _lastNoteOffX;
			}
		} else {
			frames = Paths.getSparrowAtlas(skin, null, false);
			loadNoteAnims();
			if(!isSustainNote)
			{
				centerOffsets();
				centerOrigin();
			}
		}

		if(isSustainNote) {
			scale.y = lastScaleY;
		}
		updateHitbox();

		if(animName != null)
			animation.play(animName, true);
	}
	
	static var saveTexture:String;
	static var skin:String;
	static var _lastValidChecked:String; //optimization
	static var skinPixel:String;
	static var skinPostfix:String;
	static var customSkin:String;
	static var pathPixel:String;
		
	public static function reloadPath(texture:String = '', postfix:String = '') {
	    saveTexture = texture;
	    
	    skin = texture + postfix;
		if(texture.length < 1) {
			skin = PlayState.SONG != null ? PlayState.SONG.arrowSkin : null;
			if(skin == null || skin.length < 1)
				skin = defaultNoteSkin + postfix;
		}
		
		skinPixel = skin;		
		skinPostfix = getNoteSkinPostfix();
		customSkin = skin + skinPostfix;
		pathPixel = PlayState.isPixelStage ? 'pixelUI/' : '';
		if(customSkin == _lastValidChecked || Paths.fileExists('images/' + pathPixel + customSkin + '.png', IMAGE))
		{
			skin = customSkin;
			_lastValidChecked = customSkin;
		}
		else skinPostfix = '';
	}

	public static function getNoteSkinPostfix()
	{
		var skin:String = '';
		if(ClientPrefs.data.noteSkin != ClientPrefs.defaultData.noteSkin)
			skin = '-' + ClientPrefs.data.noteSkin.trim().toLowerCase().replace(' ', '_');
		return skin;
	}

	function loadNoteAnims() {
		if (isSustainNote)
		{
			attemptToAddAnimationByPrefix('purpleholdend', 'pruple end hold', 24, true); // this fixes some retarded typo from the original note .FLA
			animation.addByPrefix(colArray[column] + 'holdend', colArray[column] + ' hold end', 24, true);
			animation.addByPrefix(colArray[column] + 'hold', colArray[column] + ' hold piece', 24, true);
		}
		else animation.addByPrefix(colArray[column] + 'Scroll', colArray[column] + '0');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims() {
		if(isSustainNote)
		{
			animation.add(colArray[column] + 'holdend', [column + 4], 24, true);
			animation.add(colArray[column] + 'hold', [column], 24, true);
		} else animation.add(colArray[column] + 'Scroll', [column + 4], 24, true);
	}

	function attemptToAddAnimationByPrefix(name:String, prefix:String, framerate:Float = 24, doLoop:Bool = true)
	{
		var animFrames = [];
		@:privateAccess
		animation.findByPrefix(animFrames, prefix); // adds valid frames to animFrames
		if(animFrames.length < 1) return;

		animation.addByPrefix(name, prefix, framerate, doLoop);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(!inEditor){
			if (noteScript != null){
				noteScript.executeFunc("noteUpdate", [elapsed], this);
			}

			if (genScript != null){
				genScript.executeFunc("noteUpdate", [elapsed], this);
            }
		}
		
		if (mustPress)
		{
			if (!ClientPrefs.data.playOpponent) {
				canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult) &&
							strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult));
		
				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
					tooLate = true;
			}else{
				canBeHit = false;

				if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				{
					if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
						wasGoodHit = true;
				}		
			}
		}else{
			if (ClientPrefs.data.playOpponent) {
				canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult) &&
							strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult));
		
				if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
					tooLate = true;
			}else{
				canBeHit = false;

				if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				{
					if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
						wasGoodHit = true;
				}		
			}			
		}
	}

	override public function destroy()
	{
		super.destroy();
		_lastValidChecked = '';
	}

	public function followStrumNote(myStrum:StrumNote, fakeCrochet:Float, songSpeed:Float = 1)
	{
		var strumX:Float = myStrum.x;
		var strumY:Float = myStrum.y;
		var strumAngle:Float = myStrum.angle;
		var strumAlpha:Float = myStrum.alpha;
		var strumDirection:Float = myStrum.direction;

		distance = (0.45 * (Conductor.songPosition - strumTime) * songSpeed * multSpeed);
		if (!myStrum.downScroll) distance *= -1;

		var angleDir = strumDirection * Math.PI / 180;
		if (copyAngle)
			angle = strumDirection - 90 + strumAngle + offsetAngle;

		if(copyAlpha)
			alpha = strumAlpha * multAlpha;

		if(copyX)
			x = strumX + offsetX + Math.cos(angleDir) * distance;

		if(copyY)
		{
			y = strumY + offsetY + correctionOffset + Math.sin(angleDir) * distance;
			if(myStrum.downScroll && isSustainNote && isSustainEnd)
			{
				if(PlayState.isPixelStage)
				{
					y -= PlayState.daPixelZoom * 9.5;
				}
				y -= (frameHeight * scale.y) - (Note.swagWidth / 2);
			}
		}
	}

	public function clipToStrumNote(myStrum:StrumNote)
	{
		var center:Float = myStrum.y + offsetY + Note.swagWidth / 2;
		if(  (isSustainNote && isSustainEnd && (mustPress || !ignoreNote) &&
			(!mustPress || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit)))
			&& !ClientPrefs.data.playOpponent)
			|| 
			(isSustainNote && (!mustPress || !ignoreNote) &&
			(mustPress || (wasGoodHit || (prevNote.wasGoodHit && !canBeHit)))
			&& ClientPrefs.data.playOpponent)
			)
		{
			if (!wasGoodHit) return;
			
			updateHitbox();
			var swagRect:FlxRect = clipRect;
			if(swagRect == null) swagRect = new FlxRect(0, 0, frameWidth, frameHeight);
			
			var time:Float = FlxMath.bound((Conductor.songPosition - strumTime) / (height / (0.45 * FlxMath.roundDecimal(PlayState.instance.songSpeed, 2))), 0, 1);
			
			swagRect.x = 0;
			swagRect.y = time * frameHeight;
			swagRect.width = frameWidth;
			swagRect.height = frameHeight;

			clipRect = swagRect;
		}
	}

	public function hitMultUpdate(number:Int = 0, maxNumber:Int = 0){
		if (number == 0){
			earlyHitMult = 0;
			lateHitMult = 1;	   //写1而不是0.5是用于修复长条先miss问题
		}else if (number == maxNumber){
			earlyHitMult = 0.75;
			lateHitMult = 0.25;	  		
			noAnimation = true; //better anim play
		}else{
			earlyHitMult = 0.5;
			lateHitMult = 0.75;	
		}
	} //this shit can make hold note work better

	public static function checkSkin() //加载检测独立出来检测省的和原来一样粑粑
	{
		if (Paths.fileExists('images/NOTE_assets.png', IMAGE) && ClientPrefs.data.noteSkin == ClientPrefs.defaultData.noteSkin) defaultNoteSkin = 'NOTE_assets';
		reloadPath(); //初始化
	}

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}
}