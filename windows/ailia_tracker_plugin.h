#ifndef FLUTTER_PLUGIN_AILIA_TRACKER_PLUGIN_H_
#define FLUTTER_PLUGIN_AILIA_TRACKER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace ailia_tracker {

class AiliaTrackerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AiliaTrackerPlugin();

  virtual ~AiliaTrackerPlugin();

  // Disallow copy and assign.
  AiliaTrackerPlugin(const AiliaTrackerPlugin&) = delete;
  AiliaTrackerPlugin& operator=(const AiliaTrackerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace ailia_tracker

#endif  // FLUTTER_PLUGIN_AILIA_TRACKER_PLUGIN_H_
