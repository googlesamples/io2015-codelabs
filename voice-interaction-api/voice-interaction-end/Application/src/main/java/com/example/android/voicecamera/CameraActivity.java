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

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.widget.Toast;

public class CameraActivity extends Activity {

    private static final String TAG = "CameraActivity";
    private static final int PERMISSIONS_REQUEST_ALL_PERMISSIONS = 1;
    private Bundle mSavedInstanceState;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate: ");
        Intent intent = getIntent();

        if (needPermissions(this)) {
            requestPermissions();
        } else if (intent != null) {
            intent.setComponent(null);
            intent.setPackage("com.google.android.GoogleCamera");
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            finish();
        } else {
            finish();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[],
                                           int[] grantResults) {
        Log.d(TAG, "onRequestPermissionsResult: ");
        switch (requestCode) {
            case PERMISSIONS_REQUEST_ALL_PERMISSIONS:
                boolean hasAllPermissions = true;
                for (int i = 0; i < grantResults.length; ++i) {
                    if (grantResults[i] != PackageManager.PERMISSION_GRANTED) {
                        hasAllPermissions = false;
                        Log.e(TAG, "Unable to get permission " + permissions[i]);
                    }
                }
                if (hasAllPermissions) {
                    finish();
                } else {
                    Toast.makeText(this,
                            "Unable to get all required permissions", Toast.LENGTH_LONG).show();
                    finish();
                    return;
                }
                break;
            default:
                Log.e(TAG, "Unexpected request code");
        }
    }

    static public boolean needPermissions(Activity activity) {
        Log.d(TAG, "needPermissions: ");
        return activity.checkSelfPermission(Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED
                || activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED;
    }

    private void requestPermissions() {
        Log.d(TAG, "requestPermissions: ");
        String[] permissions = new String[] {
            Manifest.permission.CAMERA,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
        };
        requestPermissions(permissions, PERMISSIONS_REQUEST_ALL_PERMISSIONS);
    }
}
