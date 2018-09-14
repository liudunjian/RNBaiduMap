
import { NativeModules } from 'react-native';
import React, {Component} from 'react';
import _MapTypes from './js/MapTypes';
import _MapView from './js/MapView';


export const  RNbaidumap  = NativeModules.RNAmbaidumap;
export const MapTypes = _MapTypes;
export const MapView = _MapView;

