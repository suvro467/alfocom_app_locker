package in.alfocom.alfocom_app_locker;

import in.alfocom.alfocom_app_locker.BlockedAppsContract;
import in.alfocom.alfocom_app_locker.MainActivity;

import android.content.Intent;
import android.app.Service;
import android.os.Looper;
import android.os.Handler;
import android.content.Context;
import android.app.ActivityManager;
import android.util.Log;
import android.app.usage.UsageStatsManager;
import android.app.usage.UsageStats;
import in.alfocom.alfocom_app_locker.BlockedAppsContract;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;
import android.database.Cursor;
import android.os.Build;

import java.util.*;

public class LaunchChecker extends Thread {

    private Context context;
    private Handler handler;
    private ActivityManager actMan;
    private int timer = 100;
    public static final String TAG = "App Thread";
    public static String lastUnlocked;

    public LaunchChecker(Handler mainHandler, Context context) {
        this.context = context;
        this.handler = mainHandler;
        
        actMan = (ActivityManager) context
                .getSystemService(Context.ACTIVITY_SERVICE);
        this.setPriority(MAX_PRIORITY);

    }
    
    @Override
    public void run() {
        context.startService(new Intent(context, BackgroundService.class));
        Looper.prepare();
        String prevTasks;
        String recentTasks = "";
    
        prevTasks = recentTasks;
        Log.d("Thread", "Inside Thread");
        while (true) {
            try {
                String topPackageName = "";
                if(Build.VERSION.SDK_INT >= 21) {
                    UsageStatsManager mUsageStatsManager = (UsageStatsManager) context.getSystemService("usagestats");                       
                    long time = System.currentTimeMillis(); 
                    // We get usage stats for the last 10 seconds
                    List<UsageStats> stats = mUsageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 1000*5, time);                                    
                    if(stats != null) {
                        SortedMap<Long,UsageStats> mySortedMap = new TreeMap<Long,UsageStats>();
                        for (UsageStats usageStats : stats) {
                            mySortedMap.put(usageStats.getLastTimeUsed(),usageStats);
                        }                    
                        if(mySortedMap != null && !mySortedMap.isEmpty()) {
                            topPackageName =  mySortedMap.get(mySortedMap.lastKey()).getPackageName();                                   
                        }                                       
                    }
                }
                else {
                    topPackageName = actMan.getRunningAppProcesses().get(0).processName;
                }
                
                recentTasks = topPackageName;
                
                Thread.sleep(timer);

                System.out.println("onActivityResult Called : Process ID : " + actMan.getRunningAppProcesses().get(0).pid);
                if (recentTasks.length()==0 || recentTasks.equals(
                        prevTasks)) {
                } else {
                    if (isAppLocked(recentTasks)) {
                        Log.d(TAG, "Locked " + recentTasks);
                        handler.post(new RequestPassword(context, recentTasks, prevTasks));
                    }
                }
            } catch (InterruptedException e) {
                System.out.println("Inside LaunchChecker.java InterruptedException");
                e.printStackTrace();
            }
    
            prevTasks = recentTasks;
        }
    }
    
    class RequestPassword implements Runnable {
    
        private Context mContext;
        private String pkgName = "";
        private String previousPkgName = "";
    
        public RequestPassword(Context mContext, String pkgName, String previousPkgName) {
            this.mContext = mContext;
            this.pkgName = pkgName;
            this.previousPkgName = previousPkgName;
        }
    
        @Override
        public void run() {
            System.out.println("previousPkgName : " + previousPkgName + ", pkgName : " + pkgName);

            Intent passwordAct = new Intent(context, PasswordActivity.class);
                    passwordAct.putExtra("PACKAGE_NAME", pkgName);
                    passwordAct.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_SINGLE_TOP|Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
                    this.mContext.startActivity(passwordAct);
        }
    }
    
    // Check if the app is locked or not.
    private boolean isAppLocked(String packageName) {
        System.out.println("previousPkgName : PasswordActivity.lastUnlocked : " + PasswordActivity.lastUnlocked + ", packageName : " + packageName);
        if (packageName.equals(PasswordActivity.lastUnlocked) || packageName.equals("in.alfocom.alfocom_app_locker")) {
            return false;
        }
        PasswordActivity.lastUnlocked = null;
        BlockedAppsDbHelper dbHelper = new BlockedAppsDbHelper(context,"AppLocker.db");
        SQLiteDatabase db = dbHelper.getReadableDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM blockedapps WHERE packagename=\'"
                + packageName + "\'", null);
        boolean isLocked = false;
        if (cursor.moveToNext()) {
            isLocked = true;
        }
    
        cursor.close();
        db.close();
        dbHelper.close();
        return isLocked;
    }
}