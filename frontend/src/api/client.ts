import axios from "axios";
import {setAuthToken} from "../utilites/apiClient.ts";
import {isSsr} from "../utilites/helpers.ts";
import {getConfig} from "../utilites/config.ts";
import { notifications } from "@mantine/notifications";
import { t } from "@lingui/macro";

const LOGIN_PATH = "/auth/login";
const PREVIOUS_URL_KEY = 'previous_url';

// todo - This isn't scalable, we need to better way to manage this
const ALLOWED_UNAUTHENTICATED_PATHS = [
    'auth/login',
    'accept-invitation',
    'register',
    'forgot-password',
    'auth',
    'account/payment',
    'checkout',
    '/event/',
    'print',
    '/order/',
    'widget',
    '/ticket/',
    'check-in',
];

const getBaseUrl = () => {
    const serverUrl = import.meta.env.VITE_API_URL_SERVER;
    
    // Si estamos en producción y la URL es localhost, usar la URL del cliente
    if (import.meta.env.PROD && serverUrl.includes('localhost')) {
        return import.meta.env.VITE_API_URL_CLIENT;
    }
    
    return serverUrl;
};

// Crear la instancia del cliente
const apiClient = axios.create({
    baseURL: getBaseUrl(),
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    },
    withCredentials: true,
    // Agregar timeout
    timeout: 10000,
});

// Exportar ambas versiones para mantener compatibilidad
export const api = apiClient;
export { apiClient };

const existingToken = typeof window !== "undefined" ? window.localStorage.getItem('token') : undefined;
if (existingToken) {
    setAuthToken(existingToken);
}

// Agregar interceptor para el request
apiClient.interceptors.request.use(
    (config) => {
        console.log('Request:', {
            url: config.url,
            method: config.method,
            data: config.data,
            headers: config.headers
        });
        return config;
    },
    (error) => {
        console.error('Request Error:', error);
        return Promise.reject(error);
    }
);

// Mejorar el interceptor de respuesta
apiClient.interceptors.response.use(
    (response) => {
        const token = response?.data?.token || response?.headers["x-auth-token"];
        if (token) {
            window?.localStorage?.setItem('token', token);
            setAuthToken(token);
        }
        return response;
    },
    (error) => {
        console.error('Response Error:', error);
        
        // Mostrar mensaje de error
        if (error.response) {
            // El servidor respondió con un status code fuera del rango 2xx
            console.error('Error Data:', error.response.data);
            console.error('Error Status:', error.response.status);
            console.error('Error Headers:', error.response.headers);

            const errorMessage = error.response.data?.message || t`An unexpected error occurred`;
            notifications.show({
                title: t`Error`,
                message: errorMessage,
                color: 'red'
            });

            const { status } = error.response;
            const currentPath = window?.location.pathname;
            const isAllowedUnauthenticatedPath = ALLOWED_UNAUTHENTICATED_PATHS.some(path => currentPath.includes(path));
            const isManageEventPath = currentPath.startsWith('/manage/event/');
            const isAuthError = status === 401 || status === 403;

            if (isAuthError && (!isAllowedUnauthenticatedPath || isManageEventPath)) {
                window?.localStorage?.setItem(PREVIOUS_URL_KEY, window?.location.href);
                window?.location?.replace(LOGIN_PATH);
            }
        } else if (error.request) {
            // La petición fue hecha pero no se recibió respuesta
            console.error('No Response Received:', error.request);
            notifications.show({
                title: t`Error`,
                message: t`No response received from server`,
                color: 'red'
            });
        } else {
            // Algo sucedió al configurar la petición
            console.error('Error Setup:', error.message);
            notifications.show({
                title: t`Error`,
                message: error.message,
                color: 'red'
            });
        }

        return Promise.reject(error);
    }
);

axios.defaults.withCredentials = true;

export const redirectToPreviousUrl = () => {
    const previousUrl = window?.localStorage?.getItem(PREVIOUS_URL_KEY) || '/manage/events';
    window?.localStorage?.removeItem(PREVIOUS_URL_KEY);
    if (typeof window !== "undefined") {
        window.location.href = previousUrl;
    }
};
