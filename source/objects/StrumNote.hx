package objects;

import backend.animation.PsychAnimationController;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;
import shaders.RGBNotePalette;

import objects.playfields.PlayField;
import psychlua.HScript;

class StrumNote extends NoteObject
{
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	private var leColumn:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	////
	public var z:Float = 0;
	public var zIndex:Float = 0;
	public var desiredZIndex:Float = 0;

	private var field:PlayField;

	public var useRGBShader:Bool = true;
	public function new(x:Float, y:Float, leColumn:Int, ?playField:PlayField, player:Int) {
		animation = new PsychAnimationController(this);

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leColumn));
		rgbShader.enabled = false;
		if(PlayState.SONG != null && (PlayState.SONG.disableNoteRGB || !ClientPrefs.data.noteRGB)) useRGBShader = false;
		
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[leColumn];
		if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[leColumn];
		
		if(leColumn <= arr.length)
		{
			@:bypassAccessor
			{
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}

		RGBPaletteSwitch = new RGBNotePalette();
		shader = RGBNotePalette.shader;

		objType = STRUM;
		noteData = leColumn;
		field = playField;
		this.player = player;
		this.objType = STRUM;
		this.noteData = leColumn;
		this.field = playField;
		super(x, y);

		var skin:String = null;
		var path:String = PlayState.isPixelStage ? 'pixelUI/' : '';
		if(PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = path + PlayState.SONG.arrowSkin;
		else{
    		skin = path + Note.defaultNoteSkin;
    
    		var customSkin:String = skin + Note.getNoteSkinPostfix();
    		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;
    		
    		if (Paths.fileExists('images/NOTE_assets.png', IMAGE) && ClientPrefs.data.noteSkin == ClientPrefs.defaultData.noteSkin && !PlayState.isPixelStage) //fix for load old mods note assets
    		skin = 'NOTE_assets'; 
		}

		texture = skin; //Load texture and anims
		scrollFactor.set();
	}
	
	override function toString()
		return '(column: $column)';

	public function getZIndex(?daZ:Float)
	{
		if (daZ==null) daZ = z;
		
		var animZOffset:Float = 0;
		if (animation.name == 'confirm')
			animZOffset += 1;

		return z + desiredZIndex + animZOffset;
	}

	function updateZIndex()
	{
		zIndex = getZIndex();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image(texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image(texture), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			switch (Math.abs(leColumn) % 4)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.data.antialiasing;
			setGraphicSize(Std.int(width * 0.7));

			switch (Math.abs(leColumn) % 4)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		}
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * leColumn;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = leColumn;
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false ?note:Note) {
		animation.play(anim, force);
		if(animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
			updateZIndex();
		}
		else if (animation.curAnim.name == 'static') {
			RGBPalette.setHSB();
		}
		else if (note != null) {
			// ok now the quants should b fine lol
			RGBPalette.copyFrom(note.RGBPalette);
		}
		else {
			RGBPalette.setHSB();
		}
		
		if(useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}
}
