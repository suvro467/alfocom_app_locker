package in.alfocom.alfocom_app_locker;

import android.content.ContentValues;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;
import in.alfocom.alfocom_app_locker.BlockedAppsContract;

public class BlockedAppsDbHelper extends SQLiteOpenHelper {

    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "AppLocker.db";
    BlockedAppsContract blockedAppsContract;

    public BlockedAppsDbHelper(Context context,String DATABASE_NAME) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
        blockedAppsContract =  new BlockedAppsContract();
    }

    public void onCreate(SQLiteDatabase db) {
        db.execSQL(blockedAppsContract.SQL_CREATE_APPS);
    }

    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // This database is only a cache for online data, so its upgrade policy is
        // to simply to discard the data and start over
        db.execSQL(blockedAppsContract.SQL_DELETE_APPS);
        onCreate(db);
    }

    public void onDowngrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        onUpgrade(db, oldVersion, newVersion);
    }

}
