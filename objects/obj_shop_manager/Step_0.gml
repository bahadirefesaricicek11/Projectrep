right_key = InputPressed(INPUT_VERB.RIGHT);
left_key = InputPressed(INPUT_VERB.LEFT);

pos += right_key - left_key;
if pos >= tab_length {pos=0};
if pos < 0 {pos = tab_length-1};