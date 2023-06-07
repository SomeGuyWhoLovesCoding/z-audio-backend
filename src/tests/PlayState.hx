package tests;

import openfl.media.Sound;
import flixel.system.ui.FlxSoundTray;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.FlxState;
import zAudio.SoundLoader;
import zAudio.Sound as ZSound;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();
		trace(SoundLoader.fromFile("assets/snd/the funny.wav"));
		var snd = new ZSound(SoundLoader.fromFile("assets/snd/the funny.wav"));
		snd.play();

		//var snd_ = new FlxSound().loadEmbedded(Sound.fromFile("assets/snd/bell.ogg"));
		//snd.play();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
