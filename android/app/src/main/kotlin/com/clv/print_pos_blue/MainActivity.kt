package com.clv.print_pos_blue

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.pm.PackageManager

import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.lang.Exception
import java.lang.StringBuilder
import java.util.ArrayList
import java.util.HashMap
import android.graphics.Bitmap
import android.graphics.BitmapFactory


import com.dantsu.escposprinter.EscPosPrinter
import com.dantsu.escposprinter.connection.bluetooth.BluetoothConnection
import com.dantsu.escposprinter.connection.bluetooth.BluetoothPrintersConnections
import com.dantsu.escposprinter.textparser.PrinterTextParserImg


class MainActivity: FlutterActivity() {
    /*override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }*/
    private val CHANNEL_PRINT: String? = "com.clv.demo/print"
    private val CHANNEL_BATTERY: String? = "com.clv.demo/battery"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        // khởi tạo bluetooth
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        mBluetoothAdapter?.startDiscovery()
        // getFlutterView () == getFlutterEngine().getDartExecutor().getBinaryMessenger()
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_PRINT).setMethodCallHandler { call, result ->
            try {
                val arguments = call.arguments<Map<String, Any>>()
                if (call.method == "getMessage") {
                    val message = "Android say hi!"
                    result.success(message)
                } else if (call.method == "getDevices") {
                    val arrDevice = onGetDevicesBluetooth()
                    result.success(arrDevice)
                } else if (call.method == "onPrint") {
                    System.out.println("I am here");
                    val bitmapInput = arguments["bitmapInput"] as ByteArray;
                    val printerDpi = arguments["printerDpi"] as Int;
                    val heightMax = arguments["heightMax"] as Int
                    val widthMax = arguments["widthMax"] as Int
                    val arrStatus = onPrint(bitmapInput, printerDpi, widthMax, heightMax)
                    result.success(arrStatus)
                }
            } catch (e: Exception) {
                result.error("500", "Server Error", e.message)
            }
        }

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_BATTERY).setMethodCallHandler { call, result ->
            try {
                if (call.method == "getPlatformVersion") {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                } else if (call.method == "getBatteryLevel") {
                    result.success(99);
                } else{
                    result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("500", "Server Error", e.message)
            }
        }

    }

    // test print
    val PERMISSION_BLUETOOTH = 1
    private var mBluetoothAdapter: BluetoothAdapter? = null
    var pairedDevices: Set<BluetoothDevice>? = null
    private val mDeviceList = ArrayList<String>()
    var devices: ArrayList<DevicesModel>? = null
    private fun onGetDevicesBluetooth(): ArrayList<DevicesModel>? {
        pairedDevices = mBluetoothAdapter?.getBondedDevices()
        devices = ArrayList<DevicesModel>()
        for (bt in pairedDevices!!) {
            devices!!.add(DevicesModel("", bt.name, bt.address))
            val deviceName = bt.name
            Log.i("BTT", deviceName + "\n" + bt.address)
        }
        return devices
    }
    private fun onPrint(
            bitmapInput: ByteArray,
            printerDpi: Int,
            widthMax: Int, heightMax: Int
    ): Map<String, Any>? {
        val dataMap: MutableMap<String, Any> = HashMap()
        var _message = ""
        try {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.BLUETOOTH), PERMISSION_BLUETOOTH)
            } else {
                val connection: BluetoothConnection? = BluetoothPrintersConnections.selectFirstPaired()
                if (connection != null) {
                    val printer = EscPosPrinter(connection, printerDpi, 80f, 32)
                    val bitMapData = bitmapInput;// stream.toByteArray()
                    val decodedByte = BitmapFactory.decodeByteArray(bitMapData, 0, bitMapData.size)
                    var widthTemp = decodedByte.width
                    var heightTemp = decodedByte.height
                    System.out.println( "-----------------Start--------------------");
                    System.out.println( "Input:   $widthMax || $heightMax");
                    System.out.println( "Curent:  $widthTemp || $heightTemp");
                    System.out.println( "------------------End---------------------");
                    widthTemp = if (widthMax < 580) {
                        580
                    } else {
                        widthMax
                    }
                    heightTemp = if (heightMax < 100) {
                        200
                    } else {
                        heightMax
                    }
                    val resizedBitmap = Bitmap.createScaledBitmap(decodedByte, widthTemp, heightTemp, false)
                    decodedByte.recycle()
                    val width = resizedBitmap.width
                    val height = resizedBitmap.height
                    val textToPrint = StringBuilder()
                    var y = 0
                    while (y < height) {
                        val bitmap = Bitmap.createBitmap(resizedBitmap, 0, y, width, if (y + 256 >= height) height - y else 256)
                        textToPrint.append("""
                        [C]<img>${PrinterTextParserImg.bitmapToHexadecimalString(printer, bitmap).toString()}</img>
                        
                        """.trimIndent())
                        y += 256
                    }
                    textToPrint.append("[C]Printed!!!\n")
                    printer.printFormattedTextAndCut(textToPrint.toString())
                    _message = "Success"
                } else {
                    println("\"No printer was connected!\"")
                    _message = "\"No printer was connected!\""
                    val arrStatus = onPrint(bitmapInput, printerDpi, widthMax, heightMax)
                }
            }
        } catch (e: Exception) {
            _message = "Error"
            println(e)
        }
        dataMap["message"] = _message
        return dataMap
    }
}

class DevicesModel(val id: String?, val deviceName: String?, val deviceAddress: String?)