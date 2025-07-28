var _finalVol = global.musicVolume*global.masterVolume;

if songAsset != targetSongAsset
{
	if audio_is_playing(songInstance)
	{
		array_push(fadeOutInstances, songInstance);
		array_push(fadeOutInstVol, fadeInInstVol);
		array_push(fadeOutInstTime, endFadeOutTime);
		
		songInstance = noone;
		songAsset = noone;
	}
	
	if array_length(fadeOutInstances) == 0
	{
		if audio_exists(targetSongAsset) 
		{
			songInstance = audio_play_sound(targetSongAsset, 4, true)
	
			audio_sound_gain(songInstance, 0, 0);
			fadeInInstVol = 0;
		}
	
		songAsset = targetSongAsset;
	}
}


if audio_is_playing(songInstance) 
{
	if startFadeInTime > 0
	{
		if fadeInInstVol < 1 
		{
			fadeInInstVol += 1/startFadeInTime;
		}
		else
		{
			fadeInInstVol = 1;
		}
	}
	else
	{
		fadeInInstVol = 1;
	}
	
	audio_sound_gain(songInstance, fadeInInstVol*_finalVol, 0);
}

for( var i = 0; i < array_length(fadeOutInstances); i++)
{
	if fadeOutInstTime[i] > 0
	{
		if fadeOutInstVol[i] > 0
		{
			fadeOutInstVol -= 1/fadeOutInstTime[i];
		}
		else
		{
			fadeOutInstVol[i] = 0;
		}
		
		audio_sound_gain (fadeOutInstances[i], fadeOutInstVol[i]*_finalVol, 0);
		
		if fadeOutInstVol[i] <= 0
		{
			if audio_is_playing(fadeOutInstances[i])
			{
				audio_stop_sound(fadeOutInstances[i]);
			}
			array_delete(fadeOutInstances, i, 1);
			array_delete(fadeOutInstVol, i, 1);
			array_delete(fadeOutInstTime, i, 1);
			i--;
		}
	}
}