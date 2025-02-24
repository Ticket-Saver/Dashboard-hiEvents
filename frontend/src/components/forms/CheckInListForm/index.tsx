import {MultiSelect, Textarea, TextInput, Select, Group, Button} from "@mantine/core";
import {t} from "@lingui/macro";
import {UseFormReturnType} from "@mantine/form";
import {CheckInListRequest, Ticket} from "../../../types.ts";
import {InputLabelWithHelp} from "../../common/InputLabelWithHelp";
import {InputGroup} from "../../common/InputGroup";
import {IconTicket} from "@tabler/icons-react";
import {useState, useMemo, useEffect} from "react";

interface CheckInListFormProps {
    form: UseFormReturnType<CheckInListRequest>;
    tickets: Ticket[],
}

export const CheckInListForm = ({form, tickets}: CheckInListFormProps) => {
    const [selectedPosition, setSelectedPosition] = useState<string | null>(null);
    const [selectedSection, setSelectedSection] = useState<string | null>(null);
    const [showAllTickets, setShowAllTickets] = useState(false);

    // Obtener lista única de posiciones
    const positions = useMemo(() => {
        const uniquePositions = new Set(tickets?.map(ticket => ticket.position || t`No Position`));
        console.log('Posiciones disponibles:', Array.from(uniquePositions));
        return Array.from(uniquePositions).map(position => ({
            value: position,
            label: position
        }));
    }, [tickets]);

    // Obtener secciones disponibles para la posición seleccionada
    const sections = useMemo(() => {
        if (!selectedPosition) return [];
        
        console.log('Filtrando secciones para posición:', selectedPosition);
        console.log('Tickets disponibles:', tickets);
        
        const filteredTickets = tickets?.filter(ticket => {
            const matches = (ticket.position || t`No Position`) === selectedPosition;
            console.log('Ticket:', ticket.title, 'Position:', ticket.position, 'Matches:', matches);
            return matches;
        }); 

        console.log('Tickets filtrados por posición:', filteredTickets);
        
        const uniqueSections = new Set( 
            filteredTickets?.map(ticket => ticket.section || t`No Section`)
        );
        
        console.log('Secciones únicas:', Array.from(uniqueSections));
        
        return Array.from(uniqueSections).map(section => ({
            value: section,
            label: section
        }));
    }, [tickets, selectedPosition]);

    // Modificar filteredTickets para manejar showAllTickets
    const filteredTickets = useMemo(() => {
        if (showAllTickets) {
            return tickets?.map(ticket => ({
                value: String(ticket.id),
                label: `${ticket.title} - ${ticket.position || t`No Position`} - ${ticket.section || t`No Section`} (${ticket.seat_number || t`No Seat`})`
            })) || [];
        }

        if (!selectedPosition || !selectedSection) return [];
        
        return tickets?.filter(ticket => 
            (ticket.position || t`No Position`) === selectedPosition &&
            (ticket.section || t`No Section`) === selectedSection
        ).map(ticket => ({
            value: String(ticket.id),
            label: `${ticket.title} (${ticket.seat_number || t`No Seat`})`
        })) || [];
    }, [tickets, selectedPosition, selectedSection, showAllTickets]);

    // Limpiar filtros cuando se activa showAllTickets
    useEffect(() => {
        if (showAllTickets) {
            setSelectedPosition(null);
            setSelectedSection(null);
        }
    }, [showAllTickets]);

    console.log('Tickets en CheckInListForm:', tickets?.map(ticket => ({
        id: ticket.id,
        title: ticket.title,
        position: ticket.position,
        section: ticket.section,
        seat_number: ticket.seat_number
    })));

    // Función para seleccionar todos los tickets de una posición
    const handleSelectAllFromPosition = () => {
        const ticketsToAdd = tickets
            ?.filter(ticket => 
                (ticket.position || t`No Position`) === selectedPosition
            )
            .map(ticket => String(ticket.id)) || [];

        const currentSelected = form.values.ticket_ids || [];
        const newSelection = [...new Set([...currentSelected, ...ticketsToAdd])];
        form.setFieldValue('ticket_ids', newSelection);
    };

    // Función para seleccionar todos los tickets filtrados
    const handleSelectAllFiltered = () => {
        const ticketsToAdd = tickets
            ?.filter(ticket => 
                (ticket.position || t`No Position`) === selectedPosition &&
                (ticket.section || t`No Section`) === selectedSection
            )
            .map(ticket => String(ticket.id)) || [];

        // Obtener los tickets actuales seleccionados
        const currentSelected = form.values.ticket_ids || [];
        
        // Combinar los tickets actuales con los nuevos, evitando duplicados
        const newSelection = [...new Set([...currentSelected, ...ticketsToAdd])];
        
        // Actualizar el formulario
        form.setFieldValue('ticket_ids', newSelection);
    };

    return (
        <>
            <TextInput
                {...form.getInputProps('name')}
                required
                label={t`Name`}
                placeholder={t`VIP check-in list`}
            />

            <Group position="apart" mb="sm">
                <Button 
                    variant={showAllTickets ? "filled" : "light"}
                    onClick={() => setShowAllTickets(!showAllTickets)}
                    leftSection={<IconTicket size="1rem"/>}
                >
                    {showAllTickets ? t`Using filtered selection` : t`Show all tickets`}
                </Button>
            </Group>

            {!showAllTickets && (
                <>
                    {/* Selector de Posición */}
                    <Select
                        label={t`Select position`}
                        placeholder={t`Choose a position first`}
                        data={positions}
                        value={selectedPosition}
                        onChange={setSelectedPosition}
                        clearable
                        searchable
                    />

                    {/* Selector de Sección */}
                    {selectedPosition && (
                        <Select
                            label={t`Select section for ${selectedPosition}`}
                            placeholder={t`Choose a section`}
                            data={sections}
                            value={selectedSection}
                            onChange={setSelectedSection}
                            clearable
                            searchable
                        />
                    )}
                </>
            )}

            {!showAllTickets && selectedPosition && (
                <Group position="apart" mb="sm">
                    <Button
                        onClick={handleSelectAllFromPosition}
                        variant="light"
                        color="blue"
                    >
                        {t`Add all from position ${selectedPosition}`}
                    </Button>
                    
                    {selectedSection && (
                        <Button
                            onClick={handleSelectAllFiltered}
                            variant="light"
                            color="blue"
                        >
                            {t`Add all from section ${selectedSection}`}
                        </Button>
                    )}
                </Group>
            )}

            {/* MultiSelect de Tickets */}
            {(showAllTickets || (selectedPosition && selectedSection)) && (
                <>
                    <Group position="apart" mb="sm">
                        <MultiSelect
                            label={showAllTickets ? 
                                t`Select tickets` : 
                                t`Select tickets for ${selectedPosition} - ${selectedSection}`
                            }
                            multiple
                            placeholder={t`Select tickets`}
                            data={filteredTickets}
                            required
                            leftSection={<IconTicket size="1rem"/>}
                            searchable
                            {...form.getInputProps('ticket_ids')}
                            style={{ flex: 1 }}
                        />
                    </Group>
                </>
            )}

            <Textarea
                {...form.getInputProps('description')}
                label={<InputLabelWithHelp
                    label={t`Description for check-in staff`}
                    helpText={t`This description will be shown to the check-in staff`}
                />}
                placeholder={t`Add a description for this check-in list`}
            />

            <InputGroup>
                <TextInput
                    {...form.getInputProps('activates_at')}
                    type="datetime-local"
                    label={<InputLabelWithHelp
                        label={t`Activation date`}
                        helpText={t`No attendees will be able to check in before this date using this list`}
                    />}
                    placeholder={t`What date should this check-in list become active?`}
                />
                <TextInput
                    {...form.getInputProps('expires_at')}
                    type="datetime-local"
                    label={<InputLabelWithHelp
                        label={t`Expiration date`}
                        helpText={t`This list will no longer be available for check-ins after this date`}
                    />}
                    placeholder={t`When should this check-in list expire?`}
                />
            </InputGroup>
        </>
    );
}
