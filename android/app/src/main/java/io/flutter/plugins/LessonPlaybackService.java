package com.vbhc.diab;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

/**
 * Foreground service (type mediaPlayback) kept alive while a lesson video is
 * playing, so the OS keeps the app process at foreground-service priority
 * after the screen locks. Without it the process drops to TOP_SLEEPING once
 * the activity stops, and the system may destroy the activity ("low-mem"),
 * freeze the process or cut its network in Doze — the player is torn down,
 * audio stops, and the lesson reopens at 00:00.
 *
 * Started/stopped from Dart via the "com.vbhc.diab/lesson_playback" channel
 * (see MainActivity and lib/src/service/lesson_playback_service.dart).
 */
public class LessonPlaybackService extends Service {
    private static final String TAG = "LessonPlaybackService";
    public static final String ACTION_START = "com.vbhc.diab.lesson_playback.START";
    public static final String ACTION_STOP = "com.vbhc.diab.lesson_playback.STOP";
    public static final String EXTRA_TITLE = "title";
    private static final String CHANNEL_ID = "lesson_playback";
    private static final int NOTIFICATION_ID = 41027;

    /**
     * Set by MainActivity: true once Dart asked to stop, false on each start.
     * Covers a stop that lands between startForegroundService() and this
     * service's onStartCommand(): the service still calls startForeground()
     * first (otherwise "did not then call Service.startForeground()" crash),
     * then tears itself down right away.
     */
    public static volatile boolean stopRequested = false;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null && ACTION_STOP.equals(intent.getAction())) {
            stopForegroundCompat();
            stopSelf();
            return START_NOT_STICKY;
        }

        // startForeground() must come before anything else that can fail:
        // an exception before it would leave the startForegroundService()
        // request unanswered and crash the app.
        String title = intent != null ? intent.getStringExtra(EXTRA_TITLE) : null;
        Notification notification;
        try {
            notification = buildNotification(title);
        } catch (Exception e) {
            Log.w(TAG, "buildNotification failed, using minimal one: " + e);
            notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setSilent(true)
                    .build();
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIFICATION_ID, notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK);
            } else {
                startForeground(NOTIFICATION_ID, notification);
            }
        } catch (Exception e) {
            // e.g. ForegroundServiceStartNotAllowedException (API 31+) when the
            // app is no longer allowed to start a FGS. Playback just loses the
            // background-priority boost; never crash for it.
            Log.w(TAG, "startForeground failed: " + e);
            stopSelf();
            return START_NOT_STICKY;
        }

        if (stopRequested) {
            // A stop arrived before this start was processed.
            Log.d(TAG, "stop requested before start was processed; stopping");
            stopForegroundCompat();
            stopSelf();
        }
        return START_NOT_STICKY;
    }

    private Notification buildNotification(@Nullable String title) {
        NotificationManager manager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && manager != null
                && manager.getNotificationChannel(CHANNEL_ID) == null) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID, getString(R.string.lesson_playback_channel_name),
                    NotificationManager.IMPORTANCE_LOW);
            channel.setShowBadge(false);
            manager.createNotificationChannel(channel);
        }

        PendingIntent contentIntent = null;
        Intent launch = getPackageManager().getLaunchIntentForPackage(getPackageName());
        if (launch != null) {
            launch.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            contentIntent = PendingIntent.getActivity(this, 0, launch,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        }

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title != null && !title.isEmpty()
                        ? title : getString(R.string.app_name))
                .setContentText(getString(R.string.lesson_playback_text))
                .setContentIntent(contentIntent)
                .setOngoing(true)
                .setSilent(true)
                .setShowWhen(false)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setCategory(NotificationCompat.CATEGORY_TRANSPORT)
                .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
                .build();
    }

    private void stopForegroundCompat() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(Service.STOP_FOREGROUND_REMOVE);
        } else {
            stopForeground(true);
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
