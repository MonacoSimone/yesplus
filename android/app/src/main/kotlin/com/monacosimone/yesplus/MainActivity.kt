package com.monacosimone.yesplus

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.io.File

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Assicurati che la directory flutter_assets abbia i permessi corretti
        val flutterAssetsDir = File(applicationContext.dataDir, "app_flutter/flutter_assets")
        if (flutterAssetsDir.exists() && !flutterAssetsDir.canRead()) {
            flutterAssetsDir.setReadable(true)
            Log.d("MainActivity", "Permessi flutter_assets impostati")
        }
    }
}
