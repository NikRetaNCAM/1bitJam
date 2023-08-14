package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.text.FlxTypeText;
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

	var isDial:Bool = false;
	var dialLine:Int = 0;
	var dialText:FlxTypeText;

	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	var whiteBlocks:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var blackBlocks:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var buttons:FlxTypedGroup<Button> = new FlxTypedGroup();
	var boxes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var powblocks:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

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

		if (needDialogue())
			doDial();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(players, walls);

		if (FlxG.keys.justPressed.TAB) // do i have to say anything? -.-
			switchPallet();

		if (isDial && FlxG.keys.justPressed.ENTER)
		{
			dialLine++;
			doDial();
		}

		if (blackPallet) // BLACK BG
		{
			if (plBLACK.x != plWHITE.x || plBLACK.y != plWHITE.y)
			{
				// plBLACK.setPosition(plWHITE.x, plWHITE.y);
				plWHITE.setPosition(plBLACK.x, plBLACK.y);
			}

			FlxG.collide(whiteBlocks, players);
		}
		if (!blackPallet) // WHITE BG
		{
			if (plBLACK.x != plWHITE.x || plBLACK.y != plWHITE.y)
			{
				// plWHITE.setPosition(plBLACK.x, plBLACK.y);
				plBLACK.setPosition(plWHITE.x, plWHITE.y);
			}

			FlxG.collide(blackBlocks, players);
		}

		FlxG.collide(boxes, players);
		FlxG.collide(boxes, walls);

		for (i in buttons) // bad way of checking this!!
		{
			if (i.overlaps(boxes) && !i.isPressed || i.overlaps(players) && !i.isPressed) // ??????
			{
				i.isPressed = true;
				switch (i.connect) // check target type
				{
					case 'powblock':
						for (j in powblocks)
						{
							if (j.x == i.tar_x && j.y == i.tar_y) // check target pos
							{
								j.visible = false;
							}
						}
				}
			}
			if (!i.overlaps(boxes) && !i.overlaps(players) && i.isPressed)
			{
				i.isPressed = false;
				switch (i.connect)
				{
					case 'powblock':
						for (j in powblocks)
						{
							if (j.x == i.tar_x && j.y == i.tar_y) // check target pos
							{
								j.visible = true;
							}
						}
				}
			}
		}

		FlxG.overlap(powblocks, players, function sep(powbl, pl) // this checks if powblock is visible and if so, activates collision
		{
			FlxObject.separate(powbl, pl);
		}, function check(pow, pl)
		{
			if (pow.visible)
				return true;
			else
				return false;
		});
	}

	function needDialogue():Bool
	{
		var retValue:Bool = false;

		switch (level)
		{
			case 0:
				retValue = true;
		}

		return retValue;
	}

	function doDial()
	{
		isDial = true;
		var dial:Array<String> = [''];
		switch (level) // THE part
		{
			case 0:
				dial = [
					'hi\n-enter-',
					'move around\n-arrow keys-',
					'use the lightswitch\n-tab-',
					'you should solve the puzzle,\n-N O W-'
				];
		}
		remove(dialText);

		if (dialLine >= dial.length) // should work :/
			return;

		dialText = new FlxTypeText(0, 0, 600, dial[dialLine], 16);
		dialText.screenCenter();
		dialText.y -= 75;
		dialText.alignment = CENTER;
		dialText.scrollFactor.set(0, 0);
		add(dialText);
		dialText.start(0.125);
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

				add(whiteBlocks);
				remove(blackBlocks);
				add(buttons);
				add(boxes);
				add(powblocks);
				buttons.visible = true;
				boxes.visible = false;

				add(players);
			case 'block':
				var newBlock:FlxSprite = new FlxSprite(entity.x, entity.y);
				newBlock.immovable = true;
				if (entity.values.color == 'black')
				{
					newBlock.makeGraphic(32, 32, FlxColor.BLACK);
					blackBlocks.add(newBlock);
				}
				else if (entity.values.color == 'white')
				{
					newBlock.makeGraphic(32, 32, FlxColor.WHITE);
					whiteBlocks.add(newBlock);
				}
			case 'button':
				var newButt = new Button(entity.x, entity.y, entity.values.connect, entity.values.tar_x, entity.values.tar_y);
				newButt.loadGraphic('assets/images/button.png');
				buttons.add(newButt);
			case 'boxSpawn':
				var newBox = new FlxSprite(entity.x, entity.y);
				newBox.loadGraphic('assets/images/box.png');
				newBox.drag.x = 240;
				newBox.drag.y = 240;
				boxes.add(newBox);
			case 'powBlock':
				var powBlock = new FlxSprite(entity.x, entity.y);
				powBlock.loadGraphic('assets/images/powblock.png', true, 32, 32);
				powBlock.animation.add('white', [0]);
				powBlock.animation.add('black', [1]);
				powBlock.animation.play('white');
				powBlock.immovable = true;
				powblocks.add(powBlock);
		}
	}

	function switchPallet() // ? <-- this is a question mark.
	{
		blackPallet = !blackPallet;
		if (blackPallet) // if bg is switched to black
		{
			dialText.color = FlxColor.WHITE;
			bgColor = FlxColor.BLACK;
			// add(walls);
			/*remove(lightObj);
				add(darkObj); */
			add(whiteBlocks);
			remove(blackBlocks);
			for (i in powblocks)
				i.animation.play('white');

			walls.color = FlxColor.WHITE;

			buttons.visible = true;
			boxes.visible = false;

			plWHITE.visible = true;
			plBLACK.visible = false;
		}
		if (!blackPallet) // if bg is switched to white
		{
			dialText.color = FlxColor.BLACK;
			bgColor = FlxColor.WHITE;
			// remove(walls);
			/*remove(darkObj);
				add(lightObj); */
			add(blackBlocks);
			remove(whiteBlocks);
			for (i in powblocks)
				i.animation.play('black');

			walls.color = FlxColor.BLACK;

			buttons.visible = false;
			boxes.visible = true;

			plWHITE.visible = false;
			plBLACK.visible = true;
		}
	}
}

class Button extends FlxSprite
{
	public var connect:String = 'powblock';
	public var tar_x:Float = 0;
	public var tar_y:Float = 0;

	public var isPressed:Bool = false;

	public function new(x:Float, y:Float, pconnect:String, ptx:Float, pty:Float)
	{
		super(x, y);
		connect = pconnect;
		tar_x = ptx;
		tar_y = pty;
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

		setSize(24, 24);
		offset.set(4, 4);
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
