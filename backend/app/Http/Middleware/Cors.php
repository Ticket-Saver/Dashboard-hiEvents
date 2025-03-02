<?php

namespace HiEvents\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class Cors
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);
        
        $response->headers->set('Access-Control-Allow-Origin', '*');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, X-Auth-Token');
        $response->headers->set('Access-Control-Max-Age', '86400');
        
        if ($request->isMethod('OPTIONS')) {
            $response->setStatusCode(200);
        }
        
        return $response;
    }
} 