import {
  requireNativeComponent,
  View,
  NativeModules,
  Platform,
  DeviceEventEmitter
} from 'react-native';
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import MapTypes from './MapTypes';

export default class MapView extends Component {
  static propTypes = {
    ...View.propTypes,
    zoomControlsVisible: PropTypes.bool,
    trafficEnabled: PropTypes.bool,
    baiduHeatMapEnabled: PropTypes.bool,
    mapType: PropTypes.number,
    zoom: PropTypes.number,
    center: PropTypes.object,
    marker: PropTypes.object,
    markers: PropTypes.array,
    childrenPoints: PropTypes.array,
    poiKeywords:PropTypes.array,
    onMapStatusChangeStart: PropTypes.func,
    onMapStatusChange: PropTypes.func,
    onMapStatusChangeFinish: PropTypes.func,
    onMapLoaded: PropTypes.func,
    onMapClick: PropTypes.func,
    onMapDoubleClick: PropTypes.func,
    onMarkerClick: PropTypes.func,
    onMapPoiClick: PropTypes.func,
    showsUserLocation:PropTypes.bool
  };

  static defaultProps = {
    zoomControlsVisible: true,
    trafficEnabled: false,
    baiduHeatMapEnabled: false,
    showsUserLocation:false,
    mapType: MapTypes.NORMAL,
    childrenPoints: [],
    poiKeywords:['小吃'],
    marker: null,
    markers: [],
    center: null,
    zoom: 16
  };

  constructor() {
    super();
  }

  _onChange(event) {
    console.log("_onChange");
    if (typeof this.props[event.nativeEvent.type] === 'function') {
      this.props[event.nativeEvent.type](event.nativeEvent.params);
    }
  }

  render() {
    return <BaiduMapView {...this.props} onChange={this._onChange.bind(this)}/>;
  }
}

const BaiduMapView = requireNativeComponent('RNMapView', MapView, {
  nativeOnly: {onChange: true}
});
