package com.carnivalmobile.carnivalcordovaplugin;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.XmlResourceParser;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.text.TextUtils;
import android.util.Log;
import android.location.Location;
import android.support.v4.content.LocalBroadcastManager;

import com.carnival.sdk.Carnival;
import com.carnival.sdk.CarnivalImpressionType;
import com.carnival.sdk.Carnival.TagsHandler;
import com.carnival.sdk.CarnivalStreamActivity;
import com.carnival.sdk.MessageActivity;
import com.carnival.sdk.Message;

public class CarnivalCordovaPlugin extends CordovaPlugin {

	private static final String ACTION_START_ENGINE = "startEngine";
	private static final String ACTION_GET_TAGS = "getTags";
	private static final String ACTION_SET_TAGS = "setTags";
	private static final String ACTION_SHOW_MESSAGE_STREAM = "showMessageStream";
	private static final String ACTION_UPDATE_LOCATION = "updateLocation";
	private static final String ACTION_LOG_EVENT = "logEvent";
	private static final String ACTION_SET_STRING = "setString";
	private static final String ACTION_SET_INTEGER = "setInteger";
	private static final String ACTION_SET_FLOAT = "setFloat";
	private static final String ACTION_SET_BOOLEAN = "setBool";
	private static final String ACTION_SET_DATE = "setDate";
	private static final String ACTION_REMOVE_ATTRIBUTE = "removeAttribute";
	private static final String ACTION_UNREAD_COUNT = "unreadCount";
	private static final String ACTION_DEVICE_ID = "deviceID";
	private static final String ACTION_PRESENT_DETAIL = "presentMessageDetail";
	private static final String ACTION_DISMISS_DETAIL = "dismissMessageDetail";
	private static final String ACTION_MESSAGES = "messages";
	private static final String ACTION_IN_APP_ENABLED = "setInAppNotificationsEnabled";
	private static final String ACTION_REGISTER_IMPRESSION = "registerImpression";
	private static final String ACTION_REMOVE_MESSAGE = "removeMessage";
	private static final String ACTION_MARK_READ = "markMessageAsRead";
	private static final String ACTION_SET_USER_ID = "setUserId";
	
	private final BroadcastReceiver unreadCountReceiver = new BroadcastReceiver() {
			@Override
			public void onReceive(Context context, Intent intent) {
				final int unreadCount = intent.getIntExtra(Carnival.EXTRA_UNREAD_MESSAGE_COUNT, 0);
				final String javascript = "javascript:var event = new CustomEvent('unreadcountdidchange', { detail : {'unreadCount': %d }}); document.dispatchEvent(event);";

				CarnivalCordovaPlugin.this.webView.loadUrl(String.format(javascript, unreadCount));
			}
		};

	private void setup() {
		LocalBroadcastManager broadcastManager = LocalBroadcastManager.getInstance(this.cordova.getActivity());
		broadcastManager.registerReceiver(unreadCountReceiver, new IntentFilter(Carnival.ACTION_MESSAGE_COUNT_UPDATE));
	}

	@Override
	public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
		
		if (ACTION_START_ENGINE.equals(action)) {
			startEngine();
		} else if (ACTION_GET_TAGS.equals(action)) {
			Carnival.getTags(new TagsHandler() {
				
				@Override
				public void onSuccess(List<String> arg0) {
					callbackContext.success(new JSONArray(arg0));
				}
				
				@Override
				public void onFailure(Error arg0) {
					callbackContext.error(arg0.getLocalizedMessage());
				}
			});
		} else if (ACTION_SET_TAGS.equals(action)) {
				setTags(args);	
		} else if (ACTION_SHOW_MESSAGE_STREAM.equals(action)) {
			showMessageStream();
		} else if (ACTION_UPDATE_LOCATION.equals(action)) {
			updateLocation(args.getJSONArray(0));
		} else if (ACTION_LOG_EVENT.equals(action)) {
			logEvent(args.getJSONArray(0));
		} else if (ACTION_SET_STRING.equals(action)) {
			setString(args.getJSONArray(0));
		} else if (ACTION_SET_INTEGER.equals(action)) {
			setInteger(args.getJSONArray(0));
		} else if (ACTION_SET_FLOAT.equals(action)) {
			setFloat(args.getJSONArray(0));
		} else if (ACTION_SET_BOOLEAN.equals(action)) {
			setBoolean(args.getJSONArray(0));
		} else if (ACTION_SET_DATE.equals(action)) {
			setDate(args.getJSONArray(0));
		} else if (ACTION_REMOVE_ATTRIBUTE.equals(action)) {
			removeAttribute(args.getJSONArray(0));
		} else if (ACTION_UNREAD_COUNT.equals(action)) {
			callbackContext.success(""+Carnival.getUnreadMessageCount());
		} else if (ACTION_DEVICE_ID.equals(action)) {
			callbackContext.success(Carnival.getDeviceId());
		}else if (ACTION_PRESENT_DETAIL.equals(action)) {
			presentMessageDetail(args.getJSONObject(0));
		}else if (ACTION_DISMISS_DETAIL.equals(action)) {
			//Do Nothing
		} else if (ACTION_MESSAGES.equals(action)) {
			getMessages(callbackContext);
		} else if (ACTION_IN_APP_ENABLED.equals(action)) {
			setInAppNotificationsEnabled(args.getJSONArray(0));
		} else if (ACTION_REGISTER_IMPRESSION.equals(action)) {
			registerImpression(args, callbackContext);
		} else if (ACTION_REMOVE_MESSAGE.equals(action)) {
			removeMessage(args.getJSONObject(0), callbackContext);
		}else if (ACTION_MARK_READ.equals(action)) {
			markMessagesAsRead(args, callbackContext);
		} else if (ACTION_SET_USER_ID.equals(action)) {
			setUserId(args.getJSONArray(0), callbackContext);
		} else {
			return false;
		}
		
		return true;
	}

	/**
	 * 
	 */
	private void startEngine() {
		Activity activity = this.cordova.getActivity();
		String packageName = activity.getPackageName();
		int xmlId = activity.getResources().getIdentifier("config", "xml", packageName);
		XmlResourceParser parser = activity.getResources().getXml(xmlId);
		
		String carnivalAppKey = "";
		String carnivalProjectNumber = "";
		
		try {
			int eventType = parser.getEventType();
			
			while (eventType != XmlPullParser.END_DOCUMENT && (TextUtils.isEmpty(carnivalAppKey) || TextUtils.isEmpty(carnivalProjectNumber))) {
				
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
						} else if ("carnival_android_project_number".equals(attNameValue)) {
							carnivalProjectNumber = attValue;
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
		Carnival.startEngine(this.cordova.getActivity(), carnivalProjectNumber, carnivalAppKey);

		setup();
	}
	
	/**
	 * @param args
	 * @throws JSONException
	 */
	private void setTags(JSONArray args) throws JSONException {
		JSONArray jsonTags = args.getJSONArray(0);
		
		List<String> list = new ArrayList<String>();
		for (int i=0; i<jsonTags.length(); i++) {
			list.add( jsonTags.getString(i) );
		}
		
		Carnival.setTags(list);
	}
	
	/**
	 * 
	 */
	private void showMessageStream() {

		this.cordova.getThreadPool().execute (new Runnable() {
			public void run() {
				Activity activity = CarnivalCordovaPlugin.this.cordova.getActivity();
				Intent i = new Intent(activity, CarnivalStreamActivity.class);
				activity.startActivity(i);
			}
		});
	}

	private void updateLocation(JSONArray args) throws JSONException {
		double lat = args.getDouble(0);
		double lon = args.getDouble(1);

		Location location = new Location("Carnival Cordova");
		location.setLatitude(lat);
		location.setLongitude(lon);

		Carnival.updateLocation(location);
	}

	private void logEvent(JSONArray args) throws JSONException {
		String event = args.getString(0);
		Carnival.logEvent(event);
	}

	private void setInAppNotificationsEnabled(JSONArray args) throws JSONException {
		boolean enable = args.getBoolean(0);
		Carnival.setInAppNotificationsEnabled(enable);
	}

	private void setString(JSONArray args) throws JSONException {
		String key = args.getString(1);
		String value = args.getString(0);

		Carnival.setAttribute(key, value);
	}

	private void setInteger(JSONArray args) throws JSONException {
		String key = args.getString(1);
		int value = args.getInt(0);

		Carnival.setAttribute(key, value);
	}

	private void setBoolean(JSONArray args) throws JSONException {
		String key = args.getString(1);
		boolean value = args.getBoolean(0);

		Carnival.setAttribute(key, value);
	}

	private void setFloat(JSONArray args) throws JSONException {
		String key = args.getString(1);
		float value = (float) args.getDouble(0);

		Carnival.setAttribute(key, value);
	}

	private void setDate(JSONArray args) throws JSONException {
		String key = args.getString(1);
		Date value = new Date(args.getInt(0));

		Carnival.setAttribute(key, value);
	}

	private void removeAttribute(JSONArray args) throws JSONException {
		String key = args.getString(0);

		Carnival.removeAttribute(key);
	}

	private void presentMessageDetail(JSONObject args) throws JSONException {
		Intent i = new Intent(this.cordova.getActivity(), MessageActivity.class);
		String messageId = args.optString("id", "");
		i.putExtra(Carnival.EXTRA_MESSAGE_ID, messageId);
		this.cordova.getActivity().startActivity(i);
	}

	private void setUserId(JSONArray args, final CallbackContext callbackContext) throws JSONException {
		String value = args.getString(0);
		
		Carnival.setUserId(value, new Carnival.CarnivalHandler<Void>() {
            @Override
            public void onSuccess(Void value) {
                callbackContext.success(new JSONArray());
            }

            @Override
            public void onFailure(Error error) {
            	callbackContext.error(error.getLocalizedMessage());
            }
        });
	}

	private void getMessages(final CallbackContext callbackContext) {
		Carnival.getMessages(new Carnival.MessagesHandler() {
			@Override
			public void onSuccess(ArrayList<Message> messages) {

				try {
					Method toJsonMethod = Message.class.getDeclaredMethod("toJSON");
					toJsonMethod.setAccessible(true);
					JSONArray messagesJson = new JSONArray();

					for (Message message: messages) {
						JSONObject obj = (JSONObject) toJsonMethod.invoke(message);
						messagesJson.put(obj);
					}

					callbackContext.success(messagesJson);
				} catch (Exception e) {
					callbackContext.error(e.getLocalizedMessage());
				}
			}

			@Override
			public void onFailure(Error error) {
				callbackContext.error(error.getLocalizedMessage());
			}
		});
	}

	private void registerImpression(JSONArray args, final CallbackContext callbackContext) throws JSONException {
		int typeCode = args.getInt(0);
		JSONObject messageJson = args.getJSONObject(1);

		Message message = null;
		try {
			Constructor<Message> constructor;
			constructor = Message.class.getDeclaredConstructor(JSONObject.class);
			constructor.setAccessible(true);
			message = constructor.newInstance(messageJson);
		} catch (Exception e) {
			callbackContext.error(e.getLocalizedMessage());
		}

		CarnivalImpressionType type = null;

		if (typeCode == 2000) type = CarnivalImpressionType.IMPRESSION_TYPE_STREAM_VIEW;
		else if (typeCode == 2001) type = CarnivalImpressionType.IMPRESSION_TYPE_DETAIL_VIEW;
		else if (typeCode == 2002) type = CarnivalImpressionType.IMPRESSION_TYPE_IN_APP_VIEW;

		Carnival.registerMessageImpression(type, message);
		callbackContext.success();

	}

	private void removeMessage(JSONObject messageJson, final CallbackContext callbackContext) {
		Message message = null;
		try {
			Constructor<Message> constructor;
			constructor = Message.class.getDeclaredConstructor(JSONObject.class);
			constructor.setAccessible(true);
			message = constructor.newInstance(messageJson);
		} catch (Exception e) {
			e.printStackTrace();
		}

		Carnival.deleteMessage(message, new Carnival.MessageDeletedHandler() {
			@Override
			public void onSuccess() {
				callbackContext.success();
			}

			@Override
			public void onFailure(Error error) {
				callbackContext.error(error.getLocalizedMessage());
			}
		});
	}

	private void markMessagesAsRead(JSONArray messagesJson, final CallbackContext callbackContext) {
		ArrayList<Message> messages = new ArrayList<Message>();

		for (int i = 0; i < messagesJson.length(); i++) {
			Message message = null;
			try {
				JSONObject messageJson = messagesJson.getJSONObject(i);
				Constructor<Message> constructor;
				constructor = Message.class.getDeclaredConstructor(JSONObject.class);
				constructor.setAccessible(true);
				message = constructor.newInstance(messageJson);
			} catch (Exception e) {
				e.printStackTrace();
			}
			if (message != null) {
				messages.add(message);
			}
		}
		Carnival.setMessagesRead(messages, new Carnival.MessagesReadHandler() {
            @Override
            public void onSuccess() {
                callbackContext.success();
            }

            @Override
            public void onFailure(Error error) {
            	callbackContext.error(error.getLocalizedMessage());
            }
        });
	}

}
