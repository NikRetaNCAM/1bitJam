package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends FlxState
{
	var level:Int = 0;

	var plWHITE:Player;
	var plBLACK:Player;
	var blackPallet:Bool = true; // aka if BG is black

	var darkObj:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var lightObj:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	override public function create()
	{
		super.create();
		plWHITE = new Player(0, 0, 'WHITE');
		plBLACK = new Player(0, 0, 'BLACK');
		add(plWHITE);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.TAB)
			switchPallet();
	}

	function switchPallet()
	{
		blackPallet = !blackPallet;
		if (blackPallet)
		{
			add(darkObj);
			plWHITE.visible = true;
			plBLACK.visible = false;
		}
		if (!blackPallet)
		{
			add(lightObj);
			plWHITE.visible = true;
			plBLACK.visible = false;
		}
	}
}

class Player extends FlxSprite
{
	var speed:Float = 80;

	public function new(x:Float, y:Float, which:String)
	{
		super(x, y);
		loadGraphic('assets/images/player$which.png', true, 32, 32);

		animation.add('ud_idle', [0]);
		animation.add('ud_run', [1, 2], 12);
		animation.add('lr_idle', [3]);
		animation.add('lr_run', [4, 5], 12);
		setFacingFlip(RIGHT, false, false);
		setFacingFlip(LEFT, true, false);
		drag.x = drag.y = speed * 4;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateMovement();
	}

	function updateMovement()
	{
		var up:Bool = FlxG.keys.pressed.UP;
		var down:Bool = FlxG.keys.pressed.DOWN;
		var left:Bool = FlxG.keys.pressed.LEFT;
		var right:Bool = FlxG.keys.pressed.RIGHT;

		var animtag:String = 'ud';

		var newAngle:Float = 0; // 0 - right; 90 - down; 180 - left; 270 - up

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (up)
		{
			animtag = 'ud';
			newAngle = 270;
			if (left)
				newAngle -= 45;
			if (right)
				newAngle += 45;
		}
		else if (down)
		{
			animtag = 'ud';
			newAngle = 90;
			if (left)
				newAngle += 45;
			if (right)
				newAngle -= 45;
		}
		else if (left)
		{
			animtag = 'lr';
			newAngle = 180;
			facing = LEFT;
		}
		else if (right)
		{
			animtag = 'lr';
			newAngle = 0;
			facing = RIGHT;
		}

		if (left || right || up || down)
		{
			velocity.setPolarDegrees(speed, newAngle);
			animation.play('${animtag}_run');
		}
		else
		{
			animation.play('${animtag}_idle');
		}
	}
}
