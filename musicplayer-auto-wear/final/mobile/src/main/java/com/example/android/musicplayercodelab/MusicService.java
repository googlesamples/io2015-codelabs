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

    @Override
    public void onCreate() {
        super.onCreate();

        // Start a new MediaSession
        mSession = new MediaSession(this, "MusicService");
        mSession.setCallback(mCallback);
        mSession.setFlags(MediaSession.FLAG_HANDLES_MEDIA_BUTTONS |
                MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS);
        setSessionToken(mSession.getSessionToken());

        final MediaNotificationManager mediaNotificationManager = new MediaNotificationManager(this);

        mPlayback = new PlaybackManager(this, new PlaybackManager.Callback() {
            @Override
            public void onPlaybackStatusChanged(PlaybackState state) {
                mSession.setPlaybackState(state);
                mediaNotificationManager.update(mPlayback.getCurrentMedia(), state, getSessionToken());
            }
        });
    }

    @Override
    public void onDestroy() {
        mPlayback.stop();
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
