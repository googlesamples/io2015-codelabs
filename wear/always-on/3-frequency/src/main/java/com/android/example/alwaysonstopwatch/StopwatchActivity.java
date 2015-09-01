/*
 * Copyright (C) 2015 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.example.alwaysonstopwatch;

import android.annotation.SuppressLint;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.support.wearable.activity.WearableActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextClock;
import android.widget.TextView;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.concurrent.TimeUnit;


/**
 * This activity displays a stopwatch.
 */
public class StopwatchActivity extends WearableActivity {

    private static final String TAG = "StopwatchActivity";

    // Milliseconds between waking processor/screen for updates when active
    private static final long ACTIVE_INTERVAL_MS = TimeUnit.SECONDS.toMillis(1);
    // Milliseconds between waking processor/screen for updates when in ambient mode
    private static final long AMBIENT_INTERVAL_MS = TimeUnit.SECONDS.toMillis(10);
    // 60 seconds for updating the clock in active mode
    private static final long MINUTE_INTERVAL_MS = TimeUnit.SECONDS.toMillis(60);

    @SuppressLint("SimpleDateFormat")
    private static final SimpleDateFormat mDebugTimeFormat = new SimpleDateFormat("HH:mm:ss");

    // Screen components
    private TextView mTimeView;
    private Button mStartStopButton;
    private Button mResetButton;
    private View mBackground;
    private TextClock mClockView;
    private TextView mNotice;

    // Wake up the Activity in ambient mode.
    private AlarmManager mAmbientStateAlarmManager;
    private PendingIntent mAmbientStatePendingIntent;

    // The last time that the stop watch was updated or the start time.
    private long mLastTick = 0L;
    // Store time that was measured so far.
    private long mTimeSoFar = 0L;
    // Keep track to see if the stop watch is running.
    private boolean mRunning = false;
    // Handle
    private final Handler mActiveModeUpdateHandler = new UpdateStopwatchHandler(this);
    // Handler for updating the clock in active mode
    private final Handler mActiveClockUpdateHandler = new UpdateClockHandler(this);
    // Foreground and background color in active view.
    private int mActiveBackgroundColor;
    private int mActiveForegroundColor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_stopwatch);

        // Enable Ambient Mode
        setAmbientEnabled();

        mAmbientStateAlarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);

        // Create pending intent
        Intent intent = new Intent(getApplicationContext(), StopwatchActivity.class);
        mAmbientStatePendingIntent = PendingIntent.getActivity(
                getApplicationContext(),
                R.id.msg_update,
                intent,
                PendingIntent.FLAG_CANCEL_CURRENT);

        // Get on screen items
        mStartStopButton = (Button) findViewById(R.id.startstopbtn);
        mResetButton = (Button) findViewById(R.id.resetbtn);
        mTimeView = (TextView) findViewById(R.id.timeview);
        resetTimeView(); // initialise TimeView

        mBackground = findViewById(R.id.gridbackground);
        mClockView = (TextClock) findViewById(R.id.clock);
        mNotice = (TextView) findViewById(R.id.notice);
        mNotice.getPaint().setAntiAlias(false);
        mActiveBackgroundColor = ContextCompat.getColor(this, R.color.activeBackground);
        mActiveForegroundColor = ContextCompat.getColor(this, R.color.activeText);

        mStartStopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.d(TAG, "Toggle start / stop state");
                toggleStartStop();
            }
        });

        mResetButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.d(TAG, "Reset time");
                mLastTick = 0L;
                mTimeSoFar = 0L;
                resetTimeView();
            }
        });

        mActiveClockUpdateHandler.sendEmptyMessage(R.id.msg_update);
    }

    private void updateDisplayAndSetRefresh() {
        if (!mRunning) {
            return;
        }
        incrementTimeSoFar();

        int seconds = (int) (mTimeSoFar / 1000);
        final int minutes = seconds / 60;
        seconds = seconds % 60;

        setTimeView(minutes, seconds);

        if (!isAmbient()) {
            // In Active mode update directly via handler.
            long timeMs = System.currentTimeMillis();
            long delayMs = ACTIVE_INTERVAL_MS - (timeMs % ACTIVE_INTERVAL_MS);
            Log.d(TAG, "NOT ambient - delaying by: " + delayMs);
            mActiveModeUpdateHandler
                    .sendEmptyMessageDelayed(R.id.msg_update, delayMs);
        } else {
            // In Ambient mode update via AlarmManager.
            long timeMs = System.currentTimeMillis();
            long delayMs = AMBIENT_INTERVAL_MS - (timeMs % AMBIENT_INTERVAL_MS);
            long triggerTimeMs = timeMs + delayMs;
            Log.d(TAG, "In ambient - trigger time: " + mDebugTimeFormat.format(triggerTimeMs));
            mAmbientStateAlarmManager.cancel(mAmbientStatePendingIntent);
            mAmbientStateAlarmManager.setExact(AlarmManager.RTC_WAKEUP,
                    triggerTimeMs, mAmbientStatePendingIntent);
        }
    }

    private void incrementTimeSoFar() {
        // Update display time
        final long now = System.currentTimeMillis();
        Log.d(TAG, String.format("current time: %d. start: %d", now, mLastTick));
        mTimeSoFar = mTimeSoFar + now - mLastTick;
        mLastTick = now;
    }

    /**
     * This is mostly triggered by the Alarms we set in Ambient mode and informs us we need to
     * update the screen (and process any data).
     */
    @Override
    public void onNewIntent(Intent intent) {
        Log.d(TAG, "onNewIntent(): " + intent);
        super.onNewIntent(intent);
        setIntent(intent);
        Log.d(TAG, "Running? " + mRunning + ", Start time: " + mLastTick);
        updateDisplayAndSetRefresh();
    }

    /**
     * Set the time view to its initial state.
     */
    private void resetTimeView() {
        setTimeView(0, 0);
    }

    /**
     * Set time view to a specified time.
     *
     * @param minutes The minutes to display.
     * @param seconds The seconds to display.
     */
    private void setTimeView(int minutes, int seconds) {
        if (seconds < 10) {
            mTimeView.setText(minutes + ":0" + seconds);
        } else {
            mTimeView.setText(minutes + ":" + seconds);
        }
    }

    private void toggleStartStop() {
        Log.d(TAG, "mRunning: " + mRunning);
        if (mRunning) {
            // This can only happen in interactive mode - so we only need to stop the handler
            // AlarmManager should be clear
            mActiveModeUpdateHandler.removeMessages(R.id.msg_update);
            incrementTimeSoFar();
            // Currently running - turn it to stop
            mStartStopButton.setText(getString(R.string.btn_label_start));
            mRunning = false;
            mResetButton.setEnabled(true);
        } else {
            mLastTick = System.currentTimeMillis();
            mStartStopButton.setText(getString(R.string.btn_label_pause));
            mRunning = true;
            mResetButton.setEnabled(false);
            updateDisplayAndSetRefresh();
        }
    }

    @Override
    public void onEnterAmbient(Bundle ambientDetails) {
        Log.d(TAG, "ENTER Ambient");
        super.onEnterAmbient(ambientDetails);

        if (mRunning) {
            mActiveModeUpdateHandler.removeMessages(R.id.msg_update);
            mNotice.setVisibility(View.VISIBLE);
        }

        mActiveClockUpdateHandler.removeMessages(R.id.msg_update);

        mTimeView.setTextColor(Color.WHITE);
        Paint textPaint = mTimeView.getPaint();
        textPaint.setAntiAlias(false);
        textPaint.setStyle(Paint.Style.STROKE);
        textPaint.setStrokeWidth(2);

        mStartStopButton.setVisibility(View.INVISIBLE);
        mResetButton.setVisibility(View.INVISIBLE);
        mBackground.setBackgroundColor(Color.BLACK);

        mClockView.setTextColor(Color.WHITE);
        mClockView.getPaint().setAntiAlias(false);

        updateDisplayAndSetRefresh();
    }

    @Override
    public void onExitAmbient() {
        Log.d(TAG, "EXIT Ambient");
        super.onExitAmbient();

        if (mRunning) {
            mAmbientStateAlarmManager.cancel(mAmbientStatePendingIntent);
        }

        mTimeView.setTextColor(mActiveForegroundColor);
        Paint textPaint = mTimeView.getPaint();
        textPaint.setAntiAlias(true);
        textPaint.setStyle(Paint.Style.FILL);

        mStartStopButton.setVisibility(View.VISIBLE);
        mResetButton.setVisibility(View.VISIBLE);
        mBackground.setBackgroundColor(mActiveBackgroundColor);

        mClockView.setTextColor(mActiveForegroundColor);
        mClockView.getPaint().setAntiAlias(true);

        mActiveClockUpdateHandler.sendEmptyMessage(R.id.msg_update);

        if (mRunning) {
            mNotice.setVisibility(View.INVISIBLE);
            updateDisplayAndSetRefresh();
        }
    }

    @Override
    public void onUpdateAmbient() {
        super.onUpdateAmbient();
        updateDisplayAndSetRefresh();
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "onDestroy()");

        mActiveModeUpdateHandler.removeMessages(R.id.msg_update);
        mActiveClockUpdateHandler.removeMessages(R.id.msg_update);
        mAmbientStateAlarmManager.cancel(mAmbientStatePendingIntent);

        super.onDestroy();
    }

    // <editor-fold desc="Update handlers">

    /**
     * Simplify update handling for different types of updates.
     */
    private static abstract class UpdateHandler extends Handler {

        private final WeakReference<StopwatchActivity> mStopWatchActivityWeakReference;

        public UpdateHandler(StopwatchActivity reference) {
            mStopWatchActivityWeakReference = new WeakReference<>(reference);
        }

        @Override
        public void handleMessage(Message message) {
            StopwatchActivity stopwatchActivity = mStopWatchActivityWeakReference.get();

            if (stopwatchActivity == null) {
                return;
            }
            switch (message.what) {
                case R.id.msg_update:
                    handleUpdate(stopwatchActivity);
                    break;
            }
        }

        /**
         * Handle the update within this method.
         *
         * @param stopwatchActivity The activity that handles the update.
         */
        public abstract void handleUpdate(StopwatchActivity stopwatchActivity);
    }

    /**
     * Handle clock updates every minute.
     */
    private static class UpdateClockHandler extends UpdateHandler {

        public UpdateClockHandler(StopwatchActivity reference) {
            super(reference);
        }

        @Override
        public void handleUpdate(StopwatchActivity stopwatchActivity) {
            long timeMs = System.currentTimeMillis();
            long delayMs = MINUTE_INTERVAL_MS - (timeMs % MINUTE_INTERVAL_MS);
            Log.d(TAG, "NOT ambient - delaying by: " + delayMs);
            stopwatchActivity.mActiveClockUpdateHandler
                    .sendEmptyMessageDelayed(R.id.msg_update, delayMs);
        }
    }

    /**
     * Handle stopwatch changes in active mode.
     */
    private static class UpdateStopwatchHandler extends UpdateHandler {

        public UpdateStopwatchHandler(StopwatchActivity reference) {
            super(reference);
        }

        @Override
        public void handleUpdate(StopwatchActivity stopwatchActivity) {
            stopwatchActivity.updateDisplayAndSetRefresh();
        }
    }
    // </editor-fold>
}
