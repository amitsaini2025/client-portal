package com.bansalimmigration.clientportal

/*import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.NormalTheme)
        super.onCreate(savedInstanceState)
    }
}*/


import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Optional: force theme here if needed
        setTheme(R.style.NormalTheme)
    }
}

