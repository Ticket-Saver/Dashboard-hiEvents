import {useQuery} from "@tanstack/react-query";
import {GenericPaginatedResponse, IdParam, QueryFilters, Ticket} from "../types.ts";
import {axios} from "../lib/axios";

export const GET_TICKETS_QUERY_KEY = 'getTickets';

export const useGetTickets = (eventId?: string | number, filters?: Partial<QueryFilters>) => {
    return useQuery({
        queryKey: ['tickets', eventId, filters],
        queryFn: async () => {
            const params = {
                page: filters?.pageNumber || 1,
                per_page: 20,
                query: filters?.query || '',
                sort_by: filters?.sortBy || 'order',
                sort_direction: filters?.sortDirection || 'asc',
                position: filters?.position || '',
                seat_number: filters?.seat_number || '',
                section: filters?.section || '',
            }; 

            console.log('Request params:', params);
            console.log('Current filters:', filters);

            try {
                const response = await axios.get(`/events/${eventId}/tickets`, { params });
                console.log('API Response:', response.data);
                
                // Verificar si hay datos
                if (!response.data.data) {
                    console.warn('No data in response:', response.data);
                    return response.data;
                }

                // Verificar los tickets antes y después del filtrado
                console.log('Total tickets before filter:', response.data.data.length);
                
                // Mostrar los tickets que coinciden con el filtro
                if (filters?.position || filters?.section || filters?.seat_number) {
                    const filteredTickets = response.data.data.map((ticket: any) => ({
                        id: ticket.id,
                        title: ticket.title,
                        position: ticket.position,
                        section: ticket.section,
                        seat_number: ticket.seat_number
                    }));
                    console.log('Filtered tickets:', filteredTickets);
                    console.log('Total tickets after filter:', filteredTickets.length);
                }

                return response.data;
            } catch (error) {
                console.error('Error fetching tickets:', error);
                throw error;
            }
        },
        enabled: !!eventId,
        // Configuración para asegurar datos frescos
        refetchOnWindowFocus: true,
        refetchOnMount: true,
        staleTime: 0, // Considerar los datos obsoletos inmediatamente
        cacheTime: 0, // No mantener en caché
        retry: 1 // Intentar una vez más si falla
    });
};