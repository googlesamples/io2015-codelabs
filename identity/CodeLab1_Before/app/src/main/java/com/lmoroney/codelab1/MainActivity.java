package com.lmoroney.codelab1;

import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentSender;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.SignInButton;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.plus.People;
import com.google.android.gms.plus.Plus;


public class MainActivity extends FragmentActivity implements
        GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener,
        View.OnClickListener {

    private static final String TAG = "logincl";

    private static final int SIGNED_IN = 0;
    private static final int STATE_SIGNING_IN = 1;
    private static final int STATE_IN_PROGRESS = 2;
    private static final int RC_SIGN_IN = 0;

    private GoogleApiClient mGoogleApiClient;
    private int mSignInProgress;
    private PendingIntent mSignInIntent;

    private SignInButton mSignInButton;
    private Button mSignOutButton;
    private Button mRevokeButton;
    private TextView mStatus;


    @Override
    public void onCreate(Bundle savedInstanceState) {

    }


    private GoogleApiClient buildGoogleApiClient() {

    }

    @Override
    protected void onStart() {

    }

    @Override
    protected void onStop() {

    }

    public void onConnectionSuspended(int cause) {

    }

    @Override
    public void onConnected(Bundle connectionHint) {


    }

    @Override
    public void onConnectionFailed(ConnectionResult result) {

    }

    private void onSignedOut() {


    }

    private void resolveSignInError() {

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode,
                                    Intent data) {

    }

    @Override
    public void onClick(View v) {
        
    }
}
