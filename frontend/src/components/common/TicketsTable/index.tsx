import {useEffect, useState} from 'react';
import classes from './TicketsTable.module.scss';
import {NoResultsSplash} from "../NoResultsSplash";
import {t} from "@lingui/macro";
import {
    closestCenter,
    DndContext,
    PointerSensor,
    TouchSensor,
    UniqueIdentifier,
    useSensor, 
    useSensors,
} from '@dnd-kit/core';
import {SortableContext, verticalListSortingStrategy,} from '@dnd-kit/sortable';
import {Ticket, Event} from "../../../types";
import {useSortTickets} from "../../../mutations/useSortTickets.ts";
import {useParams} from "react-router-dom";
import {showError, showSuccess} from "../../../utilites/notifications.tsx";
import {SortableTicket} from "./SortableTicket";
import {useDragItemsHandler} from "../../../hooks/useDragItemsHandler.ts";
import {Button, Checkbox, Group, NumberInput} from "@mantine/core";
import {IconPlus, IconCurrencyDollar} from "@tabler/icons-react";
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../../../api/client';
import { useSearchParams } from 'react-router-dom';

interface TicketCardProps {
    tickets: Ticket[];
    event: Event;
    enableSorting: boolean;
    openCreateModal: () => void;
}

export const TicketsTable = ({tickets = [], event, openCreateModal, enableSorting = false}: TicketCardProps) => {
    const {eventId} = useParams();
    const [selectedTickets, setSelectedTickets] = useState<number[]>([]);
    const [bulkPrice, setBulkPrice] = useState<number | ''>(0);
    const sortTicketsMutation = useSortTickets();
    const queryClient = useQueryClient();
    const searchParams = useSearchParams()[0];

    const updatePriceMutation = useMutation({
        mutationFn: async (data: { ticketId: number, price: number }) => {
            const ticket = tickets.find(t => t.id === data.ticketId);
            if (!ticket) throw new Error('Ticket not found');

            const priceId = ticket.prices[0]?.id;
            if (!priceId) throw new Error('No price found for ticket');

            return api.put(`/events/${eventId}/tickets/${data.ticketId}`, {
                id: ticket.id,
                title: ticket.title,
                type: ticket.type,
                order: ticket.order,
                description: ticket.description,
                price: data.price,
                max_per_order: ticket.max_per_order,
                min_per_order: ticket.min_per_order,
                initial_quantity_available: ticket.initial_quantity_available || 1,
                prices: [{
                    id: priceId,
                    price: data.price,
                    order: 1
                }],
                position: ticket.position,
                seat_number: ticket.seat_number,
                section: ticket.section
            });
        },
        onSuccess: (_, variables) => {
            console.log(`Successfully updated ticket ${variables.ticketId} with price ${variables.price}`);
            queryClient.invalidateQueries(['tickets', eventId]);
            showSuccess(t`Price updated successfully`);
        },
        onError: (error, variables) => {
            console.error(`Failed to update ticket ${variables.ticketId}:`, error);
            showError(t`Failed to update price`);
        }
    });

    const handleBulkPriceUpdate = async () => {
        if (selectedTickets.length === 0 || !bulkPrice) {
            showError(t`Please select tickets and enter a price`);
            return;
        }

        try {
            const currentFilters = {
                position: searchParams?.get('position') || '',
                section: searchParams?.get('section') || '',
                seat_number: searchParams?.get('seat_number') || '',
                query: searchParams?.get('query') || '',
                sort_by: searchParams?.get('sort_by') || 'order',
                sort_direction: searchParams?.get('sort_direction') || 'asc'
            };

            for (const ticketId of selectedTickets) {
                const ticket = tickets.find(t => t.id === ticketId);
                if (!ticket) continue;

                const priceId = ticket.prices?.[0]?.id;
                if (!priceId) continue;

                // Mantener todos los atributos existentes del ticket
                await api.put(`/events/${eventId}/tickets/${ticketId}`, {
                    id: ticket.id,
                    title: ticket.title,
                    type: ticket.type,
                    order: ticket.order,
                    description: ticket.description,
                    price: Number(bulkPrice),
                    max_per_order: ticket.max_per_order,
                    min_per_order: ticket.min_per_order,
                    initial_quantity_available: ticket.initial_quantity_available || 1,
                    hide_before_sale_start_date: ticket.hide_before_sale_start_date,
                    hide_after_sale_end_date: ticket.hide_after_sale_end_date,
                    show_quantity_remaining: ticket.show_quantity_remaining,
                    hide_when_sold_out: ticket.hide_when_sold_out,
                    is_hidden_without_promo_code: ticket.is_hidden_without_promo_code,
                    is_hidden: ticket.is_hidden,
                    position: ticket.position,        // Mantener la posición original
                    seat_number: ticket.seat_number,  // Mantener el número de asiento
                    section: ticket.section,          // Mantener la sección
                    prices: [{
                        id: priceId,
                        price: Number(bulkPrice),
                        order: 1,
                        initial_quantity_available: ticket.prices[0]?.initial_quantity_available || 1,
                        is_available: ticket.prices[0]?.is_available,
                        is_hidden: ticket.prices[0]?.is_hidden,
                        label: ticket.prices[0]?.label
                    }],
                    taxes_and_fees: ticket.taxes_and_fees?.map(tax => tax.id) || []
                });

                // Verificar el ticket actualizado
                const updatedTicket = await api.get(`/events/${eventId}/tickets/${ticketId}`);
                console.log('Ticket actualizado:', updatedTicket.data);
            }

            // Invalidar y refrescar la query con los filtros actuales
            await queryClient.invalidateQueries({
                queryKey: ['tickets', eventId, currentFilters]
            });

            // Refrescar la página actual
            await queryClient.refetchQueries({
                queryKey: ['tickets', eventId, currentFilters]
            });

            // Después de la actualización
            await queryClient.invalidateQueries({
                queryKey: ['tickets', eventId],
                refetchActive: true // Forzar refetch de queries activas
            });

            // Esperar un momento y refrescar explícitamente
            setTimeout(() => {
                queryClient.refetchQueries({
                    queryKey: ['tickets', eventId],
                    exact: true
                });
            }, 100);

            showSuccess(t`Prices updated successfully`);
            setSelectedTickets([]);
            setBulkPrice(0);
        } catch (error) {
            console.error('Error updating prices:', error);
            showError(t`Failed to update prices`);
        }
    };

    const handleSelectAll = (checked: boolean) => {
        if (checked) {
            setSelectedTickets(tickets.map(ticket => ticket.id));
        } else {
            setSelectedTickets([]);
        }
    };

    const handleSelectTicket = (ticketId: number, checked: boolean) => {
        if (checked) {
            setSelectedTickets(prev => [...prev, ticketId]);
        } else {
            setSelectedTickets(prev => prev.filter(id => id !== ticketId));
        }
    };

    const {items, setItems, handleDragEnd} = useDragItemsHandler({
        initialItemIds: tickets.map((ticket) => Number(ticket.id)),
        onSortEnd: (newArray) => {
            sortTicketsMutation.mutate({
                sortedTickets: newArray.map((id, index) => {
                    return {id, order: index + 1};
                }),
                eventId: eventId,
            }, {
                onSuccess: () => {
                    queryClient.invalidateQueries(['tickets', eventId]);
                    showSuccess(t`Tickets sorted successfully`);
                },
                onError: () => {
                    showError(t`An error occurred while sorting the tickets. Please try again or refresh the page`);
                }
            })
        },
    });

    const sensors = useSensors(
        useSensor(PointerSensor),
        useSensor(TouchSensor)
    );

    useEffect(() => {
        const sortedTickets = [...tickets].sort((a, b) => {
            return (a.order || 0) - (b.order || 0);
        });
        setItems(sortedTickets.map((ticket) => Number(ticket.id)));
    }, [tickets]);

    if (!event) {
        return null;
    }

    if (tickets.length === 0) {
        return <NoResultsSplash
            imageHref={'/blank-slate/tickets.svg'}
            heading={t`No tickets to show`}
            subHeading={(
                <>
                    <p>
                        {t`You'll need at least one ticket to get started. Free, paid or let the user decide what to pay.`}
                    </p>
                    <Button
                        size={'xs'}
                        leftSection={<IconPlus/>}
                        color={'green'}
                        onClick={() => openCreateModal()}>{t`Create a Ticket`}
                    </Button>
                </>
            )}
        />;
    }

    const handleDragStart = (event: any) => {
        if (!enableSorting) {
            showError(t`Please remove filters and set sorting to "Homepage order" to enable sorting`);
            event.cancel();
        }
    }

    return (
        <>
            <Group mb="md" position="apart">
                <Group>
                    <Checkbox
                        label={t`Select All`}
                        checked={selectedTickets.length === tickets.length}
                        indeterminate={selectedTickets.length > 0 && selectedTickets.length < tickets.length}
                        onChange={(event) => handleSelectAll(event.currentTarget.checked)}
                    />
                    {selectedTickets.length > 0 && (
                        <Group>
                            <NumberInput
                                value={bulkPrice}
                                onChange={(val) => setBulkPrice(val)}
                                placeholder={t`Enter price`}
                                min={0}
                                precision={2}
                                icon={<IconCurrencyDollar size={16} />}
                                disabled={updatePriceMutation.isLoading}
                            />
                            <Button
                                onClick={handleBulkPriceUpdate}
                                loading={updatePriceMutation.isLoading}
                                disabled={!bulkPrice || selectedTickets.length === 0}
                            >
                                {t`Update Prices`}
                            </Button>
                        </Group>
                    )}
                </Group>
            </Group>

            <DndContext
                onDragStart={handleDragStart}
                sensors={sensors}
                collisionDetection={closestCenter}
                onDragEnd={handleDragEnd}
            >
                <SortableContext items={items as UniqueIdentifier[]} strategy={verticalListSortingStrategy}>
                    <div className={classes.cards}>
                        {items.map((ticketId) => {
                            const ticket = tickets.find((t) => t.id === ticketId);
                            if (!ticket) return null;

                            return (
                                <div key={ticketId} className={classes.ticketRow}>
                                    <Checkbox
                                        checked={selectedTickets.includes(ticket.id)}
                                        onChange={(event) => handleSelectTicket(ticket.id, event.currentTarget.checked)}
                                    />
                                  
                                    <SortableTicket
                                        ticket={ticket}
                                        enableSorting={enableSorting}
                                        currencyCode={event.currency}
                                    />
                                </div>
                            );
                        })}
                    </div>
                </SortableContext>
            </DndContext>
        </>
    );
};
