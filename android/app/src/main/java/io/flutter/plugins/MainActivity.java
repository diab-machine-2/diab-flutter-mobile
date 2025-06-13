package com.vbhc.diab;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.Manifest;
import android.annotation.TargetApi;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.util.SparseArray;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RadioButton;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import com.zing.zalo.zalosdk.oauth.ZaloSDK;

import com.isens.standard.ble.IBLE_Callback;
import com.isens.standard.ble.IBLE_Const;
import com.isens.standard.ble.IBLE_Device;
import com.isens.standard.ble.IBLE_Error;
import com.isens.standard.ble.IBLE_GlucoseRecord;
import com.isens.standard.ble.IBLE_Manager;
import com.isens.standard.ble.IBLE_ScannerServiceParser;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.concurrent.TimeUnit;
import org.json.JSONObject;

import android.util.Log;
import android.net.Uri;
// import javax.naming.spi.DirStateFactory.Result;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;
import android.content.Intent;
import android.os.Bundle;

import com.vnpay.authentication.VNP_AuthenticationActivity;
import com.vnpay.authentication.VNP_SdkCompletedCallback;

public class MainActivity extends FlutterFragmentActivity {

    private ScanCallback mScanCallback;
    private LocationManager mLocationManager;
    private BluetoothAdapter mBluetoothAdapter;
    private BluetoothManager mBluetoothManager;
    private DeviceAdapter mDeviceAdapter;
    private EventChannel.EventSink events;

    private Context context;
    private static final String TAG = "MainActivity";
    private static final String VNPAY_CHANNEL = "paymentGateway";
    private static final String VNPAY_APP_SCHEME = "diabvnpay";

    @Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}

    @Override
    protected void onDestroy() {
        IBLE_Manager.getInstance().DestroySDK();
        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        context = this;
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "iBleSdk")
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("request_permission")) {
                                requestPermission(result);
                            } else if (call.method.equals("init_IBle_Sdk")) {
                                initIBle();
                            } else if (call.method.equals("start_scan")) {
                                startScan();
                            } else if (call.method.equals("stop_scan")) {
                                stopScan();
                            }  else if (call.method.equals("connect")) {
                                connect(call.arguments.toString());
                            } else if (call.method.equals("dis_connect")) {
                                disConnect();
                            } else if (call.method.equals("destroy_sdk")) {
                                destroySDK();
                            } else if (call.method.equals("get_data")) {
                                getData();
                            } else {
                                result.notImplemented();
                            }
                        }
                );

        // Add VNPay channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), VNPAY_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("openSDK")) {
                                String url = call.argument("url");
                                String tmnCode = call.argument("tmnCode");
                                String scheme = call.argument("scheme") != null ? call.argument("scheme") : VNPAY_APP_SCHEME;
                                Boolean isSandbox = call.argument("isSandbox") != null ? call.argument("isSandbox") : false;
                                
                                Log.d(TAG, "[VNPAY] Opening VNPay SDK with URL: " + url);
                                startVNPayActivity(url, tmnCode, scheme, isSandbox);
                                result.success(true);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    final IBLE_Callback mIBleCallback = new IBLE_Callback() {

        @Override
        public void CallbackInitSDK(int version) {
            emitData("init_success", null);
                    emitData("SDK init Success with Version : " + version, null);

        }

        @Override
        public void CallbackConnectedDevice() {
            emitData("connected", null);
        }

        @Override
        public void CallbackDisconnectedDevice() {
            emitData("device_disconnect", null);
        }

        @Override
        public void CallbackRequestTimeSync() {

            emitData("CallbackRequestTimeSync", null);
        }

        @Override
        public void CallbackRequestRecordsComplete(SparseArray<IBLE_GlucoseRecord> sparseArray) {
            SparseArray<IBLE_GlucoseRecord> mRecords = sparseArray;
            ArrayList<Map<String, String>> data = new ArrayList<Map<String, String>>();
                    if (mRecords == null || mRecords.size() <= 0) {
                        emitData("get_data_success", data);
                        return;
                    }


                    for (int i = mRecords.size() - 1; i >= 0; i--) {
                        final IBLE_GlucoseRecord glucoseRecord = mRecords.valueAt(i);
                        Map<String, String> map = new HashMap();
                        map.put("glucose", String.valueOf(glucoseRecord.glucoseData));
                        map.put("date", String.valueOf(glucoseRecord.time));
                        data.add(map);
                    }

                    emitData("get_data_success", data);
        }

        @Override
        public void CallbackReadDeviceInfo(IBLE_Device ible_device) {
            emitData("CallbackReadDeviceInfo", null);
            emitData("device_connected", null);
        }

        @Override
        public void CallbackError(IBLE_Error ible_error) {
            emitData("connect_error", null);
        }
    };

    private BluetoothAdapter.LeScanCallback mLEScanCallback = new BluetoothAdapter.LeScanCallback() {
        @Override
        public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {
            if (device != null) {
                try {
                    if (IBLE_ScannerServiceParser.decodeDeviceAdvData(scanRecord)) {
                        if (device.getBondState() == BluetoothDevice.BOND_BONDED) {
                            addScannedDevice(device, rssi, true);
                        } else {
                            addScannedDevice(device, rssi, false);
                        }
                    }
                } catch (Exception e) {
                    emitData("scan_error",null);
                    e.getMessage();
                }
            }
        }
    };

    private void addScannedDevice(final BluetoothDevice device, final int rssi, final boolean isBonded) {
        try {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    int count = mDeviceAdapter.getCount();
                    mDeviceAdapter.addDevice(new ExtendedDevice(device, rssi, isBonded));
                    if (count != mDeviceAdapter.getCount()) {

                        ArrayList<ExtendedDevice> listItems = mDeviceAdapter.getList();
                        ArrayList<Map<String, String>> data = new ArrayList<Map<String, String>>();

                        for (int i = 0; i < listItems.size(); i++) {
                            ExtendedDevice item = listItems.get(i);

                            Map<String, String> map = new HashMap();
                            map.put("address", item.device.getAddress());
                            map.put("name", item.device.getName());
                            data.add(map);

                        }
                        emitData("new_device",data);

                    }
                }
            });
            
        } catch (NullPointerException e) {
            emitData("scan_error",null);
        } catch (Exception e) {
            emitData("scan_error",null);
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private void initCallbackLollipop() {
        if (mScanCallback != null) return;
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            this.mScanCallback = new ScanCallback() {
                @Override
                public void onScanResult(int callbackType, final ScanResult result) {
                    super.onScanResult(callbackType, result);
                    if (result != null) {
                        try {
                            if (IBLE_ScannerServiceParser.decodeDeviceAdvData(result.getScanRecord().getBytes())) {
                                if (result.getDevice().getBondState() == BluetoothDevice.BOND_BONDED) {
                                    addScannedDevice(result.getDevice(), result.getRssi(), true);
                                } else {
                                    addScannedDevice(result.getDevice(), result.getRssi(), false);
                                }
                            }
                        } catch (Exception e) {
                            emitData("scan_error",null);
                        }
                    }
                }

                @Override
                public void onBatchScanResults(List<ScanResult> results) {
                    super.onBatchScanResults(results);
                    emitData("scan_error",null);
                }

                @Override
                public void onScanFailed(int errorCode) {
                    super.onScanFailed(errorCode);
                    emitData("scan_error",null);
                }
            };
        }
    }


    public boolean checkPermission(String[] permission) {
        for (int i = 0; i < permission.length; i++) {
            if (ContextCompat.checkSelfPermission(getApplicationContext(), permission[i]) < 0) {
                return false;
            }
        }
        return true;
    }

    private boolean isGPSEnabled() {
        if (!mLocationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
            return false;
        }
        return true;
    }

    private boolean isBLEEnabled() {
        final BluetoothAdapter adapter = mBluetoothManager.getAdapter();
        return adapter != null && adapter.isEnabled();
    }

    public void requestPermissions(String[] permission) {
        for (int i = 0; i < permission.length; i++) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(MainActivity.this, permission[i]) == false) {
                ActivityCompat.requestPermissions(MainActivity.this, permission, 100);
                return;
            }
        }
    }

    public String getDate(long t) {
        SimpleDateFormat sdfNow = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String date = sdfNow.format(t * 1000);

        return date;
    }


    // call method chanel----------------------------------------------
    
    private void requestPermission(MethodChannel.Result result) {
        mBluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        mBluetoothAdapter = mBluetoothManager.getAdapter();
        if (mBluetoothAdapter.getState() == BluetoothAdapter.STATE_ON) {
            result.success("ble_already");
        } else {
            result.success("ble_off");
        }
        // boolean isBleAvailable = getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE) ? true : false;
        // if (isBleAvailable && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        //     mBluetoothManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        //     mBluetoothAdapter = mBluetoothManager.getAdapter();
        //     if (mBluetoothAdapter == null) {
        //         //ble_not_supported
        //         result.success("ble_not_supported");
        //         //emitData("ble_not_supported", null);
        //     } else {
        //         result.success("ble_already");
        //         //emitData("ble_already", null);
        //     }
        // } else {
        //     //BLE off. Turn on ble mode
        //     result.success("ble_off");
        //     //emitData("ble_off", null);
        // }

        // mLocationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
        
        // String[] permission = new String[]{Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION};
        // if (isBLEEnabled() && isGPSEnabled() && checkPermission(permission)) {
        //     emitData("permission_grand", null);
        // } else if (isBLEEnabled() == false) {
        //     //BT 설정화면으로 이동
        //     final Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
        //     startActivity(enableIntent);
        // } else if (isGPSEnabled() == false) {
        //     //GPS 설정화면으로 이동
        //     Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
        //     intent.addCategory(Intent.CATEGORY_DEFAULT);
        //     startActivity(intent);
        // } else if (checkPermission(permission) == false) {
        //     requestPermissions(permission);
        // }

    }

    private void emitData(String event, Object data) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Map<String, Object> map = new HashMap();
                map.put("event", event);
                map.put("data", data );
                events.success(map);
            }
        });
        
    }

    private void initIBle() {
        if (IBLE_Manager.mIBleManager == null) {
            IBLE_Manager.getInstance().SetCallback(mIBleCallback);
            IBLE_Manager.getInstance().InitSDK(this);
            mDeviceAdapter = new DeviceAdapter(this);
        }
        
    }

    

    private void startScan() {
        mLocationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
        initIBle();
        if (mDeviceAdapter != null) {
            mDeviceAdapter.clearDevices();
        } 
        try {
            if (mBluetoothAdapter.getState() == BluetoothAdapter.STATE_ON) {
                String xStr = Integer.toString(Build.VERSION.SDK_INT);
                emitData(xStr, null);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    if (mScanCallback == null)
                        initCallbackLollipop();

                    List<ScanFilter> filters = new ArrayList<ScanFilter>();

                    ScanSettings settings = new ScanSettings.Builder()
                            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                            .setReportDelay(0)
                            .build();

                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                        emitData("is_scanning", null);
                        mBluetoothAdapter.getBluetoothLeScanner().flushPendingScanResults(mScanCallback);
                        mBluetoothAdapter.getBluetoothLeScanner().stopScan(mScanCallback);
                        mBluetoothAdapter.getBluetoothLeScanner().startScan(filters, settings, mScanCallback);
                    } else {
                        emitData("scanning_faild", null);
                    }

                } else {
                    mBluetoothAdapter.startLeScan(mLEScanCallback);
                    emitData("is_scanning", null);
                }


            } else {
                emitData("ble_off", null);
            }


        } catch (Exception e) {
            emitData("scan_error",null);
            //emitData(e.getMessage().toString(), null);
        }

    }

    public void stopScan() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                // Stop scan and flush pending scan
                mBluetoothAdapter.getBluetoothLeScanner().flushPendingScanResults(mScanCallback);
                mBluetoothAdapter.getBluetoothLeScanner().stopScan(mScanCallback);
            } else {
                mBluetoothAdapter.stopLeScan(mLEScanCallback);
            }
            emitData("stop_scan", null);
        } catch (Exception e) {
            e.getMessage();
        }
    }

    private void connect(String address) {
        ExtendedDevice device = mDeviceAdapter.getItem(address);
                if (device != null) {
                    emitData("connecting device", null);
                    IBLE_Manager.getInstance().ConnectDevice(device.device.getAddress());
                } else {
                    emitData("device_not_connect", null);
                }
    }

    private void disConnect() {
        IBLE_Manager.getInstance().DisconnectDevice();
    }

    private void destroySDK() {
        IBLE_Manager.getInstance().DestroySDK();
    }

    private void getData() {
        IBLE_Manager.getInstance().RequestAllRecords();
    }

    /**
     * Start the VNPAY Authentication Activity
    */
    private void sendPaymentResult(String action, int resultCode, Map<String, Object> extras) {
        HashMap<String, Object> resultMap = new HashMap<>();
        MethodChannel channel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), VNPAY_CHANNEL);
        resultMap.put("action", action);
        resultMap.put("resultCode", resultCode);
        resultMap.putAll(extras);

        runOnUiThread(() -> {
            channel.invokeMethod("PaymentBack", resultMap);
        });
    }

    private void startVNPayActivity(String url, String tmnCode, String scheme, Boolean isSandbox) {
        Intent intent = new Intent(this, VNP_AuthenticationActivity.class);
        
        // Required parameters for VNPay SDK
        intent.putExtra("url", url);          // Payment URL provided by VNPay
        intent.putExtra("tmn_code", tmnCode); // Terminal code provided by VNPay
        intent.putExtra("scheme", scheme);    // Scheme for reopening app after bank payment
        intent.putExtra("is_sandbox", isSandbox); // Whether to use sandbox environment
        
        Log.d(TAG, "[VNPAY] Starting VNPay activity with URL: " + url);
        
        // Set callback for VNPay SDK
        VNP_AuthenticationActivity.setSdkCompletedCallback(new VNP_SdkCompletedCallback() {
            @Override
            public void sdkAction(String action) {
                Log.d("[VNPAY] SplashActivity", "action: " + action);
                switch (action) {
                    case "AppBackAction":
                        sendPaymentResult(action, 24, new HashMap<>()); // custom code for canceled
                        break;
                    case "CallMobileBankingApp":
                        sendPaymentResult(action, 10, new HashMap<>()); // custom code for "in progress"
                        break;
                    case "WebBackAction":
                        sendPaymentResult(action, 24, new HashMap<>());
                        Log.d(TAG, "[VNPAY] WebBackAction detected - waiting for redirect with parameters");
                        break;
                    case "FaildBackAction":
                        sendPaymentResult(action, 99, new HashMap<>()); // error code
                        break;
                    case "SuccessBackAction":
                        sendPaymentResult(action, 0, new HashMap<>()); // success code
                        break;
                }
            }
        });
        
        // Start the VNPay activity
        startActivity(intent);
    }

   @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        String scheme = intent.getScheme();
        String data = intent.getDataString();

        Log.d(TAG, "[VNPAY] New Intent received: " + data + " with scheme: " + scheme);

        // Handle VNPay app scheme returns
        if (VNPAY_APP_SCHEME.equals(scheme)) {
            handleVNPayAppSchemeReturn(data);
        }
        // // Handle custom merchant return URLs from web
        // else if (data != null && (data.startsWith("http://success.sdk.merchantbackapp") ||
        //                         data.startsWith("http://cancel.sdk.merchantbackapp") ||
        //                         data.startsWith("http://fail.sdk.merchantbackapp"))) {
        //     handleVNPayMerchantReturn(data);
        // }
    }

    private void handleVNPayAppSchemeReturn(String data) {
        try {
            Uri uri = Uri.parse(data);
            Log.d(TAG, "[VNPAY] handleVNPayAppSchemeReturn data:  " + data);;
            String responseCode = uri.getQueryParameter("vnp_ResponseCode") != null ? 
                                uri.getQueryParameter("vnp_ResponseCode") : "";

                                
            String txnRef = uri.getQueryParameter("vnp_TxnRef");
            if (txnRef == null || txnRef.isEmpty()) {
                Log.d(TAG, "[VNPAY] Ignoring scheme call without transaction reference");
                return;
            }
            
            Map<String, Object> extras = extractAllVNPayParams(uri);
            
            int resultCode = "00".equals(responseCode) ? 0 : 99;
            Log.d(TAG, "[VNPAY] App scheme return data processed");
            sendPaymentResult("ReturnFromVNPay", resultCode, extras);
        } catch (Exception e) {
            Log.d(TAG, "[VNPAY] Error parsing app scheme return URL: " + e.getMessage());
            Map<String, Object> errorMap = new HashMap<>();
            errorMap.put("error", e.getMessage() != null ? e.getMessage() : "Unknown error");
            sendPaymentResult("ReturnFromVNPay", 99, errorMap);
        }
    }

    // private void handleVNPayMerchantReturn(String url) {
    //     Log.d(TAG, "[VNPAY] Handling VNPay merchant return URL: " + url);
        
    //     try {
    //         Uri uri = Uri.parse(url);
    //         String responseCode = uri.getQueryParameter("vnp_ResponseCode") != null ? 
    //                             uri.getQueryParameter("vnp_ResponseCode") : "99";
            
    //         // Extract all VNPay parameters
    //         Map<String, Object> extras = extractAllVNPayParams(uri);
            
    //         int resultCode;
    //         String action;
            
    //         if (url.startsWith("http://success.sdk.merchantbackapp")) {
    //             // Success case - responseCode should be "00"
    //             resultCode = "00".equals(responseCode) ? 0 : 99;
    //             action = "WebBackSuccess";
    //         } else if (url.startsWith("http://cancel.sdk.merchantbackapp")) {
    //             // Cancel case - responseCode should be "24"
    //             resultCode = 24;
    //             action = "WebBackCancel";
    //         } else if (url.startsWith("http://fail.sdk.merchantbackapp")) {
    //             // Fail case - any error code
    //             resultCode = 99;
    //             action = "WebBackFail";
    //         } else {
    //             // Default to fail
    //             resultCode = 99;
    //             action = "WebBackFail";
    //         }
            
    //         Log.d(TAG, "[VNPAY] Processed merchant return URL - Action: " + action + 
    //                 ", ResultCode: " + resultCode + ", ResponseCode: " + responseCode);
            
    //         sendPaymentResult(action, resultCode, extras);
            
    //     } catch (Exception e) {
    //         Log.e(TAG, "[VNPAY] Error handling merchant return URL: " + e.getMessage());
    //         Map<String, Object> errorMap = new HashMap<>();
    //         errorMap.put("error", e.getMessage() != null ? e.getMessage() : "Unknown error");
    //         sendPaymentResult("WebBackFail", 99, errorMap);
    //     }
    // }

    private Map<String, Object> extractAllVNPayParams(Uri uri) {
        Map<String, Object> extras = new HashMap<>();
        
        // Extract all VNPay parameters
        for (String paramName : uri.getQueryParameterNames()) {
            String paramValue = uri.getQueryParameter(paramName);
            if (paramValue != null) {
                extras.put(paramName, paramValue);
            }
        }
        
        // Ensure essential parameters are present with default values if missing
        String[] essentialParams = {
            "vnp_ResponseCode", "vnp_BankTranNo", "vnp_Amount", "vnp_BankCode",
            "vnp_OrderInfo", "vnp_CardType", "vnp_PayDate", "vnp_TmnCode",
            "vnp_TransactionNo", "vnp_TransactionStatus", "vnp_TxnRef"
        };
        
        for (String param : essentialParams) {
            if (!extras.containsKey(param)) {
                extras.put(param, "");
            }
        }
        
        return extras;
    }
}