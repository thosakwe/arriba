import React from 'react';
import {render} from 'react-dom';
import App from './src/app';
import './arriba.sass';

const container = document.querySelector('#app');
render(<App/>, container);