package options;

import substates.PauseSubState;

import backend.ClientPrefs;
import backend.StageData;

import objects.Note;
import objects.StrumNote;

import flixel.addons.transition.FlxTransitionableState;
import flixel.input.gamepad.FlxGamepad;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;

class OptionsSubstate extends MusicBeatSubstate
{
	public static var instance:OptionsSubstate;

	public var background:FlxSprite;

	public var selectedCat:OptionCata;
	
	public var CatTeam:FlxTypedGroup<FlxSprite>;

	public var selectedOption:Option;

	public var selectedCatIndex = 0;
	public var selectedOptionIndex = 0;
	
	private static var savePosition:Int = 0;
	private static var saveSelectedCatIndex:Int = 0;
	private static var saveSelectedOptionIndex:Int = 0;
	
	public var startFix:Bool = false;

	public var isInMain:Bool; //true 是大类，false是小类
	public var options:Array<OptionCata>;

	public var shownStuff:FlxTypedGroup<FlxText>;

	public var visibleRange = [114, 640];
	public var camMouseCheck:FlxCamera;
	
	public var strumNote:FlxTypedGroup<StrumNote>;
	public var normalNote:FlxTypedGroup<Note>;
	var notesTween:Array<FlxTween> = [];
	var noteBG:FlxSprite;
    
    
	var ColorArray:Array<Int> = [
		0xFF9400D3,
		0xFF4B0082,
		0xFF0000FF,
		0xFF00FF00,
		0xFFFFFF00,
		0xFFFF7F00,
		0xFFFF0000
	                                
	    ];
	    
	public static var currentColor:Int = 1;    
	public static var currentColorAgain:Int = 0;    

	public var menu:FlxTypedGroup<FlxSprite>;

	public var descText:FlxText;
	public var descBack:FlxSprite;
	
	public static var pauseMusic:FlxSound;
    
	override function create()
	{
	    #if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
		
		pauseMusic = new FlxSound();
		try
		{
			if (PauseSubState.songName == null || PauseSubState.songName.toLowerCase() != 'none')
			{
				if(PauseSubState.songName == null)
				{
					var path:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
					if(path.toLowerCase() != 'none')
						pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
				}
				else pauseMusic.loadEmbedded(Paths.music(PauseSubState.songName), true, true);
			}
		} catch(e:Dynamic) {}
		pauseMusic.volume = PauseSubState.pauseMusic.volume;		
		pauseMusic.play(false, 0);
		pauseMusic.time = PauseSubState.pauseMusic.time;
		
		options = [
			new OptionCata(50, 40, OptionsName.setGameplay(), [								
                new ResultsScreen('If checked, Open Results Screen at end song.'),                          
			]),
			new OptionCata(345, 40, OptionsName.setAppearance(), [
			    //new HitSoundType('Choose sound type for hitSound.'),
                new HitSound("Adds 'hitsound' on note hits."),				               
				new CamZoom("Toggle the camera zoom in-game."),
				new ScoreZoom("Zoom score on"),
				new SmoothScore("smooth score is still on beta and not working"),
				new JudgementCounter("Show your judgements that you've gotten in the song"),								
                new HideHud("Shows to you hud."),           
                new HideOppStrums("Shows/Hides opponent strums on screen."),		
                new ShowComboNum("Combo sprite appearance."),
                new ComboColor("Allow combo Sprite to get and use rating color."),	
                new ComboOffset('Fix combo member position skewing.'),
                new ShowRating("Rating sprite appearance."),               
                new ShowSplashes("Show particles on SICK hit."),
                new SplashAlpha('How much transparent should the Note Splashes be.'),                 
                new HealthBarAlpha("Healthbar Transparceny."),     
			]),
			new OptionCata(640, 40, OptionsName.setMisc(), [			    			    
				new PauseMusic('What song do you prefer for the Pause Screen?'),
				new PauseButton('Add pauseButton in game'),
				#if CHECK_FOR_UPDATES new CheckForUpdates('On Release builds, turn this on to check for updates when you start the game.'), #end
				#if DISCORD_ALLOWED new DiscordRPC('Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord'), #end				
				#if mobile new GameOverVibration('If checked, your device will vibrate at game over.'),    	
				new ScreenSaver('If checked, the phone will sleep after going inactive for few seconds.'), #end
        		]),
			new OptionCata(935, 40, OptionsName.setOpponentMode(), [			    		    
				new OpponentCodeFix('If checked, goodNoteHit and opponentNoteHit not follow playOpponent setting to change.\nif you playing it will return goodNoteHit function.'),
				new BotOpponentFix('Bot Opponent Fix'),				
				new HealthDrainOPPO('Health Drain on opponent mode'),
				new HealthDrainOPPOMult('Health Drain multiplier on opponent mode'),			 
			]),			
			new OptionCata(50, 40 + 64, OptionsName.setMenuExtend(), [
			    new CustomFadeType('Change Custom Fade Type'),
				new CustomFadeSound('Change Custom Fade Sound Volume.'),	
				new CustomFadeText('Check for showcase engine version and loading condition.'),								
				new SkipTitleVideo('Check for skip intro video'),
				new FreeplayStateVersion('Choose which engine freeplay you need.'),
			]),
			new OptionCata(345, 40 + 64, OptionsName.setControls(), [                
			    new ControlsAlpha('Virtual pad alpha at state.'),
            	new PlayControlsAlpha('android control alpha for play.'),         	
			]),
			new OptionCata(640, 40 + 64, "System", [
			    //new Language("Change language in some state."), //will use fot NF1.2.0
			    new FPSCap("Change your FPS Cap."),					    
			    new ColorblindMode("You can set colorblind filter.\nmakes the game more playable for colorblind people"),
			    new Shaders("Shaders used for some visual effects, and also CPU intensive for weaker PCs."),
				new GPUcache("If checked, allows the GPU to be used for caching textures, decreasing RAM usage."),				
				new LoadingScreen("Add a LoadingScreen for PlayState and load faster\nif have some problem please disable it."),
				new FlashingLights("Toggle flashing lights that can cause epileptic seizures and strain."),
				new QualityLow("Turn off some object on stages."),
				new GameQuality('Change game quality for screen.'),
                new Antialiasing("Toggle antialiasing, improving graphics quality at a slight performance penalty."),				  
				new AutoPause("Stops game, when its unfocused."),				              
			]),			
			new OptionCata(935, 40 + 64, "Watermark", [                
				new FPSOption("Toggle the FPS counter."),
				new FPSRainbowOption("Make the FPS Counter color varies according to your frame count."),
				new FPSScale('Set the size of FPS counter.'),
                new ExtraOption("Toggle the extra counter."),
                new MEMType("Choose memory showcase data."),                
                new WaterMarkOption('Toggle the watermark.'),
                new WaterMarkScale('Set the size of watermark.'),
			]),			
			new OptionCata(-1, 125, "Editing Judgements", [			
				new FrameOption("Changes how many frames you have for hitting a note earlier or late."),
                new RatingOffset('Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.'),			
				new MarvelousMsOption("How many milliseconds are in the MARVELOUS hit window."),
				new SickMsOption("How many milliseconds are in the SICK hit window."),
				new GoodMsOption("How many milliseconds are in the GOOD hit window."),
				new BadMsOption("How many milliseconds are in the BAD hit window."),
				new MarvelousRating('Extend marvelous rate for playing.'),
				new MarvelousSprite('If unchecked,Marvelous rate will also use sick sprite.'),
			], true)
		];
		
		persistentUpdate = persistentDraw = true;

		instance = this;

		menu = new FlxTypedGroup<FlxSprite>();

		shownStuff = new FlxTypedGroup<FlxText>();
		
		CatTeam = new FlxTypedGroup<FlxSprite>();
		
        var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.5;
		bg.scrollFactor.set();
		add(bg);
		
		background = new FlxSprite(50, 40).makeGraphic(1180, 670, FlxColor.BLACK);
		background.alpha = 0.5;
		background.scrollFactor.set();
		menu.add(background);
        
		descBack = new FlxSprite(50, 640).makeGraphic(1180, 70, FlxColor.BLACK);
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();
		menu.add(descBack);

		add(menu);

		add(shownStuff);
		
		add(CatTeam);

		for (i in 0...options.length - 1)
		{
			var cat = options[i];
			CatTeam.add(cat);
			add(cat.titleObject);
		}
		
		var langTTF:String = '';		
	    langTTF = OptionsName.setTTF();
		langTTF = langTTF + '.ttf'; //fix

		descText = new FlxText(62, 648);
		descText.setFormat(Paths.font(langTTF), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.antialiasing = ClientPrefs.data.antialiasing;
		descText.borderSize = 2;

		add(descBack);
		add(descText);		
        
		isInMain = true;		
		
		selectedCat = options[0];
		switchCat(selectedCat);
		selectedCatIndex = 0;
		
		selectedOption = selectedCat.options[0];
		selectedOptionIndex = 0;       		              
		
        addVirtualPad(OptionStateC, OptionStateC);        
        addVirtualPadCamera(false);
        
		virtualPad.y -= 75;		
		
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];	
		
		camMouseCheck = new FlxCamera();
		camMouseCheck.bgColor.alpha = 0;
		FlxG.cameras.add(camMouseCheck, false);	
		
		super.create();					
		
		controls.isInSubstate = true;
	}

	public function switchCat(cat:OptionCata, checkForOutOfBounds:Bool = true)
	{
		try
		{
			visibleRange = [Std.int(cat.positionFix + 64), 640]; /*
			/*变量乱七八糟的我都服了，显示你得加64px去修复到开始第2个格下面
			  因为text在positionFix那里还加了偏移
			*/									
			
			startFix = false;
				
			if (selectedOption != null)
			{
				var object = selectedCat.optionObjects.members[selectedOptionIndex];
				object.text = selectedOption.getValue();
			}

			if (selectedCat.middle)
				remove(selectedCat.titleObject);

			selectedCat.changeColor(FlxColor.BLACK);
			selectedCat.alpha = 0.4;

			for (i in 0...selectedCat.options.length)
			{
				var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.positionFix + 54 + (46 * i);
			}

			while (shownStuff.members.length != 0)
			{
				shownStuff.members.remove(shownStuff.members[0]);
			}
			selectedCat = cat;
			selectedCat.alpha = 0.2;
			selectedCat.changeColor(FlxColor.WHITE);

			if (selectedCat.middle)
				add(selectedCat.titleObject);

			for (i in selectedCat.optionObjects)
				shownStuff.add(i);

			selectedOption = selectedCat.options[0];

			if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.positionFix + 54 + (46 * i);
				}
			}

			selectedOptionIndex = 0;

			if (!isInMain)
				selectOption(selectedOption);

			for (i in selectedCat.optionObjects.members)
			{
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					i.alpha = 0.4;
				}
			}
		}
	}

	public function selectOption(option:Option)
	{
		var object = selectedCat.optionObjects.members[selectedOptionIndex];

		selectedOption = option;

		if (!isInMain)
		{
			object.text = option.getValue();

			descText.text = option.getDescription();
		}
	}

    var accept = false;
    var back = false;
	var reset = false;
	 
	var right = false;
	var left = false;
	var up = false;
	var down = false;
	 
	var right_hold = false;
	var left_hold = false;
	var up_hold = false;
	var down_hold = false;
	 
	var anyKey = false;
	 
	var holdTime:Float = 0;	
    var checkTime:Float = 0;	
    var updateTime:Float = 0;
    
    public var closeUpdate:Bool = false;
	 
	override function update(elapsed:Float)
	{	    
	    if (pauseMusic.volume < 0.5)
		pauseMusic.volume += 0.01 * elapsed;
		super.update(elapsed);

		for (c in options) {
			c.titleObject.text = c.title;
			for (o in 0...c.optionObjects.length) {
				c.optionObjects.members[o].text = c.options[o].getValue();
			}
		}
				
		for (numP in 0...options.length - 1) {
			if (FlxG.mouse.justPressed 
			   && FlxG.mouse.getScreenPosition(camMouseCheck).y >= CatTeam.members[numP].y 
    	       && FlxG.mouse.getScreenPosition(camMouseCheck).y <= CatTeam.members[numP].y + CatTeam.members[numP].height
    	       && FlxG.mouse.getScreenPosition(camMouseCheck).x >= CatTeam.members[numP].x 
    	       && FlxG.mouse.getScreenPosition(camMouseCheck).x <= CatTeam.members[numP].x + CatTeam.members[numP].width
    	       ){
			    isInMain = false;		
		        
        		switchCat(options[numP]);
        		selectedCatIndex = numP;
		
        		selectedOption = selectedCat.options[0];
        		selectedOptionIndex = 0;
        		
        		selectedOption.change();       		
        		
        		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
		}		
       
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;		

		accept = controls.ACCEPT;
		right = controls.UI_RIGHT_P;
		left = controls.UI_LEFT_P;
		up = controls.UI_UP_P;
		down = controls.UI_DOWN_P;
		
		right_hold = false;
        left_hold = false;
	    up_hold = false;
		down_hold = false;				
	 
		if (controls.UI_RIGHT_P || controls.UI_LEFT_P || controls.UI_UP_P || controls.UI_DOWN_P){
    		holdTime = 0;		
    		checkTime = 0;
	    	updateTime = 0.1;
		}
		
		if(controls.UI_LEFT || controls.UI_RIGHT)
			{
			    holdTime += elapsed;
			    checkTime += elapsed;
                
				if(holdTime > 0.5 && checkTime >= updateTime){
				    checkTime = 0;
				    if (updateTime > 1 / ClientPrefs.data.framerate)
				    updateTime = updateTime - 0.005;
				    else if (updateTime < 1 / 30)
				    updateTime = 1 / 30;
				    
				    right_hold = controls.UI_RIGHT;
				    left_hold = controls.UI_LEFT;
				    up_hold = controls.UI_UP;
				    down_hold = controls.UI_DOWN;
				}	            
			}

		anyKey = FlxG.keys.justPressed.ANY || (gamepad != null ? gamepad.justPressed.ANY : false);
		back = controls.BACK;
		reset = controls.RESET #if android || virtualPad.buttonC.justPressed #end;
		
			if (isInMain)
			{
				descText.text = "Please select a category";
				if (right)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();

					if ((selectedCatIndex + 1) % 4 == 0)
						selectedCatIndex -= 3;
					else
						selectedCatIndex += 1;

					switchCat(options[selectedCatIndex]);
				}
				else if (left)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					
					if (selectedCatIndex % 4 == 0)
						selectedCatIndex += 3;
					else
						selectedCatIndex -= 1;

					switchCat(options[selectedCatIndex]);
				}				
				else if (up || down)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();				

					if (selectedCatIndex >= 4)
						selectedCatIndex -= 4;
					else
                        selectedCatIndex += 4;
					switchCat(options[selectedCatIndex]);
				}

				if (accept)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					selectedOptionIndex = 0;
					isInMain = false;
					selectOption(selectedCat.options[0]);
					selectedOption.change();
				}

				if (back)
				{
				    ClientPrefs.saveSettings();
				    controls.isInSubstate = true;
				    pauseMusic.pause();
				    close();
				}
			}
			else
			{
				if (selectedOption != null)
					if (selectedOption.acceptType)
					{
						if (back && selectedOption.waitingType)
						{
							FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
							selectedOption.waitingType = false;
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							object.text = selectedOption.getValue();
							return;
						}
						else if (anyKey)
						{
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							selectedOption.onType(gamepad == null ? FlxG.keys.getIsDown()[0].ID.toString() : gamepad.firstJustPressedID());
							object.text = selectedOption.getValue();
						}
					}
				if (selectedOption.acceptType || !selectedOption.acceptType) //这啥玩意这
				{
					if (accept)
					{
					    FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						var prev = selectedOptionIndex;
						var object = selectedCat.optionObjects.members[selectedOptionIndex];																		
           				
						selectedOption.press();
                        selectedOption.change();						
						ClientPrefs.saveSettings();

						object.text = selectedOption.getValue();
					}

					if (down || down_hold)
					{   					    
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						
						var DOWNmoveFix = false;
					    if (selectedOptionIndex == options[selectedCatIndex].options.length - 1 - 5/* && startFix*/) DOWNmoveFix = true;
						
						selectedOptionIndex++;

						if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
						{
						    
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.positionFix + 54 + (46 * i);
							}
							selectedOptionIndex = 0;
							startFix = false;
						}																		

						if (selectedOptionIndex != 0
							&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
							&& options[selectedCatIndex].options.length > 10 
							&& selectedOptionIndex >= 5
							&& (selectedOptionIndex <= options[selectedCatIndex].options.length - 1 - 5 || DOWNmoveFix)
							)
						{
							for (i in selectedCat.optionObjects.members)
							{
								i.y -= 46;
							}							
						}
						
						
						
						moveCheak();

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}
					else if (up || up_hold)
					{
					    
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						
						var UPmoveFix:Bool = false;
						if (selectedOptionIndex == 5/* && !startFix*/) UPmoveFix = true;
						
						selectedOptionIndex--;

						if (selectedOptionIndex < 0)
						{						    
							selectedOptionIndex = options[selectedCatIndex].options.length - 1;
							
                            if (options[selectedCatIndex].options.length > 10)
							for (i in 0...selectedCat.options.length)
							{
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.positionFix + 54 + (46 * (i - (selectedCat.options.length - 10))); 
							}
							startFix = true;
						}																							

						if (selectedOptionIndex != 0 
    						&& options[selectedCatIndex].options.length > 10
    						&& (selectedOptionIndex >= 5 || UPmoveFix)
    						&& selectedOptionIndex <= options[selectedCatIndex].options.length - 1 - 5
    						)						
						{							
								for (i in selectedCat.optionObjects.members)
								{
									i.y += 46;
								}
						}
						
                        
                        
                        moveCheak();
                        
						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}

					if (right || right_hold)
					{
						if (!right_hold) FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.right();
                        selectedOption.change();
						ClientPrefs.saveSettings();
                        
						object.text = selectedOption.getValue();
					}
					else if (left || left_hold)
					{
						if (!left_hold) FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.left();
                        selectedOption.change();
						ClientPrefs.saveSettings();
                        
						object.text = selectedOption.getValue();
					}

					if(reset)
					{					
						resetOptions();
						
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);													
					}

					if (back)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);						
                        
						if (selectedCatIndex >= 9)  //这是干啥用的,但是目前来看没用
							selectedCatIndex = 0;                        
                                                
						for (i in 0...selectedCat.options.length)
						{
							var opt = selectedCat.optionObjects.members[i];
							opt.y = selectedCat.positionFix + 54 + (46 * i);
						}
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();													
						
						if (selectedCat.middle){
						    resetOptionChoose();						    
						}else{
						    isInMain = true;
						}
						
						
						
						if (selectedCat.optionObjects != null){ //别删这个if包含的代码，会出问题
							for (i in selectedCat.optionObjects.members)
							{
								if (i != null)
								{
									if (i.y < visibleRange[0] - 24)
										i.alpha = 0;
									else if (i.y > visibleRange[1] - 24)
										i.alpha = 0;
									else
									{
										i.alpha = 0.4;
									}
								}
						    }
						}    
					}
				}
			}
		
		if (!selectedCat.middle){
		    saveSelectedOptionIndex = selectedOptionIndex;
		    saveSelectedCatIndex = selectedCatIndex;
		    savePosition = Std.int((selectedCat.optionObjects.members[0].y - (selectedCat.positionFix + 54)) / 46);
		}
		
		if (selectedCat != null && !isInMain)
		{
			for (i in selectedCat.optionObjects.members)
			{
				if (selectedCat.middle)
				{
					i.screenCenter(X);
				}

				// I wanna die!!!
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					if (selectedCat.optionObjects.members[selectedOptionIndex].text != i.text)
						i.alpha = 0.4;
					else
						i.alpha = 1;
				}
			}
		}
	}
	
	override function destroy()
	{
		pauseMusic.destroy();
		
		super.destroy();
	}

	function resetOptions() //stupid code but work well
	{
        switch(selectedCatIndex){
        
            case 0:
                ClientPrefs.data.resultsScreen = ClientPrefs.defaultData.resultsScreen;
		ClientPrefs.data.smoothHealth = ClientPrefs.defaultData.smoothHealth;
            case 1:                
                //ClientPrefs.data.hitsoundType = ClientPrefs.defaultData.hitsoundType;
                ClientPrefs.data.hitsoundVolume = ClientPrefs.defaultData.hitsoundVolume;
                ClientPrefs.data.camZooms = ClientPrefs.defaultData.camZooms;
                ClientPrefs.data.scoreZoom = ClientPrefs.defaultData.scoreZoom;
		ClientPrefs.data.smoothScore = ClientPrefs.defaultData.smoothScore;
                ClientPrefs.data.judgementCounter = ClientPrefs.defaultData.judgementCounter;
                ClientPrefs.data.hideHud = ClientPrefs.defaultData.hideHud;
                ClientPrefs.data.opponentStrums = ClientPrefs.defaultData.opponentStrums;
                ClientPrefs.data.showComboNum = ClientPrefs.defaultData.showComboNum;
                ClientPrefs.data.comboColor = ClientPrefs.defaultData.comboColor;
                ClientPrefs.data.comboOffsetFix = ClientPrefs.defaultData.comboOffsetFix;
                ClientPrefs.data.showRating = ClientPrefs.defaultData.showRating;
                ClientPrefs.data.showSplash = ClientPrefs.defaultData.showSplash;
                ClientPrefs.data.splashAlpha = ClientPrefs.defaultData.splashAlpha;
                ClientPrefs.data.healthBarAlpha = ClientPrefs.defaultData.healthBarAlpha;                
            case 2:                
                ClientPrefs.data.pauseMusic = ClientPrefs.defaultData.pauseMusic;               
                ClientPrefs.data.checkForUpdates = ClientPrefs.defaultData.checkForUpdates;
                ClientPrefs.data.discordRPC = ClientPrefs.defaultData.discordRPC;
                ClientPrefs.data.gameOverVibration = ClientPrefs.defaultData.gameOverVibration;
                ClientPrefs.data.screensaver = ClientPrefs.defaultData.screensaver;                                
            case 3:                
                ClientPrefs.data.opponentCodeFix = ClientPrefs.defaultData.opponentCodeFix;
                ClientPrefs.data.botOpponentFix = ClientPrefs.defaultData.botOpponentFix;
                ClientPrefs.data.HealthDrainOPPO = ClientPrefs.defaultData.HealthDrainOPPO;
                ClientPrefs.data.HealthDrainOPPOMult = ClientPrefs.defaultData.HealthDrainOPPOMult;                                
            case 4:
                ClientPrefs.data.CustomFade = ClientPrefs.defaultData.CustomFade;
                ClientPrefs.data.CustomFadeSound = ClientPrefs.defaultData.CustomFadeSound;
                ClientPrefs.data.CustomFadeText = ClientPrefs.defaultData.CustomFadeText;
                ClientPrefs.data.skipTitleVideo = ClientPrefs.defaultData.skipTitleVideo;       
                ClientPrefs.data.freeplayOld = ClientPrefs.defaultData.freeplayOld;                       
            case 5:                
                ClientPrefs.data.controlsAlpha = ClientPrefs.defaultData.controlsAlpha;
                ClientPrefs.data.playControlsAlpha = ClientPrefs.defaultData.playControlsAlpha;                                
            case 6:
                ClientPrefs.data.framerate = ClientPrefs.defaultData.framerate;
                ClientPrefs.data.colorblindMode = ClientPrefs.defaultData.colorblindMode;
                ClientPrefs.data.shaders = ClientPrefs.defaultData.shaders;
                ClientPrefs.data.cacheOnGPU = ClientPrefs.defaultData.cacheOnGPU;
                ClientPrefs.data.loadingScreen = ClientPrefs.defaultData.loadingScreen;     
                ClientPrefs.data.flashing = ClientPrefs.defaultData.flashing;
                ClientPrefs.data.lowQuality = ClientPrefs.defaultData.lowQuality;
                ClientPrefs.data.gameQuality = ClientPrefs.defaultData.gameQuality;
                ClientPrefs.data.antialiasing = ClientPrefs.defaultData.antialiasing;      
                ClientPrefs.data.autoPause = ClientPrefs.defaultData.autoPause;                     
            case 7:                
                ClientPrefs.data.showFPS = ClientPrefs.defaultData.showFPS;                
                ClientPrefs.data.rainbowFPS = ClientPrefs.defaultData.rainbowFPS;
                ClientPrefs.data.FPSScale = ClientPrefs.defaultData.FPSScale;      
                ClientPrefs.data.showExtra = ClientPrefs.defaultData.showExtra;          
                ClientPrefs.data.memoryType = ClientPrefs.defaultData.memoryType;                
                ClientPrefs.data.showWatermark = ClientPrefs.defaultData.showWatermark;
                ClientPrefs.data.WatermarkScale = ClientPrefs.defaultData.WatermarkScale;            
        }
        
        ClientPrefs.saveSettings();
        
        for (mem in 0...selectedCat.length){
            if (selectedCat.options[mem] != null) 
            selectedCat.options[mem].change();
        }
	}
	
	public function resetOptionChoose()  //用于返回原来选择
	{
        isInMain = false;  
        
        selectedCatIndex = saveSelectedCatIndex;
		switchCat(options[saveSelectedCatIndex]);       
		
		selectedOptionIndex = saveSelectedOptionIndex;    					        					
        selectOption(selectedCat.options[saveSelectedOptionIndex]);	
        
        
        if (selectedOptionIndex != 0 
    	&& options[selectedCatIndex].options.length > 10
    	&& selectedOptionIndex >= 5
    	&& selectedOptionIndex <= options[selectedCatIndex].options.length - 1 - 5
    	){
			for (i in 0...selectedCat.options.length)
			{
			    var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.positionFix + 54 + (46 * (i + (selectedOptionIndex - 5))); 
			}
		}
	}
	
	public function moveCheak() //I have no idea to fix kade shit problem so I think this is the best way to fix shit choose problem
	{
        if (options[selectedCatIndex].options.length > 10 && !selectedCat.middle){
            if (selectedCat.optionObjects.members[0].y > selectedCat.positionFix + 54){
                for (i in selectedCat.optionObjects.members){
					i.y -= 46;
				}
                moveCheak(); //check again until not have problem
            }
        
            if (selectedCat.optionObjects.members[selectedCat.options.length - 1].y < selectedCat.positionFix + 54 + 46 * 9){
                for (i in selectedCat.optionObjects.members){
					i.y += 46;
				}
                moveCheak(); //check again until not have problem
            }
        }
	}	
	
	public function changeControlAlpha(){
	    virtualPad.alpha = ClientPrefs.data.controlsAlpha;
	}
}
