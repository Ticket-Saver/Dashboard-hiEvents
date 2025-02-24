<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | Adjusted settings for cross-origin resource sharing to allow
    | communication between the React app and the API, ensuring
    | cookies can be set and sent with requests.
    |
    | To learn more: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
    |
    */

    'paths' => ['*', 'api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    'allowed_origins' => ['*'],  // Temporalmente permitimos todos los orígenes para pruebas

    'allowed_origins_patterns' => [],

    'allowed_headers' => [
        'Content-Type',
        'X-Auth-Token',
        'Origin',
        'Authorization',
        'Accept',
        'X-Requested-With'
    ],

    'exposed_headers' => ['X-Auth-Token'],

    'max_age' => 86400,  // 24 horas

    'supports_credentials' => true,

    // Agregar esta opción para debug en producción
    'debug' => env('APP_DEBUG', false),
];

