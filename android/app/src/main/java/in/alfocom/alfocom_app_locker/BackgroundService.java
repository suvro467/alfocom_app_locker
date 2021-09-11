package in.alfocom.alfocom_app_locker;

import android.content.Intent;
import android.content.Context;
import android.app.Service;
import android.os.Looper;
import android.os.Handler;
import android.os.IBinder;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.app.Notification;
import android.app.PendingIntent;

public class BackgroundService extends Service {
    LaunchChecker launchChecker;
    Handler handler;
    Context context;
    public static final String CHANNEL_ID = "ForegroundServiceChannel";

    @Override
    public void onCreate() {
        handler = new Handler(getMainLooper());
        context = getApplicationContext();
        launchChecker = new LaunchChecker(handler, context);

        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        
        while (true) {
            System.out.println("Inside onStartCommand of ForegroundService");
            createNotificationChannel();
            Intent notificationIntent = new Intent(this, MainActivity.class);
            PendingIntent pendingIntent =
            PendingIntent.getActivity(this, 0, notificationIntent, 0);
            Notification notification =
            new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Tap to open App Locker")
                //.setContentText("Tap to open App Locker")
                .setSmallIcon(R.drawable.notification_icon)
                .setContentIntent(pendingIntent)
                .build();
        
            startForeground(1, notification);
            if (!launchChecker.isAlive()) {
                launchChecker.start();
            }
            return START_STICKY;

        }
    }

    private void createNotificationChannel() {
        NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
    }

    @Override
    public IBinder onBind(Intent intent) {
        // We don't provide binding, so return null
        return null;
    }
      
}