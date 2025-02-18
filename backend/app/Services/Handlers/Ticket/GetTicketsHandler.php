<?php

namespace HiEvents\Services\Handlers\Ticket;

use HiEvents\DomainObjects\TaxAndFeesDomainObject;
use HiEvents\DomainObjects\TicketPriceDomainObject;
use HiEvents\Http\DTO\QueryParamsDTO;
use HiEvents\Repository\Interfaces\TicketRepositoryInterface;
use HiEvents\Services\Domain\Ticket\TicketFilterService;
use Illuminate\Pagination\LengthAwarePaginator;

class GetTicketsHandler
{
    public function __construct(
        private readonly TicketRepositoryInterface $ticketRepository,
        private readonly TicketFilterService       $ticketFilterService,
    )
    {
    }

    public function handle(int $eventId, QueryParamsDTO $params): LengthAwarePaginator
    {
        \Log::info('GetTicketsHandler::handle - Starting', [
            'eventId' => $eventId,
            'filter_fields' => $params->filter_fields
        ]);

        $ticketPaginator = $this->ticketRepository
            ->loadRelation(TicketPriceDomainObject::class)
            ->loadRelation(TaxAndFeesDomainObject::class)
            ->findByEventId($eventId, $params);

        $filteredTickets = $this->ticketFilterService->filter(
            tickets: collect($ticketPaginator->items()),
            hideSoldOutTickets: false,
        );

        $ticketPaginator->setCollection($filteredTickets);

        return $ticketPaginator;
    }
}
