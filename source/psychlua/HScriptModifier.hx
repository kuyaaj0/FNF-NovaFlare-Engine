package psychlua;
// @author Riconuts


import objects.playfields.NoteField;
import psychlua.HScript;
import psychlua.Modifier;
import objects.StrumNote;
import math.Vector3;

class HScriptModifier extends Modifier
{
	public var script:HScript;
	public var name:String = "unknown";

	public function new(modMgr:ModManager, ?parent:Modifier, script:HScript) 
	{
		this.psychlua = psychlua;
		this.modMgr = modMgr;
		this.parent = parent;

		psychlua.set("this", this);
		psychlua.set("modMgr", this.modMgr);
		psychlua.set("parent", this.parent);
		psychlua.set("getValue", getValue);
		psychlua.set("getPercent", getPercent);
		psychlua.set("getSubmodValue", getSubmodValue);
		psychlua.set("getSubmodPercent", getSubmodPercent);
		psychlua.set("setValue", setValue);
		psychlua.set("setPercent", setPercent);
		psychlua.set("setSubmodValue", setSubmodValue);
		psychlua.set("setSubmodPercent", setSubmodPercent);

		psychlua.executeFunc("onCreate");

		super(this.modMgr, this.parent);

		psychlua.executeFunc("onCreatePost");
	}

	@:noCompletion
	private static final _scriptEnums:Map<String, Dynamic> = [
		"NOTE_MOD" => NOTE_MOD,
		"MISC_MOD" => MISC_MOD,

		"FIRST" => FIRST,
		"PRE_REVERSE" => PRE_REVERSE,
		"REVERSE" => REVERSE,
		"POST_REVERSE" => POST_REVERSE,
		"DEFAULT" => DEFAULT,
		"LAST" => LAST
	];

	public static function fromString(modMgr:ModManager, ?parent:Modifier, scriptSource:String):HScriptModifier
	{
		return new HScriptModifier(
			modMgr, 
			parent, 
			HScript.fromString(scriptSource, "HScriptModifier", _scriptEnums, false)
		);
	}

	public static function fromName(modMgr:ModManager, ?parent:Modifier, psychluaName:String):Null<HScriptModifier>
	{		
		var filePath:String = Paths.getHScriptPath('modifiers/$psychluaName');
		if(filePath == null){
			trace('Modifier script: $psychluaName not found!');
			return null;
		}

		var mod = new HScriptModifier(
			modMgr, 
			parent, 
			FunkinHScript.fromFile(filePath, filePath, _scriptEnums, false)
		);
		mod.name = psychluaName;
		return mod;

	}

	//// this is where a macro could have helped me, if i weren't so stupid.
	// lol i'll probably rewrite this to use a macro dont worry bb

	override public function getModType()
		return psychlua.exists("getModType") ? psychlua.executeFunc("getModType") : super.getModType();

	override public function ignorePos()
		return psychlua.exists("ignorePos") ? psychlua.executeFunc("ignorePos") : super.ignorePos();

	override public function ignoreUpdateReceptor()
		return psychlua.exists("ignoreUpdateReceptor") ? psychlua.executeFunc("ignoreUpdateReceptor") : super.ignoreUpdateReceptor();

	override public function ignoreUpdateNote()
		return psychlua.exists("ignoreUpdateNote") ? psychlua.executeFunc("ignoreUpdateNote") : super.ignoreUpdateNote();

	override public function doesUpdate()
		return psychlua.exists("doesUpdate") ? psychlua.executeFunc("doesUpdate") : super.doesUpdate();

	override public function shouldExecute(player:Int, value:Float):Bool
		return psychlua.exists("shouldExecute") ? psychlua.executeFunc("shouldExecute", [player, value]) : super.shouldExecute(player, value);

	override public function getOrder():Int
		return psychlua.exists("getOrder") ? psychlua.executeFunc("getOrder") : super.getOrder();

	override public function getName():String
		return psychlua.exists("getName") ? psychlua.executeFunc("getName") : name;

	override public function getSubmods():Array<String>
		return psychlua.exists("getSubmods") ? psychlua.executeFunc("getSubmods") : super.getSubmods();

	override public function updateReceptor(beat:Float, receptor:StrumNote, player:Int) 
		return psychlua.exists("updateReceptor") ? psychlua.executeFunc("updateReceptor", [beat, receptor, player]) : super.updateReceptor(beat, receptor, player);

	override public function updateNote(beat:Float, note:Note, player:Int)
		return psychlua.exists("updateNote") ? psychlua.executeFunc("updateNote", [beat, note, player]) : super.updateNote(beat, note, player);

	override public function getPos(diff:Float, tDiff:Float, beat:Float, pos:Vector3, data:Int, player:Int, obj:NoteObject, field:NoteField):Vector3 
		return psychlua.exists("getPos") ? psychlua.executeFunc("getPos", [diff, tDiff, beat, pos, data, player, obj, field]) : super.getPos(diff, tDiff, beat, pos, data, player, obj, field);

	override public function modifyVert(beat:Float, vert:Vector3, idx:Int, obj:NoteObject, pos:Vector3, player:Int, data:Int, field:NoteField):Vector3 
		return psychlua.exists("modifyVert") ? psychlua.executeFunc("modifyVert",
			[beat, vert, idx, obj, pos, player, data, field]) : super.modifyVert(beat, vert, idx, obj, pos, player, data, field);

	override public function getExtraInfo(diff:Float, tDiff:Float, beat:Float, info:RenderInfo, obj:NoteObject, player:Int, data:Int):RenderInfo
	{
		return psychlua.exists("getExtraInfo") ? psychlua.executeFunc("getExtraInfo",
			[diff, tDiff, beat, info, obj, player, data]) : super.getExtraInfo(diff, tDiff, beat, info, obj, player, data);
	}

	override public function update(elapsed:Float, beat:Float) 
		return psychlua.exists("update") ? psychlua.executeFunc("update", [elapsed, beat]) : super.update(elapsed, beat);

	override public function isRenderMod():Bool 
		return psychlua.exists("isRenderMod") ? psychlua.executeFunc("isRenderMod") : super.isRenderMod();
}
