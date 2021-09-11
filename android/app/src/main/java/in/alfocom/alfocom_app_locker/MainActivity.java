package in.alfocom.alfocom_app_locker;

import in.alfocom.alfocom_app_locker.BlockedAppsContract;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;
import android.content.ContentValues;
import android.database.Cursor;
import android.app.Service;

import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Intent;
import android.content.Context;
import java.util.*;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "alfocom_app_locker.alfocom.in/backgroundservice";
    
    public static MethodChannel methodChannel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        
        methodChannel.setMethodCallHandler((call, result) -> {
                    // Note: This method is invoked in the main thread.
                    if (call.method.equals("createBackgroundService")) {
                        HashMap selectedAppsMap = call.arguments();
                        boolean needToStartService = call.argument("needToStartService");
                        selectedAppsMap.remove("needToStartService");

                        int res = createBackgroundService(selectedAppsMap, needToStartService);

                        if (res != -1) {
                            result.success(res);
                        } else {
                            result.error("Cannot call platform function.", "Unknown error.", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private int createBackgroundService(HashMap selectedAppsMap, boolean needToStartService) {

        insertData(selectedAppsMap);

        // If no apps are selected in the blocked apps list, then no need to start the service.
        Intent intent = new Intent(this, BackgroundService.class);
        if(needToStartService == true) {
            startForegroundService(intent);
        } else {
            stopService(intent);
        }

        System.out.println("Inside MainActivity.java : startForegroundService called.");
        
        return selectedAppsMap.size();
    }

    private void insertData(HashMap selectedAppsMap) {

        // Getting an iterator 
        Iterator saIterator = selectedAppsMap.entrySet().iterator();

        Context context = getContext();
        BlockedAppsDbHelper dbHelper = new BlockedAppsDbHelper(context,"AppLocker.db");
        BlockedAppsContract blockedAppsContract = new BlockedAppsContract();

        // Gets the data repository in write mode
        SQLiteDatabase db = dbHelper.getWritableDatabase();

        // Delete all the existing rows from the table first.         
        int deletedRows = db.delete("blockedapps", null, null);
        System.out.println("Rows deleted : " + deletedRows);

        
        //values.put("blockedAppsContract.BlockedAppsEntry.COLUMN_NAME_PACKAGENAME", "Testing");
        while (saIterator.hasNext()) { 
            Map.Entry mapElement = (Map.Entry)saIterator.next(); 
            String app = ((String)mapElement.getValue()); 
            System.out.println(mapElement.getKey() + " : " + app); 
            // Create a new map of values, where column names are the keys
            ContentValues values = new ContentValues();
            values.put("packagename", app);
            // Insert the new row, returning the primary key value of the new row
            long newRowId = db.insert("blockedapps", null, values);
        }
        
        db.close();
        
    }

}

