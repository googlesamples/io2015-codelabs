/*
 * Copyright 2015 Google Inc. All rights reserved.
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

package com.example.android.xyztouristattractions.common;

import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;

import com.google.android.gms.maps.model.LatLng;

/**
 * A simple shared tourist attraction class to easily pass data around. Used
 * in both the mobile app and wearable app.
 *
 * Implements Parcelable so that Attractions can be passed from one Activity
 * to another. Note that the Wearable DataItem does not support Parcelable
 * items so it cannot be used for moving items from device to wearable.
 */
public class Attraction implements Parcelable {
    public String name;
    public String description;
    public String longDescription;
    public Uri imageUrl;
    public Uri secondaryImageUrl;
    public LatLng location;
    public String city;

    public Bitmap image;
    public Bitmap secondaryImage;
    public String distance;

    public Attraction() {}

    public Attraction(String name, String description, String longDescription, Uri imageUrl,
                      Uri secondaryImageUrl, LatLng location, String city) {
        this.name = name;
        this.description = description;
        this.longDescription = longDescription;
        this.imageUrl = imageUrl;
        this.secondaryImageUrl = secondaryImageUrl;
        this.location = location;
        this.city = city;
    }

    protected Attraction(Parcel in) {
        name = in.readString();
        description = in.readString();
        longDescription = in.readString();
        imageUrl = (Uri) in.readValue(Uri.class.getClassLoader());
        secondaryImageUrl = (Uri) in.readValue(Uri.class.getClassLoader());
        location = (LatLng) in.readValue(LatLng.class.getClassLoader());
        city = in.readString();
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(name);
        dest.writeString(description);
        dest.writeString(longDescription);
        dest.writeValue(imageUrl);
        dest.writeValue(secondaryImageUrl);
        dest.writeValue(location);
        dest.writeString(city);
    }

    @SuppressWarnings("unused")
    public static final Parcelable.Creator<Attraction> CREATOR = new Parcelable.Creator<Attraction>() {
        @Override
        public Attraction createFromParcel(Parcel in) {
            return new Attraction(in);
        }

        @Override
        public Attraction[] newArray(int size) {
            return new Attraction[size];
        }
    };

}
