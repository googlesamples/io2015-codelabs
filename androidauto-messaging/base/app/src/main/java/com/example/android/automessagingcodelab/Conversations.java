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

package com.example.android.automessagingcodelab;

import java.util.concurrent.ThreadLocalRandom;

/**
 * A simple class that denotes unread conversations and messages. In a real world application,
 * this would be replaced by a content provider that actually gets the unread messages to be
 * shown to the user.
 */
public class Conversations {

    /**
     * Set of strings used as messages by the sample.
     */
    private static final String[] MESSAGES = new String[]{
            "Are you at home?",
            "Can you give me a call?",
            "Hey yt?",
            "Don't forget to get some milk on your way back home",
            "Is that project done?",
            "Did you finish the Messaging app yet?"
    };

    /**
     * Senders of all the messages.
     */
    public static final String SENDER_NAME = "John Doe";

    /**
     * A static conversation Id for all our messages.
     */
    public static final int CONVERSATION_ID = 13;

    private Conversations() {
    }

    public static String getUnreadMessage() {
        return MESSAGES[ThreadLocalRandom.current().nextInt(0, MESSAGES.length)];
    }
}
