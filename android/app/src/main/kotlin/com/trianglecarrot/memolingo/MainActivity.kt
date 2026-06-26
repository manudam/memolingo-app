package com.trianglecarrot.memolingo

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Match Android 15 edge-to-edge default on older versions to validate insets.
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
