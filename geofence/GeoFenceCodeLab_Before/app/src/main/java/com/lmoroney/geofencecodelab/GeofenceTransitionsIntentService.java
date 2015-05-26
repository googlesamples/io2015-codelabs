package com.lmoroney.geofencecodelab;

import android.app.IntentService;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.TaskStackBuilder;
import android.text.TextUtils;
import android.util.Log;

import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingEvent;

import java.util.ArrayList;
import java.util.List;


public class GeofenceTransitionsIntentService extends IntentService {
    
    public GeofenceTransitionsIntentService() {
        // Use the TAG to name the worker thread.
        super(TAG);
    }

    @Override
    public void onCreate()
    {
        super.onCreate();
    }

    @Override
    protected void onHandleIntent(Intent intent) {
    }

    private String getGeofenceTransitionDetails(
    }

    private String getTransitionString(int transitionType) {
    }

    private void sendNotification(String notificationDetails) {
	}

}
