if(active)
{
	hover += InputPressed(INPUT_VERB.DOWN) - InputPressed(INPUT_VERB.UP);
	if(hover > array_length(options)-1) hover = 0;
	if(hover < 0) hover = array_length(options)-1;
	
	if(InputPressed(INPUT_VERB.ACCEPT))
	{
		if(array_length(options[hover]) > 1) &&	(options[hover][3] == true)
		{
			if(options[hover][1] != -1)
			{
				var _func= options[hover][1];
				if( options[hover][2] != -1) script_execute_ext(_func,options[hover][2]);
			}
		}
	}
	
	if (InputPressed(INPUT_VERB.PAUSE))
	{
		if(subMenuLevel > 0) MenuGoBack();
	}
}