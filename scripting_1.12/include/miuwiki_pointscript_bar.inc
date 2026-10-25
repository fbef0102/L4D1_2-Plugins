/** Double-include prevention */
#if defined _miuwiki_pointscript_bar_included_
  #endinput
#endif
#define _miuwiki_pointscript_bar_included_

#define SEND_SUCCESS 0

methodmap PointScriptBar
{
    /**
     * Get point script bar of client.
     *
     * @param  client       A human player client id.
     * 
     * @return              client itself.
     */
    public PointScriptBar(int client){
        return view_as<PointScriptBar>(client);
    }

    /**
     * Get client point script bar is available or not.
     * 
     * @return True if client point script bar is available, false if otherwise.
     */
    property bool IsAvailable{
        public native get();
    }

    /**
     * Get client point script bar is showing or not .
     * 
     * @return True if point script bar is showing for this client, false if otherwise.
     */
    property bool IsShowing{
        public native get();
    }

    /**
     * Get point script bar duration.
     * 
     */
    property float duration{
        public native get();
    }

    /**
     * Get or Set point script bar persent.
     * 
     * @param pesent Set point script bar current persent, in [0.0 - 1.0].
     */
    property float persent{
        public native get();
        public native set(float persent);
    }

    /**
     * Get or Set point script bar pause.
     * 
     * @param pause Set point script bar to pause in current persent.
     */
    property bool pause{
        public native get();
        public native set(bool pause);
    }

    /**
     * Get point script bar Text.
     * 
     * @param text      Buffer to store the value of point script bar text.
     * @param mexlength Maximum length of string buffer.
     */
    public native void GetText(char[] text, int maxlength);

    /**
     * Set point script bar Text.
     * 
     * @param text      New string for point script bar text.
     */
    public native void SetText(const char[] text);

    /**
     * Get point script bar SubText.
     * 
     * @param text      Buffer to store the value of point script bar subtext.
     * @param mexlength Maximum length of string buffer.
     */
    public native void GetSubText(char[] text, int maxlength);

    /**
     * Set point script bar SubText.
     * 
     * @param subtext New string for point script bar text.
     */
    public native void SetSubText(const char[] subtext);

     /**
     * Apply client point script bar with current setting.
     * 
     * @param duration  Set point script bar total duration time and start it immedately, 0.0 means close a bar.
     * @param force     Force replace to current bar if one is already showing.
     * @param locked    Prevent this bar from being replaced in duration time.
     * 
     * @note Set duration 0.0 to close a point script bar.
     * 
     * @return True on showing success, false if client has non-replaceable bar shwoing.
     */
    public native bool Apply(float duration, bool force = true, bool locked = false);
}