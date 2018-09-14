
package com.qd.almo.baidumap;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class RNAmbaidumapModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNAmbaidumapModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNAmbaidumap";
  }
}