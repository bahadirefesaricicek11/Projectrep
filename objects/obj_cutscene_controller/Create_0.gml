event_queue    = [];   // array of CutsceneEvent structs
current_event  = -1;   // index of active event
is_running     = false;
is_done        = false;

// Pushes a new event onto the queue
enqueue = function(_ready_fn, _execute_fn) {
    array_push(event_queue, {
        started: false,
        ready:   _ready_fn,   // function() -> bool: true = this event is done
        execute: _execute_fn  // function(): runs once when event starts
    });
};

// Call this to start the cutscene
start = function() {
    is_running    = true;
    current_event = 0;
    if (array_length(event_queue) > 0) {
        event_queue[0].execute();
        event_queue[0].started = true;
    }
};