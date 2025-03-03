<?php

namespace HiEvents\Http\Requests\Ticket;

use Illuminate\Foundation\Http\FormRequest;

class UpsertTicketRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|string',
            'order' => 'nullable|integer',
            'price' => 'required|numeric|min:0',
            'max_per_order' => 'required|integer|min:1',
            'min_per_order' => 'required|integer|min:1',
            'quantity_sold' => 'nullable|integer',
            'sale_start_date' => 'nullable|date',
            'sale_end_date' => 'nullable|date',
            'event_id' => 'required|integer',
            'initial_quantity_available' => 'nullable|integer',
            'hide_before_sale_start_date' => 'boolean',
            'hide_after_sale_end_date' => 'boolean',
            'show_quantity_remaining' => 'boolean',
            'hide_when_sold_out' => 'boolean',
            'is_hidden_without_promo_code' => 'boolean',
            'is_hidden' => 'boolean',
            'is_before_sale_start_date' => 'boolean',
            'is_after_sale_end_date' => 'boolean',
            'is_available' => 'boolean',
            'is_sold_out' => 'boolean',
            'position' => 'nullable|string',
            'seat_number' => 'nullable|string',
            'section' => 'nullable|string',
            'prices' => 'required|array',
            'prices.*.id' => 'required|integer',
            'prices.*.label' => 'nullable|string',
            'prices.*.price' => 'required|numeric|min:0',
            'prices.*.sale_start_date' => 'nullable|date',
            'prices.*.sale_end_date' => 'nullable|date',
            'prices.*.is_before_sale_start_date' => 'boolean',
            'prices.*.is_after_sale_end_date' => 'boolean',
            'prices.*.is_available' => 'boolean',
            'prices.*.initial_quantity_available' => 'nullable|integer',
            'prices.*.quantity_sold' => 'nullable|integer',
            'prices.*.is_sold_out' => 'boolean',
            'prices.*.is_hidden' => 'boolean',
            'prices.*.off_sale_reason' => 'nullable|string',
            'prices.*.order' => 'required|integer',
            'taxes_and_fees' => 'nullable|array',
            'taxes_and_fees.*' => 'integer'
        ];
    }
} 