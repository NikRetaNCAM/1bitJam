package;

import flixel.FlxG;
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
		plWHITE = new Player(0, 0, 'WHITE');
		plBLACK = new Player(0, 0, 'BLACK');
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

		animation.add('ud_idle', [0]);
		animation.add('ud_run', [1, 2]);
		animation.add('lr_idle', [3]);
		animation.add('lr_run', [4, 5]);
		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
	}

	override public function update(elapsed:Float)
	{
		updateMovement();
	}

	function updateMovement()
	{
		var up:Bool = FlxG.keys.pressed.UP;
		var down:Bool = FlxG.keys.pressed.DOWN;
		var left:Bool = FlxG.keys.pressed.LEFT;
		var right:Bool = FlxG.keys.pressed.RIGHT;

		var newAngle:Float = 0; // 0 - right; 90 - down; 180 - left; 270 - up

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up)
		{
			newAngle = 270;
			if (left)
				newAngle -= 45;
			if (right)
				newAngle += 45;
		}
		else if (down)
		{
			newAngle = 90;
			if (left)
				newAngle += 45;
			if (right)
				newAngle -= 45;
		}
	}
}
