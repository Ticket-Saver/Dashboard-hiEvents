import Axios from 'axios';
import { getConfig } from '../utilites/config';
import { isSsr } from '../utilites/helpers';

const getBaseUrl = () => {
    const baseUrl = isSsr()
        ? getConfig('VITE_API_URL_SERVER')
        : getConfig('VITE_API_URL_CLIENT');
    
    console.log('Base URL:', baseUrl); // Para debugging
    return baseUrl;
};

export const axios = Axios.create({
    baseURL: getBaseUrl(),
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
});

// Añadir interceptor para el token si es necesario
axios.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Interceptor para logs con más información
axios.interceptors.request.use(
    (config) => {
        const fullUrl = `${config.baseURL || ''}${config.url || ''}`;
        console.log('Request Details:', {
            baseURL: config.baseURL,
            url: config.url,
            fullUrl: fullUrl,
            params: config.params,
            method: config.method
        });
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

axios.interceptors.response.use(
    (response) => {
        console.log('Response:', response.status, response.data);
        return response;
    },
    (error) => {
        console.error('API Error:', error.response?.status, error.response?.data);
        return Promise.reject(error);
    }
); 