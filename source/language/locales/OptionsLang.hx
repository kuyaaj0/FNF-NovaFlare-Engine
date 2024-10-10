package language.locales;

import haxe.Json;

typedef OptionData =
{
    Reset:String,
    //==General==\\
    General:String,
    framerate:String,
    language:String,
    colorblindMode:String,
    lowQuality:String, 
    gameQuality:String,
    antialiasing:String, 
    flashing:String, 
    shaders:String, 
    cacheOnGPU:String, 
    autoPause:String, 

    //==Gameplay==\\
    Gameplay:String, 
    ////////
    downScroll:String,
    middleScroll:String,
    flipChart:String, 
    ghostTapping:String, 
    guitarHeroSustains:String,
    noReset:String, 
    ////////
    Opponent:String, 
    ////////
    playOpponent:String, 
    opponentCodeFix:String, 
    botOpponentFix:String, 
    HealthDrainOPPO:String,
    HealthDrainOPPOMult:String, 

    //==Backend==\\
    Backend:String, 
    Gameplaybackend:String, 
    fixLNL:String, 
    pauseMusic:String, 
    hitsoundType:String, 
    hitsoundVolume:String,
    oldHscriptVersion:String, 
    pauseButton:String,
    gameOverVibration:String, 
    ratingOffset:String, 
    NoteOffsetState:String, 
    safeFrames:String, 
    marvelousWindow:String, 
    sickWindow:String, 
    goodWindow:String, 
    badWindow:String, 
    marvelousRating:String, 
    marvelousSprite:String, 
    ////////
    Appbackend:String, 
    ////////
    discordRPC:String, 
    checkForUpdates:String, 
    screensaver:String, 
    filesCheck:String,

    //==Game UI==\\
    GameUI:String, 
    GameUITitle:String, 
    ////////
    Visble:String,
    ////////
    hideHud:String, 
    showComboPopup:String, 
    showComboNum:String, 
    showRating:String, 
    opponentStrums:String, 
    judgementCounter:String, 
    judgementZoom:String, 
    keyboardDisplay:String, 
    ////////
    TimeBar:String, 
    ////////
    timeBarType:String, 
    ////////
    HealthBar:String, 
    healthBarAlpha:String, 
    oldHealthBarVersion:String, 
    ////////
    Combo:String, 
    ////////
    comboColor:String, 
    comboOffsetFix:String, 
    ////////
    KeyBoard:String, 
    ////////
    keyboardAlpha:String, 
    keyboardTime:String, 
    keyboardTimeDisplay:String,
    keyboardBGColor:String, 
    keyboardTextColor:String, 
    ////////
    Camera:String, 
    ////////
    camZooms:String, 
    scoreZoom:String, 
    ////////
    Tweens:String,
    ////////
    tweenableTimeTxt:String, 
    tweenableScoreTxt:String, 

    //==Skin==\\
    Skin:String, 
    ////////
    Note:String, 
    noteSkin:String,
    noteRGB:String, 
    NotesSubState:String, 
    ////////
    Splash:String, 
    ////////
    splashSkin:String,
    splashRGB:String, 
    showSplash:String, 
    splashAlpha:String, 

    //==Input==\\
    Input:String, 
    ////////
    ControlsSubState:String, 
    ////////
    TouchMain:String,
    ////////
    needMobileControl:String, 
    controlsAlpha:String,
    ////////
    TouchGame:String, 
    ////////
    MobileControlSelectSubState:String, 
    dynamicColors:String, 
    hitboxLocation:String,
    playControlsAlpha:String,
    extraKey:String, 
    MobileExtraControl:String, 



    //==Smooth Option==\\
    SmoothOption:String,
    SmoothOptionTitle:String,
    ////////
    smoothhealthearlyaccess:String,
    ////////
    smoothHealth:String,
    ////////
    EarlyAccess:String,
    ////////
    smoothScore:String,


    //==User Interface==\\
    UserInterface:String, 
    UserInterfaceTitle:String, 
    ////////
    CustomFade:String, 
    CustomFadeSound:String, 
    CustomFadeText:String, 
    skipTitleVideo:String, 
    audioDisplayQuality:String,
    freeplayOld:String, 
    resultsScreen:String, 
    loadingScreen:String, 



    //==Watermark==\\
    Watermark:String, 
    ////////
    FPScounter:String, 
    ////////
    showFPS:String, 
    showExtra:String, 
    rainbowFPS:String, 
    memoryType:String, 
    FPSScale:String, 

    showWatermark:String,
    WatermarkScale:String
}

class OptionsLang
{
    static var data:OptionData;

    static public function get(value:String):String {
        return Reflect.getProperty(data, value);
    }

    static public function updateLang() {
        try{
            data = Json.parse(Paths.getTextFromFile('language/' + ClientPrefs.data.language + '/options.json'));
        } catch(e:Any) {
            try{
                data = Json.parse(Paths.getTextFromFile('language/' + 'English' + '/options.json'));
            }
        }
    }
}
