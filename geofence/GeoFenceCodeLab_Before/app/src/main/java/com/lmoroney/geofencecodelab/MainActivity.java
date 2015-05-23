package com.lmoroney.geofencecodelab;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.model.LatLng;

import java.util.ArrayList;
import java.util.Map;

public class MainActivity extends Activity implements
        GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener, ResultCallback<Status> {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
    }

    public void populateGeofenceList() {
    }

    protected synchronized void buildGoogleApiClient() {
    }

    @Override
    protected void onStart() {
    }

    @Override
    protected void onStop() {
    }

    @Override
    public void onConnected(Bundle connectionHint) {
    }

    @Override
    public void onConnectionFailed(ConnectionResult result) {
    }

    @Override
    public void onConnectionSuspended(int cause) {
    }

    public void addGeofencesButtonHandler(View view) {
    }

    private GeofencingRequest getGeofencingRequest() {
    }

    private PendingIntent getGeofencePendingIntent() {
    }

    public void onResult(Status status) {
    }

}
