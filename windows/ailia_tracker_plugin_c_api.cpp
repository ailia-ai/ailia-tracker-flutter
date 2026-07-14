#include "include/ailia_tracker/ailia_tracker_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "ailia_tracker_plugin.h"

void AiliaTrackerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ailia_tracker::AiliaTrackerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
