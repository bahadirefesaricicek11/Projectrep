function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
        //Add your own verbs here!
        UP,
        DOWN,
        LEFT,
        RIGHT,
        ACCEPT,
        CANCEL,
        DELETE,
        INVENTORY,
        ACTION,
        SPECIAL,
        PAUSE,
		FULLSCREEN,
		L1,
		R1,
    }
    
    enum INPUT_CLUSTER
    {
        //Add your own clusters here!
        //Clusters are used for two-dimensional checkers (InputDirection() etc.)
        NAVIGATION,
    }
    
    if (not INPUT_ON_SWITCH)
    {
        InputDefineVerb(INPUT_VERB.UP,         "up",         [vk_up,     "W"],    [-gp_axislv, gp_padu]);
        InputDefineVerb(INPUT_VERB.DOWN,       "down",       [vk_down,   "S"],    [ gp_axislv, gp_padd]);
        InputDefineVerb(INPUT_VERB.LEFT,       "left",       [vk_left,   "A"],    [-gp_axislh, gp_padl]);
        InputDefineVerb(INPUT_VERB.RIGHT,      "right",      [vk_right,  "D"],    [ gp_axislh, gp_padr]);
        InputDefineVerb(INPUT_VERB.ACCEPT,     "accept",     [vk_enter,  "Z"],    [gp_face1]);
        InputDefineVerb(INPUT_VERB.CANCEL,     "cancel",     [vk_shift,  "X"],    [gp_face2]);
        InputDefineVerb(INPUT_VERB.DELETE,     "delete",     [vk_backspace  ],    [		   ]);
        InputDefineVerb(INPUT_VERB.INVENTORY,  "inventory",  [  "C" ,  "E"  ],    [gp_face4]);
        InputDefineVerb(INPUT_VERB.ACTION,     "action",     [vk_space,     ],    [gp_face3]);
        InputDefineVerb(INPUT_VERB.PAUSE,      "pause",      [vk_escape,    ],    [gp_start]);
        InputDefineVerb(INPUT_VERB.FULLSCREEN, "fullscreen", [vk_f11,  vk_f4],    [gp_select]);
        InputDefineVerb(INPUT_VERB.L1,		   "l1",		 undefined,			  [gp_shoulderl]);
        InputDefineVerb(INPUT_VERB.R1,		   "r1",		 undefined,			  [gp_shoulderr]);
    }
    else //Flip A/B over on Switch
    {
        InputDefineVerb(INPUT_VERB.UP,          "up",        undefined, [-gp_axislv, gp_padu]);
        InputDefineVerb(INPUT_VERB.DOWN,        "down",      undefined, [ gp_axislv, gp_padd]);
        InputDefineVerb(INPUT_VERB.LEFT,        "left",      undefined, [-gp_axislh, gp_padl]);
        InputDefineVerb(INPUT_VERB.RIGHT,       "right",     undefined, [ gp_axislh, gp_padr]);
        InputDefineVerb(INPUT_VERB.ACCEPT,      "accept",    undefined,   gp_face2); // !!
        InputDefineVerb(INPUT_VERB.CANCEL,      "cancel",    undefined,   gp_face1); // !!
		InputDefineVerb(INPUT_VERB.INVENTORY,   "inventory", undefined,   gp_padd);
        InputDefineVerb(INPUT_VERB.ACTION,      "action",    undefined,   gp_face3);
        InputDefineVerb(INPUT_VERB.SPECIAL,     "special",   undefined,   gp_face4);
        InputDefineVerb(INPUT_VERB.PAUSE,       "pause",     undefined,   gp_start);
    }
    
    //Define a cluster of verbs for moving around
    InputDefineCluster(INPUT_CLUSTER.NAVIGATION, INPUT_VERB.UP, INPUT_VERB.RIGHT, INPUT_VERB.DOWN, INPUT_VERB.LEFT);
}