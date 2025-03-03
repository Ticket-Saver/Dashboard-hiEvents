<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Database\Eloquent\Builder;

class TicketController extends Controller
{
    public function index(Request $request, Event $event)
    {
        // Log inicial de parámetros
        \Log::info('Ticket query params:', $request->all());
        
        $query = $event->tickets() 
            ->with(['prices' => function($q) {
                $q->orderBy('order', 'asc');
            }]);

        // Log de la query inicial
        \DB::enableQueryLog();
        $initialQuery = $query->toSql();
        $initialBindings = $query->getBindings();
        
        \Log::info('Initial SQL Query:', [
            'sql' => $initialQuery,
            'bindings' => $initialBindings,
            'full_query' => vsprintf(str_replace(['?'], ['\'%s\''], $initialQuery), $initialBindings)
        ]);

        // Búsqueda en múltiples campos
        if ($request->has('query') && $request->get('query')) {
            $searchQuery = $request->get('query');
            $query->where(function($q) use ($searchQuery) { 
                $q->where('tickets.title', 'LIKE', "%{$searchQuery}%")
                  ->orWhere('tickets.position', 'LIKE', "%{$searchQuery}%")
                  ->orWhere('tickets.seat_number', 'LIKE', "%{$searchQuery}%")
                  ->orWhere('tickets.section', 'LIKE', "%{$searchQuery}%");
            });
        }

        // Filtros específicos
        if ($request->has('position') && $request->get('position')) {
            $query->where('tickets.position', $request->get('position'));
        }

        if ($request->has('section') && $request->get('section')) {
            $query->where('tickets.section', $request->get('section'));
        }

        if ($request->has('seat_number') && $request->get('seat_number')) {
            $query->where('tickets.seat_number', 'LIKE', "%{$request->get('seat_number')}%");
        }

        // Ordenamiento
        $sortBy = $request->get('sort_by', 'order');
        $sortDirection = $request->get('sort_direction', 'asc');
        
        $query->orderBy('tickets.order', 'asc')
              ->orderBy('tickets.id', 'asc');

        // Log de la query final
        $finalQuery = $query->toSql();
        $finalBindings = $query->getBindings();
        
        \Log::info('Final SQL Query:', [
            'sql' => $finalQuery,
            'bindings' => $finalBindings,
            'full_query' => vsprintf(str_replace(['?'], ['\'%s\''], $finalQuery), $finalBindings)
        ]);

        try {
            $perPage = $request->get('per_page', 20);
            $results = $query->paginate($perPage);
            
            // Log de los resultados
            \Log::info('Query results:', [
                'total' => $results->total(),
                'per_page' => $results->perPage(),
                'current_page' => $results->currentPage(),
                'last_page' => $results->lastPage(),
                'sample_ids' => $results->items() ? collect($results->items())->pluck('id') : []
            ]);
            
            return $results;
        } catch (\Exception $e) {
            \Log::error('Error en la consulta de tickets: ' . $e->getMessage());
            \Log::error('Stack trace: ' . $e->getTraceAsString());
            return response()->json(['error' => 'Error al obtener los tickets'], 500);
        }
    }
} 