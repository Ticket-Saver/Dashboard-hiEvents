<?php

declare(strict_types=1);

namespace HiEvents\Http\Actions\Tickets;

use HiEvents\DomainObjects\EventDomainObject;
use HiEvents\DomainObjects\TicketDomainObject;
use HiEvents\Http\Actions\BaseAction;
use HiEvents\Resources\Ticket\TicketResource;
use HiEvents\Services\Handlers\Ticket\GetTicketsHandler;
use HiEvents\Http\DTO\QueryParamsDTO;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use HiEvents\Models\Ticket;

class GetTicketsAction extends BaseAction
{
    public function __construct(
        private readonly GetTicketsHandler $getTicketsHandler,
    )
    {
    }

    public function __invoke(int $eventId, Request $request): JsonResponse
    {
        $this->isActionAuthorized($eventId, EventDomainObject::class);

        // Obtener los parámetros de la request
        $requestData = $request->all(); 
        
        // Forzar el ordenamiento por id
        $requestData['sort_by'] = 'id';
        $requestData['sort_direction'] = 'asc';

        // Agregar los filtros a la query
        $requestData['filter_fields'] = collect();
        
        if ($position = $request->get('position')) {
            $requestData['filter_fields']->push([
                'field' => 'position',
                'operator' => 'like',
                'value' => $position
            ]);  
        }
        
        if ($section = $request->get('section')) {
            $requestData['filter_fields']->push([
                'field' => 'section',
                'operator' => 'like',
                'value' => $section
            ]);
        }
        
        if ($seatNumber = $request->get('seat_number')) {
            $requestData['filter_fields']->push([
                'field' => 'seat_number',
                'operator' => 'like',
                'value' => $seatNumber
            ]);
        }

        \Log::info('Filter fields:', [
            'filter_fields' => $requestData['filter_fields']
        ]);
        
        // Crear el DTO con los parámetros modificados
        $params = QueryParamsDTO::fromArray($requestData);

        DB::flushQueryLog();
        DB::enableQueryLog();

        // Usar el handler para obtener los tickets
        $tickets = $this->getTicketsHandler->handle(
            eventId: $eventId,
            params: $params
        );

        // Obtener todas las queries ejecutadas
        $queries = DB::getQueryLog();

        // Encontrar la query principal de tickets
        $mainQuery = collect($queries)->first(function($q) {
            return str_contains($q['query'], 'select * from "tickets"');
        });

        // Construir la query completa con los filtros
        $fullQuery = $mainQuery ? vsprintf(
            str_replace(['?'], ['\'%s\''], $mainQuery['query']), 
            array_map(function($binding) {
                return is_numeric($binding) ? $binding : $binding;
            }, $mainQuery['bindings'])
        ) : null;

        // Modificar la respuesta para incluir la información SQL
        $response = $this->filterableResourceResponse(
            resource: TicketResource::class,
            data: $tickets,
            domainObject: TicketDomainObject::class
        );

        // Obtener el contenido actual
        $content = json_decode($response->getContent(), true);

        // Agregar la información SQL y detalles de tickets a meta
        $content['meta']['debug_info'] = [
            'applied_filters' => [
                'position' => $request->get('position'),
                'section' => $request->get('section'),
                'seat_number' => $request->get('seat_number'),
            ],
            'sql_query' => [
                'raw' => $mainQuery['query'] ?? null,
                'bindings' => $mainQuery['bindings'] ?? [],
                'full_query' => $fullQuery,
                'execution_time' => $mainQuery['time'] ?? null
            ],
            'request_params' => $request->all()
        ];

        return new JsonResponse($content, $response->status());
    }
}
