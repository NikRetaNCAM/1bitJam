package;

import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	var level:Int = 0;

	var plWHITE:Player;
	var plBLACK:Player;

	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

class Player extends FlxSprite
{
	public function new(x:Float, y:Float, which:String)
	{
		super(x, y);
		loadGraphic('assets/images/player$which.png', true, 32, 32);
	}

	override public function update(elapsed:Float) {}
}
