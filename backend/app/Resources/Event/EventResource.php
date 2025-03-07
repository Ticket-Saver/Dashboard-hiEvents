<?php

namespace HiEvents\Resources\Event;

use HiEvents\DomainObjects\EventDomainObject;
use HiEvents\Resources\BaseResource;
use HiEvents\Resources\Image\ImageResource;
use HiEvents\Resources\Organizer\OrganizerResource;
use HiEvents\Resources\Ticket\TicketResource;
use Illuminate\Http\Request;

/**
 * @mixin EventDomainObject
 */
class EventResource extends BaseResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->getId(),
            'title' => $this->getTitle(),
            'description' => $this->getDescription(),
            'start_date' => $this->getStartDate(),
            'end_date' => $this->getEndDate(),
            'status' => $this->getStatus(),
            'lifecycle_status' => $this->getLifeCycleStatus(),
            'currency' => $this->getCurrency(),
            'timezone' => $this->getTimezone(), 
            'slug' => $this->getSlug(),
            'tipoticket' => $this->getTipoticket(),
            'map' => $this->getMap(),
            'tickets' => $this->when((bool)$this->getTickets(), fn() => TicketResource::collection($this->getTickets())),
            'attributes' => $this->when((bool)$this->getAttributes(), fn() => $this->getAttributes()),
            'images' => $this->when((bool)$this->getImages(), fn() => ImageResource::collection($this->getImages())),
            'location_details' => $this->when((bool)$this->getLocationDetails(), fn() => $this->getLocationDetails()),
            'settings' => $this->when(
                !is_null($this->getEventSettings()),
                fn() => new EventSettingsResource($this->getEventSettings())
            ),
            'organizer' => $this->when(
                !is_null($this->getOrganizer()),
                fn() => new OrganizerResource($this->getOrganizer())
            ),
        ];
    }
}
