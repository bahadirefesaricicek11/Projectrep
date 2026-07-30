function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
        UP,
        DOWN,
        LEFT,
        RIGHT,
        ACCEPT,
        CANCEL,
        ACTION,
        SPECIAL,
        PAUSE,
        L1,
        R1,
        FULLSCREEN,
        DELETE,
        INVENTORY,
		ANY
    }
    
    enum INPUT_CLUSTER
    {
        NAVIGATION,
    }
    
    InputDefineVerb(INPUT_VERB.ANY, "any", 
	    [vk_anykey], 
	    [gp_face1, gp_face2, gp_face3, gp_face4, gp_start, gp_select]
	);
	
    InputDefineVerb(INPUT_VERB.UP,      "up",       [vk_up,    "W"],    [-gp_axislv, gp_padu]);
    InputDefineVerb(INPUT_VERB.DOWN,    "down",     [vk_down,  "S"],    [ gp_axislv, gp_padd]);
    InputDefineVerb(INPUT_VERB.LEFT,    "left",     [vk_left,  "A"],    [-gp_axislh, gp_padl]);
    InputDefineVerb(INPUT_VERB.RIGHT,   "right",    [vk_right, "D"],    [ gp_axislh, gp_padr]);

    InputDefineVerb(INPUT_VERB.INVENTORY, "inventory", ["C", "E", vk_control], [gp_face4]);
    InputDefineVerb(INPUT_VERB.ACTION,  "action",   ["Z", vk_enter],    [gp_face3]);
    InputDefineVerb(INPUT_VERB.SPECIAL, "special",  ["X", vk_shift],    [gp_face4]);
    InputDefineVerb(INPUT_VERB.PAUSE,   "pause",    [vk_escape],        [gp_start]);
    InputDefineVerb(INPUT_VERB.DELETE,    "delete",    [vk_backspace],      undefined);
    InputDefineVerb(INPUT_VERB.L1,        "l1",        undefined,           [gp_shoulderl]);
    InputDefineVerb(INPUT_VERB.R1,        "r1",        undefined,           [gp_shoulderr]);
    
    // 4. Platform-Specific Accept/Cancel Overrides
    if (INPUT_ON_SWITCH_X)
    {
        InputDefineVerb(INPUT_VERB.ACCEPT, "accept", undefined, [gp_face2]); 
        InputDefineVerb(INPUT_VERB.CANCEL, "cancel", undefined, [gp_face1]); 
    }
    else
    {
        InputDefineVerb(INPUT_VERB.ACCEPT, "accept", ["Z", vk_enter], [gp_face1]);
        InputDefineVerb(INPUT_VERB.CANCEL, "cancel", ["X", vk_shift], [gp_face2]);
    }
    
    // 5. Platform-Specific Map & Fullscreen Handling
    if (INPUT_ON_PS5)
    {
        InputDefineVerb(INPUT_VERB.FULLSCREEN, "fullscreen", [vk_f11, vk_f4],       undefined);
    }
    else
    {
        InputDefineVerb(INPUT_VERB.FULLSCREEN, "fullscreen", [vk_f11, vk_f4],       [gp_select]);
    }
    
    // Define a cluster of verbs for moving around
    InputDefineCluster(INPUT_CLUSTER.NAVIGATION, INPUT_VERB.UP, INPUT_VERB.RIGHT, INPUT_VERB.DOWN, INPUT_VERB.LEFT);
}