package zAudio;

import lime.app.Application;
import lime.ui.Window;
import lime.media.AudioManager;
import lime._internal.backend.native.NativeApplication;

/**
 * Class responsible for global sound handling and memory management.
 */
class SoundHandler {
    //public static var activeSounds:Array<Sound> = [];
    /**
     * All preloaded Buffers mapped to their assigned files, to avoid duplicates.
     */
    public static var existingBufferData:Map<String, BufferHandle> = [];
    /**
     * If true, audio playback is paused on every unfocused window (or just the main window if you only have one).
     * 
     * The playback resumes once the window has been focused.
     * 
     * It is highly recommended this is set to true if the rest of your application also pauses when a window is unfocused
     * to prevent audio desyncing.
     */
    private static inline var foc_lost_def:Bool = true;
	public static var focusLost_pauseSnd(default, set):Bool = foc_lost_def;

    private static var windowEvents:Map<String, Bool> = [];

    /**
     * Sets up the zAudio backend, should be called on Main `before` starting your game
	 * and `after` all SoundHandler options have been set to your preferred choice.
     */
    public static function init() {

        //Initialize all settings on startup.
        //We dont trigger the setter twice as these are only triggered if the variable has the same value (which doesnt activate the setter)
		if(focusLost_pauseSnd == foc_lost_def) change_focusLost_pauseSnd();
    }

    /**
     * A map containing all paths to sounds you want to keep cached after a `clear_bufferCache` call.
     * 
     * Every path in this map needs to be removed manually, so keep that in mind.
     *
     * Simply do `keepCacheSounds.set("yourAsset_orWebPath.wav_or_ogg", true)` to keep a sound safe from general buffer cache clearing.
     * 
     * `removeFromCache` will remove a sound from cache regardless of if its kept in here!
     */
    public static var keepCacheSounds:Map<String, Bool> = [];
    /**
     * Simply clears the entire `existingBufferData` cache, with the exception of all paths in `keepCacheSounds`.
     * 
     * This function force-calls the garbage collector.
     */
    public static function clear_bufferCache():Void {
        for(n => buf in existingBufferData) {
            if(keepCacheSounds[n] != null) continue;

            existingBufferData.remove(n);
            buf.destroy();
            buf = null;
        }
        cpp.vm.Gc.compact();
        cpp.vm.Gc.run(true);
    }

    /**
     * Removes the sound stored at `path` from the cache.
     * 
     * If no sound stored at `path` is found in the cache, this function will throw a Null Object Reference.
     * 
     * If you need to check whether this is the case, use `existsInCache`.
     * 
     * This function does not force-call the garbage collector.
     */
    public static function removeFromCache(path:String):Void {
        var buf = existingBufferData[path];
        
        if(keepCacheSounds[path] != null) keepCacheSounds.remove(path);
        existingBufferData.remove(path);
        buf.destroy();
        buf = null;
    }

    /**
     * Removes the sound `snd` from the memory entirely, creating space for other things.
     * 
     * This function renders the `snd` unusable as it is destroyed.
     * 
     * This function will also automatically collect all other destroyed sounds (as it simply calls the garbage collector).
     * 
     * @param snd The snd you want to ensure is removed from memory.
     */
    public static function clearFromMemory(snd:Sound) {
        snd.destroy();
        cpp.vm.Gc.compact();
        cpp.vm.Gc.run(true);
    }

    /**
     * Returns true if a sound stored at `path` is found in the cache, otherwise false.
     */
    public static function existsInCache(path:String):Bool return existingBufferData[path] != null;

    static function set_focusLost_pauseSnd(val:Bool):Bool {
		final changed:Bool = focusLost_pauseSnd == val;
		if (!changed) return val;
		focusLost_pauseSnd = val;

        change_focusLost_pauseSnd();
        return val;
    }
    private static function change_focusLost_pauseSnd() {
        @:privateAccess {
            switch(focusLost_pauseSnd) {
                case true:
					windowEvents.set("focusLost_pauseSnd", true);
                    for (window in Application.current.__windows) {
                        var onUnfocus:Void -> Void = () -> AudioManager.suspend();
                        var onFocus:Void -> Void = () -> AudioManager.resume();

                        window.onFocusOut.add(onUnfocus);
                        window.onFocusIn.add(onFocus);
                    }
                case false:
					if (windowEvents["focusLost_pauseSnd"] == null) return;
					windowEvents.remove("focusLost_pauseSnd");

                    for (window in Application.current.__windows) {
						window.onFocusOut.remove(() -> AudioManager.suspend());
						window.onFocusIn.remove(() -> AudioManager.resume());
                    }
            }
        }
    }
}
