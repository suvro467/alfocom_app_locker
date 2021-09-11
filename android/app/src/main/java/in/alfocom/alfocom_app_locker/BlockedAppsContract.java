package in.alfocom.alfocom_app_locker;

import android.content.ContentValues;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;


public final class BlockedAppsContract {

    /* Inner class that defines the table contents */
    public static class BlockedAppsEntry implements BaseColumns {
        public static final String TABLE_NAME = "blockedapps";
        public static final String COLUMN_NAME_PACKAGENAME = "packagename";
    }
    
    public static final String SQL_CREATE_APPS =
    "CREATE TABLE " + BlockedAppsEntry.TABLE_NAME + " (" +
    BlockedAppsEntry._ID + " INTEGER PRIMARY KEY," +
    BlockedAppsEntry.COLUMN_NAME_PACKAGENAME + " TEXT)";

    public static final String SQL_DELETE_APPS =
    "DROP TABLE IF EXISTS " + BlockedAppsEntry.TABLE_NAME;

}
