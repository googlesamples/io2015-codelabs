/*
 * Copyright 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.android.voicecamera;

import android.app.Activity;
import android.app.VoiceInteractor;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

public class TakePictureActivity extends Activity {
    private static String TAG = "TakePictureActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate: ");
        Intent intent = getIntent();
        if (intent == null) {
            finish();
        } else if (CameraActivity.needPermissions(this)) {
            startActivity(new Intent(this, CameraActivity.class)
                    .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
            finish();
            return;
        } else if (!isVoiceInteraction()) {
            Log.e(TAG, "Not voice interaction");
            if (intent != null) {
                intent.setComponent(null);
                intent.setPackage("com.google.android.GoogleCamera");
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
            finish();
            return;
        }

        setContentView(R.layout.activity_camera);
        CameraFragment fragment = CameraFragment.newInstance();
        fragment.setArguments(getIntent().getExtras());

        getFragmentManager().beginTransaction()
                .replace(R.id.container, fragment)
                .commit();
    }

    @Override
    protected void onStart() {
        Log.d(TAG, "onStart: ");
        super.onStart();
    }

    @Override
    protected void onResume() {
        Log.d(TAG, "onResume: ");
        super.onResume();
    }

    @Override
    protected void onPause() {
        Log.d(TAG, "onPause: ");
        super.onPause();
    }

    @Override
    protected void onStop() {
        Log.d(TAG, "onStop: ");
        super.onStop();
    }

    @Override
    protected void onRestart() {
        Log.d(TAG, "onRestart: ");
        super.onRestart();
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, "onDestroy: ");
        super.onDestroy();
    }
}
