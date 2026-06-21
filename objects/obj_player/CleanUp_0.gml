/// @description obj_player Clean Up Event
if (ds_exists(pos_history, ds_type_list)) {
    ds_list_destroy(pos_history);
}