package in.alfocom.alfocom_app_locker;

import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.content.Context;
import android.app.Activity;
import android.os.Bundle;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint;
import io.flutter.embedding.engine.FlutterEngineCache;

public class PasswordActivity extends Activity {

    public static String lastUnlocked;
    FlutterEngine flutterEngine;

    private static final String PINSCREENSENDTOBACKGROUNDCHANNEL = "alfocom_app_locker.alfocom.in/pinscreensendtobackground";
    public static MethodChannel methodChannelSendToBackground;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String packageName;
        Bundle extras = getIntent().getExtras();
        packageName = extras.getString("PACKAGE_NAME");

        // Instantiate a FlutterEngine.
        flutterEngine = new FlutterEngine(this);

        // Configure an initial route.
        flutterEngine.getNavigationChannel().setInitialRoute("/unlockscreen");

        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.getDartExecutor().executeDartEntrypoint(
            DartEntrypoint.createDefault()
        );

        // Cache the FlutterEngine to be used by FlutterActivity.
        FlutterEngineCache
        .getInstance()
        .put("my_engine_id", flutterEngine);

        FlutterActivity flutterActivity = new FlutterActivity();

        startActivityForResult(
            flutterActivity
            .withCachedEngine("my_engine_id")
            .build(this),2
        );

        lastUnlocked = packageName;

        System.out.println("All operations completed");

        methodChannelSendToBackground = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PINSCREENSENDTOBACKGROUNDCHANNEL);
                methodChannelSendToBackground.setMethodCallHandler((call, result) -> {
                    // Note: This method is invoked in the main thread.
                    System.out.println("Inside methodChannelSendToBackground ");
                    if (call.method.equals("sendToBackground")) {
                        flutterActivity.moveTaskToBack(true);
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }

                });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        System.out.println("onActivityResult Called");
        finish();
    }
    
}