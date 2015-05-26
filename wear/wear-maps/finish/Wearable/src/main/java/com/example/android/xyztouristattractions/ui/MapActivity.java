/*
 * Copyright (C) 2015 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.android.xyztouristattractions.ui;

import android.app.Activity;
import android.os.Bundle;
import android.support.wearable.view.DismissOverlayView;

import com.example.android.xyztouristattractions.R;
import com.example.android.xyztouristattractions.common.Attraction;
import com.example.android.xyztouristattractions.common.Constants;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

/**
 * Sample that shows how to set up a basic Google Map on Android Wear. This Activity is started from
 * AttractionsActivity when the user taps the lite mode map.
 */
public class MapActivity extends Activity implements OnMapReadyCallback,
        GoogleMap.OnMapLongClickListener {

    /**
     * Overlay that shows a short help text when first launched. It also provides an option to
     * exit the app.
     */
    private DismissOverlayView mDismissOverlay;

    /**
     * The map. It is initialized when the map has been fully loaded and is ready to be used.
     * @see #onMapReady(com.google.android.gms.maps.GoogleMap)
     */
    private GoogleMap mMap;

    /**
     * The attraction. It will be used to center and highlight on the map, once loaded.
     */
    private Attraction mAttraction;

    public void onCreate(Bundle savedState) {
        super.onCreate(savedState);

        // Set the layout. It only contains a SupportMapFragment and a DismissOverlay.
        setContentView(R.layout.activity_map);

        // Obtain the Attraction that we need to display.
        mAttraction = getIntent().getParcelableExtra(Constants.EXTRA_ATTRACTION);

        // Obtain the DismissOverlayView and display the intro help text.
        mDismissOverlay = (DismissOverlayView) findViewById(R.id.map_dismiss_overlay);
        mDismissOverlay.setIntroText(R.string.exit_intro_text);
        mDismissOverlay.showIntroIfNecessary();

        // Obtain the MapFragment and set the async listener to be notified when the map is ready.
        MapFragment mapFragment = (MapFragment) getFragmentManager()
                        .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        // Map is ready to be used.
        mMap = googleMap;

        // Set the long click listener as a way to exit the map.
        mMap.setOnMapLongClickListener(this);

        if (mAttraction != null) {
            // Add a marker with a title that is shown in its info window.
            mMap.addMarker(new MarkerOptions()
                    .position(mAttraction.location)
                    .title(mAttraction.name));

            // Move the camera to show the marker.
            mMap.moveCamera(CameraUpdateFactory.newLatLng(mAttraction.location));
        }
    }

    @Override
    public void onMapLongClick(LatLng latLng) {
        // Display the dismiss overlay with a button to exit this activity.
        mDismissOverlay.show();
    }
}
