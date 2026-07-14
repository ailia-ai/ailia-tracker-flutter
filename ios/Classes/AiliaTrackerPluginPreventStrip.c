//
//  AiliaTrackerPluginPreventStrip.c
//

// Dummy link to keep libailia_tracker.a from being deleted

extern int ailiaTrackerCreate(void** tracker, int algorithm, const void* settings, int version, int flags);

void ailia_tracker_prevent_strip(void){
    ailiaTrackerCreate(0, 0, 0, 0, 0);
}
