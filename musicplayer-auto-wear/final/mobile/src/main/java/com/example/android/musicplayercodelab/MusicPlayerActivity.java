/*
 * Copyright (C) 2014 The Android Open Source Project
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
package com.example.android.musicplayercodelab;

import android.app.Activity;
import android.content.ComponentName;
import android.media.MediaMetadata;
import android.media.browse.MediaBrowser;
import android.media.session.MediaController;
import android.media.session.PlaybackState;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

/**
 * An Activity to browse and play media.
 */
public class MusicPlayerActivity extends AppCompatActivity {

    private BrowseAdapter mBrowserAdapter;
    private ImageButton mPlayPause;
    private TextView mTitle;
    private TextView mSubtitle;
    private ImageView mAlbumArt;
    private ViewGroup mPlaybackControls;

    private MediaMetadata mCurrentMetadata;
    private PlaybackState mCurrentState;

    private MediaBrowser mMediaBrowser;

    private final MediaBrowser.ConnectionCallback mConnectionCallback =
            new MediaBrowser.ConnectionCallback() {
                @Override
                public void onConnected() {
                    mMediaBrowser.subscribe(mMediaBrowser.getRoot(), mSubscriptionCallback);
                    MediaController mediaController = new MediaController(
                            MusicPlayerActivity.this, mMediaBrowser.getSessionToken());
                    updatePlaybackState(mediaController.getPlaybackState());
                    updateMetadata(mediaController.getMetadata());
                    mediaController.registerCallback(mMediaControllerCallback);
                    setMediaController(mediaController);
                }
            };

    // Receive callbacks from the MediaController. Here we update our state such as which queue
    // is being shown, the current title and description and the PlaybackState.
    private final MediaController.Callback mMediaControllerCallback = new MediaController.Callback() {
        @Override
        public void onMetadataChanged(MediaMetadata metadata) {
            updateMetadata(metadata);
            mBrowserAdapter.notifyDataSetChanged();
        }

        @Override
        public void onPlaybackStateChanged(PlaybackState state) {
            updatePlaybackState(state);
            mBrowserAdapter.notifyDataSetChanged();
        }

        @Override
        public void onSessionDestroyed() {
            updatePlaybackState(null);
            mBrowserAdapter.notifyDataSetChanged();
        }
    };

    private final MediaBrowser.SubscriptionCallback mSubscriptionCallback =
        new MediaBrowser.SubscriptionCallback() {
            @Override
            public void onChildrenLoaded(String parentId, List<MediaBrowser.MediaItem> children) {
                onMediaLoaded(children);
            }
        };

    private void onMediaLoaded(List<MediaBrowser.MediaItem> media) {
        mBrowserAdapter.clear();
        mBrowserAdapter.addAll(media);
        mBrowserAdapter.notifyDataSetChanged();
    }

    private void onMediaItemSelected(MediaBrowser.MediaItem item) {
        if (item.isPlayable()) {
            getMediaController().getTransportControls().playFromMediaId(item.getMediaId(), null);
        }
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_player);
        setTitle(getString(R.string.app_name));
        setSupportActionBar((Toolbar) findViewById(R.id.toolbar));


        mBrowserAdapter = new BrowseAdapter(this);

        ListView listView = (ListView) findViewById(R.id.list_view);
        listView.setAdapter(mBrowserAdapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                MediaBrowser.MediaItem item = mBrowserAdapter.getItem(position);
                onMediaItemSelected(item);
            }
        });

        // Playback controls configuration:
        mPlaybackControls = (ViewGroup) findViewById(R.id.playback_controls);
        mPlayPause = (ImageButton) findViewById(R.id.play_pause);
        mPlayPause.setEnabled(true);
        mPlayPause.setOnClickListener(mPlaybackButtonListener);

        mTitle = (TextView) findViewById(R.id.title);
        mSubtitle = (TextView) findViewById(R.id.artist);
        mAlbumArt = (ImageView) findViewById(R.id.album_art);
    }


    @Override
    public void onStart() {
        super.onStart();

        mMediaBrowser = new MediaBrowser(this,
               new ComponentName(this, MusicService.class), mConnectionCallback, null);
        mMediaBrowser.connect();
    }

    @Override
    public void onStop() {
        super.onStop();
        try {
            getMediaController().unregisterCallback(mMediaControllerCallback);
            mMediaBrowser.unsubscribe(mMediaBrowser.getRoot());
        } finally {
            mMediaBrowser.disconnect();
        }
    }

    private void updatePlaybackState(PlaybackState state) {
        mCurrentState = state;
        if (state == null || state.getState() == PlaybackState.STATE_PAUSED ||
                state.getState() == PlaybackState.STATE_STOPPED) {
            mPlayPause.setImageDrawable(getDrawable(R.drawable.ic_play_arrow_black_36dp));
        } else {
            mPlayPause.setImageDrawable(getDrawable(R.drawable.ic_pause_black_36dp));
        }
        mPlaybackControls.setVisibility(state == null ? View.GONE : View.VISIBLE);
    }

    private void updateMetadata(MediaMetadata metadata) {
        mCurrentMetadata = metadata;
        mTitle.setText(metadata == null ? "" : metadata.getDescription().getTitle());
        mSubtitle.setText(metadata == null ? "" : metadata.getDescription().getSubtitle());
        mAlbumArt.setImageBitmap(metadata == null ? null : MusicLibrary.getAlbumBitmap(this,
                metadata.getDescription().getMediaId()));
        mBrowserAdapter.notifyDataSetChanged();
    }

    // An adapter for showing the list of browsed MediaItem's
    private class BrowseAdapter extends ArrayAdapter<MediaBrowser.MediaItem> {

        public BrowseAdapter(Activity context) {
            super(context, R.layout.media_list_item, new ArrayList<MediaBrowser.MediaItem>());
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            MediaBrowser.MediaItem item = getItem(position);
            int itemState = MediaItemViewHolder.STATE_NONE;
            if (item.isPlayable()) {
                String itemMediaId = item.getDescription().getMediaId();
                int playbackState = PlaybackState.STATE_NONE;
                if (mCurrentState != null) {
                    playbackState = mCurrentState.getState();
                }
                if (mCurrentMetadata != null &&
                        itemMediaId.equals(mCurrentMetadata.getDescription().getMediaId())) {
                    if (playbackState == PlaybackState.STATE_PLAYING ||
                        playbackState == PlaybackState.STATE_BUFFERING) {
                        itemState = MediaItemViewHolder.STATE_PLAYING;
                    } else if (playbackState != PlaybackState.STATE_ERROR) {
                        itemState = MediaItemViewHolder.STATE_PAUSED;
                    }
                }
            }
            return MediaItemViewHolder.setupView((Activity) getContext(), convertView, parent,
                item.getDescription(), itemState);
        }
    }

    private final View.OnClickListener mPlaybackButtonListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            final int state = mCurrentState == null ?
                    PlaybackState.STATE_NONE : mCurrentState.getState();
            if (state == PlaybackState.STATE_PAUSED ||
                    state == PlaybackState.STATE_STOPPED ||
                    state == PlaybackState.STATE_NONE) {

                if (mCurrentMetadata == null) {
                    mCurrentMetadata = MusicLibrary.getMetadata(MusicPlayerActivity.this,
                            MusicLibrary.getMediaItems().get(0).getMediaId());
                    updateMetadata(mCurrentMetadata);
                }
                getMediaController().getTransportControls().playFromMediaId(
                        mCurrentMetadata.getDescription().getMediaId(), null);

            } else {
                getMediaController().getTransportControls().pause();
            }
        }
    };

}
