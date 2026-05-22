package com.serafindanyil.shake_flashlight_plugin

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ShakeFlashlightPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var cameraManager: CameraManager
    private var torchCameraId: String? = null
    private var isTorchEnabled = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        cameraManager =
            binding.applicationContext.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != TOGGLE_LIGHT_METHOD) {
            result.notImplemented()
            return
        }

        try {
            result.success(toggleLight())
        } catch (error: Exception) {
            result.error(ERROR_CODE, error.message, null)
        }
    }

    private fun toggleLight(): Boolean {
        val cameraId = resolveTorchCameraId()
        val nextState = !isTorchEnabled
        cameraManager.setTorchMode(cameraId, nextState)
        isTorchEnabled = nextState
        return isTorchEnabled
    }

    private fun resolveTorchCameraId(): String {
        torchCameraId?.let { return it }

        for (cameraId in cameraManager.cameraIdList) {
            val characteristics = cameraManager.getCameraCharacteristics(cameraId)
            val hasFlash = characteristics.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
            val lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING)

            if (hasFlash && lensFacing == CameraCharacteristics.LENS_FACING_BACK) {
                torchCameraId = cameraId
                return cameraId
            }
        }

        throw IllegalStateException(NO_FLASH_MESSAGE)
    }

    private companion object {
        const val CHANNEL_NAME = "shake_flashlight_plugin"
        const val TOGGLE_LIGHT_METHOD = "toggleLight"
        const val ERROR_CODE = "flashlight_error"
        const val NO_FLASH_MESSAGE = "Back camera flashlight is unavailable"
    }
}
