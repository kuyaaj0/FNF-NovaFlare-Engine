package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	// Ensure that a valid character is always provided
	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		// Make sure 'char' has a valid value
		if (char == null || char == "") {
			char = "bf"; // Default to 'bf' if 'char' is invalid
		}

		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// Ensure sprTracker is not null before accessing it
		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];

	// Add error handling and log checks
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		// Ensure valid input
		if(this.char != char) {
			var name:String = 'icons/' + char;
			
			// Try finding icon file, fallback to defaults if missing
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face';
			
			// Load graphic only if it exists to prevent null error
			var graphic = Paths.image(name, allowGPU);
			if (graphic == null) {
				trace("Error: Missing icon file for " + name); // Add logging for missing graphics
				return; // Exit to prevent further errors
			}

			var delimiter:Int = (Math.floor(graphic.width / 3) >= graphic.height) ? 3 : 2;
			loadGraphic(graphic, true, Math.floor(graphic.width / delimiter), graphic.height);
			updateHitbox();

			animation.add(char, [for (i in 0...numFrames) i], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			// Adjust anti-aliasing based on character type
			if(char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	public var autoAdjustOffset:Bool = true;

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}