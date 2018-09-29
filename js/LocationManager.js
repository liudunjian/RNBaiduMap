import {DeviceEventEmitter, NativeModules} from 'react-native';

const _module = NativeModules.RNLocManager;

export default {

    startUpdatingLocation() {
        _module.startUpdatingLocation(null);
    },

    stopAllLocation() {
        _module.stopAllLocation();
    },

    startOnceLocation() {
        return new Promise((resolve, reject) => {
            try {
                _module.requestLocationWithReGeocode();
            } catch (e) {
                reject(e);
                return;
            }
            DeviceEventEmitter.once('locationEventReminderReceived', resp => {
                resolve(resp);
            });
        });
    }

}
