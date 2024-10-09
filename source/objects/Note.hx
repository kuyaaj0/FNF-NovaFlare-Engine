package objects;

import backend.animation.PsychAnimationController;
import backend.NoteTypesConfig;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

import states.editors.EditorPlayState;

import objects.StrumNote;

import flixel.math.FlxRect;

using StringTools;

// Define the EventNote type for event notes with associated properties.
typedef EventNote = {
	strumTime: Float,
	event: String,
	value1: String,
	value2: String
}

// Define the NoteSplashData type to hold note splash properties.
typedef NoteSplashData = {
	disabled: Bool,
	texture: String,
	useGlobalShader: Bool, 
	useRGBShader: Bool,
	antialiasing: Bool,
	r: FlxColor,
	g: FlxColor,
	b: FlxColor,
	a: Float
}

/**
 * The note object used as a data structure to spawn and manage notes during gameplay.
 * 
 * If you want to make a custom note type, you should search for: "function set_noteType"
**/
class Note extends FlxSprite {
	public var extraData: Map<String, Dynamic> = new Map<String, Dynamic>();

	public var strumTime: Float = 0;
	public var noteData: Int = 0;

	public var mustPress: Bool = false;
	public var canBeHit: Bool = false;
	public var tooLate: Bool = false;

	public var wasGoodHit: Bool = false;
	public var missed: Bool = false;

	public var ignoreNote: Bool = false;
	public var hitByOpponent: Bool = false;
	public var noteWasHit: Bool = false;
	public var prevNote: Note;
	public var nextNote: Note;

	public var spawned: Bool = false;

	public var tail: Array<Note> = []; // for sustains
	public var parent: Note;
	public var blockHit: Bool = false; // only works for player

	public var sustainLength: Float = 0;
	public var canHold: Bool = false;
	public var isSustainNote: Bool = false;
	public var noteType(default, set): String = null;

	public var eventName: String = '';
	public var eventLength: Int = 0;
	public var eventVal1: String = '';
	public var eventVal2: String = '';

	public var rgbShader: RGBShaderReference;
	public static var globalRgbShaders: Array<RGBPalette> = [];
	public var inEditor: Bool = false;

	public var animSuffix: String = '';
	public var gfNote: Bool = false;
	public var earlyHitMult: Float = 1;
	public var lateHitMult: Float = 1;
	public var lowPriority: Bool = false;

	public static var SUSTAIN_SIZE: Int = 44;
	public static var swagWidth: Float = 160 * 0.7;
	public static var colArray: Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var defaultNoteSkin: String = 'noteSkins/NOTE_assets';

	public var noteSplashData: NoteSplashData = {
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

	public var offsetX: Float = 0;
	public var offsetY: Float = 0;
	public var offsetAngle: Float = 0;
	public var multAlpha: Float = 1;
	public var multSpeed(default, set): Float = 1;

	public var copyX: Bool = true;
	public var copyY: Bool = true;
	public var copyAngle: Bool = true;
	public var copyAlpha: Bool = true;

	public var hitHealth: Float = 0.023;
	public var missHealth: Float = 0.0475;
	public var rating: String = 'unknown';
	public var ratingMod: Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled: Bool = false;

	public var texture(default, set): String = null;
	public var noteSplashTexture: String = null;  //just use fix old mods  XD

	public var noAnimation: Bool = false;
	public var noMissAnimation: Bool = false;
	public var hitCausesMiss: Bool = false;
	public var distance: Float = 2000; // plan on doing scroll directions soon -bb

	public var hitsoundDisabled: Bool = false;
	public var hitsoundChartEditor: Bool = true;
	public var hitsound: String = 'hitsound';

	public var noteSplashBrt: Int = 0;
	public var noteSplashSat: Int = 0;
	public var noteSplashHue: Int = 0;

	private function set_multSpeed(value: Float): Float {
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		return value;
	}

	public function resizeByRatio(ratio: Float) {
		if (isSustainNote && animation.curAnim != null && !animation.curAnim.name.endsWith('end')) {
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value: String): String {
		if (texture != value) {
			reloadNote(value);
		}
		texture = value;
		return value;
	}

	public function defaultRGB() {
		var arr: Array<FlxColor> = ClientPrefs.data.arrowRGB[noteData];
		if (PlayState.isPixelStage) {
			arr = ClientPrefs.data.arrowRGBPixel[noteData];
		}

		if (noteData > -1 && noteData <= arr.length) {
			rgbShader.r = arr[0];
			rgbShader.g = arr[1];
			rgbShader.b = arr[2];
		}
	}

	private function set_noteType(value: String): String {
		noteSplashData.texture = PlayState.SONG != null ? PlayState.SONG.splashSkin : 'noteSplashes';
		defaultRGB();

		if (noteData > -1 && noteType != value) {
			switch (value) {
				case 'Hurt Note':
					ignoreNote = mustPress;
					rgbShader.r = 0xFF101010;
					rgbShader.g = 0xFFFF0000;
					rgbShader.b = 0xFF990022;

					// Splash data and colors
					noteSplashData.r = 0xFFFF0000;
					noteSplashData.g = 0xFF101010;
					noteSplashData.texture = 'noteSplashes/noteSplashes-electric';

					// Gameplay data
					lowPriority = true;
					missHealth = isSustainNote ? 0.25 : 0.1;
					hitCausesMiss = true;
					hitsound = 'cancelMenu';
					hitsoundChartEditor = false;
					break;
				case 'Alt Animation':
					animSuffix = '-alt';
					break;
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
					break;
				case 'GF Sing':
					gfNote = true;
					break;
			}
			if (value != null && value.length > 1) {
				NoteTypesConfig.applyNoteTypeData(this, value);
			}
			if (hitsound != 'hitsound' && ClientPrefs.data.hitsoundVolume > 0) {
				Paths.sound(hitsound); // Pre-cache new sound for being idiot-proof
			}
			noteType = value;
		}
		return value;
	}

	public function new(strumTime: Float, noteData: Int, ?prevNote: Note, ?sustainNote: Bool = false, ?inEditor: Bool = false, ?createdFrom: Dynamic = null) {
		super();

		if (ClientPrefs.data.hitsoundType != ClientPrefs.defaultData.hitsoundType) {
			hitsound = 'hitsounds/' + ClientPrefs.data.hitsoundType;
		}

		animation = new PsychAnimationController(this);

		antialiasing = ClientPrefs.data.antialiasing;
		if (createdFrom == null) createdFrom = PlayState.instance;

		if (prevNote == null) {
			prevNote = this;
		}

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		this.moves = false;

		x += (ClientPrefs.data.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		y -= 2000; // Move the note off-screen initially
		this.strumTime = strumTime;
		if (!inEditor) {
			this.strumTime += ClientPrefs.data.noteOffset;
		}

		this.noteData = noteData;

		if (noteData > -1) {
			texture = '';
			rgbShader = new RGBShaderReference(this, initializeGlobalRGBShader(noteData));
			if (PlayState.SONG != null && (PlayState.SONG.disableNoteRGB || !ClientPrefs.data.noteRGB)) {
				rgbShader.enabled = false;
			}

			x += swagWidth * noteData;
			if (!isSustainNote && noteData < colArray.length) {
				var animToPlay: String;
