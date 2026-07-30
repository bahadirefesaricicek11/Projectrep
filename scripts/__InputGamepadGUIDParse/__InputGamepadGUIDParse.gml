// Feather disable all

/// @param GUID

function __InputGamepadGUIDParse(_guid)
{
    static _result = {};
    
    _result.__vendor  = "";
    _result.__product = "";
    
    if (_guid == "00000000000000000000000000000000")
    {
        __InputTrace("Warning! GUID was empty");
        return _result;
    }
    
    //Expected GUID pattern:
    // 
    //  ****0000****0000****0000****XXXX
    //  N1  N2  N3  N4  N5  N6  N7  N8
    //
    // N1: Bus (OS driver)
    // N3: Vendor ID
    // N5: Product ID
    // N7: Revision
    // N8: Driver hint (SDL)
    
    //Check for empty N4, indicating this is not a description encoded GUID
    if (string_copy(_guid, 13, 4) == "0000")
    {
        // MODIFIED: We bypass the strict N6 empty check. 
        // Some Bluetooth stacks write custom data into chars 21-24,
        // but we can still safely extract the VID and PID anyway.
        if (string_copy(_guid, 21, 4) != "0000")
        {
            __InputTrace("Notice: GUID \"", _guid, "\" has data in N6, but continuing to extract VID/PID.");
        }
        
        //Check to see if N1 for this GUID is what we expect
        if ((string_copy(_guid, 1, 4) != "0300") 
        &&  (string_copy(_guid, 1, 4) != "0500"))
        {
            __InputTrace("Warning! GUID \"", _guid, "\" driver ID does not match expected (Found ", string_copy(_guid, 1, 4), ", expect either 0300 or 0500)");
        }
        
        _result.__vendor  = string_copy(_guid,  9, 4);
        _result.__product = string_copy(_guid, 17, 4);
    }
    
    return _result;
}