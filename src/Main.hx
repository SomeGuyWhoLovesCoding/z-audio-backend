package;

import haxe.Timer;
import zAudio.SoundLoader;
import zAudio.Sound;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, tests.PlayState));

		var snd = new Sound(SoundLoader.fromFile("assets/snd/inspected.mp3"));
		snd.play();

		Timer.delay(() -> {
			snd.stop();
		}, 10);
	}
}
