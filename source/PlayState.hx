package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var level:Int = 0;

	var players:FlxTypedGroup<Player> = new FlxTypedGroup();
	var plWHITE:Player;
	var plBLACK:Player;
	var blackPallet:Bool = true; // aka if BG is black

	var darkObj:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var lightObj:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	override public function create()
	{
		super.create();

		map = new FlxOgmo3Loader(AssetPaths.main__ogmo, 'assets/data/lvl_$level.json'); // loading the level
		walls = map.loadTilemap(AssetPaths.tileset__png, 'walls');
		add(walls);

		map.loadEntities(entitiesLoad, 'entities'); // >:(

		walls.setTileProperties(0, NONE); // holy shit 0.0
		walls.setTileProperties(1, ANY);
		walls.setTileProperties(2, ANY);
		walls.setTileProperties(3, ANY);
		walls.setTileProperties(4, NONE);
		walls.setTileProperties(5, ANY);
		walls.setTileProperties(6, ANY);
		walls.setTileProperties(7, ANY);
		walls.setTileProperties(8, NONE);
		walls.setTileProperties(9, ANY);
		walls.setTileProperties(10, ANY);
		walls.setTileProperties(11, ANY);
		walls.follow();

		FlxG.camera.follow(plWHITE);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(players, walls);
		if (FlxG.keys.justPressed.TAB) // do i have to say anything? -.-
			switchPallet();
	}

	function entitiesLoad(entity:EntityData)
	{
		switch (entity.name)
		{
			case 'player':
				plWHITE = new Player(entity.x, entity.y, 'WHITE'); // setting up the player(s)
				plBLACK = new Player(entity.x, entity.y, 'BLACK'); // WHITE/BLACK refers to outline!
				players.add(plWHITE);
				players.add(plBLACK);
				plWHITE.visible = true;
				plBLACK.visible = false;
				add(players);
		}
	}

	function switchPallet() // ? <-- this is a question mark.
	{
		blackPallet = !blackPallet;
		if (blackPallet) // if bg is switched to black
		{
			bgColor = FlxColor.BLACK;
			// add(walls);
			remove(lightObj);
			add(darkObj);
			plWHITE.visible = true;
			plBLACK.visible = false;
		}
		if (!blackPallet) // if bg is switched to white
		{
			bgColor = FlxColor.WHITE;
			// remove(walls);
			remove(darkObj);
			add(lightObj);
			plWHITE.visible = false;
			plBLACK.visible = true;
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
