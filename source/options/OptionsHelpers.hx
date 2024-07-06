package options;

import sys.FileSystem;
import sys.io.File;

class OptionsHelpers
{
    public static var languageArray = ["English", "简体中文", "繁體中文"];
    public static var qualityArray = ["Low", "Normal", "High", 'Very High'];
	public static var colorblindFilterArray = ['None', 'Protanopia', 'Protanomaly', 'Deuteranopia','Deuteranomaly','Tritanopia','Tritanomaly','Achromatopsia','Achromatomaly'];
    public static var memoryTypeArray = ["Usage", "Reserved", "Current", "Large"];
    public static var hitsoundArray = [];
    public static var TimeBarArray = ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled'];
    public static var PauseMusicArray = ['None', 'Breakfast', 'Tea Time'];
    public static var fileLoadArray = ["NovaFlare Engine", "NF Engine", "PsychEngine", "OS Engine", "TG Engine", "SB Engine"];
	public static var colorArray:Array<FlxColor> = [FlxColor.BLACK,FlxColor.WHITE,FlxColor.GRAY,FlxColor.RED,FlxColor.GREEN,FlxColor.BLUE,FlxColor.YELLOW,FlxColor.PINK,FlxColor.ORANGE,FlxColor.PURPLE,FlxColor.BROWN,FlxColor.CYAN];
	public static var colorStingArray = ['BLACK', 'WHITE', 'GRAY', 'RED', 'GREEN', 'BLUE', 'YELLOW', 'PINK', 'ORANGE', 'PURPLE', 'BROWN', 'CYAN'];
	
    static public function setNoteSkin()
    {
        var noteSkins:Array<String> = [];
		if(Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared').length > 0)
			noteSkins = Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared');
		else
			noteSkins = CoolUtil.coolTextFile(Paths.getSharedPath('shared/images/noteSkins/list.txt'));
			
		if(noteSkins.length > 0)
		{
		    noteSkins.insert(0, ClientPrefs.defaultData.noteSkin);
		    
			if(!noteSkins.contains(ClientPrefs.data.noteSkin)){
				ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; //Reset to default if saved noteskin couldnt be found
				NoteSkin.chooseNum = 0;
            }else{
                for (i in 0...noteSkins.length - 1){
                    if (ClientPrefs.data.noteSkin == noteSkins[i])
                        NoteSkin.chooseNum = i;
                }
            }
		}else{
		    ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin;
		    NoteSkin.chooseNum = 0;
		}
    }
    
    static public function changeNoteSkin()
    {
        var noteSkins:Array<String> = [];
		if(Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared').length > 0)
			noteSkins = Mods.mergeAllTextsNamed('images/noteSkins/list.txt', 'shared');
		else
			noteSkins = CoolUtil.coolTextFile(Paths.getSharedPath('shared/images/noteSkins/list.txt'));
			
		if(noteSkins.length > 0)
		{
		    noteSkins.insert(0, ClientPrefs.defaultData.noteSkin);
		
		    if (NoteSkin.chooseNum < 0) NoteSkin.chooseNum = noteSkins.length - 1;
		    if (NoteSkin.chooseNum > noteSkins.length - 1) NoteSkin.chooseNum = 0;
		    
			if(!noteSkins.contains(ClientPrefs.data.noteSkin)){
				ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; //Reset to default if saved noteskin couldnt be found
				NoteSkin.chooseNum = 0;
            }else{
                ClientPrefs.data.noteSkin = noteSkins[NoteSkin.chooseNum];
            }
		}else{
		    ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin;
		    NoteSkin.chooseNum = 0;
		}
    }
    
    static public function setSplashSkin()
    {
        var noteSplashes:Array<String> = [];
		if(Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared').length > 0)
			noteSplashes = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');
		else
			noteSplashes = CoolUtil.coolTextFile(Paths.getSharedPath('shared/images/noteSplashes/list.txt'));
			
		if(noteSplashes.length > 0)
		{
		    noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin);
		    
			if(!noteSplashes.contains(ClientPrefs.data.splashSkin)){
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved noteskin couldnt be found
				SplashSkin.chooseNum = 0;
            }else{
                for (i in 0...noteSplashes.length - 1){
                    if (ClientPrefs.data.splashSkin == noteSplashes[i])
                        SplashSkin.chooseNum = i;
                }
            }
		}else{
		    ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin;
		    SplashSkin.chooseNum = 0;
		}
    }
    
    static public function changeSplashSkin()
    {
        var noteSplashes:Array<String> = [];
		if(Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared').length > 0)
			noteSplashes = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt', 'shared');
		else
			noteSplashes = CoolUtil.coolTextFile(Paths.getSharedPath('shared/images/noteSplashes/list.txt'));
			
		if(noteSplashes.length > 0)
		{
		    noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin);
		
		    if (SplashSkin.chooseNum < 0) SplashSkin.chooseNum = noteSplashes.length - 1;
		    if (SplashSkin.chooseNum > noteSplashes.length - 1) SplashSkin.chooseNum = 0;
		    
			if(!noteSplashes.contains(ClientPrefs.data.splashSkin)){
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved noteskin couldnt be found
				SplashSkin.chooseNum = 0;
            }else{
                ClientPrefs.data.splashSkin = noteSplashes[SplashSkin.chooseNum];
            }
		}else{
		    ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin;
		    SplashSkin.chooseNum = 0;
		}
    }
    
    static public function setHitSoundType()
    {        
        hitsoundArray = [];
        hitsoundArray.push(ClientPrefs.defaultData.hitsoundType);
               
        for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'sounds/hitsounds/'))
			for (file in FileSystem.readDirectory(folder))
			{				
				if(file.endsWith('.ogg'))
					hitsoundArray.push(file.replace('.ogg', ''));				
			}
		if(!hitsoundArray.contains(ClientPrefs.data.hitsoundType)){
			ClientPrefs.data.hitsoundType = ClientPrefs.defaultData.hitsoundType;
			HitSoundType.chooseNum = 0;
        }else{
	        for (i in 0...hitsoundArray.length)
	            if (ClientPrefs.data.hitsoundType == hitsoundArray[i]) HitSoundType.chooseNum = i;
	    }
	    if (HitSoundType.chooseNum >= hitsoundArray.length) HitSoundType.chooseNum = 0;
    }
    
    static public function changeHitSoundType()
    {        
        if (HitSoundType.chooseNum < 0) HitSoundType.chooseNum = hitsoundArray.length - 1;
		if (HitSoundType.chooseNum > hitsoundArray.length - 1) HitSoundType.chooseNum = 0;
		ClientPrefs.data.hitsoundType = hitsoundArray[HitSoundType.chooseNum];
		
		if (ClientPrefs.data.hitsoundType == ClientPrefs.defaultData.hitsoundType) FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
		else FlxG.sound.play(Paths.sound('hitsounds/' + ClientPrefs.data.hitsoundType), ClientPrefs.data.hitsoundVolume);
    }
    
    static public function setTimeBarType()
    {        
        if(!TimeBarArray.contains(ClientPrefs.data.timeBarType)){
			ClientPrefs.data.timeBarType = ClientPrefs.defaultData.timeBarType; //Reset to default if saved noteskin couldnt be found
			NoteSkin.chooseNum = 0;
        }else{
            for (i in 0...TimeBarArray.length - 1){
                if (ClientPrefs.data.timeBarType == TimeBarArray[i])
                    TimeBarType.chooseNum == i;
            }
        }
    }
    
    static public function changeTimeBarType()
    {
        if (TimeBarType.chooseNum < 0) TimeBarType.chooseNum = TimeBarArray.length - 1;
		if (TimeBarType.chooseNum > TimeBarArray.length - 1) TimeBarType.chooseNum = 0;
		
		ClientPrefs.data.timeBarType = TimeBarArray[TimeBarType.chooseNum];
		
		
    }
    
    static public function setPauseMusicType()
    {        
        if (!PauseMusicArray.contains(ClientPrefs.data.pauseMusic)){
			ClientPrefs.data.pauseMusic = ClientPrefs.defaultData.pauseMusic; //Reset to default if saved noteskin couldnt be found
			PauseMusic.chooseNum = 0;
        }else{
            for (i in 0...PauseMusicArray.length - 1){
                if (ClientPrefs.data.timeBarType == PauseMusicArray[i])
                    PauseMusic.chooseNum == i;
            }
        }
    }
    
    static public function changePauseMusicType()
    {
        if (PauseMusic.chooseNum < 0) PauseMusic.chooseNum = PauseMusicArray.length - 1;
		if (PauseMusic.chooseNum > PauseMusicArray.length - 1) PauseMusic.chooseNum = 0;
		
		ClientPrefs.data.pauseMusic = PauseMusicArray[PauseMusic.chooseNum];
    }
    
}

class OptionsName
{
    public static function setTTF():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "vcr";
			case 1: //chinese
			    return "vcr-CH";
			case 2: //chinese
			    return "vcr-CH";    
		}					
		return "vcr";
    }
    
    //--------------TTF SETTING------------------------//
    
    public static function funcDisable():String{
	    switch (ClientPrefs.data.language)
	    {
			case 0: //english
			return 'Disabled';
			case 1: //chinese
			return '禁用';
			case 2: //chinese
			return '禁用';
		}			
		return 'Disabled';
	}
	
	public static function funcEnable():String{
	    switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return 'Enabled';
			case 1: //chinese
			    return '启用';
			case 2: //chinese
			    return '啟用';    
		}			
		return 'Enabled';
	}
	
	public static function funcMS():String{
	    switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return 'MS';
			case 1: //chinese
			    return '毫秒';
			case 2: //chinese
			    return '毫秒';    
		}			
		return 'MS';
	}
	
	public static function funcGrid():String{
	    switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return 'Grid';
			case 1: //chinese
			    return '格';
			case 2: //chinese
			    return '格';    
		}			
		return 'Grid';
	}
	
	//----------OPTION SETTING------------------------//

    public static function setGameplay():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "Gameplay";
			case 1: //chinese
			    return "游玩设置";
			case 2: //chinese
			    return "遊玩設置";    
		}					
		return "Gameplay";
    }
    
    public static function setAppearance():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "Appearance";
			case 1: //chinese
			    return "视图";
			case 2: //chinese
			    return "視圖";    
		}					
		return "Appearance";
    }
    
    public static function setMisc():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "Misc";
			case 1: //chinese
			    return "杂项";
			case 2: //chinese
			    return "雜項";    
		}					
		return "Misc";
    }
    
    public static function setOpponentMode():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "Opponent";
			case 1: //chinese
			    return "对手设置";
			case 2: //chinese
			    return "對手設置";    
		}					
		return "Opponent Mode";
    }
    
    public static function setMenuExtend():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "Menu Extend";
			case 1: //chinese
			    return "主菜单扩展";
			case 2: //chinese
			    return "主菜單擴展";    
		}					
		return "Menu Extend";
    }
    
    public static function setControls():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "Controls";
			case 1: //chinese
			    return "摁键设置";
			case 2: //chinese
			    return "摁鍵設置";    
		}					
		return "Controls";
    }
    
    //----------OPTION CAP------------------------//
    
    public static function setDownscrollOption():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "Toggle making the notes scroll down rather than up.";
			case 1: //chinese
			    return "让note从上往下接触判定线";
			case 2: //chinese
			    return "讓note從上往下接觸判定線";    
		}				
		return "Toggle making the notes scroll down rather than up.";
    }
    
    public static function displayDownscrollOption():String{
        switch (ClientPrefs.data.language)
	    {
			case 0: //english
			    return "Downscroll";
			case 1: //chinese
			    return "下落式";
			case 2: //chinese
			    return "下落式";    
		}					
		return "Downscroll";
    }
    
    //----------OPTION OptionCata------------------------//
    
    
    
}