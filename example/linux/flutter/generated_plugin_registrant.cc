//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <ailia_tracker/ailia_tracker_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) ailia_tracker_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AiliaTrackerPlugin");
  ailia_tracker_plugin_register_with_registrar(ailia_tracker_registrar);
}
