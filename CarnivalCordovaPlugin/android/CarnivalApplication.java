package com.carnivalmobile.carnivalcordovaplugin;

import android.app.Application;
import android.content.res.XmlResourceParser;
import android.text.TextUtils;

import com.carnival.sdk.Carnival;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;

/**
 * Created by danielebernardi on 1/20/17.
 */

public class CarnivalApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        String packageName = this.getPackageName();
        int xmlId = this.getResources().getIdentifier("config", "xml", packageName);
        XmlResourceParser parser = this.getResources().getXml(xmlId);
        String carnivalAppKey = "";

        try {
            int eventType = parser.getEventType();

            while (eventType != XmlPullParser.END_DOCUMENT && TextUtils.isEmpty(carnivalAppKey)) {

                if(eventType == XmlPullParser.START_TAG) {
                    if ("preference".equals(parser.getName())) {
                        String attNameValue = "";
                        String attValue = "";
                        for (int i = 0; i < parser.getAttributeCount(); i++) {
                            String attName = parser.getAttributeName(i);
                            if (attName.equals("name")) {
                                attNameValue = parser.getAttributeValue(i);
                            } else if (attName.equals("value")) {
                                attValue = parser.getAttributeValue(i);
                            }
                        }

                        if ("carnival_android_app_key".equals(attNameValue)) {
                            carnivalAppKey = attValue;
                        }
                    }

                }
                eventType = parser.next();
            }

        } catch (XmlPullParserException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        parser.close();
        Carnival.setInAppNotificationsEnabled(false);
        Carnival.startEngine(this, carnivalAppKey);
    }
}
