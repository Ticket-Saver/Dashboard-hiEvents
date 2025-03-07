<?php

declare(strict_types=1);

namespace HiEvents\Models;

use HiEvents\DomainObjects\Generated\TicketDomainObjectAbstract;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Ticket extends BaseModel
{
    protected $fillable = [
        'title',
        'description',
        'type',
        'max_per_order',
        'min_per_order',
        'sale_start_date',
        'sale_end_date',
        'hide_before_sale_start_date',
        'hide_after_sale_end_date',
        'show_quantity_remaining',
        'hide_when_sold_out',
        'is_hidden_without_promo_code',
        'event_id',
        'position',
        'seat_number',
        'order',
        'is_hidden',
        'section',
    ];

    protected $casts = [
        'hide_before_sale_start_date' => 'boolean',
        'hide_after_sale_end_date' => 'boolean',
        'show_quantity_remaining' => 'boolean',
        'hide_when_sold_out' => 'boolean',
        'is_hidden_without_promo_code' => 'boolean',
        'is_hidden' => 'boolean',
    ];

    protected function getCastMap(): array
    {
        return [
            TicketDomainObjectAbstract::SALES_VOLUME => 'float',
            TicketDomainObjectAbstract::SALES_TAX_VOLUME => 'float',
            'position' => 'string',
            'seat_number' => 'string',
        ];
    }

    protected function getFillableFields(): array
    {
        return [
            'position',
            'seat_number',
        ];
    }

    public function questions(): BelongsToMany
    {
        return $this->belongsToMany(Question::class, 'ticket_questions');
    }

    public function ticket_prices(): HasMany
    {
        return $this->hasMany(TicketPrice::class)->orderBy('order');
    }

    public function tax_and_fees(): BelongsToMany
    {
        return $this->belongsToMany(TaxAndFee::class, 'ticket_taxes_and_fees');
    }

    public function capacity_assignments(): BelongsToMany
    {
        return $this->belongsToMany(CapacityAssignment::class, 'ticket_capacity_assignments');
    }

    public function check_in_lists(): BelongsToMany
    {
        return $this->belongsToMany(CheckInList::class, 'ticket_check_in_lists');
    }
}
