if (!is_running || is_done) exit;

var _ev = event_queue[current_event];

// Check if current event signals completion
if (_ev.ready()) {
    current_event++;

    if (current_event >= array_length(event_queue)) {
        // All events done
        is_done    = true;
        is_running = false;
        instance_destroy();
        exit;
    }

    // Start next event
    var _next = event_queue[current_event];
    _next.execute();
    _next.started = true;
}