package com.example.cricket_scorer

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "cricket_scorer/launcher_icon"
    private val preferencesName = "launcher_icon_state"
    private val defaultAlias = "MainActivityDefault"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(true)
                    "getSelectedIcon" -> result.success(selectedIconId())
                    "normalizeLauncherState" -> {
                        normalizeAliases(call.argument<String>("iconId"), result)
                    }
                    "restoreDefaultIcon" -> switchIcon(null, result)
                    "setLauncherIcon" -> {
                        val iconId = call.argument<String>("iconId")
                        if (iconId == null || !iconId.matches(Regex("jersey_([1-9]|[1-9][0-9])"))) {
                            result.error("INVALID_ICON", "Invalid jersey launcher icon ID.", iconId)
                        } else {
                            switchIcon(iconId, result)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun selectedIconId(): String {
        return getSharedPreferences(preferencesName, MODE_PRIVATE)
            .getString("selectedIconId", "default") ?: "default"
    }

    private fun aliasFor(iconId: String?): String {
        if (iconId == null) return defaultAlias
        val display = iconId.removePrefix("jersey_")
        return "MainActivityJersey$display"
    }

    private fun switchIcon(iconId: String?, result: MethodChannel.Result) {
        val packageManager = packageManager
        val preferences = getSharedPreferences(preferencesName, MODE_PRIVATE)
        val previousId = preferences.getString("selectedIconId", null)
        val nextAlias = aliasFor(iconId)
        val previousAlias = aliasFor(previousId)
        try {
            val nextComponent = ComponentName(packageName, "$packageName.$nextAlias")
            packageManager.setComponentEnabledSetting(
                nextComponent,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
            if (previousAlias != nextAlias) {
                val previousComponent = ComponentName(packageName, "$packageName.$previousAlias")
                packageManager.setComponentEnabledSetting(
                    previousComponent,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }
            preferences.edit().apply {
                if (iconId == null) remove("selectedIconId") else putString("selectedIconId", iconId)
            }.apply()
            result.success(true)
        } catch (error: Exception) {
            result.error("ICON_SWITCH_FAILED", error.message, nextAlias)
        }
    }

    private fun normalizeAliases(iconId: String?, result: MethodChannel.Result) {
        val validIconId = iconId?.takeIf {
            it.matches(Regex("jersey_([1-9]|[1-9][0-9])"))
        }
        val desiredAlias = aliasFor(validIconId)
        try {
            // Enable the desired component first so migration can never leave
            // the application without a launcher entry.
            setAliasEnabled(desiredAlias, true)
            setAliasEnabled(defaultAlias, desiredAlias == defaultAlias)
            for (number in 1..99) {
                val alias = "MainActivityJersey$number"
                if (alias != desiredAlias) setAliasEnabled(alias, false)
            }
            getSharedPreferences(preferencesName, MODE_PRIVATE).edit().apply {
                if (validIconId == null) remove("selectedIconId")
                else putString("selectedIconId", validIconId)
            }.apply()
            result.success(true)
        } catch (error: Exception) {
            result.error("ICON_NORMALIZATION_FAILED", error.message, desiredAlias)
        }
    }

    private fun setAliasEnabled(alias: String, enabled: Boolean) {
        packageManager.setComponentEnabledSetting(
            ComponentName(packageName, "$packageName.$alias"),
            if (enabled) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
    }
}
