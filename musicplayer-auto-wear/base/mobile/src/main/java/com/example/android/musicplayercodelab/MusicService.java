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

 import android.media.MediaMetadata;
 import android.media.browse.MediaBrowser.MediaItem;
 import android.media.session.MediaSession;
 import android.media.session.PlaybackState;
 import android.os.Bundle;
 import android.service.media.MediaBrowserService;

 import java.util.List;

public class MusicService extends MediaBrowserService {

    private MediaSession mSession;
    private MediaNotificationManager mMediaNotificationManager;
    private PlaybackManager mPlayback;

    final MediaSession.Callback mCallback = new MediaSession.Callback() {
        @Override
        public void onPlayFromMediaId(String mediaId, Bundle extras) {
            mSession.setActive(true);
            MediaMetadata metadata = MusicLibrary.getMetadata(MusicService.this, mediaId);
            mSession.setMetadata(metadata);
            mPlayback.play(metadata);
        }

        @Override
        public void onPlay() {
            if (mPlayback.getCurrentMediaId() != null) {
                onPlayFromMediaId(mPlayback.getCurrentMediaId(), null);
            }
        }

        @Override
        public void onPause() {
            mPlayback.pause();
        }

        @Override
        public void onStop() {
            stopSelf();
        }

        @Override
        public void onSkipToNext() {
            onPlayFromMediaId(MusicLibrary.getNextSong(mPlayback.getCurrentMediaId()), null);
        }

        @Override
        public void onSkipToPrevious() {
            onPlayFromMediaId(MusicLibrary.getPreviousSong(mPlayback.getCurrentMediaId()), null);
        }
    };

    /*
         * (non-Javadoc)
         * @see android.app.Service#onCreate()
         */
    @Override
    public void onCreate() {
        super.onCreate();

        // Start a new MediaSession
        mSession = new MediaSession(this, "MusicService");
        mSession.setCallback(mCallback);
        mSession.setFlags(MediaSession.FLAG_HANDLES_MEDIA_BUTTONS |
                MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS);
        setSessionToken(mSession.getSessionToken());

        mPlayback = new PlaybackManager(this, new PlaybackManager.Callback() {
            @Override
            public void onPlaybackStatusChanged(PlaybackState state) {
                mSession.setPlaybackState(state);
                mMediaNotificationManager.update(mPlayback.getCurrentMedia(), state, getSessionToken());
            }
        });

        mMediaNotificationManager = new MediaNotificationManager(this);
    }

    /**
     * (non-Javadoc)
     * @see android.app.Service#onDestroy()
     */
    @Override
    public void onDestroy() {
        // Service is being killed, so make sure we release our resources
        mPlayback.stop();

        // Always release the MediaSession to clean up resources
        // and notify associated MediaController(s).
        mSession.release();
    }

    @Override
    public BrowserRoot onGetRoot(String clientPackageName, int clientUid, Bundle rootHints) {
        return new BrowserRoot(MusicLibrary.getRoot(), null);
    }

    @Override
    public void onLoadChildren(final String parentMediaId, final Result<List<MediaItem>> result) {
        result.sendResult(MusicLibrary.getMediaItems());
    }

}
