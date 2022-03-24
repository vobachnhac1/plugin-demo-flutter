package com.clv.nhacvo.clv_nhacvo_print;

import static java.sql.DriverManager.println;


import androidx.annotation.NonNull;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.*;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

import com.dantsu.escposprinter.EscPosPrinter;
import com.dantsu.escposprinter.connection.bluetooth.BluetoothConnection;
import com.dantsu.escposprinter.connection.bluetooth.BluetoothPrintersConnections;
import com.dantsu.escposprinter.textparser.PrinterTextParserImg;
import com.dantsu.escposprinter.exceptions.EscPosConnectionException;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/** ClvNhacvoPrintPlugin */
public class ClvNhacvoPrintPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, RequestPermissionsResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private static final String TAG = "BluetoothPrintPlugin";

  private MethodChannel channel;
  private MethodChannel channelPrint;
  private ArrayList<String> mDeviceList = new ArrayList<String>();
  private BluetoothAdapter mBluetoothAdapter;
  Set<BluetoothDevice> pairedDevices;
  ArrayList<DevicesModel> devices = new ArrayList<DevicesModel>();;
  public static final int PERMISSION_BLUETOOTH = 1;
  private Object initializationLock = new Object();


  private FlutterPluginBinding pluginBinding;
  private ActivityPluginBinding activityBinding;
  private Application application;
  private Activity activity;
  private Application context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    pluginBinding = flutterPluginBinding;
  }
  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    try {
        Map<String, Object> arguments = call.arguments();
        System.out.println("NHACVO_DEMO: I am here");
        System.out.println("NHACVO_DEMO: "+ call.method);

      if (call.method.toString() == "getPlatformVersion") {
        result.success("Android ${android.os.Build.VERSION.RELEASE}");
      } else  if (call.method.equals("getMessage")) {
        System.out.println("I am here getMessage");
        String message = "Android say hi!";
        result.success(message);
      } else if (call.method.equals("getDevices")) {
        System.out.println("I am here getDevices");
        ArrayList<DevicesModel> arrDevice = onGetDevicesBluetooth();
        result.success(arrDevice);
      } else if (call.method.equals("onPrint")) {
        System.out.println("I am here onPrint");
        byte[] bitmapInput = (byte[]) arguments.get("bitmapInput");
        int printerDpi = (int) arguments.get("printerDpi");
        int heightMax = (int) arguments.get("heightMax");
        int widthMax = (int) arguments.get("widthMax");
        Map<String, Object> arrStatus = onPrint(bitmapInput, printerDpi, widthMax, heightMax);
        result.success(arrStatus);
      }
    } catch (Exception e) {
      result.error("500", "Server Error", e.getMessage());
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channelPrint.setMethodCallHandler(null);
    channel.setMethodCallHandler(null);
    pluginBinding = null;

  }

  public ClvNhacvoPrintPlugin(){
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activityBinding = binding;
    setup(
            pluginBinding.getBinaryMessenger(),
            (Application) pluginBinding.getApplicationContext(),
            activityBinding.getActivity(),
            null,
            activityBinding);
  }

  @Override
  public void onDetachedFromActivity() {
    Log.i(TAG, "onDetachedFromActivity");
    context = null;
    activityBinding.removeRequestPermissionsResultListener(this);
    activityBinding = null;
    channel.setMethodCallHandler(null);
    channelPrint.setMethodCallHandler(null);
    channel = null;
    channelPrint = null;
    mBluetoothAdapter = null;
    application = null;
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }




  private void setup(
          final BinaryMessenger messenger,
          final Application application,
          final Activity activity,
          final PluginRegistry.Registrar registrar,
          final ActivityPluginBinding activityBinding) {
    synchronized (initializationLock) {
      Log.i(TAG, "setup");
      this.activity = activity;
      this.application = application;
      this.context = application;
      channel = new MethodChannel(messenger, "com.clv.demo/print");
      channelPrint = new MethodChannel(messenger, "com.clv.demo/print");
      channel.setMethodCallHandler(this);
      channelPrint.setMethodCallHandler(this);
      mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
      mBluetoothAdapter.startDiscovery();
      if (registrar != null) {
        // V1 embedding setup for activity listeners.
        registrar.addRequestPermissionsResultListener(this);
      } else {
        // V2 embedding setup for activity listeners.
        activityBinding.addRequestPermissionsResultListener(this);
      }
    }
  }


  private static final int REQUEST_FINE_LOCATION_PERMISSIONS = 1452;

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

    if (requestCode == REQUEST_FINE_LOCATION_PERMISSIONS) {
      if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//        startScan(pendingCall, pendingResult);
      } else {
//        pendingResult.error("no_permissions", "this plugin requires location permissions for scanning", null);
//        pendingResult = null;
      }
      return true;
    }
    return false;

  }
  private ArrayList<DevicesModel> onGetDevicesBluetooth() {
    pairedDevices = mBluetoothAdapter.getBondedDevices();
    devices = new ArrayList<>();

    for (BluetoothDevice bt : pairedDevices) {
      devices.add(new DevicesModel("", bt.getName(), bt.getAddress()));
    }
    return devices;
  }
  private Map<String, Object> onPrint(
          byte[] bitmapInput,
          int printerDpi ,
          int heightMax ,
          int widthMax  ){
    Map<String, Object>  dataMap = new HashMap<>();
    String _message = "";
    try {
      if (ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions( activityBinding.getActivity(), new String[]{Manifest.permission.BLUETOOTH}, PERMISSION_BLUETOOTH);
      } else {
        BluetoothConnection connection = BluetoothPrintersConnections.selectFirstPaired();
        if (connection != null) {
          EscPosPrinter printer = new EscPosPrinter(connection, printerDpi, 80f, 32);

          byte[]  bitMapData = bitmapInput;// stream.toByteArray()
          Bitmap decodedByte = BitmapFactory.decodeByteArray(bitMapData, 0, bitMapData.length);
          int widthTemp = decodedByte.getWidth();
          int heightTemp = decodedByte.getHeight();


          System.out.println( "-----------------Start--------------------");
          System.out.println( "Input:   $widthMax || $heightMax");
          System.out.println( "Curent:  $widthTemp || $heightTemp");
          System.out.println( "------------------End---------------------");

          widthTemp = widthMax < 580? 580 : widthMax;
          heightTemp = heightMax < 100? 200 : heightMax;
          Bitmap resizedBitmap = Bitmap.createScaledBitmap(decodedByte, widthTemp, heightTemp, false);
          decodedByte.recycle();
          int width = resizedBitmap.getWidth();
          int height = resizedBitmap.getHeight();

          StringBuilder textToPrint = new StringBuilder();
          for(int y = 0; y < height; y += 256) {
            Bitmap bitmap = Bitmap.createBitmap(resizedBitmap, 0, y, width, (y + 256 >= height) ? height - y : 256);
            textToPrint.append("[C]<img>" + PrinterTextParserImg.bitmapToHexadecimalString(printer, bitmap) + "</img>\n");
          }
          textToPrint.append("[C]Printed!!!\n");
          printer.printFormattedTextAndCut(textToPrint.toString());
          _message = "Success";
        } else {
          println("\"No printer was connected!\"");
          _message = "\"No printer was connected!\"";
          Map<String, Object> arrStatus = onPrint(bitmapInput, printerDpi, widthMax, heightMax);
        }
      }
    }
    catch (Exception e) {
      _message = "Error";
      println(e.getMessage());
    }
    dataMap.put("message",_message);
    return dataMap;
  }
}

class DevicesModel{
//  val id: String?, val deviceName: String?, val deviceAddress: String?
  String id;

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public String getDeviceName() {
    return deviceName;
  }

  public void setDeviceName(String deviceName) {
    this.deviceName = deviceName;
  }

  public String getDeviceAddress() {
    return deviceAddress;
  }

  public void setDeviceAddress(String deviceAddress) {
    this.deviceAddress = deviceAddress;
  }

  String deviceName;
  String deviceAddress;

  DevicesModel(String id, String deviceName, String deviceAddress){
    this.id = id;
    this.deviceName = deviceName;
    this.deviceAddress = deviceAddress;
  }
}
